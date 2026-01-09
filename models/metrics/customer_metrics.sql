-- Customer-focused metrics derived from sales data
-- This model tracks customer behavior and activity patterns

with customer_activity as (
    select 
        customer_key,
        count(rental_id) as lifetime_rentals,
        sum(amount) as lifetime_revenue,
        min(rental_date_key) as first_rental_date_key,
        max(rental_date_key) as last_rental_date_key,
        count(distinct film_id) as distinct_films_rented,
        avg(amount) as avg_rental_amount
    from {{ ref('fact_sales') }}
    group by customer_key
)

select 
    ca.customer_key,
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.email,
    ca.lifetime_rentals,
    ca.lifetime_revenue,
    ca.distinct_films_rented,
    ca.avg_rental_amount,
    fc.date_day as first_rental_date,
    lc.date_day as last_rental_date,
    lc.date_day - fc.date_day as customer_tenure_days,
    case 
        when ca.lifetime_rentals > 0 
        then ca.lifetime_revenue / ca.lifetime_rentals 
        else 0 
    end as revenue_per_rental
from customer_activity ca
inner join {{ ref('dim_customer') }} dc
    on dc.customer_key = ca.customer_key
    and dc.is_current = true
inner join {{ ref('dim_calendar') }} fc
    on fc.date_key = ca.first_rental_date_key
inner join {{ ref('dim_calendar') }} lc
    on lc.date_key = ca.last_rental_date_key
order by ca.lifetime_revenue desc
