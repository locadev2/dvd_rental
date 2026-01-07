-- Test to ensure calendar dimension has continuous date coverage
-- Validates that there are no gaps in the date spine

with date_sequence as (
    select
        date_day,
        lead(date_day) over (order by date_day) as next_date
    from {{ ref('dim_calendar') }}
)
select
    date_day,
    next_date,
    (next_date::date - date_day::date) as day_gap
from date_sequence
where next_date is not null
    and (next_date::date - date_day::date) > 1
