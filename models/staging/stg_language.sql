with source as (

    select * 
    from {{ source('rental', 'language') }}

),

final as (

    select
        language_id, "name"
    from source

)

select * from final
