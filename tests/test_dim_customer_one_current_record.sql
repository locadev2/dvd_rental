-- Test to ensure customer dimension has only one current record per customer_id
-- SCD Type 2 validation: only one is_current = true per business key

select
    customer_id,
    count(*) as current_records_count
from {{ ref('dim_customer') }}
where is_current = true
group by customer_id
having count(*) > 1
