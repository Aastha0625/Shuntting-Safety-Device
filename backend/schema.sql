-- Run this script in your AWS RDS PostgreSQL database to initialize the tables

CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- required for gen_random_uuid()

-- 1. Users Table (Already exists, included for completeness)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    designation VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Yards Table
CREATE TABLE IF NOT EXISTS yards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    yard_name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Yard Lines Table
CREATE TABLE IF NOT EXISTS yard_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    yard_id UUID NOT NULL REFERENCES yards(id) ON DELETE CASCADE,
    line_code VARCHAR(50) NOT NULL,
    line_name VARCHAR(100) NOT NULL,
    line_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Devices Table
CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_code VARCHAR(50) UNIQUE NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    battery_level VARCHAR(20),
    condition_status VARCHAR(50) DEFAULT 'Good',
    sim_status VARCHAR(50) DEFAULT 'Active',
    network_status VARCHAR(50) DEFAULT 'Offline',
    last_heartbeat TIMESTAMP,
    assigned_line_id UUID REFERENCES yard_lines(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Device Assignments Table (Issue/Return Log)
CREATE TABLE IF NOT EXISTS device_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    employee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    returned_at TIMESTAMP,
    condition_at_issue VARCHAR(50),
    condition_at_return VARCHAR(50),
    fault_reported VARCHAR(50),
    remarks TEXT
);

-- 6. Alerts & Logs Table
CREATE TABLE IF NOT EXISTS alerts_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    severity VARCHAR(50) NOT NULL,
    yard_id UUID REFERENCES yards(id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
