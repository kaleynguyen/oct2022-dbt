Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

# Analytics engineering with dbt

Template repository for the projects and environment of the course: Analytics engineering with dbt

> Please note that this sets some environment variables so if you create some new terminals please load them again.

Welcome to your new dbt project!


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

# dbt project env
After forking the project and following the url `gitpod.io/#git_url`, we need to remember to pin the project in the gitpod dashboard interface so the project stays persistent. We can run `dbt --version` follow by `./pgui.sh` to show a simple GUI of the database. 

# dbt project setup
1. `dbt --version` to check whether dbt is installed or not.
2. `dbt init greenery` to create a dbt project. 
3.  move into the project directory by `cd greenery` and then `vim ~/.dbt/profiles.yml` or `open ~/.dbt/profiles.yml` to change the profiles.yml file as below: 

```yml
greenery:
  outputs:
    dev:
      account: ryb00700.us-east-1
      database: dev_db
      password: ******
      role: TRANSFORMER_DEV
      schema: dbt_nanangannguyen
      threads: 1
      type: snowflake
      user: nanangannguyen
      warehouse: TRANSFORMER_DEV_WH
  target: dev
```


4. Run `dbt debug` to test the connection in the postgres database. 


# dbt overview
dbt is the T in ELT. dbt utilizes the power of modern data warehouses and the separation of compute/storage to take code, compile it to SQL, and run against the database. dbt allows analysts to work more like software engineers by following principles such as VC, code modularity and collaboration.

dbt helps data analysts to share work, have more control and discover dependencies, which is more advantageous than the traditional SQL stored procedures (business logic lies in the procedures) or other methods. 

# Week 1
Modern data stacks: data ingestion, data warehouse, transformation and BI tools

* ETL: extract, transform into a staging area, then load into a data warehouse.
* ELT: extract, load into a data warehouse, transform into a materialzed view in the data warehouse. 

### dbt fundamentals

* seeds `dbt seed`: csv files that dbt uploads to the data warehouse as tables and do not change frequently. seeds can be an external infectious icd9/icd10 codes to flag potentially incorrect prescription or a mapping data dictionary of abbreviated states to full name states. Ideally it should be a 1-1 mapping but icd9/icd10 conversion does not follow the 1-1 mapping rule. 

* sources `dbt source freshness`: raw data that I use to build dbt models off of. sources are defined in source.yml file

* models `dbt run`: models are SQL select statements that are compiled, then run against the data warehouse, then materialized into tables or views. 

1. table: a model that's created as a table. 
2. view: a model that's created as a view. A view is just a snapshot of the database and is not materialized. 
3. incremental (stay only for a short amount of time): `is_incremental()` in jinja
4. ephemeral: like temp tables in T-SQL and **not** materialized. dbt builds them into the models that ref them as CTE. 

 dbt model materialization can be defined in dbt_project.yml as the global materialized config. Each project can overide the dbt_project.yml in the source.yml (eg src_facebook_ads.yml). 

 * tests `dbt test`: test NULLness, uniqueness, positivivity or user defined test functions/udf. Snowflake can have Javacript udf but not so sure whether they have supported Python udf. 
 * snapshots `dbt snapshot` to easily capture data changes over time. Eg, number of invetory products or which dates of the trading pipelines have been processed until today. 
 * docs `dbt docs generate` and `dbt docs serve` to generate docs and visualize DAGs of models and metadata. 
 * Jinja + macros: macros are pieces of jinja code, like functions. Add the macro below into `macros/` directory. 

 Example:

```sql
{% macro lbs_to_kgs(column_name, precision=2) %}
    ROUND(
       (CASE WHEN {{ column_name }} = -99 THEN NULL ELSE {{ column_name }} END / 2.205)::NUMERIC, 
       {{ precision }}
    )
{% endmacro %}
```

* packages `dbt deps` to install code libraries. Within the dbt project, the packages.yml should be placed at the same level as the dbt_project.yml. The most common used dbt package is dbt_utils 

# Week 2

### Model Layers

1. base: 1:1 with source, no JOINING. Live in staging/staging_mysql/base_zendesk.sql

2. stg: 1:1 with source or JOINING of base tables. Live in staging/staging_mysql/stg_mysql_order.sql

3. int: heavier transformation with business logic applied. Should live in marts/finance/int_orders_groupby_month. If a bipartite DAG with no int model between stg/dim or stg/fact exists, it suggests that an int model is needed.   

4. dim or fact: end state and a good point to bring to BI tools through exposure. 

> Marts contains step 3 and 4 models
> Marts has their own custom schemas. In the dbt_project.yml we can define marts like this:
> 

