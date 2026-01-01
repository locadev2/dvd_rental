SELECT
    'rental' as TableName,
    count(*) as N
FROM
    public.rental
UNION ALL
SELECT
    'facts',
    count(*)
FROM
    main.fact_sales
UNION ALL
SELECT
    'facts_dimensions',
    count(*)
FROM
    main.fact_sales f
    INNER JOIN main.dim_calendar cd 
        on cd.date_key = f.rental_date_key
    INNER JOIN main.dim_calendar cr 
        on cr.date_key = f.return_date_key
    INNER JOIN main.dim_customer cs 
        on cs.customer_key = f.customer_key
    INNER JOIN main.dim_store st 
        on st.store_id = f.store_id
    INNER JOIN main.dim_film fm
        on fm.film_id = f.film_id

