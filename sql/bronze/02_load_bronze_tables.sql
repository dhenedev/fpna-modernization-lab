-- ============================================================
-- FP&A Modernization Lab
-- Bronze Layer CSV Load Script
--
-- Purpose:
-- Loads synthetic CSV datasets from the internal Snowflake stage
-- into bronze tables.
--
-- Prerequisite:
-- Upload CSV files from data/synthetic/ into:
-- INGESTION.SYNTHETIC_FINANCE_STAGE
-- ============================================================

USE DATABASE FPNA_MODERNIZATION_LAB;
USE WAREHOUSE FPNA_LAB_WH;

-- ============================================================
-- File Format
-- ============================================================

CREATE OR REPLACE FILE FORMAT INGESTION.CSV_STANDARD_FORMAT
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE
    DATE_FORMAT = 'AUTO'
    TRIM_SPACE = TRUE;

-- ============================================================
-- Load Vendors
-- ============================================================

COPY INTO BRONZE.bronze_vendors
FROM @INGESTION.SYNTHETIC_FINANCE_STAGE/vendors.csv
FILE_FORMAT = INGESTION.CSV_STANDARD_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================
-- Load GL Accounts
-- ============================================================

COPY INTO BRONZE.bronze_gl_accounts
FROM @INGESTION.SYNTHETIC_FINANCE_STAGE/gl_accounts.csv
FILE_FORMAT = INGESTION.CSV_STANDARD_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================
-- Load Assets
-- ============================================================

COPY INTO BRONZE.bronze_assets
FROM @INGESTION.SYNTHETIC_FINANCE_STAGE/assets.csv
FILE_FORMAT = INGESTION.CSV_STANDARD_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================
-- Load Employees
-- ============================================================

COPY INTO BRONZE.bronze_employees
FROM @INGESTION.SYNTHETIC_FINANCE_STAGE/employees.csv
FILE_FORMAT = INGESTION.CSV_STANDARD_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================
-- Load Invoices
-- ============================================================

COPY INTO BRONZE.bronze_invoices
FROM @INGESTION.SYNTHETIC_FINANCE_STAGE/invoices.csv
FILE_FORMAT = INGESTION.CSV_STANDARD_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================
-- Load Work Orders
-- ============================================================

COPY INTO BRONZE.bronze_work_orders
FROM @INGESTION.SYNTHETIC_FINANCE_STAGE/work_orders.csv
FILE_FORMAT = INGESTION.CSV_STANDARD_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================
-- Load Forecast
-- ============================================================

COPY INTO BRONZE.bronze_forecast
FROM @INGESTION.SYNTHETIC_FINANCE_STAGE/forecast.csv
FILE_FORMAT = INGESTION.CSV_STANDARD_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================
-- Load Validation
-- ============================================================

SELECT 'bronze_vendors' AS table_name, COUNT(*) AS row_count FROM BRONZE.bronze_vendors
UNION ALL
SELECT 'bronze_gl_accounts', COUNT(*) FROM BRONZE.bronze_gl_accounts
UNION ALL
SELECT 'bronze_assets', COUNT(*) FROM BRONZE.bronze_assets
UNION ALL
SELECT 'bronze_employees', COUNT(*) FROM BRONZE.bronze_employees
UNION ALL
SELECT 'bronze_invoices', COUNT(*) FROM BRONZE.bronze_invoices
UNION ALL
SELECT 'bronze_work_orders', COUNT(*) FROM BRONZE.bronze_work_orders
UNION ALL
SELECT 'bronze_forecast', COUNT(*) FROM BRONZE.bronze_forecast;