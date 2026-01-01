with 
film as (

    select *
    from {{ ref('stg_film') }}

),
"language" as (

    select *
    from {{ ref('stg_language') }}

)

select
    film_id,
    title,
    release_year,
    rental_duration,
    rental_rate,
    "length",
    rating,
    l.name as language_name

from film f
inner join "language" l
    on l.language_id = f.language_id