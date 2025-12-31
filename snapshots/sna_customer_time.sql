{% snapshot sna_customer_time %}

{{
    config(
      target_schema = 'staging',
      unique_key = 'customer_id',
      strategy = 'timestamp',
      updated_at = 'last_update'
    )
}}

select
    *
from {{ref('mid_customer')}}

{% endsnapshot %}
