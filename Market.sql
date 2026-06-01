-- ================================================
-- Instacart Market Basket Analysis
-- Author: Rayun Sa
-- Date: June 2026
-- Description: Consumer purchasing pattern analysis
--              using 3.4M+ grocery orders
-- ================================================


-- Create Database
CREATE DATABASE instacart;
USE instacart;

-- Create aisles table
CREATE TABLE aisles (
    aisle_id INT PRIMARY KEY,
    aisle VARCHAR(100)
);

-- Create departments table
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department VARCHAR(100)
);

-- Create products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    aisle_id INT,
    department_id INT
);

-- Create orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    eval_set VARCHAR(10),
    order_number INT,
    order_dow INT,               -- day of week: 0=Sunday, 6=Saturday
    order_hour_of_day INT,
    days_since_prior_order FLOAT -- NULL for a customer's first order
);

-- Create order_products table
CREATE TABLE order_products (
    order_id INT,
    product_id INT,
    add_to_cart_order INT,       -- the order in which the item was added to cart
    reordered INT                -- 1 if reordered, 0 if first time
);


-- ================================================
-- Data Validation: Check row counts for all tables
-- Purpose: Verify that all CSV files were loaded correctly
--          before running any analysis queries
-- ================================================
SELECT 'aisles'          AS table_name, COUNT(*) AS row_count FROM aisles
UNION ALL
SELECT 'departments'     AS table_name, COUNT(*) AS row_count FROM departments
UNION ALL
SELECT 'products'        AS table_name, COUNT(*) AS row_count FROM products
UNION ALL
SELECT 'orders'          AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL
SELECT 'order_products'  AS table_name, COUNT(*) AS row_count FROM order_products;


-- ================================================
-- Q1: Top 10 Most Ordered Product Departments
-- Purpose: Identify which food categories drive the most orders.
--          This helps prioritize inventory and marketing investment
--          by revealing the highest-demand product categories.
-- Tables used: order_products + products + departments
-- Key techniques: JOIN (x2), GROUP BY, ORDER BY, LIMIT
-- ================================================
SELECT 
    d.department,
    COUNT(*) AS total_orders
FROM order_products op
JOIN products p ON op.product_id = p.product_id       -- link order items to product info
JOIN departments d ON p.department_id = d.department_id -- link products to department names
GROUP BY d.department
ORDER BY total_orders DESC
LIMIT 10;


-- ================================================
-- Q2: Order Patterns by Day of Week and Hour of Day
-- Purpose: Understand when customers are most active.
--          Identifying peak shopping times supports decisions on
--          promotions, staffing, and push notification timing.
-- Tables used: orders
-- Key techniques: CASE WHEN (to convert numeric codes to day names),
--                 GROUP BY (multiple columns), ORDER BY
-- ================================================
SELECT 
    CASE order_dow
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,
    order_hour_of_day,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_dow, order_hour_of_day
ORDER BY order_dow, order_hour_of_day;


-- ================================================
-- Q3: Top 10 Products with Highest Reorder Rate
-- Purpose: Discover which products have the strongest customer loyalty.
--          High reorder rates indicate essential or habitual purchases,
--          making these products ideal for subscription or bundling strategies.
-- Tables used: order_products + products
-- Key techniques: JOIN, SUM (on binary column), ROUND, HAVING
-- Note: HAVING COUNT(*) >= 100 filters out low-volume products
--       whose reorder rates would be statistically unreliable
-- ================================================
SELECT 
    p.product_name,
    COUNT(*) AS total_orders,
    SUM(op.reordered) AS reorder_count,
    ROUND(SUM(op.reordered) / COUNT(*) * 100, 1) AS reorder_rate_pct
FROM order_products op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
HAVING COUNT(*) >= 100                                 -- exclude rarely ordered products
ORDER BY reorder_rate_pct DESC
LIMIT 10;


