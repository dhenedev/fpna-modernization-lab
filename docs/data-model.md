# FP&A Modernization Lab — Data Model

## Overview

This document defines the synthetic enterprise finance data model used throughout the FP&A Modernization Lab.

The model is designed to simulate common finance modernization challenges including:

- fragmented reporting systems
- inconsistent vendor mappings
- spreadsheet-driven workflows
- limited forecasting visibility
- inconsistent KPI definitions
- manual reconciliation
- stale operational reporting

The architecture supports demonstration of:

- Snowflake medallion architecture
- governance-aware analytics
- executive KPI reporting
- data quality frameworks
- AI-assisted operational intelligence concepts


---

# Synthetic Enterprise Scenario

## Company Overview

Northstar Infrastructure Services (synthetic organization) is a mid-market infrastructure operations company providing:

- utility maintenance services
- field inspections
- emergency infrastructure response
- asset maintenance operations
- regional operations management

The organization operates across multiple regions with distributed operational teams, external vendors, and finance reporting processes heavily dependent on spreadsheets and manually consolidated reporting workflows.

---

# Modernization Challenges

The organization currently faces several common enterprise modernization challenges:

## Finance Challenges

- fragmented forecasting processes
- inconsistent vendor mappings
- delayed operational reporting
- spreadsheet-driven reconciliation
- limited cash flow visibility
- inconsistent KPI definitions

---

## Operational Challenges

- siloed reporting systems
- inconsistent regional reporting
- delayed field operations visibility
- limited executive operational dashboards
- reactive incident reporting

---

## Governance Challenges

- inconsistent master data definitions
- duplicate vendor entities
- inconsistent GL categorization
- incomplete operational tagging
- lack of centralized governance workflows

---

# Modernization Goals

The FP&A Modernization Lab demonstrates how a governed Snowflake-based analytics platform can improve:

- executive visibility
- operational reporting
- forecast accuracy
- data trust
- governance consistency
- KPI standardization
- finance and operations alignment

---

# Core Business Domains

The synthetic environment models several core business domains:

| Domain | Description |
|---|---|
| Finance | AP/AR, forecasting, GL mappings, vendor spend |
| Operations | Field operations, response tracking, work orders |
| Vendors | Vendor hierarchy and spend management |
| Assets | Infrastructure asset tracking |
| Workforce | Regional operational staffing and utilization |
| Executive Reporting | KPI scorecards and operational summaries |

---
---

# Source Systems

The synthetic modernization environment models data ingestion from several disconnected enterprise systems.

These systems intentionally simulate common operational and finance modernization challenges including inconsistent identifiers, fragmented reporting, stale data, and governance gaps.

---

## Finance ERP System

### Purpose

Primary system for finance operations and accounting activity.

### Sample Data

- invoices
- accounts payable
- accounts receivable
- GL transactions
- vendor payments
- forecasting adjustments

### Example Challenges

- inconsistent GL mappings
- duplicate vendors
- delayed reconciliation
- manual export workflows

---

## Field Operations System

### Purpose

Tracks field service operations, work orders, inspections, and response activities.

### Sample Data

- work orders
- incident responses
- regional operations
- service completion metrics
- operational utilization

### Example Challenges

- inconsistent operational tagging
- delayed updates
- regional process inconsistency
- incomplete operational reporting

---

## Asset Management System

### Purpose

Tracks infrastructure assets and maintenance activities.

### Sample Data

- asset inventory
- maintenance schedules
- inspection records
- asset status
- replacement forecasting

### Example Challenges

- incomplete asset metadata
- inconsistent maintenance classifications
- fragmented asset ownership

---

## Workforce Management System

### Purpose

Tracks staffing, utilization, scheduling, and operational workforce allocation.

### Sample Data

- staffing assignments
- utilization metrics
- regional staffing levels
- overtime tracking
- scheduling activity

### Example Challenges

- inconsistent employee hierarchy mappings
- delayed utilization reporting
- manual staffing adjustments

---

# Core Business Entities

The modernization lab models several shared business entities across systems.

These entities intentionally contain governance and quality challenges to support data quality and modernization demonstrations.

---

# Vendor

Represents third-party service providers and operational suppliers.

## Example Attributes

| Attribute | Description |
|---|---|
| vendor_id | Unique vendor identifier |
| vendor_name | Vendor display name |
| parent_vendor | Parent organization |
| vendor_category | Operational category |
| payment_terms | Payment agreement |
| region | Operational region |

## Governance Challenges

- duplicate vendors
- inconsistent naming
- missing parent hierarchy
- incomplete categorization

---

# Invoice

Represents AP and AR financial transactions.

## Example Attributes

| Attribute | Description |
|---|---|
| invoice_id | Invoice identifier |
| vendor_id | Associated vendor |
| invoice_date | Transaction date |
| amount | Financial amount |
| GL_account | General ledger category |
| payment_status | Payment lifecycle status |

