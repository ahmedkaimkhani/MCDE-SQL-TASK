
-- Task 20:  Count how many products exist in each category. Show category name and product count.

SELECT COUNT(P.product_name),
c.category_name
FROM
production.categories AS c
INNER JOIN production.products AS p
ON c.category_id = p.category_id
GROUP BY c.category_name

-- Task 21:  Find the average list price of products per brand.

SELECT AVG(p.list_price) AS avg_price,
b.brand_name
FROM 
production.products AS p
LEFT JOIN production.brands AS b
ON p.brand_id = b.brand_id
GROUP BY b.brand_name

-- Task 22:  For each store, count the total number of orders.

SELECT COUNT(o.order_status),
s.store_name
FROM 
sales.stores AS s
INNER JOIN sales.orders AS o
ON s.store_id = o.store_id
GROUP BY s.store_name

-- Task 23:  Find the total revenue per order. Revenue = quantity × list_price × (1 - discount).

SELECT oi.order_id ,
SUM (oi.quantity * p.list_price * (1 - oi.discount)) AS Revenue
FROM
sales.order_items AS oi
LEFT JOIN production.products AS p
ON oi.product_id = p.product_id
GROUP BY oi.order_id
ORDER BY OI.order_id ASC

-- Task 24:  Find each customer's total number of orders. Sort by order count descending.

SELECT c.customer_id,
COUNT (o.order_id) AS order_count
FROM 
sales.customers AS c
LEFT JOIN sales.orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY order_count DESC

-- Task 25:  Find the brand that has the highest average product price.

SELECT TOP 1
b.brand_name,
AVG (p.list_price) highest_avg_pp
FROM 
production.brands AS b
LEFT JOIN production.products AS p
ON b.brand_id = P.brand_id
GROUP BY b.brand_name
ORDER BY highest_avg_pp DESC 

-- Task 26:  List categories that have more than 50 products.

SELECT c.category_name ,
COUNT (p.product_name) FROM 
production.categories AS c
LEFT JOIN production.products AS p
ON c.category_id = p.category_id
GROUP BY c.category_name
HAVING COUNT (p.product_name) > 50

-- Task 27:  For each store, find the total revenue generated across all orders.

SELECT s.store_name,
SUM (oi.quantity * p.list_price * (1 - oi.discount)) AS total_revenue
FROM 
sales.stores AS s
LEFT JOIN sales.orders AS o
ON s.store_id = o.store_id
LEFT JOIN sales.order_items AS oi
ON o.order_id = oi.order_id
LEFT JOIN production.products AS p
ON oi.product_id = p.product_id
GROUP BY s.store_name

-- Task 28:  Find how many orders each staff member handled, and show only those who handled more than 50 orders.

SELECT s.first_name+ ' ' +s.last_name AS full_name,
s.staff_id ,
COUNT (o.order_status) AS orders_handled FROM
SALES.orders AS o
LEFT JOIN sales.staffs AS s
ON o.staff_id = s.staff_id
GROUP BY s.staff_id, s.first_name+ ' ' +s.last_name
HAVING COUNT (o.order_status) > 100
