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

-- Calculate 7-day rolling metrics
rolling_7d as (
    select
        dc.date_day,
        sum(count(distinct fs.rental_id)) over (
            order by dc.date_day 
            rows between 6 preceding and current row
        ) as rentals_rolling_7d,
        sum(sum(fs.amount)) over (
            order by dc.date_day 
            rows between 6 preceding and current row
        ) as revenue_rolling_7d,
        avg(avg(fs.amount)) over (
            order by dc.date_day 
            rows between 6 preceding and current row
        ) as avg_rental_amount_rolling_7d
    from dim_calendar dc
    left join fact_sales fs
        on dc.date_key = fs.rental_date_key
    where dc.date_day < '9999-12-31'::date
    group by dc.date_day
),

-- Calculate 30-day rolling metrics
rolling_30d as (
    select
        dc.date_day,
        sum(count(distinct fs.rental_id)) over (
            order by dc.date_day 
            rows between 29 preceding and current row
        ) as rentals_rolling_30d,
        sum(sum(fs.amount)) over (
            order by dc.date_day 
            rows between 29 preceding and current row
        ) as revenue_rolling_30d,
        avg(avg(fs.amount)) over (
            order by dc.date_day 
            rows between 29 preceding and current row
        ) as avg_rental_amount_rolling_30d
    from dim_calendar dc
    left join fact_sales fs
        on dc.date_key = fs.rental_date_key
    where dc.date_day < '9999-12-31'::date
    group by dc.date_day
)

select
    r7.date_day,
    r7.rentals_rolling_7d,
    r7.revenue_rolling_7d,
    r7.avg_rental_amount_rolling_7d,
    r30.rentals_rolling_30d,
    r30.revenue_rolling_30d,
    r30.avg_rental_amount_rolling_30d
from rolling_7d r7
inner join rolling_30d r30
    on r7.date_day = r30.date_day
order by r7.date_day desc
