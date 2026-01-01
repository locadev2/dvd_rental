with source as (

    select * 
    from {{ source('landing', 'staff') }}

),

final as (

    select *
    from source
)

select * from final
