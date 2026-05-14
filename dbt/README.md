# dbt Transformation Framework

This folder contains the planned dbt transformation framework for the FP&A Modernization Lab.

The goal is to evolve SQL transformation scripts into a modern analytics engineering workflow with:

- modular transformation models
- source definitions
- model documentation
- data tests
- lineage visibility
- governed analytics development

## Planned Model Layers

| Layer | Purpose |
|---|---|
| Sources | Bronze-layer Snowflake tables |
| Silver | Standardized governed business entities |
| Gold | Business-ready KPI and reporting models |

## Future Enhancements

- dbt source freshness checks
- schema tests
- model documentation
- lineage graph
- reusable macros
- CI-friendly transformation workflow