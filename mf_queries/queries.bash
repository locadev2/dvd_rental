# Basic metric queries
mf query \
  --metrics total_revenue

mf query \
  --metrics total_rentals

mf query \
  --metrics distinct_customers

mf query \
  --metrics average_rental_value

mf query \
  --metrics revenue_per_customer

# Multiple metrics in one query
mf query \
  --metrics total_revenue,total_rentals,distinct_customers

mf query \
  --metrics average_rental_value,revenue_per_customer

# Queries with time dimensions
mf query \
  --metrics total_revenue \
  --group-by metric_time__month

mf query \
  --metrics total_revenue,total_rentals \
  --group-by metric_time__year

mf query \
  --metrics average_rental_value \
  --group-by metric_time__quarter

mf query \
  --metrics revenue_per_customer \
  --group-by metric_time__day

# Queries with time granularity and ordering
mf query \
  --metrics total_revenue,total_rentals,distinct_customers \
  --group-by metric_time__month \
  --order metric_time__month

mf query \
  --metrics average_rental_value,revenue_per_customer \
  --group-by metric_time__week \
  --order -total_revenue

# Queries with time filters
mf query \
  --metrics total_revenue \
  --group-by metric_time__month \
  --where "{{ Dimension('metric_time__month') }} >= '2023-01-01'"

mf query \
  --metrics total_revenue,total_rentals \
  --where "{{ Dimension('metric_time__year') }} = '2024'"

# Queries with limits
mf query \
  --metrics total_revenue \
  --group-by metric_time__day \
  --order -total_revenue \
  --limit 10

# Comprehensive query example
mf query \
  --metrics total_revenue,total_rentals,average_rental_value,distinct_customers,revenue_per_customer \
  --group-by metric_time__month \
  --order metric_time__month \
  --limit 12

