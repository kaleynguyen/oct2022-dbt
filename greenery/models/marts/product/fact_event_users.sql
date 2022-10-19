{{config(
    materialized='table'
)}}

SELECT
    user_id
    , u.first_name
    , u.last_name
    , u.zipcode
    , MIN(e.created_at_utc) last_session
    , MAX(e.created_at_utc) first_session
    , SUM("package_shipped") package_shipped
    , SUM("page_view") page_view
    , SUM("add_to_cart") add_to_cart
    , SUM("checkout") checkout
    , SUM(order_total) AS order_total
    , SUM(num_orders) AS num_orders
    , COUNT(distinct session_id) AS num_unique_session
    , ROUND(SUM(num_orders)/COUNT(DISTINCT session_id)::NUMERIC,2) AS order_session_ratio
    , ROUND(SUM(num_orders)/SUM("page_view")::NUMERIC,2) as order_pageview_ratio
FROM {{ref("int_event_types")}} e
LEFT JOIN {{ref("dim_users")}} u USING(user_id)
LEFT JOIN {{ref("fact_orders")}} o USING(user_id)
GROUP BY 1,2,3,4