## Governance Challenges

- invalid GL mappings
- stale payment status
- duplicate invoice IDs
- missing operational tagging

---

# Work Order

Represents operational service activity performed by field teams.

## Example Attributes

| Attribute | Description |
|---|---|
| work_order_id | Operational work identifier |
| asset_id | Associated infrastructure asset |
| assigned_region | Regional operational team |
| completion_status | Operational status |
| response_time | SLA response measurement |
| operational_cost | Cost associated with work |

## Governance Challenges

- inconsistent status codes
- delayed operational updates
- missing cost allocations

---

# Asset

Represents managed infrastructure assets.

## Example Attributes

| Attribute | Description |
|---|---|
| asset_id | Infrastructure asset identifier |
| asset_type | Asset classification |
| region | Operating region |
| maintenance_status | Current operational status |
| replacement_risk | Forecasted replacement indicator |

## Governance Challenges

- incomplete metadata
- inconsistent classifications
- stale maintenance records

---

# Employee

Represents operational and finance workforce personnel.

## Example Attributes

| Attribute | Description |
|---|---|
| employee_id | Workforce identifier |
| department | Organizational unit |
| region | Operational region |
| utilization_rate | Workforce utilization |
| manager_id | Reporting hierarchy |

## Governance Challenges

- incomplete reporting hierarchy
- inconsistent department mappings
- delayed staffing updates

---

# Medallion Architecture Strategy

The FP&A Modernization Lab uses a medallion architecture pattern to demonstrate modern Snowflake data platform design principles.

The architecture separates data into progressively refined layers to improve:

- scalability
- governance
- auditability
- data trust
- reporting consistency
- operational visibility

---

# Architecture Layers

| Layer | Purpose |
|---|---|
| Bronze | Raw ingested source system data |
| Silver | Validated and standardized business entities |
| Gold | Business-ready analytics and KPI models |

---

# Bronze Layer — Raw Ingestion

## Purpose

The bronze layer stores raw source-system extracts with minimal transformation.

This layer preserves source fidelity and supports:

- auditability
- replay capability
- ingestion validation
- lineage tracking

---

## Example Bronze Tables

| Table | Description |
|---|---|
| bronze_invoices | Raw finance transactions |
| bronze_vendors | Raw vendor records |
| bronze_work_orders | Raw field operations activity |
| bronze_assets | Raw infrastructure assets |
| bronze_employees | Raw workforce records |

---

## Bronze Layer Characteristics

- append-focused ingestion
- limited transformation
- source-aligned schemas
- ingestion timestamps
- raw operational values

---

# Silver Layer — Standardized & Governed

## Purpose

The silver layer standardizes and validates core business entities.

This layer applies:

- data quality rules
- business validation logic
- master data alignment
- standardized operational definitions

---

## Example Silver Tables

| Table | Description |
|---|---|
| silver_vendors | Standardized vendor master |
| silver_invoices | Validated finance transactions |
| silver_work_orders | Standardized operational activities |
| silver_assets | Governed infrastructure asset records |
| silver_employees | Standardized workforce hierarchy |

---

## Silver Layer Responsibilities

- remove duplicates
- standardize naming
- validate business rules
- align master data
- enrich operational context
- flag quality exceptions

---

# Gold Layer — Business Analytics

## Purpose

The gold layer contains business-ready reporting and KPI models optimized for analytics and executive reporting.

This layer supports:

- dashboards
- executive scorecards
- operational reporting
- forecasting
- AI-assisted analytics concepts

---

## Example Gold Models

| Model | Description |
|---|---|
| gold_cash_flow_summary | Executive cash flow reporting |
| gold_vendor_spend | Vendor spend analytics |
| gold_operational_kpis | SLA and operational performance |
| gold_forecast_accuracy | Forecast vs actual analysis |
| gold_asset_health | Infrastructure maintenance visibility |

---

## Gold Layer Characteristics

- business-friendly schemas
- KPI-oriented models
- aggregated reporting structures
- executive-ready metrics
- governed business definitions

---

# Governance & Data Quality Flow

The modernization lab demonstrates governance-aware transformation workflows across all architecture layers.

---

## Governance Concepts

- RBAC-aligned access concepts
- controlled business definitions
- standardized KPI logic
- lineage-aware transformations
- auditability checkpoints

---

## Data Quality Concepts

| DQ Rule | Example |
|---|---|
| Completeness | Missing vendor categories |
| Validity | Invalid GL account mappings |
| Uniqueness | Duplicate invoice IDs |
| Freshness | Delayed operational updates |
| Consistency | Regional status code mismatches |

---

# Reporting & Analytics Flow

The architecture supports downstream reporting through:

- executive KPI dashboards
- operational intelligence reporting
- exception monitoring
- forecasting visibility
- AI-assisted summaries

The reporting layer is intentionally designed to demonstrate governance-aware executive reporting concepts.