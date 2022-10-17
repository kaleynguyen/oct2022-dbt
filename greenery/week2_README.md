
#Part 1: Models

## 1. What is our user repeat rate?

repeat rate = users who purchased 2 or more times / users who purchased

```sql
SELECT count(distinct user_id) / (select count(distinct user_id) from stg_orders)::FLOAT
FROM (
    SELECT user_id, 
            SUM(CASE WHEN order_id IS NOT NULL THEN 1 ELSE 0 END) AS cnt_order
    FROM stg_orders
    GROUP BY 1
) AS a WHERE a.cnt_order >= 2
```

The repeat rate is approximately 0.80 (rounded up)

## 2. What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?

**Good indicators**
* A user who has purchased two or more times
* Frequent website visit, visit to order conversion 
* Number of purchases / time between purchases. The larger the ratio, the better.
* Number of item purchased
* Total spend / average spend
* Same item purchases over time.

**Not good indicators**
* Low website visit, low visit to order conversion
* Only one purchase with promo code or all purchased have promo codes.
* Low total spend  / average spend ratio 

**Other features**
* Net promoter score survey result / any other survey result to measure customer loyalty and rate the likelihood that a customer would recommend Greenery to their family or friends. 
* User site feedback 
* Returned customer data / New customers ratio
* Seasonal related data points. 

**Other analysis**
- cohort: compare the revenue by the month customers arrived to measure how quickly the revenue declines. Identify the month that dilutes the overall health of the metrics based on the differences in the cohort table. 
- segmentation: compare similar groups of customers at a point in time to see which group is more likely to purchase.
- A/B testing: need enough traffic and may have to implement multivariate testings with bonferroni correction or multi-arm bandit.

## 3. Build int_, dim_ and fact_model

**core**
- dim_users: users info + addresses
- fact_orders: orders info + addresses + promo codes
- dim_products: products info + number of orders + quantities ordered

All of the models in the core team uses an **order** as the grain of the business. Both the dim_users and dim_products model are just metadata about the users and products; the fact_orders model contains all information about each order and the associated promo codes and addreses for further analysis such as geospatial analysis or promotion rollout. 

**marketing**
- fact_order_users: users + summary stats about the orders + frequent ind when the number of orders >= 2.

**product**
- int_event_types: pivot event_type's levels to columns
- fact_event_users: user + his/her first/last session + total event type (number of sessions/page-views/checkouts/add_to_cart/package_shipped) + total orders + number of orders + order to session/pageview ratio.
- int_event_summary
