{{ config(materialized='view') }}

select
    invoice_id,
    vendor_id,
    invoice_type,
    invoice_date,
    amount,
    gl_account,

    case
        when payment_status is null or trim(payment_status) = ''
            then 'UNKNOWN'
        else upper(trim(payment_status))
    end as payment_status,

    upper(trim(region)) as region,

    case
        when gl_account = '9999'
            then true
        else false
    end as invalid_gl_flag,

    case
        when amount > 50000
            then true
        else false
    end as high_value_invoice_flag,

    current_timestamp() as silver_loaded_at

from {{ source('bronze', 'bronze_invoices') }}