-- =====================================================
-- Migration V4: Add Future Extensions
-- Description: Adds tables and features for future enhancements
-- Author: XP Development Team
-- Date: 2024-01-15
-- =====================================================

-- Create ORDERS table for future e-commerce functionality
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    shipping_address TEXT,
    billing_address TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_orders_total_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_orders_status CHECK (status IN ('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    CONSTRAINT chk_orders_payment_status CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED')),
    INDEX idx_orders_customer_id (customer_id),
    INDEX idx_orders_status (status),
    INDEX idx_orders_order_date (order_date),
    INDEX idx_orders_payment_status (payment_status)
);

-- Create ORDER_ITEMS table for order details
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_order_items_total_price CHECK (total_price >= 0),
    INDEX idx_order_items_order_id (order_id),
    INDEX idx_order_items_product_id (product_id)
);

-- Create CATEGORIES table for product categorization
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_categories_name_length CHECK (LENGTH(name) >= 2 AND LENGTH(name) <= 100),
    INDEX idx_categories_parent_id (parent_id),
    INDEX idx_categories_name (name)
);

-- Add category_id to products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS category_id BIGINT;
ALTER TABLE products ADD CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);

-- Create WISHLIST table for user wishlists
CREATE TABLE IF NOT EXISTS wishlist (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_wishlist_user_product (user_id, product_id),
    INDEX idx_wishlist_user_id (user_id),
    INDEX idx_wishlist_product_id (product_id)
);

-- Create REVIEWS table for product reviews
CREATE TABLE IF NOT EXISTS reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INTEGER NOT NULL,
    title VARCHAR(255),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_reviews_rating CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT chk_reviews_title_length CHECK (title IS NULL OR (LENGTH(title) >= 5 AND LENGTH(title) <= 255)),
    INDEX idx_reviews_product_id (product_id),
    INDEX idx_reviews_user_id (user_id),
    INDEX idx_reviews_rating (rating),
    INDEX idx_reviews_created_at (created_at)
);

-- Create NOTIFICATIONS table for user notifications
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    CONSTRAINT chk_notifications_type CHECK (type IN ('INFO', 'WARNING', 'ERROR', 'SUCCESS', 'PROMOTION')),
    INDEX idx_notifications_user_id (user_id),
    INDEX idx_notifications_type (type),
    INDEX idx_notifications_is_read (is_read),
    INDEX idx_notifications_created_at (created_at)
);

-- Create API_KEYS table for external API access
CREATE TABLE IF NOT EXISTS api_keys (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    key_name VARCHAR(100) NOT NULL,
    api_key VARCHAR(255) NOT NULL UNIQUE,
    user_id BIGINT,
    permissions TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP NULL,
    
    CONSTRAINT chk_api_keys_key_name_length CHECK (LENGTH(key_name) >= 3 AND LENGTH(key_name) <= 100),
    INDEX idx_api_keys_user_id (user_id),
    INDEX idx_api_keys_is_active (is_active),
    INDEX idx_api_keys_expires_at (expires_at)
);

-- Insert sample categories
INSERT INTO categories (name, description, parent_id) VALUES
('Electronics', 'Electronic devices and accessories', NULL),
('Computers', 'Computers, laptops, and related accessories', 1),
('Mobile Devices', 'Smartphones, tablets, and mobile accessories', 1),
('Audio & Video', 'Audio and video equipment', 1),
('Accessories', 'Computer and mobile accessories', NULL),
('Gaming', 'Gaming equipment and accessories', NULL),
('Office', 'Office equipment and supplies', NULL)
ON DUPLICATE KEY UPDATE 
    description = VALUES(description),
    parent_id = VALUES(parent_id);

-- Update existing products with categories
UPDATE products SET category_id = 2 WHERE name LIKE '%Laptop%';
UPDATE products SET category_id = 3 WHERE name LIKE '%iPhone%' OR name LIKE '%iPad%';
UPDATE products SET category_id = 4 WHERE name LIKE '%Headphones%' OR name LIKE '%Speaker%';
UPDATE products SET category_id = 5 WHERE name LIKE '%Keyboard%' OR name LIKE '%Mouse%' OR name LIKE '%Webcam%';
UPDATE products SET category_id = 6 WHERE name LIKE '%Gaming%';
UPDATE products SET category_id = 7 WHERE name LIKE '%Monitor%' OR name LIKE '%Desk%';

-- Add comments for new tables
COMMENT ON TABLE orders IS 'Customer orders for e-commerce functionality';
COMMENT ON TABLE order_items IS 'Individual items within customer orders';
COMMENT ON TABLE categories IS 'Product categories and subcategories';
COMMENT ON TABLE wishlist IS 'User wishlists for favorite products';
COMMENT ON TABLE reviews IS 'Product reviews and ratings from users';
COMMENT ON TABLE notifications IS 'User notifications and alerts';
COMMENT ON TABLE api_keys IS 'API keys for external system integration';

-- Add column comments
COMMENT ON COLUMN orders.total_amount IS 'Total order amount including taxes and shipping';
COMMENT ON COLUMN orders.status IS 'Current status of the order (PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED)';
COMMENT ON COLUMN order_items.quantity IS 'Quantity of the product in the order';
COMMENT ON COLUMN order_items.unit_price IS 'Price per unit at the time of order';
COMMENT ON COLUMN reviews.rating IS 'Product rating from 1 to 5 stars';
COMMENT ON COLUMN reviews.is_verified_purchase IS 'Whether the reviewer actually purchased the product';
COMMENT ON COLUMN notifications.type IS 'Type of notification (INFO, WARNING, ERROR, SUCCESS, PROMOTION)';
COMMENT ON COLUMN api_keys.permissions IS 'JSON string defining API key permissions';
