{{ config(materialized='view') }}

select
    v.vendor_id,
    v.vendor_name,
    v.parent_vendor,
    v.vendor_category,
    v.region,

    count(i.invoice_id) as invoice_count,

    sum(i.amount) as total_spend,

    avg(i.amount) as average_invoice_amount,

    count_if(i.high_value_invoice_flag) as high_value_invoice_count,

    count_if(i.invalid_gl_flag) as invalid_gl_count

from {{ ref('silver_vendors') }} v

left join {{ ref('silver_invoices') }} i
    on v.vendor_id = i.vendor_id

group by
    v.vendor_id,
    v.vendor_name,
    v.parent_vendor,
    v.vendor_category,
    v.region