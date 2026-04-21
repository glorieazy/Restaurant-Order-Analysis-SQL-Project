-- ============================================================
-- RESTAURANT ORDER ANALYSIS
-- Database: restaurant_db
-- Author:
-- Date: 2023
-- ============================================================

USE restaurant_db;

-- ============================================================
-- SECTION 0: DATABASE EXPLORATION
-- ============================================================

-- View all tables in the schema
SELECT *
FROM information_schema.tables
WHERE table_schema = 'restaurant_db';

-- Preview tables
SELECT * FROM menu_items;
SELECT * FROM order_details;

-- ============================================================
-- SECTION 1: DATA OVERVIEW & SUMMARY STATISTICS
-- ============================================================

-- Total menu items
SELECT
    COUNT(*) AS total_menu_items
FROM menu_items;

-- Distinct cuisine categories
SELECT
    category
FROM menu_items
GROUP BY category;

-- Price range across all menu items
SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM menu_items;

-- Total order records
SELECT
    COUNT(*) AS total_order_details
FROM order_details;

-- Total distinct orders
SELECT
    COUNT(DISTINCT order_id) AS total_distinct_orders
FROM order_details;

-- Date range of orders
SELECT
    MIN(order_date)                            AS start_date,
    MAX(order_date)                            AS end_date,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS total_days
FROM order_details;

-- Average items per order
SELECT
    ROUND(COUNT(item_id) / COUNT(DISTINCT order_id), 2) AS average_items_per_order
FROM order_details;

-- ============================================================
-- SECTION 2: DATA QUALITY — NULL VALUE CHECKS
-- ============================================================

-- Check for NULLs in menu_items
SELECT
    COUNT(*) - COUNT(menu_item_id) AS null_menu_item_id,
    COUNT(*) - COUNT(item_name)    AS null_item_name,
    COUNT(*) - COUNT(category)     AS null_category,
    COUNT(*) - COUNT(price)        AS null_price
FROM menu_items;

-- Check for NULLs in order_details
SELECT
    COUNT(*) - COUNT(order_details_id) AS null_order_details_id,
    COUNT(*) - COUNT(order_id)         AS null_order_id,
    COUNT(*) - COUNT(order_date)       AS null_order_date,
    COUNT(*) - COUNT(order_time)       AS null_order_time,
    COUNT(*) - COUNT(item_id)          AS null_item_id
FROM order_details;

-- Investigate which orders are affected by NULL item IDs
SELECT
    order_id,
    COUNT(*) AS null_items
FROM order_details
WHERE item_id IS NULL
GROUP BY order_id
ORDER BY null_items DESC;

-- ============================================================
-- SECTION 3: MENU INTELLIGENCE
-- ============================================================

-- TASK 3: How many Italian dishes are on the menu?
--         What are the least and most expensive Italian dishes?

-- Italian dish count with price range
SELECT
    category,
    COUNT(menu_item_id)  AS no_of_dishes,
    MIN(price)           AS cheapest_price,
    MAX(price)           AS most_expensive
FROM menu_items
WHERE category = 'Italian'
GROUP BY category;

-- Cheapest Italian dish
WITH cte_italian AS (
    SELECT
        MIN(price) AS cheapest_price,
        MAX(price) AS most_expensive
    FROM menu_items
    WHERE category = 'Italian'
)
SELECT
    category,
    item_name,
    price
FROM menu_items
WHERE category = 'Italian'
  AND price = (SELECT cheapest_price FROM cte_italian);

-- Most expensive Italian dish
WITH cte_italian AS (
    SELECT
        MIN(price) AS cheapest_price,
        MAX(price) AS most_expensive
    FROM menu_items
    WHERE category = 'Italian'
)
SELECT
    category,
    item_name,
    price
FROM menu_items
WHERE category = 'Italian'
  AND price = (SELECT most_expensive FROM cte_italian);

-- TASK 4: How many dishes are in each category?
--         What is the average, minimum, and maximum dish price per category?
SELECT
    category,
    COUNT(DISTINCT menu_item_id) AS no_of_dishes,
    ROUND(AVG(price), 2)         AS average_price,
    MIN(price)                   AS minimum_price,
    MAX(price)                   AS maximum_price
FROM menu_items
GROUP BY category;

-- ============================================================
-- SECTION 4: ORDER BEHAVIOUR
-- ============================================================

-- TASK 5: How many orders and items were placed within the date range?
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(item_id)           AS total_items
FROM order_details;

-- TASK 6: Which order had the most items?
SELECT
    order_id,
    COUNT(item_id) AS no_of_items
FROM order_details
GROUP BY order_id
ORDER BY no_of_items DESC
LIMIT 1;

-- TASK 7: How many orders had more than 12 items?
SELECT
    COUNT(*) AS total_with_more_than_12_items
FROM (
         SELECT
             order_id,
             COUNT(item_id) AS no_of_items
         FROM order_details
         GROUP BY order_id
     ) AS order_sizes
WHERE no_of_items > 12;

-- ============================================================
-- SECTION 5: COMBINED TABLE & ITEM PERFORMANCE
-- ============================================================

-- TASK 8: Combine menu_items and order_details into a single table
--         NOTE: INNER JOIN excludes the 137 NULL item_id records
SELECT *
FROM menu_items
         INNER JOIN order_details
                    ON menu_items.menu_item_id = order_details.item_id;

-- TASK 9: Full item popularity ranking (most to least ordered)
SELECT
    mi.item_name,
    mi.category,
    COUNT(mi.item_name) AS no_of_times_ordered
FROM menu_items mi
         JOIN order_details od
              ON mi.menu_item_id = od.item_id
