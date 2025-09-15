-- =====================================================
-- Migration V3: Insert Sample Data
-- Description: Inserts sample data for development and testing
-- Author: XP Development Team
-- Date: 2024-01-15
-- =====================================================

-- Insert sample users (passwords are BCrypt hashed)
-- Default password for all users: 'password123'
-- BCrypt hash: $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi

INSERT INTO users (username, password, email, role, enabled, account_non_expired, account_non_locked, credentials_non_expired) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'admin@xp.com', 'ADMIN', TRUE, TRUE, TRUE, TRUE),
('user', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'user@xp.com', 'USER', TRUE, TRUE, TRUE, TRUE),
('john.doe', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'john.doe@example.com', 'USER', TRUE, TRUE, TRUE, TRUE),
('jane.smith', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'jane.smith@example.com', 'USER', TRUE, TRUE, TRUE, TRUE),
('test.user', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'test@xp.com', 'USER', TRUE, TRUE, TRUE, TRUE)
ON DUPLICATE KEY UPDATE 
    password = VALUES(password),
    email = VALUES(email),
    role = VALUES(role),
    enabled = VALUES(enabled);

-- Insert sample products
INSERT INTO products (name, description, price, stock) VALUES
('Laptop Dell XPS 13', 'High-performance laptop with Intel i7 processor, 16GB RAM, 512GB SSD', 1299.99, 25),
('Smartphone iPhone 15', 'Latest iPhone model with A17 Pro chip, 128GB storage, Pro camera system', 999.99, 50),
('Tablet iPad Air', '10.9-inch tablet with M2 chip, 64GB storage, Wi-Fi + Cellular', 599.99, 30),
('Monitor Samsung 27"', '4K UHD monitor with HDR10, 60Hz refresh rate, USB-C connectivity', 399.99, 15),
('Keyboard Mechanical', 'RGB mechanical keyboard with Cherry MX switches, wireless connectivity', 149.99, 40),
('Mouse Gaming', 'High-precision gaming mouse with 16000 DPI, RGB lighting', 79.99, 60),
('Headphones Sony WH-1000XM5', 'Noise-cancelling wireless headphones with 30-hour battery life', 399.99, 20),
('Webcam Logitech C920', 'HD 1080p webcam with autofocus and stereo microphones', 99.99, 35),
('SSD Samsung 1TB', 'NVMe SSD with 7000MB/s read speed, perfect for gaming and content creation', 199.99, 45),
('Router Wi-Fi 6', 'AX6000 dual-band router with mesh support and advanced security', 299.99, 12)
ON DUPLICATE KEY UPDATE 
    description = VALUES(description),
    price = VALUES(price),
    stock = VALUES(stock);

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone, address) VALUES
('John', 'Doe', 'john.doe@example.com', '+1-555-0123', '123 Main Street, New York, NY 10001'),
('Jane', 'Smith', 'jane.smith@example.com', '+1-555-0456', '456 Oak Avenue, Los Angeles, CA 90210'),
('Robert', 'Johnson', 'robert.johnson@example.com', '+1-555-0789', '789 Pine Road, Chicago, IL 60601'),
('Maria', 'Garcia', 'maria.garcia@example.com', '+1-555-0321', '321 Elm Street, Houston, TX 77001'),
('David', 'Brown', 'david.brown@example.com', '+1-555-0654', '654 Maple Drive, Phoenix, AZ 85001'),
('Sarah', 'Wilson', 'sarah.wilson@example.com', '+1-555-0987', '987 Cedar Lane, Philadelphia, PA 19101'),
('Michael', 'Davis', 'michael.davis@example.com', '+1-555-0147', '147 Birch Boulevard, San Antonio, TX 78201'),
('Lisa', 'Miller', 'lisa.miller@example.com', '+1-555-0258', '258 Spruce Street, San Diego, CA 92101'),
('James', 'Anderson', 'james.anderson@example.com', '+1-555-0369', '369 Willow Way, Dallas, TX 75201'),
('Jennifer', 'Taylor', 'jennifer.taylor@example.com', '+1-555-0741', '741 Poplar Place, San Jose, CA 95101')
ON DUPLICATE KEY UPDATE 
    first_name = VALUES(first_name),
    last_name = VALUES(last_name),
    phone = VALUES(phone),
    address = VALUES(address);

-- Insert sample audit log entries
INSERT INTO audit_log (event_type, username, ip_address, details) VALUES
('LOGIN_SUCCESS', 'admin', '192.168.1.100', 'Administrator login successful'),
('LOGIN_SUCCESS', 'user', '192.168.1.101', 'User login successful'),
('DATA_ACCESS', 'admin', '192.168.1.100', 'Accessed product catalog'),
('DATA_ACCESS', 'user', '192.168.1.101', 'Viewed customer list'),
('DATA_MODIFICATION', 'admin', '192.168.1.100', 'Created new product: Laptop Dell XPS 13'),
('DATA_MODIFICATION', 'admin', '192.168.1.100', 'Updated product stock: Smartphone iPhone 15'),
('LGPD_EXPORT', 'john.doe', '192.168.1.102', 'User requested data export'),
('SECURITY_VIOLATION', 'unknown', '192.168.1.200', 'Failed login attempt with invalid credentials'),
('ADMIN_ACTION', 'admin', '192.168.1.100', 'System configuration updated'),
('SYSTEM_EVENT', 'system', '127.0.0.1', 'Application startup completed')
ON DUPLICATE KEY UPDATE 
    details = VALUES(details);

