with dates as (

    select generate_series(
        '2005-01-01'::date,
        '2008-01-01'::date,
        interval '1 day'
    ) as date_day
    union all
    select '9999-12-31'::date
)
select
    to_char(date_day, 'YYYYMMDD')::integer as date_key,
    date_day,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    extract(day from date_day) as day,
    extract(dow from date_day) as day_of_week
from dates