-- ================================================
-- Q4: Customer Segmentation by Purchase Frequency
-- Purpose: Classify customers into segments based on order frequency.
--          Understanding the distribution of Heavy/Regular/Light users
--          helps tailor retention strategies for each segment.
-- Tables used: orders
-- Key techniques: Subquery, CASE WHEN, GROUP BY, window function (OVER())
-- Segments: Heavy User (10+ orders), Regular User (5-9), Light User (1-4)
-- ================================================
SELECT 
    CASE 
        WHEN order_count >= 10 THEN 'Heavy User'
        WHEN order_count >= 5  THEN 'Regular User'
        ELSE                        'Light User'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage  -- percentage of total customers
FROM (
    -- Subquery: first calculate total order count per user
    SELECT 
        user_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY user_id
) AS user_orders
GROUP BY customer_segment
ORDER BY customer_count DESC;


-- ================================================
-- Q5: Average Purchase Cycle by Customer Segment
-- Purpose: Measure how frequently each customer segment shops.
--          Purchase cycle length is a key metric for FMCG companies
--          to align promotions and replenishment reminders with
--          actual consumer buying rhythms.
-- Tables used: orders
-- Key techniques: Subquery, CASE WHEN, AVG, WHERE IS NOT NULL
-- Note: days_since_prior_order is NULL for each customer's first order,
--       so NULL rows are excluded to avoid skewing the average
-- ================================================
SELECT
    CASE
        WHEN order_count >= 10 THEN 'Heavy User'
        WHEN order_count >= 5  THEN 'Regular User'
        ELSE                        'Light User'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_days), 1) AS avg_days_between_orders
FROM (
    -- Subquery: calculate average days between orders per user
    SELECT
        user_id,
        COUNT(*) AS order_count,
        AVG(days_since_prior_order) AS avg_days
    FROM orders
    WHERE days_since_prior_order IS NOT NULL  -- exclude first orders (no prior order exists)
    GROUP BY user_id
) AS user_stats
GROUP BY customer_segment
ORDER BY avg_days_between_orders;


-- ================================================
-- Q6: Organic vs Non-Organic Product Purchasing Patterns
-- Purpose: Measure the scale of health-conscious purchasing behavior.
--          Identifying the share of organic products in total orders
--          reflects growing consumer demand for clean-label foods —
--          a critical trend for FMCG companies when making
--          product development and portfolio decisions.
-- Tables used: order_products + products + departments
-- Key techniques: CASE WHEN (keyword detection with LIKE),
--                 JOIN, GROUP BY, ROUND
-- Note: Products containing 'organic' in their name are classified
--       as organic. This is a keyword-based approximation;
--       actual organic certification may differ.
-- ================================================
SELECT
    CASE
        WHEN LOWER(p.product_name) LIKE '%organic%' THEN 'Organic'
        ELSE 'Non-Organic'
    END AS product_type,
    d.department,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY d.department), 1) AS pct_within_department
FROM order_products op
JOIN products p ON op.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY product_type, d.department
ORDER BY d.department, product_type;


-- ================================================
-- Q6-B: Reorder Rate Comparison — Organic vs Non-Organic
-- Purpose: Test whether organic products show stronger customer
--          loyalty than non-organic equivalents.
--          From a food industry perspective, higher reorder rates
--          in organic products would support a premium pricing
--          and subscription strategy for health-conscious consumers.
-- Tables used: order_products + products
-- Key techniques: CASE WHEN (keyword detection with LIKE),
--                 AVG (on binary column), ROUND, GROUP BY
-- Note: AVG(reordered) on a 0/1 column directly gives reorder rate
--       as a proportion — equivalent to SUM/COUNT but more concise
-- ================================================
SELECT
    CASE
        WHEN LOWER(p.product_name) LIKE '%organic%' THEN 'Organic'
        ELSE 'Non-Organic'
    END AS product_type,
    COUNT(DISTINCT p.product_id)            AS unique_products,
    COUNT(*)                                AS total_orders,
    ROUND(AVG(op.reordered) * 100, 1)       AS reorder_rate_pct
FROM order_products op
JOIN products p ON op.product_id = p.product_id
GROUP BY product_type
ORDER BY reorder_rate_pct DESC;
