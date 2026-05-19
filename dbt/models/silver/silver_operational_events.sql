{{ config(materialized='view') }}

select
    event_id,
    event_timestamp,

    upper(trim(event_type)) as event_type,
    upper(trim(business_domain)) as business_domain,
    upper(trim(region)) as region,

    related_entity_id,

    operational_cost,
    revenue_impact,
    business_impact_hours,

    upper(trim(governance_risk_level)) as governance_risk_level,
    upper(trim(event_status)) as event_status,

    date_trunc('month', event_timestamp) as event_month,
    date_trunc('quarter', event_timestamp) as event_quarter,
    date_trunc('year', event_timestamp) as event_year,

    case
        when operational_cost < 0 then true
        else false
    end as invalid_operational_cost_flag,

    case
        when business_impact_hours < 0 then true
        else false
    end as invalid_impact_hours_flag,

    case
        when governance_risk_level not in ('Low', 'Medium', 'High', 'LOW', 'MEDIUM', 'HIGH')
            then true
        else false
    end as invalid_risk_level_flag,

    case
        when upper(trim(event_status)) in ('DELAYED', 'OPEN')
            then true
        else false
    end as unresolved_event_flag,

    case
        when upper(trim(governance_risk_level)) = 'HIGH'
            then true
        else false
    end as high_risk_event_flag,

    case
        when upper(trim(event_type)) = 'REFUND_ISSUED'
            then true
        else false
    end as refund_event_flag,

    case
        when upper(trim(event_type)) = 'INVOICE_PROCESSED'
            then true
        else false
    end as invoice_event_flag,

    current_timestamp() as silver_loaded_at

from {{ source('bronze', 'bronze_operational_events') }}