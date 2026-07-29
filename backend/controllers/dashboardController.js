const db = require('../config/db');

// @desc    Get dashboard summary statistics
// @route   GET /api/dashboard/summary
// @access  Private
const getDashboardSummary = async (req, res) => {
  try {
    const userId = req.user.id;
    const role = req.user.role;

    // 1. Base query conditionals based on role
    // For Yard Admin, we ideally filter devices/sessions by their assigned yards.
    // For MVP, we'll demonstrate the aggregation logic globally, 
    // and just simulate the Yard Admin filter if they have assigned yards.
    
    // Total Active Devices
    const activeRes = await db.query("SELECT COUNT(*) FROM devices WHERE network_status = 'Online'");
    const activeDevices = parseInt(activeRes.rows[0].count, 10);

    // Total Offline Devices
    const offlineRes = await db.query("SELECT COUNT(*) FROM devices WHERE network_status != 'Online'");
    const offlineDevices = parseInt(offlineRes.rows[0].count, 10);

    // Total Sessions Today (simplistic check)
    const sessionsRes = await db.query("SELECT COUNT(*) FROM device_assignments WHERE DATE(issued_at) = CURRENT_DATE");
    const totalSessionsToday = parseInt(sessionsRes.rows[0].count, 10);

    // System Status
    // Determine overall health based on critical alerts in the last 24 hours
    const recentAlertsRes = await db.query(
        "SELECT COUNT(*) FROM alerts_logs WHERE severity = 'CRITICAL' AND timestamp >= NOW() - INTERVAL '24 HOURS'"
    );
    const criticalCount = parseInt(recentAlertsRes.rows[0].count, 10);
    const systemStatus = criticalCount > 0 ? (criticalCount > 5 ? 'Warning' : '98%') : '100%';

    // Latest Critical Alert
    const alertRes = await db.query(
        "SELECT * FROM alerts_logs WHERE severity = 'CRITICAL' ORDER BY timestamp DESC LIMIT 1"
    );
    let criticalAlert = alertRes.rows.length > 0 ? alertRes.rows[0] : null;

    // --- MOCK IoT DATA INJECTION ---
    // If no real alerts from IoT, randomly inject a dummy alert for presentation purposes
    if (!criticalAlert && Math.random() > 0.5) {
        criticalAlert = {
            alert_type: 'HAZARD_PROXIMITY (MOCK)',
            message: 'Simulated IoT: Distance critically low at 12.5m',
            severity: 'CRITICAL',
            timestamp: new Date()
        };
    }

    // Live Sessions
    // Fetch currently active device assignments with mock distance formatting
    const liveSessionsRes = await db.query(`
        SELECT 
            da.id, 
            d.device_code as ld_device, 
            'DE-MOCK' as de_device, 
            da.issued_at, 
            COALESCE(yl.line_name, 'Unknown Line') as line_name,
            COALESCE(y.yard_name, 'Unknown Yard') as yard_name
        FROM device_assignments da
        JOIN devices d ON da.device_id = d.id
        LEFT JOIN yard_lines yl ON d.assigned_line_id = yl.id
        LEFT JOIN yards y ON yl.yard_id = y.id
        WHERE da.returned_at IS NULL
        ORDER BY da.issued_at DESC
        LIMIT 5
    `);
    
    // Map live sessions to the frontend UI format
    const liveSessions = liveSessionsRes.rows.map(session => {
        // --- MOCK IoT DATA INJECTION ---
        const dummyDistance = (Math.random() * 50 + 10).toFixed(1); // 10.0 to 60.0 meters
        const isClosing = dummyDistance < 20; // Mark red if under 20m
        
        return {
            id: session.id,
            yard: session.yard_name,
            line: session.line_name,
            ldDevice: session.ld_device,
            deDevice: session.de_device,
            distance: `${dummyDistance}m`, 
            isClosing: isClosing
        };
    });

    // If there are no live sessions in DB, return empty list (no mock data)
    res.json({
      health: {
        activeDevices,
        offlineDevices,
        totalSessionsToday,
        systemStatus
      },
      criticalAlert,
      liveSessions
    });
  } catch (error) {
    console.error('Error fetching dashboard summary:', error);
    res.status(500).json({ message: 'Server error fetching dashboard data' });
  }
};

module.exports = {
  getDashboardSummary
};
