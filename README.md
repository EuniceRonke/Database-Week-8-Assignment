**E-commerce Store Database
Overview**

This project is a relational database system for a simple E-commerce Store, built in MySQL.
It covers customers, products, suppliers, orders, payments, reviews, and more.

**The design demonstrates:
**
One-to-One relationships (customer ↔ profile, product ↔ inventory)

One-to-Many relationships (customer ↔ orders, customer ↔ addresses, product ↔ reviews)

Many-to-Many relationships (products ↔ categories, orders ↔ products)

Proper constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK).

**Database Schema
**
customers – stores user accounts

customer_profiles – additional profile info (1:1 with customers)

addresses – shipping and billing addresses (1:M with customers)

suppliers – product suppliers

categories – product categories

products – product catalog

product_categories – join table for products and categories (M:N)

inventory – stock levels for each product (1:1 with products)

orders – customer purchase orders

order_items – join table for orders and products (M:N with extra columns)

payments – payments for orders

reviews – customer product rev

**Verify**
Run simple queries to check data:

SELECT * FROM customers;

SELECT * FROM orders;

SELECT * FROM order_items;

**Features**

Enforces referential integrity with foreign keys.

Prevents invalid data using NOT NULL, UNIQUE, and CHECK constraints.

Models realistic E-commerce workflows: customer signup, product listing, orders, payments, and reviews.

**Deliverables**

ecommerce_db.sql – full database schema with constraints

README.md – documentation (this file)

Sample seed data (2 rows per table)


