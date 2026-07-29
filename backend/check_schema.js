const db = require('./config/db');

async function listTables() {
  try {
    const res = await db.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    console.table(res.rows);
    
    // For yards
    const yards = await db.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'yards'`);
    console.log('Yards table columns:');
    console.table(yards.rows);

    // For devices
    const devices = await db.query(`SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'devices'`);
    console.log('Devices table columns:');
    console.table(devices.rows);

    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

listTables();
