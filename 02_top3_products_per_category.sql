-- Top 3 products by revenue in each category (ROW_NUMBER with PARTITION BY).
WITH product_rev AS (
  SELECT p.category, p.name,
         SUM(oi.quantity * p.price * (1 - oi.discount)) AS revenue
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id AND o.status = 'completed'
  JOIN products p ON p.product_id = oi.product_id
  GROUP BY p.category, p.name
),
ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
  FROM product_rev
)
SELECT category, name, ROUND(revenue, 2) AS revenue, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;
