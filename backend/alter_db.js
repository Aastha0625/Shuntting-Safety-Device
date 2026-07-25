const db = require('./config/db');

async function alterDB() {
  try {
    console.log('Connecting to AWS RDS...');
    await db.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255) UNIQUE;');
    console.log('Successfully added email column to the users table!');
  } catch (error) {
    console.error('Error altering table:', error);
  } finally {
    process.exit();
  }
}

alterDB();
