with source as (

    select * 
    from {{ source('rental', 'city') }}

),

final as (

    select
        city_id,
        city,
        country_id,
        last_update
    from source

)

select * from final