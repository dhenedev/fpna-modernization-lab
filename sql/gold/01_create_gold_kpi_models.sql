-- ============================================================
-- FP&A Modernization Lab
-- Gold Layer KPI Models
--
-- Purpose:
-- Create business-ready KPI models for executive reporting,
-- operational visibility, finance analytics, and governance-aware
-- decision support.
-- ============================================================

USE DATABASE FPNA_MODERNIZATION_LAB;
USE SCHEMA GOLD;

-- ============================================================
-- Cash Flow Summary
-- ============================================================

CREATE OR REPLACE VIEW gold_cash_flow_summary AS

SELECT
    region,
    invoice_type,
    payment_status,
    DATE_TRUNC('MONTH', invoice_date) AS reporting_month,
    COUNT(*) AS invoice_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS average_invoice_amount,
    SUM(CASE WHEN high_value_invoice_flag THEN amount ELSE 0 END) AS high_value_invoice_amount,
    COUNT_IF(invalid_gl_flag) AS invalid_gl_count

FROM SILVER.silver_invoices

GROUP BY
    region,
    invoice_type,
    payment_status,
    DATE_TRUNC('MONTH', invoice_date);

-- ============================================================
-- Vendor Spend Analytics
-- ============================================================

CREATE OR REPLACE VIEW gold_vendor_spend AS

SELECT
    v.vendor_id,
    v.vendor_name,
    v.parent_vendor,
    v.vendor_category,
    v.region,
    COUNT(i.invoice_id) AS invoice_count,
    SUM(i.amount) AS total_spend,
    AVG(i.amount) AS average_invoice_amount,
    COUNT_IF(i.high_value_invoice_flag) AS high_value_invoice_count,
    COUNT_IF(i.invalid_gl_flag) AS invalid_gl_count

FROM SILVER.silver_vendors v

LEFT JOIN SILVER.silver_invoices i
    ON v.vendor_id = i.vendor_id

GROUP BY
    v.vendor_id,
    v.vendor_name,
    v.parent_vendor,
    v.vendor_category,
    v.region;

-- ============================================================
-- Operational KPI Summary
-- ============================================================

CREATE OR REPLACE VIEW gold_operational_kpis AS

SELECT
    assigned_region AS region,
    completion_status,
    COUNT(*) AS work_order_count,
    AVG(response_time_hours) AS average_response_time_hours,
    SUM(operational_cost) AS total_operational_cost,
    AVG(operational_cost) AS average_operational_cost,
    COUNT_IF(stale_work_order_flag) AS stale_work_order_count,
    COUNT_IF(high_cost_work_order_flag) AS high_cost_work_order_count

FROM SILVER.silver_work_orders

GROUP BY
    assigned_region,
    completion_status;

-- ============================================================
-- Forecast Accuracy
-- ============================================================

CREATE OR REPLACE VIEW gold_forecast_accuracy AS

SELECT
    period,
    region,
    gl_account,
    SUM(forecast_amount) AS total_forecast_amount,
    SUM(actual_amount) AS total_actual_amount,
    SUM(variance_amount) AS total_variance_amount,
    ROUND(
        ((SUM(actual_amount) - SUM(forecast_amount)) / NULLIF(SUM(forecast_amount), 0)) * 100,
        2
    ) AS variance_percent,
    COUNT_IF(material_variance_flag) AS material_variance_count

FROM SILVER.silver_forecast

GROUP BY
    period,
    region,
    gl_account;

-- ============================================================
-- Asset Health Summary
-- ============================================================

CREATE OR REPLACE VIEW gold_asset_health AS

SELECT
    region,
    asset_type,
    maintenance_status,
    replacement_risk,
    COUNT(*) AS asset_count,
    COUNT_IF(stale_inspection_flag) AS stale_inspection_count

FROM SILVER.silver_assets

GROUP BY
    region,
    asset_type,
    maintenance_status,
    replacement_risk;

-- ============================================================
-- Executive KPI Scorecard
-- ============================================================

CREATE OR REPLACE VIEW gold_executive_kpi_scorecard AS

SELECT
    'TOTAL_INVOICE_VALUE' AS kpi_name,
    SUM(amount) AS kpi_value,
    'Finance' AS kpi_domain
FROM SILVER.silver_invoices

UNION ALL

SELECT
    'HIGH_VALUE_INVOICE_COUNT',
    COUNT_IF(high_value_invoice_flag),
    'Finance'
FROM SILVER.silver_invoices

UNION ALL

SELECT
    'INVALID_GL_EXCEPTION_COUNT',
    COUNT_IF(invalid_gl_flag),
    'Governance'
FROM SILVER.silver_invoices

UNION ALL

SELECT
    'TOTAL_OPERATIONAL_COST',
    SUM(operational_cost),
    'Operations'
FROM SILVER.silver_work_orders

UNION ALL

SELECT
    'STALE_WORK_ORDER_COUNT',
    COUNT_IF(stale_work_order_flag),
    'Operations'
FROM SILVER.silver_work_orders

UNION ALL

SELECT
    'MATERIAL_FORECAST_VARIANCE_COUNT',
    COUNT_IF(material_variance_flag),
    'FP&A'
FROM SILVER.silver_forecast

UNION ALL

SELECT
    'STALE_ASSET_INSPECTION_COUNT',
    COUNT_IF(stale_inspection_flag),
    'Asset Management'
FROM SILVER.silver_assets;

-- ============================================================
-- Validation
-- ============================================================

SELECT 'gold_cash_flow_summary' AS model_name, COUNT(*) AS row_count FROM gold_cash_flow_summary
UNION ALL
SELECT 'gold_vendor_spend', COUNT(*) FROM gold_vendor_spend
UNION ALL
SELECT 'gold_operational_kpis', COUNT(*) FROM gold_operational_kpis
UNION ALL
SELECT 'gold_forecast_accuracy', COUNT(*) FROM gold_forecast_accuracy
UNION ALL
SELECT 'gold_asset_health', COUNT(*) FROM gold_asset_health
UNION ALL
SELECT 'gold_executive_kpi_scorecard', COUNT(*) FROM gold_executive_kpi_scorecard;