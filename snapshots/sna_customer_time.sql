{% snapshot sna_customer_time %}

{{
    config(
      target_schema = 'dwh',
      unique_key = 'customer_id',
      strategy = 'timestamp',
      updated_at = 'updated_at'
    )
}}

select
    *
from {{ref('mid_customer')}}

{% endsnapshot %}
