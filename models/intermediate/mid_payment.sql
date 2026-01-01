
with payment as  (
    select * 
    from {{ ref('stg_payment') }}
)
select rental_id, sum(amount)  as amount
from payment
group by rental_id