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

I tried to resize the warehouse based on the lecture but I do not have a sufficient privilege to do. 

```sql
{% macro warehouse_resize(prod_size, stage_size) %}

  {% if target.name == "prod" %}
  ALTER WAREHOUSE {{ target.warehouse }} SET WAREHOUSE_SIZE = {{ prod_size }};

  {% else %}
  ALTER WAREHOUSE {{ target.warehouse }} SET WAREHOUSE_SIZE = {{ stage_size }};

  {% endif %}

{% endmacro %}
```

# Part 3: Post hook (SQL that is run after a model, seed or snapshot)

I use the macro to grant SELECT on the model to the role 'reporting' after each model is run. 

```sql
{% macro grant(role) %}
  {% set sql %}
      GRANT USAGE ON SCHEMA {{ schema }} TO ROLE {{ role }};
      {% if role == "sysadmin" %}
       GRANT SELECT, UPDATE, TRIGGER ON {{ this }} TO ROLE {{ role }};
      {% else %} 
        GRANT SELECT ON {{ this }} TO ROLE {{ role }};
      {% endif %}
    {% endset %}
  {% set table = run_query(sql) %}
{% endmacro %}
```
# Part 4: dbt package

I installed dbt_utls, dbt_expectations and codegen package and used dbt_utils to spread the column event_type from long to wide.

```sql
{{ dbt_utils.pivot('event_type', dbt_utils.get_column_values(ref('stg_events'), 'event_type')) }}
```
 
# Part 5: dbt snapshots 

These 3 packages are shipped:

* '8385cfcd-2b3f-443a-a676-9756f7eb5404'
* 'e24985f3-2fb3-456e-a1aa-aaf88f490d70'
* '5741e351-3124-4de7-9dff-01a448e7dfd4'