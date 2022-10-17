{{
    config(
        materialized="table"
    )
}}
SELECT 
    p.product_id,
    name,
    price,
    inventory,
    COUNT(distinct oi.order_id) AS time_orders,
    SUM(oi.quantity) AS quantities_ordered
FROM {{ref('stg_products')}} p
LEFT JOIN {{ref('stg_order_items')}} oi
    USING(product_id)
GROUP BY 1,2,3,4