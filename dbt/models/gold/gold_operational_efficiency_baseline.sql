{{ config(materialized='view') }}

with monthly_operational_metrics as (

    select
        event_month,

        count(*) as total_operational_events,

        sum(operational_cost) as total_operational_cost,

        avg(operational_cost) as avg_cost_per_event,

        sum(case when refund_event_flag then 1 else 0 end)
            as refund_events,

        sum(case when unresolved_event_flag then 1 else 0 end)
            as unresolved_events,

        sum(case when high_risk_event_flag then 1 else 0 end)
            as high_risk_events

    from {{ ref('silver_operational_events') }}

    where
        invalid_operational_cost_flag = false
        and invalid_impact_hours_flag = false
        and invalid_risk_level_flag = false

    group by event_month

),

baseline_metrics as (

    select
        event_month,

        total_operational_events,
        round(total_operational_cost, 2) as total_operational_cost,

        round(
            total_operational_cost
            / nullif(total_operational_events, 0),
            2
        ) as cost_per_operational_event,

        round(
            refund_events::float
            / nullif(total_operational_events, 0),
            4
        ) as refund_event_ratio,

        round(
            unresolved_events::float
            / nullif(total_operational_events, 0),
            4
        ) as unresolved_event_ratio,

        round(
            high_risk_events::float
            / nullif(total_operational_events, 0),
            4
        ) as high_risk_event_ratio

    from monthly_operational_metrics

),

trend_metrics as (

    select
        *,

        round(
            avg(cost_per_operational_event)
            over (
                order by event_month
                rows between 2 preceding and current row
            ),
            2
        ) as rolling_3_month_avg_cost_per_event,

        round(
            (
                cost_per_operational_event
                - lag(cost_per_operational_event)
                    over (order by event_month)
            )
            / nullif(
                lag(cost_per_operational_event)
                    over (order by event_month),
                0
            ) * 100,
            2
        ) as month_over_month_cost_change_pct

    from baseline_metrics

)

select
    event_month,

    total_operational_events,
    total_operational_cost,

    cost_per_operational_event,

    rolling_3_month_avg_cost_per_event,
    month_over_month_cost_change_pct,

    refund_event_ratio,
    unresolved_event_ratio,
    high_risk_event_ratio,

    current_timestamp() as gold_loaded_at

from trend_metrics

order by event_month