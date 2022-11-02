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