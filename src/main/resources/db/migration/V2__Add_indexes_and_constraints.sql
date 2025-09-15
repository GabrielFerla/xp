-- =====================================================
-- Migration V2: Add Indexes and Constraints
-- Description: Adds performance indexes and additional constraints
-- Author: XP Development Team
-- Date: 2024-01-15
-- =====================================================

-- Add performance indexes for USERS table
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_enabled ON users(enabled);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Add performance indexes for PRODUCTS table
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_stock ON products(stock);
CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at);
CREATE INDEX IF NOT EXISTS idx_products_updated_at ON products(updated_at);

-- Add composite index for product search
CREATE INDEX IF NOT EXISTS idx_products_name_price ON products(name, price);

-- Add performance indexes for CUSTOMERS table
CREATE INDEX IF NOT EXISTS idx_customers_first_name ON customers(first_name);
CREATE INDEX IF NOT EXISTS idx_customers_last_name ON customers(last_name);
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_created_at ON customers(created_at);

-- Add composite index for customer search by name
CREATE INDEX IF NOT EXISTS idx_customers_full_name ON customers(first_name, last_name);

-- Add performance indexes for AUDIT_LOG table
CREATE INDEX IF NOT EXISTS idx_audit_log_event_type_timestamp ON audit_log(event_type, timestamp);
CREATE INDEX IF NOT EXISTS idx_audit_log_username_timestamp ON audit_log(username, timestamp);
CREATE INDEX IF NOT EXISTS idx_audit_log_ip_timestamp ON audit_log(ip_address, timestamp);

-- Add performance indexes for SECURITY_EVENT table
CREATE INDEX IF NOT EXISTS idx_security_event_type_severity ON security_event(event_type, severity);
CREATE INDEX IF NOT EXISTS idx_security_event_timestamp_severity ON security_event(timestamp, severity);
CREATE INDEX IF NOT EXISTS idx_security_event_resolved_timestamp ON security_event(resolved, timestamp);

-- Add performance indexes for LGPD_REQUEST table
CREATE INDEX IF NOT EXISTS idx_lgpd_request_user_type ON lgpd_request(user_id, request_type);
CREATE INDEX IF NOT EXISTS idx_lgpd_request_status_date ON lgpd_request(status, request_date);
CREATE INDEX IF NOT EXISTS idx_lgpd_request_type_status ON lgpd_request(request_type, status);

-- Add additional constraints for data integrity

-- Add check constraint for email format (basic validation)
ALTER TABLE users ADD CONSTRAINT chk_users_email_format 
    CHECK (email LIKE '%@%.%');

ALTER TABLE customers ADD CONSTRAINT chk_customers_email_format 
    CHECK (email LIKE '%@%.%');

-- Add check constraint for phone format (basic validation)
ALTER TABLE customers ADD CONSTRAINT chk_customers_phone_format 
    CHECK (phone IS NULL OR phone REGEXP '^[+]?[0-9\\-\\s\\(\\)]{7,20}$');

-- Add check constraint for username format
ALTER TABLE users ADD CONSTRAINT chk_users_username_format 
    CHECK (username REGEXP '^[a-zA-Z0-9_]{3,50}$');

-- Add check constraint for product name length
ALTER TABLE products ADD CONSTRAINT chk_products_name_length 
    CHECK (LENGTH(name) >= 2 AND LENGTH(name) <= 255);

-- Add check constraint for customer name length
ALTER TABLE customers ADD CONSTRAINT chk_customers_first_name_length 
    CHECK (LENGTH(first_name) >= 2 AND LENGTH(first_name) <= 100);

ALTER TABLE customers ADD CONSTRAINT chk_customers_last_name_length 
    CHECK (LENGTH(last_name) >= 2 AND LENGTH(last_name) <= 100);

-- Add check constraint for audit log event type
ALTER TABLE audit_log ADD CONSTRAINT chk_audit_log_event_type 
    CHECK (event_type IN (
        'LOGIN_SUCCESS', 'LOGIN_FAILURE', 'LOGOUT', 
        'DATA_ACCESS', 'DATA_MODIFICATION', 'DATA_DELETION',
        'AUTHORIZATION_FAILURE', 'SECURITY_VIOLATION',
        'LGPD_EXPORT', 'LGPD_DELETE', 'LGPD_PORTABILITY',
        'ADMIN_ACTION', 'SYSTEM_EVENT'
    ));

-- Add check constraint for security event severity
ALTER TABLE security_event ADD CONSTRAINT chk_security_event_severity_values 
    CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL', 'INFO', 'WARN', 'ERROR'));

-- Add check constraint for LGPD request types
ALTER TABLE lgpd_request ADD CONSTRAINT chk_lgpd_request_types 
    CHECK (request_type IN ('EXPORT', 'DELETE', 'PORTABILITY', 'RECTIFICATION'));

-- Add check constraint for LGPD request status
ALTER TABLE lgpd_request ADD CONSTRAINT chk_lgpd_request_status_values 
    CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'REJECTED'));

-- Add triggers for automatic timestamp updates (if supported by H2)
-- Note: H2 has limited trigger support, so we'll use application-level timestamp management

-- Add comments for indexes
COMMENT ON INDEX idx_users_email IS 'Index for fast email lookups during authentication';
COMMENT ON INDEX idx_products_name ON products(name) IS 'Index for product name searches';
COMMENT ON INDEX idx_customers_full_name IS 'Composite index for customer name searches';
COMMENT ON INDEX idx_audit_log_event_type_timestamp IS 'Composite index for audit log queries by event type and time';
COMMENT ON INDEX idx_security_event_timestamp_severity IS 'Composite index for security event monitoring';
COMMENT ON INDEX idx_lgpd_request_user_type IS 'Composite index for LGPD request lookups by user and type';
