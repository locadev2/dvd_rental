with dates as (

    select generate_series(
        '2005-01-01'::date,
        '2010-12-31'::date,
        interval '1 day'
    ) as date_day
)
select
    date_day as date_key,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    extract(day from date_day) as day,
    extract(dow from date_day) as day_of_week
from dates
