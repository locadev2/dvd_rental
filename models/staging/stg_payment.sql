with source as (

    select * 
    from {{ source('rental', 'payment') }}

),

final as (

    select
        payment_id,
        customer_id,
        staff_id,
        rental_id,
        amount,
        payment_date
    from source

)

select * from final