-- =====================================================
-- Migration V1: Create Initial Tables (MySQL Version)
-- Description: Creates the initial database schema for XP Application (MySQL)
-- Author: XP Development Team
-- Date: 2024-01-15
-- =====================================================

-- Create ROLE enum table
CREATE TABLE IF NOT EXISTS role (
    name VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create LGPD_REQUEST table for LGPD compliance
CREATE TABLE IF NOT EXISTS lgpd_request (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    request_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    requestor_email VARCHAR(100) NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_date TIMESTAMP NULL,
    deletion_reason TEXT,
    confirm_deletion BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT chk_lgpd_request_type CHECK (request_type IN ('EXPORT', 'DELETE', 'PORTABILITY', 'RECTIFICATION')),
    CONSTRAINT chk_lgpd_request_status CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'REJECTED')),
    INDEX idx_lgpd_request_user_id (user_id),
    INDEX idx_lgpd_request_type (request_type),
    INDEX idx_lgpd_request_status (status),
    INDEX idx_lgpd_request_date (request_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add comments to tables for documentation
ALTER TABLE users COMMENT = 'User accounts for authentication and authorization';
ALTER TABLE products COMMENT = 'Product catalog with inventory management';
ALTER TABLE customers COMMENT = 'Customer information and contact details';
ALTER TABLE audit_log COMMENT = 'Audit trail for security and compliance logging';
ALTER TABLE security_event COMMENT = 'Security events and anomaly detection logs';
ALTER TABLE lgpd_request COMMENT = 'LGPD compliance requests (export, delete, portability)';
ALTER TABLE role COMMENT = 'User roles and permissions';

-- Add column comments
ALTER TABLE users MODIFY COLUMN username VARCHAR(50) COMMENT 'Unique username for login';
ALTER TABLE users MODIFY COLUMN password VARCHAR(255) COMMENT 'Encrypted password using BCrypt';
ALTER TABLE users MODIFY COLUMN email VARCHAR(100) COMMENT 'User email address (unique)';
ALTER TABLE users MODIFY COLUMN role VARCHAR(50) COMMENT 'User role (USER or ADMIN)';
ALTER TABLE products MODIFY COLUMN price DECIMAL(10,2) COMMENT 'Product price in decimal format';
ALTER TABLE products MODIFY COLUMN stock INTEGER COMMENT 'Available stock quantity';
ALTER TABLE customers MODIFY COLUMN email VARCHAR(100) COMMENT 'Customer email address (unique)';
ALTER TABLE audit_log MODIFY COLUMN event_type VARCHAR(100) COMMENT 'Type of audit event (LOGIN, LOGOUT, DATA_ACCESS, etc.)';
ALTER TABLE security_event MODIFY COLUMN severity VARCHAR(20) COMMENT 'Event severity level (LOW, MEDIUM, HIGH, CRITICAL)';
ALTER TABLE lgpd_request MODIFY COLUMN request_type VARCHAR(50) COMMENT 'Type of LGPD request (EXPORT, DELETE, PORTABILITY, RECTIFICATION)';
