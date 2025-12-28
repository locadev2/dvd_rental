with 
customer as (

    select *,
        min(dbt_valid_from) over (partition by customer_id) as min_date
    from {{ ref('sna_customer_time') }}

)

select
    customer_id,
    first_name,
    last_name,
    email,
    is_active,
    create_date,
    "address",
    district,
    postal_code,
    city,
    country,
    dbt_valid_from as valid_from,
    coalesce(dbt_valid_to, '9999-12-31'::timestamp) as valid_to,
    case
        when dbt_valid_to is null then true else false
    end as is_current

from customer c
