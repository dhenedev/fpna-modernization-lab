-- ============================================================
-- FP&A Modernization Lab
-- Governance Exception Monitoring
--
-- Purpose:
-- Centralize governance and data quality visibility across
-- silver-layer business entities.
--
-- Note:
-- This model intentionally surfaces operational trust issues
-- rather than suppressing them.
-- ============================================================

USE DATABASE FPNA_MODERNIZATION_LAB;
USE SCHEMA GOVERNANCE;

-- ============================================================
-- Vendor Governance Exceptions
-- ============================================================

CREATE OR REPLACE VIEW vendor_governance_exceptions AS

SELECT
    'VENDOR' AS domain,
    vendor_id AS record_id,
    vendor_name AS record_name,
    'MISSING_VENDOR_CATEGORY' AS exception_type,
    'MEDIUM' AS severity,
    silver_loaded_at AS detected_at

FROM SILVER.silver_vendors

WHERE missing_category_flag = TRUE;

-- ============================================================
-- Invoice Governance Exceptions
-- ============================================================

CREATE OR REPLACE VIEW invoice_governance_exceptions AS

SELECT
    'INVOICE' AS domain,
    invoice_id AS record_id,
    vendor_id AS record_name,
    'INVALID_GL_ACCOUNT' AS exception_type,
    'HIGH' AS severity,
    silver_loaded_at AS detected_at

FROM SILVER.silver_invoices

WHERE invalid_gl_flag = TRUE

UNION ALL

SELECT
    'INVOICE',
    invoice_id,
    vendor_id,
    'HIGH_VALUE_TRANSACTION',
    'MEDIUM',
    silver_loaded_at

FROM SILVER.silver_invoices

WHERE high_value_invoice_flag = TRUE;

-- ============================================================
-- Workforce Governance Exceptions
-- ============================================================

CREATE OR REPLACE VIEW workforce_governance_exceptions AS

SELECT
    'EMPLOYEE' AS domain,
    employee_id AS record_id,
    department AS record_name,
    'UTILIZATION_OUTLIER' AS exception_type,
    'MEDIUM' AS severity,
    silver_loaded_at AS detected_at

FROM SILVER.silver_employees

WHERE utilization_outlier_flag = TRUE;

-- ============================================================
-- Asset Governance Exceptions
-- ============================================================

CREATE OR REPLACE VIEW asset_governance_exceptions AS

SELECT
    'ASSET' AS domain,
    asset_id AS record_id,
    asset_type AS record_name,
    'STALE_INSPECTION_RECORD' AS exception_type,
    'MEDIUM' AS severity,
    silver_loaded_at AS detected_at

FROM SILVER.silver_assets

WHERE stale_inspection_flag = TRUE;

-- ============================================================
-- Work Order Governance Exceptions
-- ============================================================

CREATE OR REPLACE VIEW work_order_governance_exceptions AS

SELECT
    'WORK_ORDER' AS domain,
    work_order_id AS record_id,
    assigned_region AS record_name,
    'STALE_WORK_ORDER' AS exception_type,
    'MEDIUM' AS severity,
    silver_loaded_at AS detected_at

FROM SILVER.silver_work_orders

WHERE stale_work_order_flag = TRUE

UNION ALL

SELECT
    'WORK_ORDER',
    work_order_id,
    assigned_region,
    'HIGH_OPERATIONAL_COST',
    'HIGH',
    silver_loaded_at

FROM SILVER.silver_work_orders

WHERE high_cost_work_order_flag = TRUE;

-- ============================================================
-- Forecast Governance Exceptions
-- ============================================================

CREATE OR REPLACE VIEW forecast_governance_exceptions AS

SELECT
    'FORECAST' AS domain,
    forecast_id AS record_id,
    region AS record_name,
    'MATERIAL_FORECAST_VARIANCE' AS exception_type,
    'HIGH' AS severity,
    silver_loaded_at AS detected_at

FROM SILVER.silver_forecast

WHERE material_variance_flag = TRUE;

-- ============================================================
-- Unified Governance Exception View
-- ============================================================

CREATE OR REPLACE VIEW governance_exception_summary AS

SELECT * FROM vendor_governance_exceptions
UNION ALL
SELECT * FROM invoice_governance_exceptions
UNION ALL
SELECT * FROM workforce_governance_exceptions
UNION ALL
SELECT * FROM asset_governance_exceptions
UNION ALL
SELECT * FROM work_order_governance_exceptions
UNION ALL
SELECT * FROM forecast_governance_exceptions;

-- ============================================================
-- Validation
-- ============================================================

SELECT
    domain,
    exception_type,
    severity,
    COUNT(*) AS exception_count

FROM governance_exception_summary

GROUP BY
    domain,
    exception_type,
    severity

ORDER BY
    severity DESC,
    exception_count DESC;