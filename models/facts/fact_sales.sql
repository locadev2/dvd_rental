with 
calendar as (
    select * 
    from {{ref('dim_calendar')}}    
),
customer as (
    select * 
    from {{ ref('dim_customer') }}
),
rental as (
    select * 
    from {{ ref('stg_rental') }}
),
payment as (
    select * 
    from {{ ref('stg_payment') }}
),
inventory as (
    select * 
    from {{ ref('stg_inventory') }}
),
vars as (
    select {{var("end_date_key")}}::int as "end_date_key"
),
fact as (

    select
        r.rental_id,
        i.film_id,
        cs.customer_key,
        i.store_id,
        cd.date_key as rental_date_key,
        coalesce(cr.date_key, end_date_key) as return_date_key,
        --p.payment_date,
        pm.amount
    from rental r
    cross join vars va
    inner join inventory i
        on i.inventory_id = r.inventory_id
    inner join store s
        on s.store_id = i.store_id        
    inner join customer cs
         on cs.customer_id = r.customer_id
        and r.rental_date between cs.valid_from AND cs.valid_to
    inner join calendar cd 
        on cd.date_day = r.rental_day
    left join calendar cr
        on cr.date_day = r.return_day        
    left join payment pm
        on pm.rental_id   = r.rental_id         
)

select *
from fact
{% if is_incremental() %}
where rental_date_key > (select max(rental_date_key) from {{ this }})
{% endif %}
