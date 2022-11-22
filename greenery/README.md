Welcome to your new dbt project!
### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

# Analytics engineering with dbt

Template repository for the projects and environment of the course: Analytics engineering with dbt

> Please note that this sets some environment variables so if you create some new terminals please load them again.

Welcome to the new dbt project with a fictional e-commerce plant shop!

# Part 1: Project Set Up
### dbt project env
After forking the project and following the url `gitpod.io/#git_url`, we need to remember to pin the project in the gitpod dashboard interface so the project stays persistent. We can run `dbt --version` follow by `./pgui.sh` to show a simple GUI of the database. Additionally, we can also access the database in the snowflake instance as below. 

### dbt project setup
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


### dbt overview
dbt is the T in ELT. dbt utilizes the power of modern data warehouses and the separation of compute/storage to take code, compile it to SQL, and run against the database. dbt allows analysts to work more like software engineers by following principles such as VC, code modularity and collaboration.

dbt helps data analysts to share work, have more control and discover dependencies, which is more advantageous than the traditional SQL stored procedures (business logic lies in the procedures) or other methods. 

# Part 2: dbt Fundamentals
Modern data stacks: data ingestion, data warehouse, transformation and BI tools

* ETL: extract, transform into a staging area, then load into a data warehouse.
* ELT: extract, load into a data warehouse, transform into a materialzed view in the data warehouse. 

### fundamentals

* seeds `dbt seed`: csv files that dbt uploads to the data warehouse as tables and do not change frequently. seeds can be an external infectious icd9/icd10 codes to flag potentially incorrect prescription or a mapping data dictionary of abbreviated states to full name states. Ideally it should be a 1-1 mapping but icd9/icd10 conversion does not follow the 1-1 mapping rule. 

* sources `dbt source freshness`: raw data that I use to build dbt models off of. sources are defined in source.yml file

* models `dbt run`: models are SQL select statements that are compiled, run against the data warehouse, then materialized into tables or views. 

1. table: a model that is created as a table. 
2. view: a model that is created as a view. A view is just a snapshot of the database and is not materialized. 
3. incremental (stay only for a short amount of time): `is_incremental()` in jinja. 
4. ephemeral: similar to temp tables in T-SQL and **not** materialized. dbt builds them into the models that ref them as CTE. 

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

* packages `dbt deps` to install code libraries. Within the dbt project, the packages.yml should be placed at the same level as the dbt_project.yml. The most common used dbt package is dbt_utils. 

# Part 3: Model Layers and Data Modeling Process

### Model Layers

1. base: 1:1 with source, no JOINING with light transformation. Live in staging/staging_mysql/base_zendesk.sql

2. stg: 1:1 with source or JOINING of base tables with light transformation. Live in staging/staging_mysql/stg_mysql_order.sql

3. int: heavier transformation with business logic applied. Should live in marts/finance/int_orders_groupby_month. If a bipartite DAG with no int model between stg/dim or stg/fact exists, it suggests that an int model is needed. Further consideration of the complexity of the model pipeline is also needed to simplify the DAG. 

4. dim or fact: end state models and a good point to bring to BI tools through exposure. 

> Marts contains step 3 and 4 models
> Marts has their own custom schemas. In the dbt_project.yml we can define marts like this:
> 

