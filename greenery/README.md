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

* seeds `dbt seed`: csv files that dbt uploads to the data warehouse as tables and do not change frequently. seeds can be an external infectious icd9/icd10 codes to flag incorrect prescription.

* sources `dbt source freshness`: raw data that I use to build dbt models off of. sources are defined in source.yml file

* models `dbt run`: models are SQL select statements that are compiled, then run against the data warehouse, then materialized into tables or views. 

1. table: a model that's created as a table
2. view: a model that's created as a view
3. incremental (stay only for a short amount of time): `is_incremental()` in jinja
4. ephemeral: like temp tables and **not** materialized. dbt builds them into the models that ref them as CTE.

 dbt model materialization can be defined in dbt_project.yml as the global materialized config. Each project can overide the dbt_project.yml in the source.yml (eg src_facebook_ads.yml). 

 * tests `dbt test`: test NULLness, uniqueness, positivivity or user defined test functions/udf.
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

3. int: heavier transformation with business logic applied. Should live in marts/finance/int_orders_groupby_month

4. dim or fact: end state and a good point to bring to BI tools

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

* Light transformation: type casting, renaming, filtering bad data, deleted records (CCPA compliant), same time zone 
* Heavy transformation: usually in Marts, which are traditionally based on business entities and processes and grouped by business unit (operation, marketing, sales, finance) in a sub-directory within a directory of core transformed models (dim_users, fact_orders).
* Dim (metadata): users, stores, products
* Fact (transactional data): orders, events, transactions. **fact** LEFT JOIN on **dim**

### Data Modeling 

> Data modeling is a process to define and analyze data requirements to support business processes in a way that is understandable and relevant to the business partners. (Miles Russell + wiki)

1. Biz process
2. Grain of the process
3. Identify dimensions based on the grain
4. Identify facts based on the grain 

### Testing (row level, not database level? What about IC?)











