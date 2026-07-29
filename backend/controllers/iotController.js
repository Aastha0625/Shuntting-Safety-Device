const db = require('../config/db');

// @desc    Ingest telemetry data from devices
// @route   POST /api/iot/telemetry
// @access  Public (or secured via API Key in production)
const ingestTelemetry = async (req, res) => {
  try {
    const { device_id, distance, battery, speed, timestamp } = req.body;

    if (!device_id) {
      return res.status(400).json({ message: 'device_id is required' });
    }

    // Prepare JSON payload
    const payload = {
        distance,
        battery,
        speed
    };
    const recordedAt = timestamp ? new Date(timestamp) : new Date();

    // 1. Insert into telemetry_data
    await db.query(
      'INSERT INTO telemetry_data (device_id, payload, recorded_at) VALUES ($1, $2, $3)',
      [device_id, JSON.stringify(payload), recordedAt]
    );

    // 2. Update device last_heartbeat and battery_level
    await db.query(
      'UPDATE devices SET last_heartbeat = CURRENT_TIMESTAMP, battery_level = $1 WHERE id = $2',
      [battery ? battery.toString() + '%' : null, device_id]
    );

    // 3. Process Hazard Detection
    // For example, if distance is less than 5 meters, generate a hazard alert
    if (distance !== undefined && distance < 5.0) {
        await db.query(
            'INSERT INTO alerts_logs (alert_type, message, severity) VALUES ($1, $2, $3)',
            ['HAZARD_PROXIMITY', `Device ${device_id} reported critical distance: ${distance}m`, 'CRITICAL']
        );
    }

    res.status(200).json({ success: true, message: 'Telemetry processed' });
  } catch (error) {
    console.error('Error in ingestTelemetry:', error);
    res.status(500).json({ success: false, message: 'Server error processing telemetry' });
  }
};

module.exports = {
  ingestTelemetry
};