```yml
models:
  greenery:
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
* Heavy transformation: usually in marts, which are traditionally based on business entities and processes and grouped by business unit (operation, marketing, sales, finance) in a sub-directory within a directory of core transformed models (dim_users, fact_orders).
* dim (business entities): users, stores, products
* Fact (business processes): orders, events, transactions. When **fact** LEFT JOIN on **dim**, we can find the level of the dimension that are not needed and can be removed later on. 

### Data Modeling 

> Data modeling is a process to define and analyze data requirements to support business processes in a way that is understandable and relevant to the business partners. (Miles Russell - GitLab + wiki)

1. Biz process: usually created with Bus Matrix and Table documentaiton.
2. Grain of the process: the smaller the grain, the easier it is for data analysts to drill down but may add complexity. Rolling up the dimension allows an overview of the business health but each segment may not share the same story (Simpson's paradox). 
3. Identify dimensions based on the grain: dimension tables tend to be wide and have lot of fields. If a dimension table only has one field, it is better to codify it in the fact table and use it as a degenerate dimension.
4. Identify facts based on the grain: facts represent the business processes and need to be revised with business partners. 

### Testing - only at row level with `dbt test`
Testing is the process of trying to find an error in the assumption AKA the negation of the true assumption. For example, if a test on uniqueness returns a row, the test fails and the assumption about the data is incorrect. In other words, if a test on uniqueness does not return a row, the test passes. It is recommended to always test 'not null' and 'unique' on primary keys.

* Singular test: `unique`, `not_null`, `accepted_values` and `relationships`. Suprisingly, Google Big Query does not offer referential integrity test and requires a tool such as dbt or Google CloudSpanner - OLTP to test the relationship. 

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
              to: ref('customers') # PK(customers.id) -< FK(orders.customer_id) 
              field: id 
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

# Part 4: Macros / Jinja, Hooks and Operations
Macros and Jinja open up another set of possibilities and less rigid than stored procedures. if, for loops, use of environment variables, functions, grant usage depending on the user roles are possible. 

* Grant usage macro
```sql
{% macro warehouse_resize(prod_size, stage_size) %}
  {% if target.name == "prod" %}
  ALTER WAREHOUSE {{ target.warehouse }} SET WAREHOUSE_SIZE = {{ prod_size }};
  {% else %}
  ALTER WAREHOUSE {{ target.warehouse }} SET WAREHOUSE_SIZE = {{ stage_size }};
  {% endif %}
{% endmacro %}
```
+ n levels CASE WHEN to 2 lines of macro
```sql
{{ dbt_utils.pivot('event_type', dbt_utils.get_column_values(ref('stg_events'), 'event_type')) }}
```

### Hooks
* pre-hook / post-hook: SQL that run before/after a model, seed or snapshot. For example, having 5 models requires 5 pre-hooks or 5 post-hooks.
* on-run-start / on-run-end: SQL that run before/after any model, seed or snapshot. Any operations command can only be used with on-run-start or on-run-end. These 2 types of hooks are used to size-up/size-down the warehouse. 

### Operations
Operations are a way to invoke a macro without having to invoke `dbt run` using `dbt run-operation macro_name --args '{"arg_key":"arg_value"}'`. Opeartions are useful when there are certain types of actions may needed before the `dbt run` command, such as cloning a OLTP database for an OLAP DW or anonymizing user data. 

# Part 5: Product Funnel, Exposures, Artifacts and Metadata

### Product Funnel: 
The product funnel is how user navigate through a page, with the ultimate goal of purchasing a product. The funnel steps in greenery will include:

* The total site visits or the total sessions
* Sessions with product pageview
* Sessions with add-to-cart action: add-to-cart rate = $\frac{#uniq sessions with add to cart event}{#total uniq sessions}$
* Sessions with transaction action: conversion rate = $\frac{#uniq sessions with checkout event}{#total uniq sessions}$

The whole goal of modeling product funnel is to figure out **where** users are falling out with A/B tests. 

* Availability: Identify the zipcodes of high number of sessions without any store on demand to identify the on-demand stores. As the number of on-demand stores become more available, the conversion rate also increases.
* Hours: Determine impactful hours based on session traffic group by hour and other store availabilities in the same area. 
* Capacity: Place a cap on stores to ensure the best user experience based on the number of fulfillments that a store can handle. 
* Selection: Recommend item preferences across the country and popular locally to each store (Pareto principle)
$\frac{percent of Gross Merchant Value of each store of last year}{each Designated Market Area}$
* Price: Price variance and price index play a significant role and depend on the area. 

### dbt exposures
Exposures are purely documentation. The exposure helps the team to know what downstream systems or processes will be affected by changes to models that feed into an exposure.  However, exposures require the analyst to know which models that the exposures rely on by referencing the models. 

```yaml
version: 2
exposures:  
  - name: Product Funnel Dashboard
    description: >
      Models that are critical to our product funnel dashboard
    type: dashboard
    maturity: high
    owner:
      name: kaleynguyen
      email: kaleynguyen@greenery.com
    depends_on:
      - ref('product_funnel')
```

# dbt artifacts / metadata 
* run_results.json: dbt run, test, seed, snapshot, compile, docs generate, and build. Can use this metadata to understand how our production dbt run is performing on a day to day basis
* manifest.json: dbt compile, run, test, seed, snapshot, docs generate, freshness, ls, and build. Some examples include how many models have descriptions, how many sources contain PII, and which macros are being used across our project.
* sources.json: produced by `dbt source freshness`. This metadata is generally useful to understand how your freshness checks are performing on a day to day basis.
* catalog.json: produced by `dbt docs generate`. This metadata provides information from your data warehouse on tables and views, such as row counts, table size, and column types. dbt uses this data to provide this metadata within the dbt docs site. We can use this to understand how table sizes grow over time. 





