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

dim_customer as (
    select * 
    from {{ ref('dim_customer') }}
),

customer_metrics as (
    select
        dc.customer_key,
        dc.customer_id,
        dc.first_name,
        dc.last_name,
        dc.email,
        dc.city,
        dc.country,
        dc.is_active,
        count(distinct fs.rental_id) as total_rentals,
        coalesce(sum(fs.amount), 0) as total_revenue,
        coalesce(avg(fs.amount), 0) as average_rental_value,
        min(fs.rental_date_key) as first_rental_date_key,
        max(fs.rental_date_key) as last_rental_date_key,
        case
            when coalesce(sum(fs.amount), 0) >= 150 then 'High Value'
            when coalesce(sum(fs.amount), 0) >= 100 then 'Medium Value'
            when coalesce(sum(fs.amount), 0) > 0 then 'Low Value'
            else 'No Activity'
        end as customer_segment,
        ntile(4) over (order by coalesce(sum(fs.amount), 0) desc) as revenue_quartile
    from dim_customer dc
    left join fact_sales fs
        on dc.customer_key = fs.customer_key
    where dc.is_current = true
    group by
        dc.customer_key,
        dc.customer_id,
        dc.first_name,
        dc.last_name,
        dc.email,
        dc.city,
        dc.country,
        dc.is_active
)

select *
from customer_metrics
order by total_revenue desc
