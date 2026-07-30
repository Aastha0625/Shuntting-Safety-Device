require('dotenv').config();
const { Pool } = require('pg');
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  ssl: { rejectUnauthorized: false }
});
async function run() {
  try {
    const res = await pool.query("SELECT id, full_name, employee_id, email, designation, role, is_active, created_at, profile_pic_url FROM users LIMIT 1");
    console.log('Users query OK');
  } catch (e) {
    console.error('Users Fail:', e.message);
  }
  
  try {
    const res = await pool.query("SELECT y.id, y.yard_name, y.location, y.status FROM user_yard_assignments uya JOIN yards y ON uya.yard_id = y.id LIMIT 1");
    console.log('Assignments OK');
  } catch (e) {
    console.error('Assignments Fail:', e.message);
  }

  try {
    const sessionsRes = await pool.query("SELECT COUNT(*) FROM device_assignments WHERE DATE(issued_at) = CURRENT_DATE");
    console.log('Dashboard 1 OK');
  } catch (e) { console.error('Dashboard 1 Fail:', e.message); }

  try {
    const liveSessionsRes = await pool.query("SELECT da.id, d.device_code as ld_device, 'DE-MOCK' as de_device, da.issued_at, COALESCE(yl.line_name, 'Unknown Line') as line_name, COALESCE(y.yard_name, 'Unknown Yard') as yard_name FROM device_assignments da JOIN devices d ON da.device_id = d.id LEFT JOIN yard_lines yl ON d.assigned_line_id = yl.id LEFT JOIN yards y ON yl.yard_id = y.id WHERE da.returned_at IS NULL ORDER BY da.issued_at DESC LIMIT 5");
    console.log('Dashboard 2 OK');
  } catch(e) { console.error('Dashboard 2 Fail:', e.message); }

  try {
    const alertsRes = await pool.query("SELECT COUNT(*) FROM alerts_logs WHERE severity = 'CRITICAL' AND timestamp >= NOW() - INTERVAL '24 HOURS'");
    console.log('Dashboard 3 OK');
  } catch (e) { console.error('Dashboard 3 Fail:', e.message); }

  pool.end();
}
run();
