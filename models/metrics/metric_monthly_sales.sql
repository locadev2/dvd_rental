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

monthly_metrics as (
    select
        dc.year,
        dc.month,
        to_date(dc.year || '-' || lpad(dc.month::text, 2, '0') || '-01', 'YYYY-MM-DD') as month_start_date,
        count(distinct fs.rental_id) as total_rentals,
        sum(fs.amount) as total_revenue,
        count(distinct fs.customer_key) as unique_customers,
        count(distinct fs.film_id) as unique_films_rented,
        avg(fs.amount) as average_rental_amount,
        sum(sum(fs.amount)) over (partition by dc.year order by dc.month) as revenue_ytd
    from dim_calendar dc
    left join fact_sales fs
        on dc.date_key = fs.rental_date_key
    where dc.date_day < '9999-12-31'::date
    group by dc.year, dc.month
)

select *
from monthly_metrics
order by year desc, month desc
