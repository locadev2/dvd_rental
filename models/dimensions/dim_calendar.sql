select
  d.date_day,
  extract(dow from d.date_day)     as day_of_week,
  extract(month from d.date_day)   as date_month,
  extract(year from d.date_day)    as date_year,
  to_char(d.date_day, 'YYYY-MM')   as year_month
from {{ ref('time_spine') }} d