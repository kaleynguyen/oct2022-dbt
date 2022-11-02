# Part 1. dbt Snapshots 

```sql
SELECT * FROM orders_snapshot WHERE order_id IN 
    (   select order_id from orders_snapshot 
        where dbt_valid_from 
        is null 
            and dbt_valid_to is not NULL)
```

The following ORDER_ID's went from preparing to shipped status:
   
* 38c516e8-b23a-493a-8a5c-bf7b2b9ea995
* aafb9fbd-56e1-4dcc-b6b2-a3fd91381bb6
* d1020671-7cdf-493c-b008-c48535415611

# Part 2. Modeling  

## 1: Additional dbt models to find

### Daily
* Sessions with event type 'page_view' (awareness): 87%
* Sessions with event type 'add_to_cart' (purchase intent): 70%
* Sessions with event type 'checkout' (purchase): 54%

### Hourly
* Sessions with event type 'page_view' (awareness): 64%
* Sessions with event type 'add_to_cart' (purchase intent): 51%
* Sessions with event type 'checkout' (purchase): 38%

```sql
select 
sum(uniq_sessions) total_uniq_sessions, 
sum(uniq_pv)/total_uniq_sessions::numeric * 100, 
sum(uniq_atc) / total_uniq_sessions::numeric * 100,
sum(uniq_checkout) / total_uniq_sessions::numeric * 100, 
from product_funnel
where time_ind = 'daily' #or daily 
```

Suprisingly, daily sessions are overestimating the hourly sessions. It would be better to segment the conversion rates based on the same unit of time and compare it with similar previous unit of time. For example, daily conversion rate of the same day of the last month versus this month, daily conversion rate of the same week of last year versus this year, or hourly conversion rate of the same time of the day today versus yesterday. 

# Part 3: Reflection

* if your organization is thinking about using dbt, how would you pitch the value of dbt/analytics engineering to a decision maker at your organization? I just want to let them know that technical debt is the long-term debt that can affect the whole team, and not just the person who left.

* if you are thinking about moving to analytics engineering, what skills have you picked that give you the most confidence in pursuing this next step? There are so much more to learn about different dbt packages and macro usages with dbt to reduce the amount of code and maintain knowledge sharing across different teams. I still need to improve my data modeling skill in order to move to the AE space. 