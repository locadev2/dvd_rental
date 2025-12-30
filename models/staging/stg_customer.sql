with source as (

    select * 
    from {{ source('dvdrental', 'customer') }}

),

final as (

    select
        customer_id,
        store_id,
        first_name,
        last_name,
        email,
        address_id,
        --case when customer_id = 1 then 10 else address_id end as address_id,
        activebool as is_active,
        create_date,
        last_update
    from source

)

select * from final