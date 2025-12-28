with 
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

customer as (

    select *
    from {{ ref('dim_customer') }}
),

fact as (

    select
        r.rental_id,
        i.film_id,
        c.customer_id,
        i.store_id,
        r.rental_date,
        r.return_date,
        --p.payment_date,
        p.amount
    from
        public.rental r
    inner join payment p
        on p.rental_id   = r.rental_id 
    inner join inventory i
        on i.inventory_id = r.inventory_id
    inner join store s
        on s.store_id = i.store_id        
    inner join customer c 
         on c.customer_id = r.customer_id
        --and r.rental_date between c.valid_from AND c.valid_to
)

select * from fact
