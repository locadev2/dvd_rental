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

dim_film as (
    select * 
    from {{ ref('dim_film') }}
),

film_metrics as (
    select
        df.film_id,
        df.title,
        df.rating,
        df.rental_rate,
        df.rental_duration,
        df.language_name,
        count(distinct fs.rental_id) as total_rentals,
        coalesce(sum(fs.amount), 0) as total_revenue,
        count(distinct fs.customer_key) as unique_customers,
        coalesce(avg(fs.amount), 0) as average_rental_amount,
        coalesce(sum(fs.amount) / nullif(count(distinct fs.rental_id), 0), 0) as revenue_per_rental,
        dense_rank() over (order by count(distinct fs.rental_id) desc) as popularity_rank,
        dense_rank() over (order by coalesce(sum(fs.amount), 0) desc) as revenue_rank
    from dim_film df
    left join fact_sales fs
        on df.film_id = fs.film_id
    group by
        df.film_id,
        df.title,
        df.rating,
        df.rental_rate,
        df.rental_duration,
        df.language_name
)

select *
from film_metrics
order by total_revenue desc
