-- Test to ensure no duplicate rental_ids in fact_sales
-- This validates the primary key constraint at the database level

select
    rental_id,
    count(*) as duplicate_count
from {{ ref('fact_sales') }}
group by rental_id
having count(*) > 1
