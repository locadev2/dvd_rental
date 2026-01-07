-- Test to ensure there are no overlapping validity periods for the same customer
-- SCD Type 2 validation: no temporal overlaps

select
    c1.customer_id,
    c1.customer_key as key1,
    c2.customer_key as key2,
    c1.valid_from as valid_from_1,
    c1.valid_to as valid_to_1,
    c2.valid_from as valid_from_2,
    c2.valid_to as valid_to_2
from {{ ref('dim_customer') }} c1
inner join {{ ref('dim_customer') }} c2
    on c1.customer_id = c2.customer_id
    and c1.customer_key != c2.customer_key
where 
    -- Check for overlapping date ranges
    (c1.valid_from <= c2.valid_to and c1.valid_to >= c2.valid_from)
