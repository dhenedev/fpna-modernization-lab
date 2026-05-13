# FP&A Modernization Lab — Synthetic Data Design

## Overview

This document defines the synthetic datasets used by the FP&A Modernization Lab.

The datasets are designed to simulate common enterprise finance and operations modernization challenges while avoiding any client, employer, proprietary, or confidential information.

## Design Goals

The synthetic data should support demonstration of:

- Snowflake medallion architecture
- finance and operations reporting
- data quality monitoring
- vendor governance
- executive KPI modeling
- cash flow visibility
- operational performance analytics
- AI-assisted analytics concepts

---

# Dataset Inventory

| Dataset | Domain | Purpose |
|---|---|---|
| vendors.csv | Finance / Vendor Management | Vendor master and hierarchy issues |
| invoices.csv | Finance | AP/AR transaction activity |
| gl_accounts.csv | Finance | General ledger mapping reference |
| work_orders.csv | Operations | Field work and operational service activity |
| assets.csv | Operations / Asset Management | Infrastructure asset tracking |
| employees.csv | Workforce | Staffing, hierarchy, and utilization |
| forecast.csv | FP&A | Forecast vs actual analysis |

---

# Key Data Quality Scenarios

The synthetic data will intentionally include controlled data quality issues.

| Scenario | Example |
|---|---|
| Duplicate vendors | Same vendor represented with slight naming variations |
| Missing categorization | Vendor records missing category values |
| Invalid GL mapping | Invoice records mapped to invalid GL accounts |
| Stale operational data | Work orders not updated within expected timeframe |
| Missing hierarchy | Employees missing manager assignments |
| Forecast variance | Actuals materially different from forecasted values |

---

# Core Entity Relationships

```mermaid
erDiagram

    VENDORS ||--o{ INVOICES : submits
    GL_ACCOUNTS ||--o{ INVOICES : categorizes
    ASSETS ||--o{ WORK_ORDERS : requires
    EMPLOYEES ||--o{ WORK_ORDERS : assigned_to
    FORECAST ||--o{ INVOICES : compares_to

    VENDORS {
        string vendor_id
        string vendor_name
        string parent_vendor
        string vendor_category
        string payment_terms
        string region
    }

    INVOICES {
        string invoice_id
        string vendor_id
        string invoice_type
        date invoice_date
        number amount
        string gl_account
        string payment_status
        string region
    }

    GL_ACCOUNTS {
        string gl_account
        string gl_category
        string financial_statement_line
    }

    WORK_ORDERS {
        string work_order_id
        string asset_id
        string employee_id
        string assigned_region
        string completion_status
        number response_time_hours
        number operational_cost
    }

    ASSETS {
        string asset_id
        string asset_type
        string region
        string maintenance_status
        string replacement_risk
    }

    EMPLOYEES {
        string employee_id
        string department
        string region
        number utilization_rate
        string manager_id
    }

    FORECAST {
        string forecast_id
        string period
        string region
        string gl_account
        number forecast_amount
        number actual_amount
    }