-- ============================================================
-- FP&A Modernization Lab
-- Environment Setup Script
--
-- Purpose:
-- Creates foundational Snowflake objects for a synthetic
-- FP&A modernization environment using bronze, silver, and gold
-- medallion architecture layers.
--
-- Note:
-- This project uses synthetic data only.
-- ============================================================

-- Create database
CREATE DATABASE IF NOT EXISTS FPNA_MODERNIZATION_LAB;

USE DATABASE FPNA_MODERNIZATION_LAB;

-- Create medallion schemas
CREATE SCHEMA IF NOT EXISTS BRONZE;
CREATE SCHEMA IF NOT EXISTS SILVER;
CREATE SCHEMA IF NOT EXISTS GOLD;

-- Create governance / monitoring schemas
CREATE SCHEMA IF NOT EXISTS GOVERNANCE;
CREATE SCHEMA IF NOT EXISTS AUDIT;

-- Create file stage schema
CREATE SCHEMA IF NOT EXISTS INGESTION;

-- Create warehouse
CREATE WAREHOUSE IF NOT EXISTS FPNA_LAB_WH
    WAREHOUSE_SIZE = XSMALL
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

-- Set context
USE WAREHOUSE FPNA_LAB_WH;

-- Optional: create internal stage for synthetic CSV files
CREATE STAGE IF NOT EXISTS INGESTION.SYNTHETIC_FINANCE_STAGE
    DIRECTORY = (ENABLE = TRUE);

-- Confirm environment setup
SELECT
    CURRENT_DATABASE() AS database_name,
    CURRENT_WAREHOUSE() AS warehouse_name,
    CURRENT_TIMESTAMP() AS setup_completed_at;