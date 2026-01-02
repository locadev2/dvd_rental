with source as (

    select * 
    from {{ source('rental', 'store') }}

),

final as (

    select
        store_id,
        address_id,
        manager_staff_id
    from source
)

select * from final
