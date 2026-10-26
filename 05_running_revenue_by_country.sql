-- Cumulative revenue per country over time (SUM OVER with PARTITION + ORDER).
WITH monthly AS (
  SELECT c.country, strftime('%Y-%m', o.order_date) AS month,
         SUM(oi.quantity * p.price * (1 - oi.discount)) AS revenue
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.status = 'completed'
  GROUP BY c.country, month
)
SELECT country, month, ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (PARTITION BY country ORDER BY month), 2) AS running_total
FROM monthly
ORDER BY country, month;
