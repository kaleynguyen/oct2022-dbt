# 1. How many users do we have?
```sql
select count (distinct user_id) from stg_users;
```

We have 130 unique users. 

# 2. On average, how many orders do we receive per hour?
```sql
SELECT AVG(total_order_hourly)
FROM 
(
  SELECT DATE_TRUNC('hour', created_at)
  , COUNT(DISTINCT order_id) total_order_hourly
  FROM stg_orders
  GROUP BY 1
) a
```
On average, we have 7.52 orders that we receive per hour. 

# 3. On average, how long does an order take from being placed to being delivered?

```sql
SELECT AVG(time_to_delivery) 
FROM (
    SELECT DATEDIFF(day, created_at, delivered_at) AS time_to_delivery
    FROM stg_orders
    WHERE delivered_at IS NOT NULL
) a
```
On average, it takes 3.9 days from being placed (created at) to being delivered (delivered at)

# 4. How many users have only made one purchase? Two purchases? Three+ purchases?

> Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.
```sql
SELECT COUNT(user_id) 
FROM (SELECT user_id, max(a.rn) max_rn
      FROM (SELECT user_id, 
            ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY order_id) rn
            FROM stg_orders) a 
      GROUP BY user_id) b 
WHERE b.max_rn >= 3 // or =1 or =2 
```

* One purchase: 25
* Two purchases: 28
* Three+ purchases: 71

# 5. On average, how many unique sessions do we have per hour?
```sql
SELECT AVG(cnt_session) FROM (
  SELECT DATE_TRUNC('hour', created_at_utc), 
      COUNT(DISTINCT session_id) AS cnt_session
  FROM stg_events
  GROUP BY 1
) a
```
On average, we have 16.3 unique sessions we have per hour. 
