with time_spine as (
  select *
  from {{ ref('time_spine') }} d
  union all
  select '9999-12-31'::date
)

select
  to_char(date_day, 'YYYYMMDD')::integer as date_key,
  d.date_day,
  extract(dow from d.date_day)     as day_of_week,
  extract(day from date_day)       as day_of_month,
  extract(month from d.date_day)   as date_month,
  extract(year from d.date_day)    as date_year,
  to_char(d.date_day, 'YYYY-MM')   as year_month
from time_spine d