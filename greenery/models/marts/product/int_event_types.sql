SELECT 
    user_id
    , session_id
    , created_at_utc
    , {{ dbt_utils.pivot('event_type', dbt_utils.get_column_values(ref('stg_events'), 'event_type')) }}
    , COUNT(distinct order_id) as num_orders
FROM {{ref("stg_events")}}
GROUP BY 1,2,3
