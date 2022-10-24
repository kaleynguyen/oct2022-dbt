WITH checkout AS (
SELECT
  oi.product_id
  ,COUNT(DISTINCT CASE WHEN event_type='checkout' THEN session_id END) buy_uniq_sessions
from {{ref('stg_events')}} e
LEFT JOIN {{ref('stg_order_items')}} oi ON oi.order_id = e.order_id
GROUP BY 1)

, pageview AS (
SELECT
  p.product_id
  ,COUNT(DISTINCT CASE WHEN event_type='page_view' THEN session_id END) view_uniq_sessions
FROM {{ref('stg_events')}} e
LEFT JOIN {{ref('stg_products')}} p ON p.product_id = e.product_id
GROUP BY 1
)

, final AS (
SELECT 
  p.name
  ,buy_uniq_sessions
  ,view_uniq_sessions
  ,ROUND(buy_uniq_sessions/view_uniq_sessions::numeric,4)*100 conversion_rate
  ,RANK() OVER(ORDER BY 
              ROUND(buy_uniq_sessions/view_uniq_sessions::numeric,4)*100 DESC) rnk
FROM pageview 
JOIN checkout USING(product_id)
JOIN {{ref('stg_products')}} p USING(product_id)
)

SELECT name, conversion_rate 
FROM final
ORDER BY conversion_rate DESC