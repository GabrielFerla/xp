-- =====================================================
-- MySQL Initialization Script
-- Description: Initial setup for XP Application MySQL database
-- Author: XP Development Team
-- Date: 2024-01-15
-- =====================================================

-- Create database if not exists (already created by environment variable)
-- USE xpdb;

-- Set character set and collation
ALTER DATABASE xpdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user with proper permissions (if not exists)
CREATE USER IF NOT EXISTS 'xp_user'@'%' IDENTIFIED BY 'xp_password';
GRANT ALL PRIVILEGES ON xpdb.* TO 'xp_user'@'%';
FLUSH PRIVILEGES;

-- Set timezone
SET time_zone = '+00:00';

-- Enable general log for debugging (optional)
-- SET GLOBAL general_log = 'ON';
-- SET GLOBAL general_log_file = '/var/lib/mysql/general.log';

-- Set MySQL configuration for better performance
SET GLOBAL innodb_buffer_pool_size = 128M;
SET GLOBAL max_connections = 200;
SET GLOBAL query_cache_size = 32M;
SET GLOBAL query_cache_type = 1;

-- Create initial schema version table for Flyway
CREATE TABLE IF NOT EXISTS flyway_schema_history (
    installed_rank INT NOT NULL,
    version VARCHAR(50),
    description VARCHAR(200) NOT NULL,
    type VARCHAR(20) NOT NULL,
    script VARCHAR(1000) NOT NULL,
    checksum INT,
    installed_by VARCHAR(100) NOT NULL,
    installed_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    execution_time INT NOT NULL,
    success BOOLEAN NOT NULL,
    PRIMARY KEY (installed_rank)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert initial baseline record
INSERT IGNORE INTO flyway_schema_history 
(installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success)
VALUES 
(0, NULL, '<< Flyway Baseline >>', 'BASELINE', '<< Flyway Baseline >>', NULL, 'mysql', NOW(), 0, 1);

-- Show database information
SELECT 'MySQL Database initialized successfully for XP Application' as status;
SELECT DATABASE() as current_database;
SELECT VERSION() as mysql_version;
