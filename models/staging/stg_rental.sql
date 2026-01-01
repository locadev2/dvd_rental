with source as (

    select * 
    from {{ source('landing', 'rental') }}

),

final as (

    select
        rental_id,
        rental_date::timestamp as rental_date,
        return_date::timestamp as return_date,
        rental_date::date as rental_day,
        return_date::date as return_day,
        inventory_id,
        customer_id,
        staff_id,
        last_update
    from source

)

select * from final
