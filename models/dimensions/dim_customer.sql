with 
customer as (

    select *,
        row_number() over (partition by customer_id order by last_update) as "prog"
    from {{ ref('sna_customer_check') }}

),

vars as (
    select 
        '{{var("start_date")}}'::timestamp as "start_date",
        '{{var("end_date")}}'::timestamp as "end_date"
)

select
    hashtext(concat(customer_id, dbt_valid_from)) as customer_key,
    customer_id,
    first_name,
    last_name,
    email,
    is_active,
    create_date,
    address_id,
    "address",
    district,
    postal_code,
    city,
    country,
    -- Debugging start_date variable
    case 
        when prog = 1 then v.start_date
        else dbt_valid_from 
    end as valid_from,
    coalesce(dbt_valid_to, v.end_date) as valid_to,
    case
        when dbt_valid_to is null then true else false
    end as is_current

from customer c
cross join vars v