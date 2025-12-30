with 
customer as (

    select *
    from {{ ref('stg_customer') }}

),

addresses as (

    select *
    from {{ ref('stg_address') }}

),

city as (

    select *
    from {{ ref('stg_city') }}

),

country as (

    select *
    from {{ ref('stg_country') }}

)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.is_active,
    c.create_date,

    c.address_id,
    a.address,
    a.district,
    a.postal_code,
    ci.city,
    co.country,

    greatest(
        c.last_update,
        a.last_update,
        ci.last_update,
        co.last_update
    ) as last_update

from customer c
left join addresses a
    on c.address_id = a.address_id
left join city ci
    on a.city_id = ci.city_id
left join country co
    on ci.country_id = co.country_id