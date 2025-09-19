-- ecommerce_db.sql
-- Create database and schema for a simple E-commerce store
-- Engine: InnoDB, charset utf8mb4

DROP DATABASE IF EXISTS ecommerce_store;
CREATE DATABASE ecommerce_store CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_unicode_ci';
USE ecommerce_store;
-- Users / Customers
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
  customer_id      INT AUTO_INCREMENT PRIMARY KEY,
  email            VARCHAR(255) NOT NULL UNIQUE,
  password_hash    VARCHAR(255) NOT NULL,
  first_name       VARCHAR(100) NOT NULL,
  last_name        VARCHAR(100) NOT NULL,
  phone            VARCHAR(20),
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- One-to-One example:
-- Each customer has exactly one customer_profile
DROP TABLE IF EXISTS customer_profiles;
CREATE TABLE customer_profiles (
  customer_id      INT PRIMARY KEY, -- PK and FK -> enforces 1:1
  date_of_birth    DATE,
  gender           ENUM('male','female','other') DEFAULT NULL,
  newsletter_optin BOOLEAN DEFAULT FALSE,
  bio              TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Addresses (One-to-Many: customer -> addresses)
DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses (
  address_id       INT AUTO_INCREMENT PRIMARY KEY,
  customer_id      INT NOT NULL,
  type             ENUM('shipping','billing','other') NOT NULL DEFAULT 'shipping',
  line1            VARCHAR(255) NOT NULL,
  line2            VARCHAR(255),
  city             VARCHAR(100) NOT NULL,
  state            VARCHAR(100),
  postal_code      VARCHAR(20) NOT NULL,
  country          VARCHAR(100) NOT NULL,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Suppliers
DROP TABLE IF EXISTS suppliers;
CREATE TABLE suppliers (
  supplier_id      INT AUTO_INCREMENT PRIMARY KEY,
  name             VARCHAR(255) NOT NULL,
  contact_email    VARCHAR(255),
  phone            VARCHAR(25),
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Categories (for products)
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
  category_id      INT AUTO_INCREMENT PRIMARY KEY,
  name             VARCHAR(100) NOT NULL UNIQUE,
  description      TEXT
) ENGINE=InnoDB;

-- Products
DROP TABLE IF EXISTS products;
CREATE TABLE products (
  product_id       INT AUTO_INCREMENT PRIMARY KEY,
  sku              VARCHAR(100) NOT NULL UNIQUE,
  name             VARCHAR(255) NOT NULL,
  description      TEXT,
  price            DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  supplier_id      INT,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Many-to-Many: products <-> categories
DROP TABLE IF EXISTS product_categories;
CREATE TABLE product_categories (
  product_id       INT NOT NULL,
  category_id      INT NOT NULL,
  PRIMARY KEY (product_id, category_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Inventory (One-to-One per product per warehouse)
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
  product_id       INT PRIMARY KEY,
  quantity_in_stock INT NOT NULL DEFAULT 0 CHECK (quantity_in_stock >= 0),
  reserved_quantity INT NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
  last_updated     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Orders (One-to-Many: customer -> orders)
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  order_id         INT AUTO_INCREMENT PRIMARY KEY,
  customer_id      INT NOT NULL,
  order_status     ENUM('pending','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  total_amount     DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
  shipping_address_id INT,
  billing_address_id  INT,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
  FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id) ON DELETE SET NULL,
  FOREIGN KEY (billing_address_id)  REFERENCES addresses(address_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Order Items (Many-to-Many between orders and products with extra columns)
-- Composite PK ensures one row per (order, product) pair
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
  order_id         INT NOT NULL,
  product_id       INT NOT NULL,
  quantity         INT NOT NULL CHECK (quantity > 0),
  unit_price       DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  discount         DECIMAL(10,2) DEFAULT 0 CHECK (discount >= 0),
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Payments (One-to-One with orders)
DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
  payment_id       INT AUTO_INCREMENT PRIMARY KEY,
  order_id         INT NOT NULL,
  payment_method   ENUM('card','paypal','bank_transfer','cash_on_delivery') NOT NULL,
  amount           DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
  status           ENUM('initiated','completed','failed','refunded') NOT NULL DEFAULT 'initiated',
  provider_txn_id  VARCHAR(255),
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB;

--  Indexes
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_inventory_qty ON inventory(quantity_in_stock);

-- Product Reviews (One-to-Many: product -> reviews, customer -> reviews)
DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
  review_id    INT AUTO_INCREMENT PRIMARY KEY,
  product_id   INT NOT NULL,
  customer_id  INT, -- allow NULL
  rating       TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title        VARCHAR(255),
  body         TEXT,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL
) ENGINE=InnoDB;


-- Customers
INSERT INTO customers (email, password_hash, first_name, last_name, phone)
VALUES 
('alice@gmail.com','hash_alice','Alice','Doe','555-1234'),
('bob@gmail.com','hash_bob','Bob','Smith','555-5678');

-- Customer Profiles (1:1 with customers)
INSERT INTO customer_profiles (customer_id, date_of_birth, gender, newsletter_optin, bio)
VALUES 
(1,'1990-05-12','female',TRUE,'Loves online shopping'),
(2,'1985-11-23','male',FALSE,'Enjoys tech gadgets');

-- Addresses
INSERT INTO addresses (customer_id,type,line1,city,state,postal_code,country)
VALUES
(1,'shipping','123 Main St','Lagos','LA','100001','Nigeria'),
(2,'billing','45 Broad Ave','Abuja','FC','900001','Nigeria');

-- Suppliers
INSERT INTO suppliers (name, contact_email, phone)
VALUES
('Acme Supplies','sales@acme.com','111-222-3333'),
('TechSource','support@techsource.com','444-555-6666');

-- Categories
INSERT INTO categories (name, description)
VALUES
('Electronics','Devices and gadgets'),
('Books','Printed and digital books');

-- Products
INSERT INTO products (sku, name, description, price, supplier_id)
VALUES
('SKU-100','USB Cable','1m fast-charging USB cable',5.99,1),
('SKU-200','Data Science Book','Introductory guide to Data Science',29.99,2);

-- Product Categories (many-to-many)
INSERT INTO product_categories (product_id, category_id)
VALUES
(1,1), -- USB Cable → Electronics
(2,2); -- Data Science Book → Books

-- Inventory
INSERT INTO inventory (product_id, quantity_in_stock, reserved_quantity)
VALUES
(1,100,5),
(2,25,2);

-- Orders
INSERT INTO orders (customer_id, order_status, total_amount, shipping_address_id, billing_address_id)
VALUES
(1,'processing',11.98,1,1),
(2,'pending',29.99,2,2);

-- Order Items (many-to-many orders ↔ products)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
VALUES
(1,1,2,5.99,0),   -- Alice ordered 2 USB Cables
(2,2,1,29.99,0);  -- Bob ordered 1 Book

-- Payments
INSERT INTO payments (order_id, payment_method, amount, status, provider_txn_id)
VALUES
(1,'card',11.98,'completed','TXN123'),
(2,'paypal',29.99,'initiated','TXN124');

-- Reviews
INSERT INTO reviews (product_id, customer_id, rating, title, body)
VALUES
(1,1,5,'Great Cable','Works perfectly, fast delivery!'),
(2,2,4,'Good Book','Very informative, but a bit dense.');

