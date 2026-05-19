USE DATABASE FPNA_MODERNIZATION_LAB;
USE SCHEMA BRONZE;

CREATE OR REPLACE TABLE bronze_operational_events (
    event_id STRING,
    event_timestamp DATE,
    event_type STRING,
    business_domain STRING,
    region STRING,
    related_entity_id STRING,
    operational_cost NUMBER(12,2),
    revenue_impact NUMBER(12,2),
    governance_risk_level STRING,
    business_impact_hours FLOAT,
    event_status STRING
);

SHOW TABLES IN SCHEMA BRONZE;