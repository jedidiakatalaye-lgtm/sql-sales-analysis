-- Cancellation and return rates per product category (conditional aggregation).
SELECT p.category,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN o.status = 'cancelled' THEN o.order_id END)
             / COUNT(DISTINCT o.order_id), 1) AS cancelled_pct,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN o.status = 'returned' THEN o.order_id END)
             / COUNT(DISTINCT o.order_id), 1) AS returned_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY returned_pct DESC;
