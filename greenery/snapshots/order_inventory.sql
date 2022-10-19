{% snapshot orders_snapshot %}

  {{
    config(
      target_schema='dbt_nanangannguyen',
      unique_key='order_id',
      strategy='check',
      check_cols=['status']
    )
  }}

  SELECT * FROM {{source('greenery','orders')}}

{% endsnapshot %}