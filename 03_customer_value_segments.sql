-- Customer lifetime value and spend segments (CTE + NTILE).
WITH clv AS (
  SELECT c.customer_id, c.country,
         COUNT(DISTINCT o.order_id) AS orders,
         SUM(oi.quantity * p.price * (1 - oi.discount)) AS total_spent
  FROM customers c
  JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'completed'
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p ON p.product_id = oi.product_id
  GROUP BY c.customer_id, c.country
),
seg AS (
  SELECT *, NTILE(4) OVER (ORDER BY total_spent DESC) AS quartile FROM clv
)
SELECT CASE quartile WHEN 1 THEN 'Top 25%' WHEN 2 THEN 'Upper-mid' WHEN 3 THEN 'Lower-mid' ELSE 'Bottom 25%' END AS segment,
       COUNT(*) AS customers,
       ROUND(AVG(orders), 1) AS avg_orders,
       ROUND(SUM(total_spent), 2) AS segment_revenue,
       ROUND(100.0 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 1) AS pct_of_revenue
FROM seg
GROUP BY quartile
ORDER BY quartile;
