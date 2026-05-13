-- ============================================================
-- FP&A Modernization Lab
-- Silver Layer Transformation Models
--
-- Purpose:
-- Standardize, validate, and govern core business entities
-- from the bronze layer.
--
-- Note:
-- Silver models intentionally surface governance and DQ
-- concepts rather than silently masking issues.
-- ============================================================

USE DATABASE FPNA_MODERNIZATION_LAB;
USE SCHEMA SILVER;

-- ============================================================
-- Silver Vendors
-- ============================================================

CREATE OR REPLACE TABLE silver_vendors AS

SELECT
    vendor_id,

    -- Standardize vendor naming
    UPPER(TRIM(vendor_name)) AS vendor_name,

    -- Standardize parent vendor
    CASE
        WHEN parent_vendor IS NULL OR TRIM(parent_vendor) = ''
            THEN 'UNASSIGNED_PARENT'
        ELSE UPPER(TRIM(parent_vendor))
    END AS parent_vendor,

    -- Standardize vendor category
    CASE
        WHEN vendor_category IS NULL OR TRIM(vendor_category) = ''
            THEN 'UNCLASSIFIED'
        ELSE UPPER(TRIM(vendor_category))
    END AS vendor_category,

    payment_terms,

    UPPER(TRIM(region)) AS region,

    -- Governance flags
    CASE
        WHEN vendor_category IS NULL OR TRIM(vendor_category) = ''
            THEN TRUE
        ELSE FALSE
    END AS missing_category_flag,

    CURRENT_TIMESTAMP() AS silver_loaded_at

FROM BRONZE.bronze_vendors;

-- ============================================================
-- Silver GL Accounts
-- ============================================================

CREATE OR REPLACE TABLE silver_gl_accounts AS

SELECT
    gl_account,
    UPPER(TRIM(gl_category)) AS gl_category,
    UPPER(TRIM(financial_statement_line)) AS financial_statement_line,
    CURRENT_TIMESTAMP() AS silver_loaded_at

FROM BRONZE.bronze_gl_accounts;

-- ============================================================
-- Silver Employees
-- ============================================================

CREATE OR REPLACE TABLE silver_employees AS

SELECT
    employee_id,

    -- Standardize department names
    CASE
        WHEN UPPER(TRIM(department)) = 'OPS'
            THEN 'OPERATIONS'
        ELSE UPPER(TRIM(department))
    END AS department,

    UPPER(TRIM(region)) AS region,

    utilization_rate,

    CASE
        WHEN manager_id IS NULL OR TRIM(manager_id) = ''
            THEN 'UNASSIGNED_MANAGER'
        ELSE manager_id
    END AS manager_id,

    -- Governance flags
    CASE
        WHEN utilization_rate > 1.0
            THEN TRUE
        ELSE FALSE
    END AS utilization_outlier_flag,

    CURRENT_TIMESTAMP() AS silver_loaded_at

FROM BRONZE.bronze_employees;

-- ============================================================
-- Silver Assets
-- ============================================================

CREATE OR REPLACE TABLE silver_assets AS

SELECT
    asset_id,
    UPPER(TRIM(asset_type)) AS asset_type,
    UPPER(TRIM(region)) AS region,

    CASE
        WHEN maintenance_status IS NULL OR TRIM(maintenance_status) = ''
            THEN 'UNKNOWN'
        ELSE UPPER(TRIM(maintenance_status))
    END AS maintenance_status,

    UPPER(TRIM(replacement_risk)) AS replacement_risk,

    last_inspection_date,

    -- Freshness flag
    CASE
        WHEN DATEDIFF(DAY, last_inspection_date, CURRENT_DATE()) > 365
            THEN TRUE
        ELSE FALSE
    END AS stale_inspection_flag,

    CURRENT_TIMESTAMP() AS silver_loaded_at

FROM BRONZE.bronze_assets;

-- ============================================================
-- Silver Invoices
-- ============================================================

CREATE OR REPLACE TABLE silver_invoices AS

SELECT
    invoice_id,
    vendor_id,
    invoice_type,
    invoice_date,
    amount,
    gl_account,

    CASE
        WHEN payment_status IS NULL OR TRIM(payment_status) = ''
            THEN 'UNKNOWN'
        ELSE UPPER(TRIM(payment_status))
    END AS payment_status,

    UPPER(TRIM(region)) AS region,

    -- Governance checks
    CASE
        WHEN gl_account = '9999'
            THEN TRUE
        ELSE FALSE
    END AS invalid_gl_flag,

    CASE
        WHEN amount > 50000
            THEN TRUE
        ELSE FALSE
    END AS high_value_invoice_flag,

    CURRENT_TIMESTAMP() AS silver_loaded_at

FROM BRONZE.bronze_invoices;

-- ============================================================
-- Silver Work Orders
-- ============================================================

CREATE OR REPLACE TABLE silver_work_orders AS

SELECT
    work_order_id,
    asset_id,
    employee_id,
    UPPER(TRIM(assigned_region)) AS assigned_region,

    -- Normalize operational statuses
    CASE
        WHEN UPPER(TRIM(completion_status)) = 'DONE'
            THEN 'COMPLETE'
        ELSE UPPER(TRIM(completion_status))
    END AS completion_status,

    response_time_hours,
    operational_cost,
    last_updated_date,

    -- Freshness and operational flags
    CASE
        WHEN DATEDIFF(DAY, last_updated_date, CURRENT_DATE()) > 45
            THEN TRUE
        ELSE FALSE
    END AS stale_work_order_flag,

    CASE
        WHEN operational_cost > 15000
            THEN TRUE
        ELSE FALSE
    END AS high_cost_work_order_flag,

    CURRENT_TIMESTAMP() AS silver_loaded_at

FROM BRONZE.bronze_work_orders;

-- ============================================================
-- Silver Forecast
-- ============================================================

CREATE OR REPLACE TABLE silver_forecast AS

SELECT
    forecast_id,
    period,
    UPPER(TRIM(region)) AS region,
    gl_account,
    forecast_amount,
    actual_amount,

    actual_amount - forecast_amount AS variance_amount,

    ROUND(
        ((actual_amount - forecast_amount) / NULLIF(forecast_amount, 0)) * 100,
        2
    ) AS variance_percent,

    CASE
        WHEN ABS(actual_amount - forecast_amount) > 50000
            THEN TRUE
        ELSE FALSE
    END AS material_variance_flag,

    CURRENT_TIMESTAMP() AS silver_loaded_at

FROM BRONZE.bronze_forecast;

-- ============================================================
-- Validation Queries
-- ============================================================

SELECT 'silver_vendors' AS table_name, COUNT(*) AS row_count FROM silver_vendors
UNION ALL
SELECT 'silver_gl_accounts', COUNT(*) FROM silver_gl_accounts
UNION ALL
SELECT 'silver_employees', COUNT(*) FROM silver_employees
UNION ALL
SELECT 'silver_assets', COUNT(*) FROM silver_assets
UNION ALL
SELECT 'silver_invoices', COUNT(*) FROM silver_invoices
UNION ALL
SELECT 'silver_work_orders', COUNT(*) FROM silver_work_orders
UNION ALL
SELECT 'silver_forecast', COUNT(*) FROM silver_forecast;