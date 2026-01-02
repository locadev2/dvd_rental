with source as (

    select * 
    from {{ source('rental', 'address') }}
)

select
    address_id,
    address,
    address2,
    district,
    city_id,
    postal_code,
    phone,
    last_update
from source
