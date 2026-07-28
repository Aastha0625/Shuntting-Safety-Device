-- Migration: Add role-based access control and yards support
-- Run this script in your AWS RDS PostgreSQL database

-- 1. Add 'role' column to users table
-- Maps designations to role codes: super_admin, yard_admin, maintenance_user, viewer
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(30) NOT NULL DEFAULT 'viewer';

-- 2. Add 'is_active' column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

-- 3. Update existing users: derive role from designation
UPDATE users SET role = 'super_admin' WHERE designation = 'Super Administrator' AND role = 'viewer';
UPDATE users SET role = 'yard_admin' WHERE designation = 'Yard Administrator' AND role = 'viewer';
UPDATE users SET role = 'maintenance_user' WHERE designation = 'Maintenance User' AND role = 'viewer';
UPDATE users SET role = 'viewer' WHERE designation = 'Viewer / Control Room User';

-- 4. Create yards table (per PRD Section 11.1)
CREATE TABLE IF NOT EXISTS yards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    yard_code VARCHAR(20) UNIQUE NOT NULL,
    yard_name VARCHAR(100) NOT NULL,
    station VARCHAR(100) NOT NULL,
    division VARCHAR(100) NOT NULL,
    zone VARCHAR(100) NOT NULL,
    yard_type VARCHAR(30) NOT NULL DEFAULT 'Mixed',  -- Coaching, Freight, Depot, Mixed, Other
    status VARCHAR(20) NOT NULL DEFAULT 'Active',     -- Active or Inactive
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Create user_yard_assignments table (links Yard Admins to specific yards)
CREATE TABLE IF NOT EXISTS user_yard_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    yard_id UUID NOT NULL REFERENCES yards(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(id),
    UNIQUE(user_id, yard_id)  -- A user cannot be assigned to the same yard twice
);

-- 6. Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_yard_assignments_user_id ON user_yard_assignments(user_id);
CREATE INDEX IF NOT EXISTS idx_user_yard_assignments_yard_id ON user_yard_assignments(yard_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
