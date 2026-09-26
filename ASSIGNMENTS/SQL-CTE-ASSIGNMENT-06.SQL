
-- ========== CTE ASSIGNMENT ===========
-- 6.1 — Rewrite this derived table query as a CTE.

WITH store_counts AS
(
    SELECT
        store_id,
        COUNT(*) AS order_count
    FROM sales.orders
    GROUP BY store_id
)
SELECT AVG(order_count) AS avg_orders
FROM store_counts;


-- 6.2 — Write a CTE called cte_high_value_products that returns
-- products with list_price > 2000.
-- Then query the CTE to return only Mountain Bikes from that list,
-- joining to production.categories.

WITH cte_high_value_products AS
(
    SELECT
        product_id,
        product_name,
        category_id,
        list_price
    FROM production.products
    WHERE list_price > 2000
)
SELECT
    p.product_id,
    p.product_name,
    p.list_price,
    c.category_name
FROM cte_high_value_products AS p
INNER JOIN production.categories AS c
    ON p.category_id = c.category_id
WHERE c.category_name = 'Mountain Bikes';


-- 6.3 — Write two CTEs in one WITH clause:
-- one that counts orders per customer,
-- and one that sums revenue per customer.
-- Join them in the outer query.

WITH customer_orders AS
(
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM sales.orders
    GROUP BY customer_id
),
customer_revenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT
    co.customer_id,
    co.order_count,
    cr.total_revenue
FROM customer_orders AS co
INNER JOIN customer_revenue AS cr
    ON co.customer_id = cr.customer_id;


-- 6.4 — Using a recursive CTE, generate a list of numbers from 1 to 10.
-- Each row should have the number and its square.

WITH Numbers AS
(
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM Numbers
    WHERE n < 10
)
SELECT
    n,
    n * n AS square
FROM Numbers
OPTION (MAXRECURSION 10);


-- 6.5 — Using a recursive CTE, show the manager's first_name
-- alongside each employee.
-- Also add a level column:
-- 0 = top manager
-- 1 = direct reports
-- 2 = next level down

WITH OrgChart AS
(
    -- Anchor member: top manager
    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        s.manager_id,
        CAST(NULL AS VARCHAR(50)) AS manager_first_name,
        0 AS level
    FROM sales.staffs AS s
    WHERE s.manager_id IS NULL

    UNION ALL

    -- Recursive member: employees under each manager
    SELECT
        e.staff_id,
        e.first_name,
        e.last_name,
        e.manager_id,
        m.first_name AS manager_first_name,
        oc.level + 1 AS level
    FROM sales.staffs AS e
    INNER JOIN OrgChart AS oc
        ON e.manager_id = oc.staff_id
    INNER JOIN sales.staffs AS m
        ON e.manager_id = m.staff_id
)
SELECT
    staff_id,
    first_name,
    last_name,
    manager_first_name,
    level
FROM OrgChart
ORDER BY level, staff_id;


-- 6.6 — Think About It:
-- A CTE is defined once but referenced twice in the same outer query.
-- Is it guaranteed that the CTE result is computed only once?

-- Answer:
-- No, this claim is not necessarily accurate.
-- A CTE does not guarantee that the database computes the result only once.
-- SQL Server may evaluate the CTE multiple times depending on the execution plan.
-- If the result genuinely needs to be computed once and reused,
-- a temporary table can be used.

SELECT *
INTO #temp_products
FROM production.products
WHERE list_price > 2000;

SELECT *
FROM #temp_products;

SELECT COUNT(*)
FROM #temp_products;
```
