-- =====================================================
-- Migration V1: Create Initial Tables
-- Description: Creates the initial database schema for XP Application
-- Author: XP Development Team
-- Date: 2024-01-15
-- =====================================================

-- Create ROLE enum table
CREATE TABLE IF NOT EXISTS role (
    name VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255)
);

-- Insert default roles
INSERT INTO role (name, description) VALUES 
('USER', 'Regular user with basic permissions'),
('ADMIN', 'Administrator with full system access')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Create USERS table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    account_non_expired BOOLEAN NOT NULL DEFAULT TRUE,
    account_non_locked BOOLEAN NOT NULL DEFAULT TRUE,
    credentials_non_expired BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_users_role FOREIGN KEY (role) REFERENCES role(name)
);

-- Create PRODUCTS table
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    stock INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_products_price CHECK (price >= 0),
    CONSTRAINT chk_products_stock CHECK (stock >= 0)
);

-- Create CUSTOMERS table
CREATE TABLE IF NOT EXISTS customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create AUDIT_LOG table for security and compliance
CREATE TABLE IF NOT EXISTS audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    username VARCHAR(50),
    ip_address VARCHAR(45),
    details TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_audit_log_event_type (event_type),
    INDEX idx_audit_log_username (username),
    INDEX idx_audit_log_timestamp (timestamp)
);

-- Create SECURITY_EVENT table for security monitoring
CREATE TABLE IF NOT EXISTS security_event (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    severity VARCHAR(20) NOT NULL DEFAULT 'INFO',
    description TEXT,
    ip_address VARCHAR(45),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT chk_security_event_severity CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL', 'INFO', 'WARN', 'ERROR')),
    INDEX idx_security_event_type (event_type),
    INDEX idx_security_event_severity (severity),
    INDEX idx_security_event_timestamp (timestamp),
    INDEX idx_security_event_resolved (resolved)
);

-- Create LGPD_REQUEST table for LGPD compliance
CREATE TABLE IF NOT EXISTS lgpd_request (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    request_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    requestor_email VARCHAR(100) NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_date TIMESTAMP,
    deletion_reason TEXT,
    confirm_deletion BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT chk_lgpd_request_type CHECK (request_type IN ('EXPORT', 'DELETE', 'PORTABILITY', 'RECTIFICATION')),
    CONSTRAINT chk_lgpd_request_status CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'REJECTED')),
    INDEX idx_lgpd_request_user_id (user_id),
    INDEX idx_lgpd_request_type (request_type),
    INDEX idx_lgpd_request_status (status),
    INDEX idx_lgpd_request_date (request_date)
);

-- Create FLYWAY_SCHEMA_HISTORY table (managed by Flyway)
-- This table is automatically created by Flyway to track migration history

-- Add comments to tables for documentation
COMMENT ON TABLE users IS 'User accounts for authentication and authorization';
COMMENT ON TABLE products IS 'Product catalog with inventory management';
COMMENT ON TABLE customers IS 'Customer information and contact details';
COMMENT ON TABLE audit_log IS 'Audit trail for security and compliance logging';
COMMENT ON TABLE security_event IS 'Security events and anomaly detection logs';
COMMENT ON TABLE lgpd_request IS 'LGPD compliance requests (export, delete, portability)';
COMMENT ON TABLE role IS 'User roles and permissions';

-- Add column comments
COMMENT ON COLUMN users.username IS 'Unique username for login';
COMMENT ON COLUMN users.password IS 'Encrypted password using BCrypt';
COMMENT ON COLUMN users.email IS 'User email address (unique)';
COMMENT ON COLUMN users.role IS 'User role (USER or ADMIN)';
COMMENT ON COLUMN products.price IS 'Product price in decimal format';
COMMENT ON COLUMN products.stock IS 'Available stock quantity';
COMMENT ON COLUMN customers.email IS 'Customer email address (unique)';
COMMENT ON COLUMN audit_log.event_type IS 'Type of audit event (LOGIN, LOGOUT, DATA_ACCESS, etc.)';
COMMENT ON COLUMN security_event.severity IS 'Event severity level (LOW, MEDIUM, HIGH, CRITICAL)';
COMMENT ON COLUMN lgpd_request.request_type IS 'Type of LGPD request (EXPORT, DELETE, PORTABILITY, RECTIFICATION)';
