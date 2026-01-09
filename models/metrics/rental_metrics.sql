-- Rental activity metrics derived from sales data
-- This model tracks rental patterns, film popularity, and store performance

with rental_stats as (
    select 
        film_id,
        store_id,
        count(rental_id) as rental_count,
        count(distinct customer_key) as distinct_customers,
        sum(amount) as total_revenue,
        avg(amount) as avg_rental_price,
        min(rental_date_key) as first_rental_date_key,
        max(rental_date_key) as last_rental_date_key
    from {{ ref('fact_sales') }}
    group by film_id, store_id
)

select 
    rs.film_id,
    rs.store_id,
    df.title as film_title,
    df.release_year,
    rs.rental_count,
    rs.distinct_customers,
    rs.total_revenue,
    rs.avg_rental_price,
    fc.date_day as first_rental_date,
    lc.date_day as last_rental_date,
    lc.date_day - fc.date_day as days_in_circulation,
    case 
        when rs.rental_count > 0 
        then rs.total_revenue / rs.rental_count 
        else 0 
    end as revenue_per_rental,
    case 
        when rs.rental_count > 0 
        then rs.distinct_customers::decimal / rs.rental_count 
        else 0 
    end as customer_diversity_ratio
from rental_stats rs
inner join {{ ref('dim_film') }} df
    on df.film_id = rs.film_id
inner join {{ ref('dim_calendar') }} fc
    on fc.date_key = rs.first_rental_date_key
inner join {{ ref('dim_calendar') }} lc
    on lc.date_key = rs.last_rental_date_key
order by rs.total_revenue desc
