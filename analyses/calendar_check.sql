
select
    'dim' as table_name, 
    min(date_key) as mi,
    max(date_key) as ma
from main.dim_calendar
union all

select
    'fact' as table_name, 
    min(rental_date_key) as mi,
    max(return_date_key) as ma
from main.fact_sales
