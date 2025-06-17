-- ======================================================
-- Project: 🍕 Pizza Hut Sales Analysis (SQL Project)
-- Author: Nihar Karia
-- Date: June 2025
-- Description: Analyze Pizza Hut sales data to derive insights on 
			 -- revenue, pizza popularity, order trends, and more.
-- Tools Used: MySQL
-- Dataset: pizza_sales
-- ======================================================

-- ======================================================
-- 🧠 BASIC ANALYSIS
-- ======================================================

-- 1. Total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- 2. Total revenue generated
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;

-- 3. Highest-priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(orders_details.orders_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5. Top 5 most ordered pizzas
SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- ======================================================
-- 📊 INTERMEDIATE ANALYSIS
-- ======================================================

-- 6. Quantity of each pizza category
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 7. Orders by hour
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- 8. Category-wise distribution of pizzas
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- 9. Average pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0) as avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- 10. Top 3 pizzas by revenue
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- ======================================================
-- 🚀 ADVANCED ANALYSIS
-- ======================================================

-- 11. % revenue by pizza type
SELECT 
    pizza_types.category,
    ROUND((SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    orders_details
                        JOIN
                    pizzas ON pizzas.pizza_id = orders_details.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- 12. Cumulative revenue over time
SELECT order_date, 
SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM
 (SELECT 
    orders.order_date,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS sales;

-- 13. Top 3 pizzas by revenue per category
SELECT name, revenue
FROM
(select category, name, revenue, 
rank() over(partition by category order by revenue desc) as rn
from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) AS a) AS b
WHERE rn <= 3;


-- ======================================================
-- ✅ CONCLUSION
-- ======================================================
-- - Total orders placed: 21,350
-- - Total revenue generated: $817,860.05
-- - Highest-priced pizza: "The Greek Pizza" at $35.95
-- - Most commonly ordered pizza size: Large
-- - Best-selling pizzas (by quantity): 
--     1. "The Classic Deluxe Pizza"
--     2. "The Barbecue Chicken Pizza"
--     3. "The Hawaiian Pizza"
--     4. "The Pepperoni Pizza"
--     5. "The Thai Chicken Pizza"
-- - Highest revenue generated by: "The Thai Chicken Pizza"
-- - Most popular category: "Classic had the highest sales volume, 
--                           while Supreme offered the most variety"
-- - Peak order time: 12 PM to 1 PM
-- - Daily average pizzas sold: ~138
-- - Cumulative revenue showed steady growth over time
-- - Premium pizzas such as Deluxe and Supreme were among the 
--   top-selling, though chicken-based pizzas clearly dominated total revenue.
-- ======================================================
