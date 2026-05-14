{{ config(materialized='view') }}

select
    vendor_id,

    upper(trim(vendor_name)) as vendor_name,

    case
        when parent_vendor is null or trim(parent_vendor) = ''
            then 'UNASSIGNED_PARENT'
        else upper(trim(parent_vendor))
    end as parent_vendor,

    case
        when vendor_category is null or trim(vendor_category) = ''
            then 'UNCLASSIFIED'
        else upper(trim(vendor_category))
    end as vendor_category,

    payment_terms,

    upper(trim(region)) as region,

    case
        when vendor_category is null or trim(vendor_category) = ''
            then true
        else false
    end as missing_category_flag,

    current_timestamp() as silver_loaded_at

from {{ source('bronze', 'bronze_vendors') }}