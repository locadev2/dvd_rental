select
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
from information_schema.columns
where table_schema = 'main'
order by table_name, ordinal_position;