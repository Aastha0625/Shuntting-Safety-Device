const pool = require('./config/db');

async function migrate() {
  try {
    console.log('Adding profile_pic_url column to users table...');
    await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_pic_url VARCHAR(500);`);
    console.log('Migration successful!');
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  }
}

migrate();
