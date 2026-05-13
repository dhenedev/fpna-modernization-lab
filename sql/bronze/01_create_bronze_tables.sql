-- ============================================================
-- FP&A Modernization Lab
-- Bronze Layer Table Definitions
--
-- Purpose:
-- Create raw bronze ingestion tables aligned to synthetic CSV
-- source datasets.
--
-- Note:
-- Bronze tables intentionally preserve source-system structure
-- with minimal transformation.
-- ============================================================

USE DATABASE FPNA_MODERNIZATION_LAB;
USE SCHEMA BRONZE;

-- ============================================================
-- Vendors
-- ============================================================

CREATE OR REPLACE TABLE bronze_vendors (
    vendor_id STRING,
    vendor_name STRING,
    parent_vendor STRING,
    vendor_category STRING,
    payment_terms STRING,
    region STRING
);

-- ============================================================
-- GL Accounts
-- ============================================================

CREATE OR REPLACE TABLE bronze_gl_accounts (
    gl_account STRING,
    gl_category STRING,
    financial_statement_line STRING
);

-- ============================================================
-- Assets
-- ============================================================

CREATE OR REPLACE TABLE bronze_assets (
    asset_id STRING,
    asset_type STRING,
    region STRING,
    maintenance_status STRING,
    replacement_risk STRING,
    last_inspection_date DATE
);

-- ============================================================
-- Employees
-- ============================================================

CREATE OR REPLACE TABLE bronze_employees (
    employee_id STRING,
    department STRING,
    region STRING,
    utilization_rate FLOAT,
    manager_id STRING
);

-- ============================================================
-- Invoices
-- ============================================================

CREATE OR REPLACE TABLE bronze_invoices (
    invoice_id STRING,
    vendor_id STRING,
    invoice_type STRING,
    invoice_date DATE,
    amount NUMBER(12,2),
    gl_account STRING,
    payment_status STRING,
    region STRING
);

-- ============================================================
-- Work Orders
-- ============================================================

CREATE OR REPLACE TABLE bronze_work_orders (
    work_order_id STRING,
    asset_id STRING,
    employee_id STRING,
    assigned_region STRING,
    completion_status STRING,
    response_time_hours FLOAT,
    operational_cost NUMBER(12,2),
    last_updated_date DATE
);

-- ============================================================
-- Forecast
-- ============================================================

CREATE OR REPLACE TABLE bronze_forecast (
    forecast_id STRING,
    period STRING,
    region STRING,
    gl_account STRING,
    forecast_amount NUMBER(12,2),
    actual_amount NUMBER(12,2)
);

-- ============================================================
-- Validation
-- ============================================================

SHOW TABLES IN SCHEMA BRONZE;