 -- ====== SECTION # 05 = Subqueries ======

 -- Task 29:  Find all products whose list price is above the overall average list price.

SELECT product_name, list_price
FROM production.products
WHERE list_price > (
    SELECT AVG(list_price)
    FROM production.products
);

-- Task 30: Find customers who have never placed an order.

SELECT c.customer_id,
       c.first_name + ' ' + c.last_name AS full_name
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Task 31: List the most expensive product in each category.

SELECT p.product_name,
       p.list_price,
       c.category_name
FROM production.products AS p
INNER JOIN production.categories AS c
ON p.category_id = c.category_id
WHERE p.list_price = (
    SELECT MAX(p2.list_price)
    FROM production.products AS p2
    WHERE p2.category_id = p.category_id
);

-- Task 32: Find staff members who work in the store that generated the most revenue.

SELECT s.first_name + ' ' + s.last_name AS full_name,
       st.store_name
FROM sales.staffs AS s
INNER JOIN sales.stores AS st
ON s.store_id = st.store_id
WHERE st.store_id = (
    SELECT TOP 1 o.store_id
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
    INNER JOIN production.products AS p
    ON oi.product_id = p.product_id
    GROUP BY o.store_id
    ORDER BY SUM(oi.quantity * p.list_price * (1 - oi.discount)) DESC
);

-- Task 33: Find orders where the total order value exceeds 5000.

SELECT oi.order_id,
       SUM(oi.quantity * p.list_price * (1 - oi.discount)) AS total_order_value
FROM sales.order_items AS oi
INNER JOIN production.products AS p
ON oi.product_id = p.product_id
GROUP BY oi.order_id
HAVING SUM(oi.quantity * p.list_price * (1 - oi.discount)) > 5000;

-- Task 34: List products that have never been ordered by any customer.

SELECT p.product_id,
       p.product_name
FROM production.products AS p
LEFT JOIN sales.order_items AS oi
ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- Task 35: Find the customer who has spent the most money overall.

SELECT TOP 1
       c.customer_id,
       c.first_name + ' ' + c.last_name AS full_name,
       SUM(oi.quantity * p.list_price * (1 - oi.discount)) AS total_spent
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customer_id = o.customer_id
INNER JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
INNER JOIN production.products AS p
ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;