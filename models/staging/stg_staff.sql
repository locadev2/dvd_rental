with source as (

    select * 
    from {{ source('rental', 'staff') }}

),

final as (

    select *
    from source
)

select * from final
