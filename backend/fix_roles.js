const db = require('./config/db');

async function fix() {
  try {
    await db.query(`UPDATE users SET role = 'super_admin' WHERE designation = 'Super Administrator'`);
    await db.query(`UPDATE users SET role = 'yard_admin' WHERE designation = 'Yard Administrator'`);
    await db.query(`UPDATE users SET role = 'viewer' WHERE designation = 'Viewer / Control Room User'`);
    console.log('Roles fixed successfully!');
    
    const res = await db.query('SELECT employee_id, designation, role FROM users');
    console.table(res.rows);
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

fix();
