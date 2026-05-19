USE DATABASE FPNA_MODERNIZATION_LAB;
USE WAREHOUSE FPNA_LAB_WH;

COPY INTO BRONZE.bronze_operational_events
FROM @INGESTION.SYNTHETIC_FINANCE_STAGE/operational_events.csv
FILE_FORMAT = INGESTION.CSV_STANDARD_FORMAT
ON_ERROR = 'CONTINUE';

SELECT
    'bronze_operational_events' AS table_name,
    COUNT(*) AS row_count
FROM BRONZE.bronze_operational_events;