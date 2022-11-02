
WITH seasons AS (
    SELECT 
    session_id
    , DATE_TRUNC('hour', created_at_utc) hour_trunc
    , DATE_TRUNC('day', created_at_utc) day_trunc
    , event_type
FROM {{ref("stg_events")}})

, hourly AS (
    SELECT 
        hour_trunc AS dt_truncation
        , COUNT(DISTINCT session_id) uniq_sessions
        , COUNT(DISTINCT CASE WHEN event_type='page_view' THEN session_id END) uniq_pv
        , COUNT(DISTINCT CASE WHEN event_type='add_to_cart' THEN session_id END) uniq_atc
        , COUNT(DISTINCT CASE WHEN event_type='checkout' THEN session_id END) uniq_checkout
        , 'hourly'  AS time_ind
        FROM seasons
    GROUP BY 1
)
, daily AS (
    SELECT 
        day_trunc as dt_truncation
        , COUNT(DISTINCT session_id) uniq_sessions
        , COUNT(DISTINCT CASE WHEN event_type='page_view' THEN session_id END) uniq_pv
        , COUNT(DISTINCT CASE WHEN event_type='add_to_cart' THEN session_id END) uniq_atc
        , COUNT(DISTINCT CASE WHEN event_type='checkout' THEN session_id END) uniq_checkout
        , 'daily' as time_ind
    FROM seasons
    GROUP BY 1
)
SELECT *
FROM hourly
UNION ALL 
SELECT * 
FROM daily