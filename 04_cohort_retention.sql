-- Cohort retention: customers grouped by first completed-order month,
-- and how many are still ordering 0-3 months later.
WITH first_orders AS (
  SELECT customer_id, MIN(strftime('%Y-%m', order_date)) AS cohort
  FROM orders WHERE status = 'completed' GROUP BY customer_id
),
activity AS (
  SELECT DISTINCT customer_id, strftime('%Y-%m', order_date) AS m
  FROM orders WHERE status = 'completed'
),
joined AS (
  SELECT f.cohort,
         (CAST(substr(a.m,1,4) AS INT)*12 + CAST(substr(a.m,6,2) AS INT))
         - (CAST(substr(f.cohort,1,4) AS INT)*12 + CAST(substr(f.cohort,6,2) AS INT)) AS months_since,
         a.customer_id
  FROM first_orders f JOIN activity a ON a.customer_id = f.customer_id
)
SELECT cohort, months_since, COUNT(DISTINCT customer_id) AS active_customers
FROM joined
WHERE months_since BETWEEN 0 AND 3
GROUP BY cohort, months_since
ORDER BY cohort, months_since;
