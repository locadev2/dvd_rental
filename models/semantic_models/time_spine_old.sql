{{ config(enabled=false) }}

with vars as (
    {{ dbt.date_spine(
        'day',
        "'" ~ var('start_date') ~ "'::date",
        "'" ~ var('end_date') ~ "'::date"
    ) }}
),
final as (
    select cast(date_day as date) as date_day
    from days
)

select * 
from final