```yml
models:
  drizly:

    # Defaults for all data models
    transient: false
    materialized: table

    staging:
      enabled: true
      schema: staging

    marts:
      enabled: true
      core:
        +schema: reporting
      marketing:
        +schema: marketing
      finance:
        +schema: finance
```

* Light transformation: type casting, renaming, filtering bad data, deleted records (CCPA in Cali / HIPPA compliant), specific time zone, and obfuscated data. 
* Heavy transformation: usually in Marts, which are traditionally based on business entities and processes and grouped by business unit (operation, marketing, sales, finance) in a sub-directory within a directory of core transformed models (dim_users, fact_orders).
* Dim (metadata): users, stores, products
* Fact (transactional data): orders, events, transactions. **fact** LEFT JOIN on **dim**

### Data Modeling 

> Data modeling is a process to define and analyze data requirements to support business processes in a way that is understandable and relevant to the business partners. (Miles Russell + wiki)

1. Biz process
2. Grain of the process
3. Identify dimensions based on the grain
4. Identify facts based on the grain 

### Testing - only at row level with `dbt test`
Testing is a negation of the true assumption. For example, if a test on uniqueness returns a row, the test fails and the assumption about the data is incorrect. In other words, if a test on uniqueness does not return a row, the test passes. It is recommended to always test 'not null' and 'unique'.

* Singular test: `unique`, `not_null`, `accepted_values` and `relationships`. Suprisingly, Google Big Query does not offer ref integrity test and requires a different DW to test the relationship. 

```yaml
version: 2

models:
  - name: orders
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['placed', 'shipped', 'completed', 'returned']
      - name: customer_id
        tests:
          - relationships:
              to: ref('customers')
              field: id #each customer_id in the orders model exists as an id in the customers table (also known as referential integrity)
```
* Generic Test: could use macro to parametrized the input 
```yaml
{% test positive_values(model, column_name) %}
   select *
   from {{ model }}
   where {{ column_name }} < 0
{% endtest %}
```

* Testing the source freshness by `dbt source freshness`
```yaml

version: 2

sources:

  - name: tutorial
    schema: public
    database: dbt
    freshness:
      warn_after: {count: 24, period: hour} #warn does not affect downstream models
      error_after: {count: 48, period: hour} #error stops all the downstream models

    tables:
      - name: superheroes 
        loaded_at_field: created_at
        description: >
          Contains demographic information about each superhero
```

# Week 3

# Week 4

### Product Funnel: 
The product funnel is how user navigate through a page, with the ultimate goal of purchasing a product. The funnel steps in greenery will include:

* The total site visits or the total sessions
* Sessions with product pageview
* Sessions with add-to-cart action: add-to-cart rate = $\frac{#uniq sessions with add to cart event}{#total uniq sessions}$
* Sessions with transaction action: conversion rate = $\frac{#uniq sessions with checkout event}{#total uniq sessions}$

The whole goal of modeling product funnel is to figure out **where** users are falling out with A/B tests. 

* Availability: Identify the zipcodes of high number of sessions without any store on demand to identify the on-demand stores. As the number of on-demand stores become more available, the conversion rate also increases.
* Hours: Determine impactful hours based on session traffic and other store availabilities in the same area. 
* Capacity: Place a cap on stores to ensure the best user experince based on the number of fulfillments that a store can handle. 
* Selection: Recommend item preferences across the country and popular locally to each store (Pareto principle)
$\frac{percent of GMV of each store of last year}{each Designated market area}$
* Price: Price variance and price index play a significant role. 

### dbt exposures
Exposures are purely documentation. They help you and your team know what downstream systems or processes will be affected by changes to models that feed into an exposure. Think KPI definition changes, data science model inputs, etc.  However, exposures require the analyst to know which models that the exposures rely on by referencing the models. 

```yaml
version: 2
exposures:  
  - name: Product Funnel Dashboard
    description: >
      Models that are critical to our product funnel dashboard
    type: dashboard
    maturity: high
    owner:
      name: Emily Hawkins
      email: emily@greenery.com
    depends_on:
      - ref('product_funnel')
```

# dbt artifacts / metadata 
* run_results.json: dbt run, test, seed, snapshot, compile, docs generate, and build. Can use this metadata to understand how our production dbt run is performing on a day to day basis
* manifest.json: dbt compile, run, test, seed, snapshot, docs generate, freshness, ls, and build. Some examples include how many models have descriptions, how many sources contain PII, and which macros are being used across our project.
* sources.json: produced by `dbt source freshness`. This metadata is generally useful to understand how your freshness checks are performing on a day to day basis.
* catalog.json: produced by `dbt docs generate`. This metadata provides information from your data warehouse on tables and views, such as row counts, table size, and column types. dbt uses this data to provide this metadata within the dbt docs site. We can use this to understand how table sizes grow over time. 





