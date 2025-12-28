with source as (

    select * 
    from {{ source('dvdrental', 'city') }}

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