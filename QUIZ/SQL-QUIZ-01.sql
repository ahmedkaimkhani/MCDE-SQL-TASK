-- ===== SQL QUIZ =====

--	Q1
SELECT c.first_name+ ' ' +c.last_name AS costumer_name,
o.order_id,
s.store_name,
st.first_name+ ' ' +st.last_name as staff_name
FROM
sales.orders o
LEFT JOIN sales.customers c
ON o.customer_id = c.customer_id
LEFT JOIN sales.stores as s
ON o.store_id = s.store_id
LEFT JOIN sales.staffs as st
ON s.store_id = st.store_id

-- Q2

SELECT p.product_name,
b.brand_name,
c.category_name
FROM
production.products as p
LEFT JOIN production.brands as b
ON p.brand_id = b.brand_id
LEFT JOIN production.categories as c
ON c.category_id = p.category_id

-- Q3

SELECT c.first_name+ ' ' +c.last_name as full_name,
c.city,
c.email
FROM 
sales.customers as c
LEFT JOIN sales.orders as o
ON c.customer_id = o.customer_id
WHERE o.order_status  IS NULL

-- Q4
SELECT
    s.store_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.orders o
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
JOIN sales.stores s
    ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_revenue DESC;

-- Q5

SELECT
    b.brand_name,
    COUNT(p.product_id) AS number_of_products,
    AVG(p.list_price) AS average_list_price,
    MAX(p.list_price) AS highest_list_price
FROM production.products p
JOIN production.brands b
    ON p.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING COUNT(p.product_id) > 5;

-- Q6

SELECT
    MONTH(o.order_date) AS order_month,
    COUNT(DISTINCT o.order_id) AS number_of_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.orders o
JOIN sales.order_items oi
    ON o.order_id = oi.order_id
WHERE YEAR(o.order_date) = 2017
GROUP BY MONTH(o.order_date)
ORDER BY order_month;

-- Q7

SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.list_price
FROM production.products p
WHERE p.list_price > (
    SELECT AVG(p2.list_price)
    FROM production.products p2
    WHERE p2.category_id = p.category_id
);

-- Q8

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS number_of_orders
FROM sales.customers c
JOIN sales.orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(order_id) AS order_count
        FROM sales.orders
        GROUP BY customer_id
    ) AS customer_orders
);

-- Q9

WITH CustomerSpend AS
(
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spend
    FROM sales.customers c
    JOIN sales.orders o
        ON c.customer_id = o.customer_id
    JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
),
CustomerLabel AS
(
    SELECT
        *,
        CASE
            WHEN total_spend > (SELECT AVG(total_spend) FROM CustomerSpend)
                THEN 'High'
            ELSE 'Regular'
        END AS customer_type
    FROM CustomerSpend
)
SELECT TOP 10
    customer_id,
    first_name,
    last_name,
    total_spend,
    RANK() OVER (ORDER BY total_spend DESC) AS spend_rank,
    customer_type
FROM CustomerLabel
ORDER BY total_spend DESC;

-- Q10

WITH ProductSales AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(oi.quantity) AS total_quantity
    FROM production.products p
    JOIN sales.order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,s
        p.product_name,
        p.category_id
),
RankedProducts AS
(
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category_id
            ORDER BY total_quantity DESC
        ) AS rn
    FROM ProductSales
),
Stock AS
(
    SELECT
        product_id,
        SUM(quantity) AS available_stock
    FROM production.stocks
    GROUP BY product_id
)
SELECT
    c.category_name,
    r.product_name,
    r.total_quantity AS units_sold,
    COALESCE(s.available_stock, 0) AS available_stock
FROM RankedProducts r
JOIN production.categories c
    ON r.category_id = c.category_id
LEFT JOIN Stock s
    ON r.product_id = s.product_id
WHERE r.rn = 1
ORDER BY c.category_name;