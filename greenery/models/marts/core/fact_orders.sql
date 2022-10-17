{{
    config(
        materialized="table"
    )
}}
SELECT 
    o.order_id
    ,o.user_id
    ,o.created_at AS order_created_at_utc
    ,o.order_cost
    ,o.shipping_cost
    ,o.order_total
    ,o.tracking_id
    ,o.shipping_service
    ,o.estimated_delivery_at AS order_estimated_at_utc
    ,o.delivered_at AS order_delivered_at_utc
    ,o.status AS order_status
    ,a.address
    ,a.zipcode
    ,a.state
    ,a.country
    ,p.promo_id
    ,p.discount AS promo_discount
    ,p.status AS promo_status
FROM {{ref("stg_orders")}} o 
LEFT JOIN {{ref("stg_addresses")}} a USING(address_id)
LEFT JOIN {{ref("stg_promos")}} p USING(promo_id)