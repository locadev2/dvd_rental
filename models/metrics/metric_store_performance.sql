{{
  config(
    materialized='table',
    schema='metrics'
  )
}}

with fact_sales as (
    select * 
    from {{ ref('fact_sales') }}
),

dim_store as (
    select * 
    from {{ ref('dim_store') }}
),

store_metrics as (
    select
        ds.store_id,
        ds.city as store_city,
        ds.country as store_country,
        count(distinct fs.rental_id) as total_rentals,
        coalesce(sum(fs.amount), 0) as total_revenue,
        count(distinct fs.customer_key) as unique_customers,
        count(distinct fs.film_id) as unique_films_rented,
        coalesce(avg(fs.amount), 0) as average_rental_amount,
        coalesce(sum(fs.amount) / nullif(count(distinct fs.customer_key), 0), 0) as revenue_per_customer,
        coalesce(sum(fs.amount) / nullif(count(distinct fs.rental_id), 0), 0) as revenue_per_rental
    from dim_store ds
    left join fact_sales fs
        on ds.store_id = fs.store_id
    group by
        ds.store_id,
        ds.city,
        ds.country
)

select *
from store_metrics
order by total_revenue desc
