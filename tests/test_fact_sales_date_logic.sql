-- Test to ensure rental_date_key is always less than or equal to return_date_key
-- Business rule: rentals must be returned on or after rental date

select
    rental_id,
    rental_date_key,
    return_date_key
from {{ ref('fact_sales') }}
where rental_date_key > return_date_key
    and return_date_key != {{var("default_date_key")}}
