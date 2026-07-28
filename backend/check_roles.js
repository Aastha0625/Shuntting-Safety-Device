const db = require('./config/db');

async function check() {
  try {
    const res = await db.query('SELECT id, employee_id, designation, role FROM users');
    console.table(res.rows);
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

check();
