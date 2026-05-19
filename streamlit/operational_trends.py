import streamlit as st
import pandas as pd
from pathlib import Path

st.set_page_config(
    page_title="Operational Trend Intelligence",
    page_icon="📈",
    layout="wide"
)

DATA_DIR = Path(__file__).resolve().parents[1] / "data" / "synthetic"

@st.cache_data
def load_operational_events():
    events = pd.read_csv(DATA_DIR / "operational_events.csv")
    events["event_timestamp"] = pd.to_datetime(events["event_timestamp"])
    events["operational_cost"] = pd.to_numeric(events["operational_cost"], errors="coerce")
    events["revenue_impact"] = pd.to_numeric(events["revenue_impact"], errors="coerce")
    return events

events = load_operational_events()
events["event_month"] = events["event_timestamp"].dt.to_period("M").dt.to_timestamp()

monthly = (
    events.groupby("event_month", as_index=False)
    .agg(
        total_operational_events=("event_id", "count"),
        total_operational_cost=("operational_cost", "sum"),
        total_revenue_impact=("revenue_impact", "sum"),
        refund_events=("event_type", lambda x: (x == "refund_issued").sum()),
        high_risk_events=("governance_risk_level", lambda x: (x == "High").sum()),
        unresolved_events=("event_status", lambda x: x.isin(["Open", "Delayed"]).sum()),
    )
    .sort_values("event_month")
)

monthly["cost_per_event"] = monthly["total_operational_cost"] / monthly["total_operational_events"]
monthly["rolling_3_month_cost_per_event"] = monthly["cost_per_event"].rolling(3, min_periods=1).mean()
monthly["mom_cost_per_event_change_pct"] = monthly["cost_per_event"].pct_change() * 100
monthly["refund_event_ratio"] = monthly["refund_events"] / monthly["total_operational_events"]
monthly["high_risk_event_ratio"] = monthly["high_risk_events"] / monthly["total_operational_events"]
monthly["unresolved_event_ratio"] = monthly["unresolved_events"] / monthly["total_operational_events"]

latest_month = monthly["event_month"].max()
window_start = latest_month - pd.DateOffset(months=12)
rolling_13 = monthly[monthly["event_month"] >= window_start].copy()

latest = rolling_13.iloc[-1]
prior = rolling_13.iloc[-2] if len(rolling_13) > 1 else latest

st.title("Operational Trend Intelligence")
st.caption(
    "Rolling 13-month view of workload, cost acceleration, and operational efficiency baseline telemetry."
)

st.divider()

st.subheader("Executive Trend Snapshot")

c1, c2, c3, c4 = st.columns(4)

c1.metric(
    "Current Month Workload",
    f"{latest['total_operational_events']:,.0f}",
    f"{latest['total_operational_events'] - prior['total_operational_events']:,.0f} vs prior month"
)

c2.metric(
    "Current Month Cost",
    f"${latest['total_operational_cost']:,.0f}",
    f"${latest['total_operational_cost'] - prior['total_operational_cost']:,.0f} vs prior month"
)

c3.metric(
    "Cost per Event",
    f"${latest['cost_per_event']:,.0f}",
    f"{latest['mom_cost_per_event_change_pct']:,.1f}% MoM"
)

c4.metric(
    "3-Month Baseline",
    f"${latest['rolling_3_month_cost_per_event']:,.0f}"
)

st.info(
    "This view emphasizes directional operational context. Cost movement is interpreted against workload volume "
    "and a rolling baseline to avoid overreacting to expected volatility or seasonal operating patterns."
)

st.divider()

left, right = st.columns([2, 1])

with left:
    st.subheader("Cost per Operational Event vs Rolling Baseline")
    st.line_chart(
        rolling_13,
        x="event_month",
        y=["cost_per_event", "rolling_3_month_cost_per_event"]
    )

with right:
    st.subheader("Latest Period Ratios")
    ratio_df = pd.DataFrame({
        "Signal": [
            "Refund Event Ratio",
            "High-Risk Event Ratio",
            "Unresolved Event Ratio"
        ],
        "Latest Value": [
            f"{latest['refund_event_ratio']:.1%}",
            f"{latest['high_risk_event_ratio']:.1%}",
            f"{latest['unresolved_event_ratio']:.1%}",
        ]
    })
    st.dataframe(ratio_df, use_container_width=True, hide_index=True)

st.divider()

left, right = st.columns(2)

with left:
    st.subheader("Operational Workload Trend")

    workload_chart = rolling_13.copy()

    workload_chart["avg_operational_events"] = (
        workload_chart["total_operational_events"].mean()
    )

    st.line_chart(
        workload_chart,
        x="event_month",
        y=["total_operational_events", "avg_operational_events"]
    )

with right:
    st.subheader("Operational Cost Trend")

    cost_chart = rolling_13.copy()

    cost_chart["avg_operational_cost"] = (
        cost_chart["total_operational_cost"].mean()
    )

    st.line_chart(
        cost_chart,
        x="event_month",
        y=["total_operational_cost", "avg_operational_cost"]
    )

st.divider()

st.subheader("Rolling 13-Month Baseline Detail")

baseline_detail = rolling_13[[
    "event_month",
    "total_operational_events",
    "total_operational_cost",
    "cost_per_event",
    "rolling_3_month_cost_per_event",
    "mom_cost_per_event_change_pct",
    "refund_event_ratio",
    "high_risk_event_ratio",
    "unresolved_event_ratio",
]].copy()

baseline_detail["event_month"] = baseline_detail["event_month"].dt.strftime("%Y-%m")
baseline_detail["total_operational_cost"] = baseline_detail["total_operational_cost"].round(2)
baseline_detail["cost_per_event"] = baseline_detail["cost_per_event"].round(2)
baseline_detail["rolling_3_month_cost_per_event"] = baseline_detail["rolling_3_month_cost_per_event"].round(2)
baseline_detail["mom_cost_per_event_change_pct"] = baseline_detail["mom_cost_per_event_change_pct"].round(2)
baseline_detail["refund_event_ratio"] = baseline_detail["refund_event_ratio"].round(4)
baseline_detail["high_risk_event_ratio"] = baseline_detail["high_risk_event_ratio"].round(4)
baseline_detail["unresolved_event_ratio"] = baseline_detail["unresolved_event_ratio"].round(4)

st.dataframe(baseline_detail, use_container_width=True, hide_index=True)

st.caption(
    "Synthetic operational telemetry only. Designed to demonstrate trend-aware operational intelligence, "
    "baseline comparison, and sustainable executive visibility."
)