-- Insert sample security events
INSERT INTO security_event (event_type, severity, description, ip_address, resolved) VALUES
('FAILED_LOGIN_ATTEMPT', 'MEDIUM', 'Multiple failed login attempts detected', '192.168.1.200', FALSE),
('SUSPICIOUS_ACTIVITY', 'HIGH', 'Unusual data access pattern detected', '192.168.1.150', FALSE),
('RATE_LIMIT_EXCEEDED', 'LOW', 'API rate limit exceeded for user', '192.168.1.101', TRUE),
('SECURITY_SCAN', 'INFO', 'Automated security scan completed', '127.0.0.1', TRUE),
('ANOMALY_DETECTED', 'HIGH', 'Anomalous user behavior detected', '192.168.1.102', FALSE),
('SYSTEM_ALERT', 'MEDIUM', 'High CPU usage detected', '127.0.0.1', TRUE),
('LGPD_REQUEST', 'INFO', 'LGPD data export request processed', '192.168.1.103', TRUE),
('AUTHENTICATION_SUCCESS', 'INFO', 'Successful authentication with MFA', '192.168.1.104', TRUE),
('DATA_ENCRYPTION', 'INFO', 'Sensitive data encrypted successfully', '127.0.0.1', TRUE),
('BACKUP_COMPLETED', 'INFO', 'Database backup completed successfully', '127.0.0.1', TRUE)
ON DUPLICATE KEY UPDATE 
    description = VALUES(description),
    resolved = VALUES(resolved);

-- Insert sample LGPD requests
INSERT INTO lgpd_request (user_id, request_type, status, requestor_email, deletion_reason, confirm_deletion) VALUES
(3, 'EXPORT', 'COMPLETED', 'john.doe@example.com', NULL, FALSE),
(4, 'DELETE', 'PENDING', 'jane.smith@example.com', 'User requested account deletion', TRUE),
(5, 'PORTABILITY', 'PROCESSING', 'robert.johnson@example.com', NULL, FALSE),
(6, 'RECTIFICATION', 'COMPLETED', 'maria.garcia@example.com', NULL, FALSE),
(7, 'EXPORT', 'PENDING', 'david.brown@example.com', NULL, FALSE)
ON DUPLICATE KEY UPDATE 
    status = VALUES(status),
    deletion_reason = VALUES(deletion_reason),
    confirm_deletion = VALUES(confirm_deletion);

-- Add some additional sample data for testing

-- Insert more products for testing
INSERT INTO products (name, description, price, stock) VALUES
('Gaming Chair', 'Ergonomic gaming chair with lumbar support and RGB lighting', 249.99, 8),
('Desk Lamp LED', 'Adjustable LED desk lamp with USB charging port', 49.99, 25),
('External Hard Drive', '2TB portable hard drive with USB 3.0 connectivity', 89.99, 18),
('Bluetooth Speaker', 'Waterproof Bluetooth speaker with 20-hour battery life', 79.99, 22),
('Smart Watch', 'Fitness tracking smartwatch with heart rate monitor', 199.99, 14)
ON DUPLICATE KEY UPDATE 
    description = VALUES(description),
    price = VALUES(price),
    stock = VALUES(stock);

-- Insert more customers for testing
INSERT INTO customers (first_name, last_name, email, phone, address) VALUES
('Alice', 'Williams', 'alice.williams@example.com', '+1-555-0852', '852 Cherry Street, Austin, TX 78701'),
('Bob', 'Jones', 'bob.jones@example.com', '+1-555-0963', '963 Ash Avenue, Jacksonville, FL 32201'),
('Carol', 'White', 'carol.white@example.com', '+1-555-0174', '174 Hickory Drive, Columbus, OH 43201'),
('Daniel', 'Harris', 'daniel.harris@example.com', '+1-555-0285', '285 Sycamore Lane, Charlotte, NC 28201'),
('Emma', 'Martin', 'emma.martin@example.com', '+1-555-0396', '396 Walnut Way, Seattle, WA 98101')
ON DUPLICATE KEY UPDATE 
    first_name = VALUES(first_name),
    last_name = VALUES(last_name),
    phone = VALUES(phone),
    address = VALUES(address);

-- Add comments for sample data
COMMENT ON TABLE users IS 'Sample users: admin/password123, user/password123, john.doe/password123, etc.';
COMMENT ON TABLE products IS 'Sample product catalog with various electronics and accessories';
COMMENT ON TABLE customers IS 'Sample customer database with contact information';
COMMENT ON TABLE audit_log IS 'Sample audit trail entries for security and compliance';
COMMENT ON TABLE security_event IS 'Sample security events for monitoring and alerting';
COMMENT ON TABLE lgpd_request IS 'Sample LGPD compliance requests for testing';
