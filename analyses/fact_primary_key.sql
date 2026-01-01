
select * from main.fact_sales 
where rental_id in (
    select rental_id
    from main.fact_sales
    group by rental_id
    having count(*) > 1
)