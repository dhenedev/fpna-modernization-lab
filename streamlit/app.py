import streamlit as st
import pandas as pd
from pathlib import Path

st.set_page_config(
    page_title="FP&A Modernization Command Center",
    page_icon="📊",
    layout="wide"
)

DATA_DIR = Path(__file__).resolve().parents[1] / "data" / "synthetic"

@st.cache_data
def load_data():
    return {
        "vendors": pd.read_csv(DATA_DIR / "vendors.csv"),
        "invoices": pd.read_csv(DATA_DIR / "invoices.csv"),
        "work_orders": pd.read_csv(DATA_DIR / "work_orders.csv"),
        "assets": pd.read_csv(DATA_DIR / "assets.csv"),
        "employees": pd.read_csv(DATA_DIR / "employees.csv"),
        "forecast": pd.read_csv(DATA_DIR / "forecast.csv"),
        "gl_accounts": pd.read_csv(DATA_DIR / "gl_accounts.csv"),
    }

data = load_data()

vendors = data["vendors"]
invoices = data["invoices"]
work_orders = data["work_orders"]
assets = data["assets"]
employees = data["employees"]
forecast = data["forecast"]

invoices["amount"] = pd.to_numeric(invoices["amount"], errors="coerce")
work_orders["operational_cost"] = pd.to_numeric(work_orders["operational_cost"], errors="coerce")
forecast["forecast_amount"] = pd.to_numeric(forecast["forecast_amount"], errors="coerce")
forecast["actual_amount"] = pd.to_numeric(forecast["actual_amount"], errors="coerce")

# Derived metrics
total_invoice_value = invoices["amount"].sum()
total_operational_cost = work_orders["operational_cost"].sum()
high_value_invoices = invoices[invoices["amount"] > 50000].shape[0]
invalid_gl_count = invoices[invoices["gl_account"] == 9999].shape[0] if invoices["gl_account"].dtype != "object" else invoices[invoices["gl_account"] == "9999"].shape[0]
forecast_variance = forecast["actual_amount"].sum() - forecast["forecast_amount"].sum()
forecast_accuracy = 100 - (abs(forecast_variance) / forecast["forecast_amount"].sum() * 100)
stale_assets = assets[assets["maintenance_status"].isna() | (assets["maintenance_status"] == "")].shape[0]
high_cost_work_orders = work_orders[work_orders["operational_cost"] > 15000].shape[0]
missing_vendor_categories = vendors[vendors["vendor_category"].isna() | (vendors["vendor_category"] == "")].shape[0]
governance_exception_count = (
    invalid_gl_count
    + high_value_invoices
    + stale_assets
    + high_cost_work_orders
    + missing_vendor_categories
)

# Header
st.title("FP&A Modernization Command Center")
st.caption(
    "Synthetic enterprise dashboard demonstrating Snowflake modernization, "
    "governance-aware analytics, executive reporting, and operational intelligence."
)

st.divider()

# Executive scorecard
st.subheader("Executive Scorecard")

col1, col2, col3, col4, col5 = st.columns(5)

col1.metric("Invoice Value", f"${total_invoice_value:,.0f}")
col2.metric("Operational Cost", f"${total_operational_cost:,.0f}")
col3.metric("Forecast Accuracy", f"{forecast_accuracy:,.1f}%")
col4.metric("Governance Exceptions", governance_exception_count)
col5.metric("High-Value Invoices", high_value_invoices)

st.divider()

# Executive narrative
st.subheader("Executive Summary")

if governance_exception_count > 25:
    risk_level = "elevated"
elif governance_exception_count > 10:
    risk_level = "moderate"
else:
    risk_level = "controlled"

st.info(
    f"This synthetic modernization environment shows ${total_invoice_value:,.0f} in invoice activity "
    f"and ${total_operational_cost:,.0f} in operational cost across distributed business functions. "
    f"Forecast accuracy is currently modeled at {forecast_accuracy:,.1f}%, while governance risk is "
    f"{risk_level} with {governance_exception_count} tracked exceptions across finance, vendor, asset, "
    f"and operational domains."
)

# Governance alerts
st.subheader("Governance & Operational Trust")

g1, g2, g3, g4, g5 = st.columns(5)

g1.metric("Invalid GL", invalid_gl_count)
g2.metric("Missing Vendor Categories", missing_vendor_categories)
g3.metric("High-Cost Work Orders", high_cost_work_orders)
g4.metric("Stale Asset Records", stale_assets)
g5.metric("High-Value Invoices", high_value_invoices)

governance_exceptions = pd.DataFrame({
    "Exception Type": [
        "Invalid GL Account",
        "Missing Vendor Category",
        "High-Value Invoice",
        "Stale Asset Record",
        "High-Cost Work Order"
    ],
    "Domain": [
        "Finance",
        "Vendor Governance",
        "Finance",
        "Asset Management",
        "Operations"
    ],
    "Severity": [
        "High",
        "Medium",
        "Medium",
        "Medium",
        "High"
    ],
    "Count": [
        invalid_gl_count,
        missing_vendor_categories,
        high_value_invoices,
        stale_assets,
        high_cost_work_orders,
    ]
})

st.dataframe(governance_exceptions, use_container_width=True)

st.divider()

# Charts
left, right = st.columns(2)

with left:
    st.subheader("Vendor Spend by Region")
    vendor_spend = (
        invoices.groupby("region", as_index=False)["amount"]
        .sum()
        .sort_values("amount", ascending=False)
    )
    st.bar_chart(vendor_spend, x="region", y="amount")

with right:
    st.subheader("Operational Cost by Region")
    ops_cost = (
        work_orders.groupby("assigned_region", as_index=False)["operational_cost"]
        .sum()
        .sort_values("operational_cost", ascending=False)
    )
    st.bar_chart(ops_cost, x="assigned_region", y="operational_cost")

left, right = st.columns(2)

with left:
    st.subheader("Forecast vs Actual")
    forecast_summary = (
        forecast.groupby("period", as_index=False)[["forecast_amount", "actual_amount"]]
        .sum()
        .sort_values("period")
    )
    st.line_chart(forecast_summary, x="period", y=["forecast_amount", "actual_amount"])

with right:
    st.subheader("Asset Health by Risk Level")
    asset_health = (
        assets.groupby("replacement_risk", as_index=False)["asset_id"]
        .count()
        .rename(columns={"asset_id": "asset_count"})
        .sort_values("asset_count", ascending=False)
    )
    st.bar_chart(asset_health, x="replacement_risk", y="asset_count")

st.divider()

# Platform health
st.subheader("Platform Health")

p1, p2, p3, p4 = st.columns(4)

p1.metric("Synthetic Datasets", len(data))
p2.metric("Bronze Sources", 7)
p3.metric("dbt Models", 2)
p4.metric("dbt Tests", 7)

st.caption(
    "Platform pattern: synthetic CSV sources → Snowflake bronze layer → governed silver transformations → "
    "gold KPI models → Streamlit executive dashboard."
)

with st.expander("View Source Data Samples"):
    selected = st.selectbox(
        "Select dataset",
        ["invoices", "vendors", "work_orders", "assets", "employees", "forecast", "gl_accounts"]
    )
    st.dataframe(data[selected].head(25), use_container_width=True)

st.divider()

st.caption(
    "Synthetic portfolio project only. No client, employer, proprietary, or confidential data is included."
)