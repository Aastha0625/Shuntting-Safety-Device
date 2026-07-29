const db = require('./config/db');

async function addTelemetryTable() {
  try {
    console.log('Creating telemetry_data table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS telemetry_data (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
          payload JSONB NOT NULL,
          recorded_at TIMESTAMP NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      
      -- Create an index on device_id and recorded_at for faster queries
      CREATE INDEX IF NOT EXISTS idx_telemetry_device_time ON telemetry_data(device_id, recorded_at DESC);
    `);
    console.log('Successfully created telemetry_data table.');
    process.exit(0);
  } catch (err) {
    console.error('Error creating table:', err);
    process.exit(1);
  }
}

addTelemetryTable();
