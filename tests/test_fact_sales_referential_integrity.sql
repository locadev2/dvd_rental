-- Test to ensure no orphaned records in fact_sales
-- Validates referential integrity for all foreign keys

with missing_customers as (
    select distinct fs.customer_key
    from {{ ref('fact_sales') }} fs
    left join {{ ref('dim_customer') }} dc
        on fs.customer_key = dc.customer_key
    where dc.customer_key is null
),
missing_films as (
    select distinct fs.film_id
    from {{ ref('fact_sales') }} fs
    left join {{ ref('dim_film') }} df
        on fs.film_id = df.film_id
    where df.film_id is null
),
missing_stores as (
    select distinct fs.store_id
    from {{ ref('fact_sales') }} fs
    left join {{ ref('dim_store') }} ds
        on fs.store_id = ds.store_id
    where ds.store_id is null
)
select 'customer' as dimension, customer_key as missing_key from missing_customers
union all
select 'film' as dimension, film_id as missing_key from missing_films
union all
select 'store' as dimension, store_id as missing_key from missing_stores
