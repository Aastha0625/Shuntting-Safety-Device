const db = require('../config/db');

// @desc    Register a new device
// @route   POST /api/devices
// @access  Super Admin / Yard Admin
const registerDevice = async (req, res) => {
  try {
    const { device_code, device_type } = req.body;
    if (!device_code || !device_type) {
      return res.status(400).json({ message: 'Device code and type are required' });
    }

    const newDevice = await db.query(
      'INSERT INTO devices (device_code, device_type) VALUES ($1, $2) RETURNING *',
      [device_code, device_type]
    );

    res.status(201).json(newDevice.rows[0]);
  } catch (error) {
    console.error('Error in registerDevice:', error);
    res.status(500).json({ message: 'Server error registering device' });
  }
};

// @desc    Get all devices
// @route   GET /api/devices
// @access  Private
const getDevices = async (req, res) => {
  try {
    const devices = await db.query('SELECT * FROM devices ORDER BY created_at DESC');
    res.json(devices.rows);
  } catch (error) {
    console.error('Error in getDevices:', error);
    res.status(500).json({ message: 'Server error fetching devices' });
  }
};

// @desc    Issue a device to an employee (and assign to line)
// @route   POST /api/devices/issue
// @access  Yard Admin
const issueDevice = async (req, res) => {
  try {
    const { device_id, employee_id, condition_at_issue, assigned_line_id } = req.body;

    if (!device_id || !employee_id) {
      return res.status(400).json({ message: 'device_id and employee_id are required' });
    }

    // Insert assignment
    const assignment = await db.query(
      'INSERT INTO device_assignments (device_id, employee_id, condition_at_issue) VALUES ($1, $2, $3) RETURNING *',
      [device_id, employee_id, condition_at_issue]
    );

    // Update device status
    if (assigned_line_id) {
        await db.query(
            'UPDATE devices SET assigned_line_id = $1 WHERE id = $2',
            [assigned_line_id, device_id]
        );
    }

    res.status(201).json(assignment.rows[0]);
  } catch (error) {
    console.error('Error in issueDevice:', error);
    res.status(500).json({ message: 'Server error issuing device' });
  }
};

// @desc    Return a device
// @route   POST /api/devices/return
// @access  Yard Admin
const returnDevice = async (req, res) => {
  try {
    const { assignment_id, condition_at_return, fault_reported, remarks } = req.body;

    if (!assignment_id) {
      return res.status(400).json({ message: 'assignment_id is required' });
    }

    const returned = await db.query(
      `UPDATE device_assignments 
       SET returned_at = CURRENT_TIMESTAMP, condition_at_return = $1, fault_reported = $2, remarks = $3 
       WHERE id = $4 RETURNING *`,
      [condition_at_return, fault_reported, remarks, assignment_id]
    );

    if (returned.rows.length > 0) {
        // Clear line assignment
        await db.query(
            'UPDATE devices SET assigned_line_id = NULL WHERE id = $1',
            [returned.rows[0].device_id]
        );
    }

    res.json(returned.rows[0]);
  } catch (error) {
    console.error('Error in returnDevice:', error);
    res.status(500).json({ message: 'Server error returning device' });
  }
};

// @desc    Assign device to a line
// @route   PUT /api/devices/:id/assign-line
// @access  Yard Admin
const assignLine = async (req, res) => {
  try {
    const { id } = req.params;
    const { assigned_line_id } = req.body;

    const result = await db.query(
      'UPDATE devices SET assigned_line_id = $1 WHERE id = $2 RETURNING *',
      [assigned_line_id || null, id]
    );

    if (result.rows.length === 0) {
        return res.status(404).json({ message: 'Device not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error in assignLine:', error);
    res.status(500).json({ message: 'Server error assigning line' });
  }
};

module.exports = {
  registerDevice,
  getDevices,
  issueDevice,
  returnDevice,
  assignLine
};
