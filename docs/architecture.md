# FP&A Modernization Lab — Architecture

## Overview

This document describes the target architecture for the FP&A Modernization Lab.

The architecture demonstrates how a synthetic infrastructure services company can modernize fragmented finance and operations reporting into a governed Snowflake-based analytics platform.

The design emphasizes:

- medallion architecture
- governed analytics
- data quality monitoring
- executive reporting
- AI-assisted analytics concepts
- business and technical traceability

---

# Architecture Goals

The architecture is designed to demonstrate how enterprise data platforms can improve:

- reporting trust
- finance visibility
- operational transparency
- KPI consistency
- governance maturity
- executive decision-making
- AI readiness

---

# High-Level Architecture

```mermaid
flowchart LR

    subgraph Source Systems
        ERP[Finance ERP]
        OPS[Field Operations System]
        ASSET[Asset Management System]
        WFM[Workforce Management System]
    end

    subgraph Ingestion Layer
        FILES[CSV / File Extracts]
        LOAD[Snowflake Stages]
    end

    subgraph Snowflake Data Platform
        BRONZE[Bronze Layer<br/>Raw Source Data]
        SILVER[Silver Layer<br/>Standardized & Governed Data]
        GOLD[Gold Layer<br/>Business Analytics Models]
    end

    subgraph Governance & Quality
        DQ[Data Quality Rules]
        RBAC[RBAC Concepts]
        EXCEPTIONS[Exception Monitoring]
        LINEAGE[Lineage & Auditability]
    end

    subgraph Analytics & Reporting
        KPI[Executive KPI Models]
        STREAMLIT[Streamlit Dashboard]
        SUMMARY[AI-Assisted Summaries]
    end

    ERP --> FILES
    OPS --> FILES
    ASSET --> FILES
    WFM --> FILES

    FILES --> LOAD
    LOAD --> BRONZE
    BRONZE --> SILVER
    SILVER --> GOLD

    SILVER --> DQ
    GOLD --> KPI
    DQ --> EXCEPTIONS
    RBAC --> SILVER
    RBAC --> GOLD
    SILVER --> LINEAGE
    GOLD --> LINEAGE

    KPI --> STREAMLIT
    GOLD --> STREAMLIT
    GOLD --> SUMMARY