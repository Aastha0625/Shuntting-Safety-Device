-- Run this script in your AWS RDS PostgreSQL database to initialize the users table

CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- required for gen_random_uuid() in some older postgres versions, optional in newer

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    designation VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Example insert (Optional, just to verify it works)
-- INSERT INTO users (full_name, employee_id, designation, password_hash) 
-- VALUES ('Admin User', 'RS-00001', 'Admin', 'hashed_password_here');
