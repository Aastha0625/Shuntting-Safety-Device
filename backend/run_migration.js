const db = require('./config/db');

async function runMigration() {
  try {
    console.log('Connecting to safeshunt_db...');

    // 1. Create pgcrypto extension
    console.log('1. Creating pgcrypto extension...');
    await db.query('CREATE EXTENSION IF NOT EXISTS "pgcrypto"');
    console.log('   OK');

    // 2. Create users table (from original schema.sql)
    console.log('2. Creating users table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        full_name VARCHAR(100) NOT NULL,
        employee_id VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(255) UNIQUE,
        designation VARCHAR(50) NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('   OK');

    // 3. Add role column
    console.log('3. Adding role column to users...');
    await db.query("ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(30) NOT NULL DEFAULT 'viewer'");
    console.log('   OK');

    // 4. Add is_active column
    console.log('4. Adding is_active column to users...');
    await db.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true');
    console.log('   OK');

    // 5. Update existing users roles from designation
    console.log('5. Updating existing user roles from designation...');
    await db.query("UPDATE users SET role = 'super_admin' WHERE designation = 'Super Administrator' AND role = 'viewer'");
    await db.query("UPDATE users SET role = 'yard_admin' WHERE designation = 'Yard Administrator' AND role = 'viewer'");
    await db.query("UPDATE users SET role = 'maintenance_user' WHERE designation = 'Maintenance User' AND role = 'viewer'");
    console.log('   OK');

    // 6. Create yards table
    console.log('6. Creating yards table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS yards (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        yard_code VARCHAR(20) UNIQUE NOT NULL,
        yard_name VARCHAR(100) NOT NULL,
        station VARCHAR(100) NOT NULL,
        division VARCHAR(100) NOT NULL,
        zone VARCHAR(100) NOT NULL,
        yard_type VARCHAR(30) NOT NULL DEFAULT 'Mixed',
        status VARCHAR(20) NOT NULL DEFAULT 'Active',
        remarks TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('   OK');

    // 7. Create user_yard_assignments table
    console.log('7. Creating user_yard_assignments table...');
    await db.query(`
      CREATE TABLE IF NOT EXISTS user_yard_assignments (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        yard_id UUID NOT NULL REFERENCES yards(id) ON DELETE CASCADE,
        assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        assigned_by UUID REFERENCES users(id),
        UNIQUE(user_id, yard_id)
      )
    `);
    console.log('   OK');

    // 8. Create indexes
    console.log('8. Creating indexes...');
    await db.query('CREATE INDEX IF NOT EXISTS idx_uya_user ON user_yard_assignments(user_id)');
    await db.query('CREATE INDEX IF NOT EXISTS idx_uya_yard ON user_yard_assignments(yard_id)');
    await db.query('CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)');
    console.log('   OK');

    console.log('\n=== ALL MIGRATIONS COMPLETED SUCCESSFULLY! ===');
    console.log('Tables: users, yards, user_yard_assignments');
    console.log('Columns added: users.role, users.is_active');

  } catch (error) {
    console.error('Migration error:', error.message);
  } finally {
    process.exit();
  }
}

runMigration();
