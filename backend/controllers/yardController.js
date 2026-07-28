const db = require('../config/db');

// GET /api/yards - List yards (filtered by role)
// Super Admin: sees all yards
// Yard Admin: sees only assigned yards
// Others: sees all active yards (read-only)
exports.listYards = async (req, res) => {
  try {
    let result;
    const { role, id: userId, assignedYardIds } = req.user;

    if (role === 'yard_admin' && assignedYardIds && assignedYardIds.length > 0) {
      // Yard Admin: only assigned yards
      const placeholders = assignedYardIds.map((_, i) => `$${i + 1}`).join(', ');
      result = await db.query(
        `SELECT id, yard_code, yard_name, station, division, zone, yard_type, status, remarks, created_at, updated_at
         FROM yards WHERE id IN (${placeholders}) ORDER BY yard_name`,
        assignedYardIds
      );
    } else if (role === 'yard_admin') {
      // Yard Admin with no assignments
      return res.status(200).json({ 
        yards: [],
        message: 'No yards assigned. Contact Super Administrator.' 
      });
    } else {
      // Super Admin, Maintenance, Viewer: all yards
      result = await db.query(
        `SELECT id, yard_code, yard_name, station, division, zone, yard_type, status, remarks, created_at, updated_at
         FROM yards ORDER BY yard_name`
      );
    }

    res.status(200).json({ yards: result.rows });
  } catch (error) {
    console.error('Error in listYards:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// GET /api/yards/:id - Get single yard details
exports.getYard = async (req, res) => {
  try {
    const { id } = req.params;
    const { role, assignedYardIds } = req.user;

    // Yard Admin can only view assigned yards
    if (role === 'yard_admin' && (!assignedYardIds || !assignedYardIds.includes(id))) {
      return res.status(403).json({ message: 'Access denied. This yard is not assigned to you.' });
    }

    const result = await db.query(
      `SELECT id, yard_code, yard_name, station, division, zone, yard_type, status, remarks, created_at, updated_at
       FROM yards WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Yard not found.' });
    }

    res.status(200).json({ yard: result.rows[0] });
  } catch (error) {
    console.error('Error in getYard:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// POST /api/yards - Create a new yard (Super Admin only)
exports.createYard = async (req, res) => {
  try {
    const { yardCode, yardName, station, division, zone, yardType, remarks } = req.body;

    if (!yardCode || !yardName || !station || !division || !zone) {
      return res.status(400).json({ message: 'Yard code, name, station, division and zone are required.' });
    }

    // Check for duplicate yard code
    const exists = await db.query('SELECT id FROM yards WHERE yard_code = $1', [yardCode]);
    if (exists.rows.length > 0) {
      return res.status(400).json({ message: 'A yard with this code already exists.' });
    }

    const result = await db.query(
      `INSERT INTO yards (yard_code, yard_name, station, division, zone, yard_type, remarks)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [yardCode, yardName, station, division, zone, yardType || 'Mixed', remarks || null]
    );

    res.status(201).json({ message: 'Yard created successfully.', yard: result.rows[0] });
  } catch (error) {
    console.error('Error in createYard:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// PUT /api/yards/:id - Update a yard (Super Admin only)
exports.updateYard = async (req, res) => {
  try {
    const { id } = req.params;
    const { yardCode, yardName, station, division, zone, yardType, status, remarks } = req.body;

    const result = await db.query(
      `UPDATE yards SET 
        yard_code = COALESCE($1, yard_code),
        yard_name = COALESCE($2, yard_name),
        station = COALESCE($3, station),
        division = COALESCE($4, division),
        zone = COALESCE($5, zone),
        yard_type = COALESCE($6, yard_type),
        status = COALESCE($7, status),
        remarks = COALESCE($8, remarks),
        updated_at = CURRENT_TIMESTAMP
       WHERE id = $9
       RETURNING *`,
      [yardCode, yardName, station, division, zone, yardType, status, remarks, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Yard not found.' });
    }

    res.status(200).json({ message: 'Yard updated successfully.', yard: result.rows[0] });
  } catch (error) {
    console.error('Error in updateYard:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// POST /api/yards/assign - Assign a yard to a user (Super Admin only)
exports.assignYardToUser = async (req, res) => {
  try {
    const { userId, yardId } = req.body;

    if (!userId || !yardId) {
      return res.status(400).json({ message: 'userId and yardId are required.' });
    }

    // Verify user exists and is a yard_admin
    const userResult = await db.query('SELECT id, role, full_name FROM users WHERE id = $1', [userId]);
    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }
    if (userResult.rows[0].role !== 'yard_admin') {
      return res.status(400).json({ message: 'Yards can only be assigned to Yard Administrator users.' });
    }

    // Verify yard exists
    const yardResult = await db.query('SELECT id, yard_name FROM yards WHERE id = $1', [yardId]);
    if (yardResult.rows.length === 0) {
      return res.status(404).json({ message: 'Yard not found.' });
    }

    // Check if already assigned
    const existing = await db.query(
      'SELECT id FROM user_yard_assignments WHERE user_id = $1 AND yard_id = $2',
      [userId, yardId]
    );
    if (existing.rows.length > 0) {
      return res.status(400).json({ message: 'This yard is already assigned to this user.' });
    }

    // Create assignment
    await db.query(
      'INSERT INTO user_yard_assignments (user_id, yard_id, assigned_by) VALUES ($1, $2, $3)',
      [userId, yardId, req.user.id]
    );

    res.status(201).json({
      message: `Yard "${yardResult.rows[0].yard_name}" assigned to ${userResult.rows[0].full_name}.`,
    });
  } catch (error) {
    console.error('Error in assignYardToUser:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// DELETE /api/yards/assign - Remove yard assignment from a user (Super Admin only)
exports.removeYardAssignment = async (req, res) => {
  try {
    const { userId, yardId } = req.body;

    if (!userId || !yardId) {
      return res.status(400).json({ message: 'userId and yardId are required.' });
    }

    const result = await db.query(
      'DELETE FROM user_yard_assignments WHERE user_id = $1 AND yard_id = $2 RETURNING id',
      [userId, yardId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Assignment not found.' });
    }

    res.status(200).json({ message: 'Yard assignment removed.' });
  } catch (error) {
    console.error('Error in removeYardAssignment:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
