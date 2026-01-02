{{
  config(
    materialized='table',
    schema='marts'
  )
}}

with fact_sales as (
    select * 
    from {{ ref('fact_sales') }}
),

dim_customer as (
    select * 
    from {{ ref('dim_customer') }}
),

dim_calendar as (
    select * 
    from {{ ref('dim_calendar') }}
),

dim_film as (
    select * 
    from {{ ref('dim_film') }}
),

dim_store as (
    select * 
    from {{ ref('dim_store') }}
),

joined as (
    select
        fs.rental_id,
        fs.customer_key,
        concat(dc.first_name, ' ', dc.last_name) as customer_name,
        fs.film_id,
        df.title as film_title,
        fs.store_id,
        dcal.date_day as rental_date,
        dret.date_day as return_date,
        fs.amount as rental_amount,
        (dret.date_day::date - dcal.date_day::date) as rental_days
    from fact_sales fs
    left join dim_customer dc
        on fs.customer_key = dc.customer_key
    left join dim_calendar dcal
        on fs.rental_date_key = dcal.date_key
    left join dim_calendar dret
        on fs.return_date_key = dret.date_key
    left join dim_film df
        on fs.film_id = df.film_id
    left join dim_store ds
        on fs.store_id = ds.store_id
)

select *
from joined
