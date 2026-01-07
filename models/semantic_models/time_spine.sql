with 
vars as (
    select 
        {{ "'" ~ var('start_date') ~ "'" }}::date as date_start,
        {{ "'" ~ var('end_date') ~ "'" }}::date as date_end
),
dates as (
    select
         generate_series(date_start, date_end, interval '1 day') 
         as date_day
    from vars
)
select
    date_day::date as date_day
from dates
