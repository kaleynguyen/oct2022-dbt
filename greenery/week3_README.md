# Part 1: 
conversion rate = #uniq session with a purchase event / #uniq session

* Overall conversion rate: The overall conversion rate is 62.46%

```sql
SELECT
  ROUND(COUNT(DISTINCT CASE WHEN event_type='checkout' THEN session_id END)/
    COUNT(DISTINCT session_id)::NUMERIC, 4)*100 conversion_rate
FROM stg_events
```
* Conversion rate by product

|NAME | CONVERSION_RATE|
|-----|----------------|
|String of pearls | 60.94|
|Arrow Head | 55.56|
|Cactus | 54.55|
|ZZ Plant | 53.97|
|Bamboo | 53.73|
|Rubber Plant | 51.85|
|Monstera | 51.02|
|Calathea Makoyana | 50.94|
|Fiddle Leaf Fig | 50.|
|Majesty Palm | 49.25|
|Aloe Vera | 49.23|
|Devil's Ivy | 48.89|
|Philodendron | 48.39|
|Jade Plant | 47.83|
|Pilea Peperomioides | 47.46|
|Spider Plant | 47.46|
|Dragon Tree | 46.77|
|Money Tree | 46.43|
|Orchid | 45.33|
|Bird of Paradise | 45.00|
|Ficus | 42.65|
|Birds Nest Fern | 42.31|
|Pink Anthurium | 41.89|
|Boston Fern | 41.27|
|Alocasia Polly | 41.18|
|Peace Lily | 40.91|
|Ponytail Palm | 40.00|
|Snake Plant | 39.73|
|Angel Wings Begonia | 39.34|
|Pothos | 34.43|


```sql
WITH checkout AS (
SELECT
  oi.product_id
  ,COUNT(DISTINCT CASE WHEN event_type='checkout' THEN session_id END) buy_uniq_sessions
from stg_events e
LEFT JOIN stg_order_items oi ON oi.order_id = e.order_id
GROUP BY 1)

, pageview AS (
SELECT
  p.product_id
  ,COUNT(DISTINCT CASE WHEN event_type='page_view' THEN session_id END) view_uniq_sessions
FROM stg_events e
LEFT JOIN stg_products p ON p.product_id = e.product_id
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
JOIN stg_products p USING(product_id)
)

SELECT name, conversion_rate 
FROM final
ORDER BY conversion_rate DESC;
```
**High conversion rate plants**
- Fragile plants
- Rare plants
- Excellent shipping / wrapping conditions after arrival
- Better weather during shipping

**Low conversion rate plants**
- Hardy plants => users already bought the plants and they are easy to take care of. 
- Easy to find plants so users can buy them elsewhere or at the store. 
- Bad shipping / wrapping conditions after arrival 
- Too hot / too cold weather that leads to damaged plants. 

# Part 2: macro

# Part 3: Post hook
# Part 4: dbt package
# Part 5: dbt snapshots 
