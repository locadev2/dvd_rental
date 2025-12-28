with source as (

    select * 
    from {{ source('dvdrental', 'language') }}

),

final as (

    select
        language_id, "name"
    from source

)

select * from final
