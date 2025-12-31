{% snapshot sna_customer_check %}

{{
    config(
      target_schema='staging',
      unique_key='customer_id',
      strategy='check',
      check_cols=[
        'is_active',
        'city',
        'country'
      ]
    )
}}

select
    *
from {{ref('mid_customer')}}

{% endsnapshot %}
