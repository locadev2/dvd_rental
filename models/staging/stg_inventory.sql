with source as (

    select * 
    from {{ source('rental', 'inventory') }}

),

final as (

    select
        inventory_id,
        film_id,
        store_id,
        last_update
    from source

)

select * from final