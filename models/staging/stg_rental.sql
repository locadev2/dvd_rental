with source as (

    select * 
    from {{ source('dvdrental', 'rental') }}

),

final as (

    select
        rental_id,
        rental_date::timestamp as rental_date,
        return_date::timestamp as return_date,
        inventory_id,
        customer_id,
        staff_id,
        last_update
    from source

)

select * from final
