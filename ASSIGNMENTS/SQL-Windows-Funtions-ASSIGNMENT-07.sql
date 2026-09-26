```sql
-- =========================================================
-- 7.1
-- Assign a sequential row number to each product ordered
-- by list_price descending.
-- Then assign a second row number partitioned by category_id.
-- =========================================================

SELECT
    product_id,
    product_name,
    category_id,
    list_price,
    ROW_NUMBER() OVER (
        ORDER BY list_price DESC
    ) AS overall_row_number,
    ROW_NUMBER() OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS category_row_number
FROM production.products;


-- 7.2
-- Return each product with RANK() and DENSE_RANK()
-- by list_price descending within its category.

SELECT
    product_id,
    product_name,
    category_id,
    list_price,
    RANK() OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS price_rank,
    DENSE_RANK() OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS price_dense_rank
FROM production.products;


-- Show products where RANK() and DENSE_RANK() differ.

WITH ranked_products AS
(
    SELECT
        product_id,
        product_name,
        category_id,
        list_price,
        RANK() OVER (
            PARTITION BY category_id
            ORDER BY list_price DESC
        ) AS price_rank,
        DENSE_RANK() OVER (
            PARTITION BY category_id
            ORDER BY list_price DESC
        ) AS price_dense_rank
    FROM production.products
)
SELECT
    product_id,
    product_name,
    category_id,
    list_price,
    price_rank,
    price_dense_rank
FROM ranked_products
WHERE price_rank <> price_dense_rank;


-- 7.3
-- Calculate month-over-month revenue change for each store.

WITH monthly_revenue AS
(
    SELECT
        o.store_id,
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) AS current_month_revenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.store_id,
        YEAR(o.order_date),
        MONTH(o.order_date)
)
SELECT
    store_id,
    order_year,
    order_month,
    current_month_revenue,
    LAG(current_month_revenue) OVER (
        PARTITION BY store_id
        ORDER BY order_year, order_month
    ) AS previous_month_revenue,
    current_month_revenue
    - LAG(current_month_revenue) OVER (
        PARTITION BY store_id
        ORDER BY order_year, order_month
    ) AS revenue_difference
FROM monthly_revenue
ORDER BY
    store_id,
    order_year,
    order_month;


-- 7.4
-- Divide all products into five price bands.

SELECT
    product_id,
    product_name,
    list_price,
    NTILE(5) OVER (
        ORDER BY list_price
    ) AS price_band
FROM production.products
ORDER BY list_price;


-- 7.5
-- Show each order with a running total of revenue.

WITH order_revenue AS
(
    SELECT
        o.order_id,
        o.order_date,
        SUM(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) AS order_revenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.order_date
)
SELECT
    order_id,
    order_date,
    order_revenue,
    SUM(order_revenue) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM order_revenue
ORDER BY
    order_date,
    order_id;


-- 7.6
-- Think About It:
-- Why does LAST_VALUE() require the full window frame?

-- Answer:
-- When ORDER BY is specified, the default window frame is:
-- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--
-- FIRST_VALUE() works correctly with the default frame
-- because the first row is included in the frame.
--
-- LAST_VALUE() returns the last value within the current frame.
-- Since the default frame ends at CURRENT ROW, it may return
-- the current row's value instead of the actual last value.
--
-- Therefore, LAST_VALUE() needs:
-- RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
--
-- Example:

SELECT
    product_id,
    product_name,
    category_id,
    list_price,
    FIRST_VALUE(list_price) OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
    ) AS first_price,
    LAST_VALUE(list_price) OVER (
        PARTITION BY category_id
        ORDER BY list_price DESC
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_price
FROM production.products;
```
