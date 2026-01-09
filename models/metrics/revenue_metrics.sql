-- Revenue-based metrics derived from sales semantic model
-- This model aggregates revenue metrics over time

with daily_revenue as (
    select 
        rental_date_key,
        sum(amount) as total_revenue,
        count(distinct customer_key) as distinct_customers,
        count(rental_id) as rental_count,
        avg(amount) as avg_revenue_per_rental
    from {{ ref('fact_sales') }}
    group by rental_date_key
)

select 
    dr.rental_date_key,
    c.date_day as rental_date,
    c.year,
    c.month,
    c.quarter,
    dr.total_revenue,
    dr.distinct_customers,
    dr.rental_count,
    dr.avg_revenue_per_rental,
    case 
        when dr.distinct_customers > 0 
        then dr.total_revenue / dr.distinct_customers 
        else 0 
    end as revenue_per_customer
from daily_revenue dr
inner join {{ ref('dim_calendar') }} c
    on c.date_key = dr.rental_date_key
order by dr.rental_date_key
