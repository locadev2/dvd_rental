{{
  config(
    materialized='table',
    schema='marts'
  )
}}

with dim_customer as (
    select * 
    from {{ ref('dim_customer') }}
),

fact_sales as (
    select * 
    from {{ ref('fact_sales') }}
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
        coalesce(sum(fs.amount), 0) as total_spent
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
order by total_spent desc
