with 
store as (
    select * 
    from {{ref('stg_store')}}
),
staff as (
    select * 
    from {{ref('stg_staff')}}
),
addresses as (
    select * 
    from {{ref('stg_address')}}
),
city as (
    select * 
    from {{ref('stg_city')}}
),
country as (
    select * 
    from {{ref('stg_country')}}
)
select
	s.store_id, 
    f.first_name || ' ' || f.last_name as manager_name, 
    c.city, 
    t.country
from store s
inner join staff f
	on f.staff_id   = s.manager_staff_id 
inner join addresses a 
	on a.address_id = s.address_id 
inner join city c 
	on c.city_id = a.city_id 
inner join country t
	on t.country_id = c.country_id
	
