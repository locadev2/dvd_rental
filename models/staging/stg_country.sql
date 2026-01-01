with source as (

    select * 
    from {{ source('landing', 'country') }}

),

final as (

    SELECT
        country_id, 
        country, 
        last_update
    FROM source

)

select * from final