GROUP BY item_name, category
ORDER BY no_of_times_ordered DESC;

-- TASK 1 & 9: Most ordered item
SELECT
    mi.item_name,
    mi.category,
    COUNT(mi.item_name) AS no_of_times_ordered
FROM menu_items mi
         JOIN order_details od
              ON mi.menu_item_id = od.item_id
GROUP BY item_name, category
ORDER BY no_of_times_ordered DESC
LIMIT 1;

-- TASK 1 & 9: Least ordered item
SELECT
    mi.item_name,
    mi.category,
    COUNT(mi.item_name) AS no_of_times_ordered
FROM menu_items mi
         JOIN order_details od
              ON mi.menu_item_id = od.item_id
GROUP BY item_name, category
ORDER BY no_of_times_ordered ASC
LIMIT 1;

-- ============================================================
-- SECTION 6: REVENUE DRIVERS
-- ============================================================

-- TASK 10: Top 5 orders by total spend
SELECT
    od.order_id,
    COUNT(od.item_id)  AS no_of_items,
    SUM(mi.price)      AS total_price
FROM menu_items mi
         INNER JOIN order_details od
                    ON mi.menu_item_id = od.item_id
GROUP BY order_id
ORDER BY total_price DESC
LIMIT 5;

-- TASK 11: Items in the highest spend order
SELECT
    mi.item_name,
    mi.category       AS item_category,
    mi.price
FROM menu_items mi
         JOIN order_details od
              ON mi.menu_item_id = od.item_id
WHERE od.order_id = (
    SELECT order_id
    FROM (
             SELECT
                 od2.order_id,
                 SUM(mi2.price) AS total_price
             FROM menu_items mi2
                      JOIN order_details od2
                           ON mi2.menu_item_id = od2.item_id
             GROUP BY od2.order_id
             ORDER BY total_price DESC
             LIMIT 1
         ) AS top_order
);

-- TASK 2: Highest spend orders by item count (most items ordered)
WITH cte_max_items AS (
    SELECT
        order_id,
        COUNT(order_id)  AS no_of_items,
        SUM(price)       AS total_price
    FROM menu_items
             JOIN order_details
                  ON menu_item_id = item_id
    GROUP BY order_id
    HAVING no_of_items = (
        SELECT MAX(order_count)
        FROM (
                 SELECT COUNT(order_id) AS order_count
                 FROM menu_items
                          JOIN order_details
                               ON menu_item_id = item_id
                 GROUP BY order_id
             ) AS subquery
    )
    ORDER BY total_price DESC
)
SELECT
    od.order_id,
    mi.item_name
FROM menu_items mi
         JOIN order_details od
              ON mi.menu_item_id = od.item_id
WHERE od.order_id IN (SELECT order_id FROM cte_max_items)
GROUP BY od.order_id, mi.item_name;

-- ============================================================
-- SECTION 7: OPERATIONAL INSIGHT — TIME BIN ANALYSIS
-- ============================================================

-- Traffic, revenue, and popular category by time of day
SELECT
    time_bin,
    total_orders,
    total_items,
    total_revenue,
    avg_spend_per_item,
    (
        SELECT mi2.category
        FROM order_details od2
                 JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id
        WHERE
            CASE
                WHEN HOUR(od2.order_time) BETWEEN 9  AND 11 THEN '09:00 - 11:59 (Morning)'
                WHEN HOUR(od2.order_time) BETWEEN 12 AND 14 THEN '12:00 - 14:59 (Lunch)'
                WHEN HOUR(od2.order_time) BETWEEN 15 AND 17 THEN '15:00 - 17:59 (Afternoon)'
                WHEN HOUR(od2.order_time) BETWEEN 18 AND 20 THEN '18:00 - 20:59 (Dinner)'
                WHEN HOUR(od2.order_time) BETWEEN 21 AND 23 THEN '21:00 - 23:59 (Late Night)'
                ELSE 'Other'
                END = time_bin
        GROUP BY mi2.category
        ORDER BY COUNT(od2.item_id) DESC
        LIMIT 1
    ) AS popular_category
FROM (
         SELECT
             CASE
                 WHEN HOUR(od.order_time) BETWEEN 9  AND 11 THEN '09:00 - 11:59 (Morning)'
                 WHEN HOUR(od.order_time) BETWEEN 12 AND 14 THEN '12:00 - 14:59 (Lunch)'
                 WHEN HOUR(od.order_time) BETWEEN 15 AND 17 THEN '15:00 - 17:59 (Afternoon)'
                 WHEN HOUR(od.order_time) BETWEEN 18 AND 20 THEN '18:00 - 20:59 (Dinner)'
                 WHEN HOUR(od.order_time) BETWEEN 21 AND 23 THEN '21:00 - 23:59 (Late Night)'
                 ELSE 'Other'
                 END                             AS time_bin,
             COUNT(DISTINCT od.order_id)     AS total_orders,
             COUNT(od.item_id)               AS total_items,
             ROUND(SUM(mi.price), 2)         AS total_revenue,
             ROUND(AVG(mi.price), 2)         AS avg_spend_per_item
         FROM order_details od
                  JOIN menu_items mi ON od.item_id = mi.menu_item_id
         GROUP BY time_bin
     ) AS base
ORDER BY
    CASE time_bin
        WHEN '09:00 - 11:59 (Morning)'    THEN 1
        WHEN '12:00 - 14:59 (Lunch)'      THEN 2
        WHEN '15:00 - 17:59 (Afternoon)'  THEN 3
        WHEN '18:00 - 20:59 (Dinner)'     THEN 4
        WHEN '21:00 - 23:59 (Late Night)' THEN 5
        ELSE 6
        END;