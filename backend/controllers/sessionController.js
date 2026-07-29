const db = require('../config/db');

// @desc    Get all sessions (active and history)
// @route   GET /api/sessions
// @access  Private
const getSessions = async (req, res) => {
  try {
    const { status } = req.query; // 'live' or 'history'
    let queryStr = `
        SELECT 
            da.id, 
            d.device_code as ld_device, 
            'DE-MOCK' as de_device, 
            da.issued_at, 
            da.returned_at,
            u.full_name as holder_name,
            COALESCE(yl.line_name, 'Unknown Line') as line_name,
            COALESCE(y.yard_name, 'Unknown Yard') as yard_name,
            da.remarks
        FROM device_assignments da
        JOIN devices d ON da.device_id = d.id
        JOIN users u ON da.employee_id = u.id
        LEFT JOIN yard_lines yl ON d.assigned_line_id = yl.id
        LEFT JOIN yards y ON yl.yard_id = y.id
    `;

    if (status === 'live') {
        queryStr += ' WHERE da.returned_at IS NULL ';
    } else if (status === 'history') {
        queryStr += ' WHERE da.returned_at IS NOT NULL ';
    }

    queryStr += ' ORDER BY da.issued_at DESC ';

    const sessions = await db.query(queryStr);
    
    // Map data for frontend
    const mappedSessions = sessions.rows.map(s => {
        const isLive = s.returned_at === null;
        
        // --- MOCK IoT DATA INJECTION ---
        let distanceVal = 'N/A';
        let isClosing = false;
        
        if (isLive) {
            const dummyDistance = (Math.random() * 50 + 10).toFixed(1); // 10.0 to 60.0
            distanceVal = `${dummyDistance}m`;
            isClosing = dummyDistance < 20;
        } else {
            // For history, show final dummy stopping distance
            distanceVal = `${(Math.random() * 15 + 5).toFixed(1)}m (Final)`;
        }

        return {
            id: s.id,
            yard: s.yard_name,
            line: s.line_name,
            ldDevice: s.ld_device,
            deDevice: s.de_device,
            distance: distanceVal, 
            holder: s.holder_name,
            startTime: s.issued_at,
            endTime: s.returned_at,
            duration: s.returned_at ? 'Completed' : 'Active',
            status: s.returned_at ? 'Finished' : 'In Progress',
            isClosing: isClosing
        };
    });

    res.json(mappedSessions);
  } catch (error) {
    console.error('Error in getSessions:', error);
    res.status(500).json({ message: 'Server error fetching sessions' });
  }
};

module.exports = {
  getSessions
};
