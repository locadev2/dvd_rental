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

dim_calendar as (
    select * 
    from {{ ref('dim_calendar') }}
),

daily_metrics as (
    select
        dc.date_day,
        dc.year,
        dc.month,
        count(distinct fs.rental_id) as total_rentals,
        sum(fs.amount) as total_revenue,
        count(distinct fs.customer_key) as unique_customers,
        count(distinct fs.film_id) as unique_films_rented,
        count(distinct fs.store_id) as active_stores,
        avg(fs.amount) as average_rental_amount,
        min(fs.amount) as min_rental_amount,
        max(fs.amount) as max_rental_amount
    from dim_calendar dc
    left join fact_sales fs
        on dc.date_key = fs.rental_date_key
    where dc.date_day < '9999-12-31'::date
    group by dc.date_day, dc.year, dc.month
)

select *
from daily_metrics
order by date_day desc
