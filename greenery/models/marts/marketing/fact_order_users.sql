{{
    config(
        materialized="table"
    )
}}

WITH user_orders AS (
    SELECT 
    u.user_id
    ,COUNT(DISTINCT order_id) AS num_purchased
    ,SUM(order_cost) total_amt
    ,AVG(order_cost) avg_amt
    ,MIN(order_cost) min_amt
    ,MAX(order_cost) max_amt
FROM {{ref('dim_users')}} u
LEFT JOIN {{ref('stg_orders')}} o USING(user_id)
GROUP BY 1
)

SELECT 
    user_orders.*
    ,CASE WHEN num_purchased >= 2 THEN 1 ELSE 0 END AS frequent_ind
FROM user_orders