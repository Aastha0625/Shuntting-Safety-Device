const db = require('../config/db');

// @desc    Create a new yard
// @route   POST /api/yards
// @access  Super Admin
const createYard = async (req, res) => {
  try {
    const { yard_name, location } = req.body;
    if (!yard_name) {
      return res.status(400).json({ message: 'Yard name is required' });
    }

    const newYard = await db.query(
      'INSERT INTO yards (yard_name, location, status) VALUES ($1, $2, $3) RETURNING *',
      [yard_name, location, 'Active']
    );

    res.status(201).json(newYard.rows[0]);
  } catch (error) {
    console.error('Error in createYard:', error);
    res.status(500).json({ message: 'Server error creating yard' });
  }
};

// @desc    Get all yards
// @route   GET /api/yards
// @access  Super Admin / Yard Admin (filtered)
const getYards = async (req, res) => {
  try {
    const yards = await db.query('SELECT * FROM yards ORDER BY created_at DESC');
    const lines = await db.query(`
        SELECT yl.*, d.device_code as assigned_de 
        FROM yard_lines yl 
        LEFT JOIN devices d ON d.assigned_line_id = yl.id
        ORDER BY yl.created_at DESC
    `);
    
    // Group lines by yard
    const mappedYards = yards.rows.map(y => {
        return {
            ...y,
            lines: lines.rows.filter(l => l.yard_id === y.id)
        };
    });

    res.json(mappedYards);
  } catch (error) {
    console.error('Error in getYards:', error);
    res.status(500).json({ message: 'Server error fetching yards' });
  }
};

// @desc    Create a new line for a yard
// @route   POST /api/yards/:yardId/lines
// @access  Super Admin
const addYardLine = async (req, res) => {
  try {
    const { yardId } = req.params;
    const { line_code, line_name, line_type } = req.body;

    if (!line_code || !line_name || !line_type) {
      return res.status(400).json({ message: 'Line code, name, and type are required' });
    }

    const newLine = await db.query(
      'INSERT INTO yard_lines (yard_id, line_code, line_name, line_type, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [yardId, line_code, line_name, line_type, 'Active']
    );

    res.status(201).json(newLine.rows[0]);
  } catch (error) {
    console.error('Error in addYardLine:', error);
    res.status(500).json({ message: 'Server error creating yard line' });
  }
};

// @desc    Get lines for a specific yard
// @route   GET /api/yards/:yardId/lines
// @access  Private
const getYardLines = async (req, res) => {
  try {
    const { yardId } = req.params;
    const lines = await db.query('SELECT * FROM yard_lines WHERE yard_id = $1 ORDER BY created_at DESC', [yardId]);
    res.json(lines.rows);
  } catch (error) {
    console.error('Error in getYardLines:', error);
    res.status(500).json({ message: 'Server error fetching yard lines' });
  }
};

module.exports = {
  createYard,
  getYards,
  addYardLine,
  getYardLines
};
