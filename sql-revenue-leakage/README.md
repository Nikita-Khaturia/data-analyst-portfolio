# Revenue Leakage Identification Using SQL

## Overview

Revenue leakage -- the gap between what a company *should* collect and what it *actually* collects -- is one of the most overlooked sources of margin erosion. Industry estimates suggest that 1-5% of enterprise revenue is lost to billing errors, contract misalignment, and process breakdowns that go undetected without systematic reconciliation.

This project simulates a **contract-to-billing reconciliation** for a mid-size B2B SaaS company. Using SQL-driven analysis across seven dimensions, the investigation uncovered **~$500K in cumulative revenue discrepancies** spanning expired-contract billing, pricing mismatches, duplicate invoices, unapplied discounts, and charges against cancelled contracts.

The methodology mirrors the approach used in Big Four advisory engagements (e.g., identifying a $2.5M revenue discrepancy during a PwC contract audit) and is fully reproducible on any PostgreSQL or MySQL instance.

---

## Database Schema

```
 +----------------+        +------------------+        +----------------+
 |   customers    |        |    contracts      |        |    products     |
 |----------------|        |------------------|        |----------------|
 | customer_id PK |<---+   | contract_id  PK  |   +--->| product_id  PK |
 | name           |    |   | customer_id  FK  |   |    | product_name   |
 | segment        |    +---| customer_id      |   |    | category       |
 | region         |        | contract_type    |   |    +----------------+
 | created_date   |        | start_date       |   |
 +----------------+        | end_date         |   |    +------------------+
                           | annual_value     |   |    |  pricing_tiers   |
                           | discount_pct     |   |    |------------------|
                           | auto_renewal     |   |    | tier_id      PK  |
                           | status           |   +----| product_id   FK  |
                           +------------------+   |    | tier_name        |
                                    |              |    | unit_price       |
                                    |              |    | effective_from   |
                 +------------------+              |    | effective_to     |
                 |                                 |    +------------------+
                 v                                 |
        +------------------+                       |
        |    invoices       |                       |
        |------------------|                       |
        | invoice_id   PK  |                       |
        | contract_id  FK  |                       |
        | customer_id  FK  |                       |
        | invoice_date     |                       |
        | total_amount     |                       |
        | status           |                       |
        +------------------+                       |
                 |                                 |
                 v                                 |
        +--------------------+                     |
        |   invoice_lines    |                     |
        |--------------------|                     |
        | line_id        PK  |                     |
        | invoice_id     FK  |---------------------+
        | product_id     FK  |
        | quantity           |
        | unit_price         |
        | line_total         |
        | pricing_tier_id FK |
        +--------------------+
                 |
                 v
        +------------------+
        |    payments       |
        |------------------|
        | payment_id   PK  |
        | invoice_id   FK  |
        | payment_date     |
        | amount_paid      |
        | payment_method   |
        +------------------+
```

---

## Key Findings

| # | Leakage Category                       | Amount       | Affected Customers |
|---|----------------------------------------|--------------|--------------------|
| 1 | Billing after contract expiry          | ~$180,000    | 6                  |
| 2 | Unit price vs. contracted rate mismatch| ~$95,000     | 8                  |
| 3 | Duplicate invoices                     | ~$45,000     | 4                  |
| 4 | Contracted discounts not applied       | ~$120,000    | 7                  |
| 5 | Billing on cancelled contracts         | ~$60,000     | 3                  |
| **Total** |                                 | **~$500,000**|                    |

Full findings are documented in [`findings/summary.md`](findings/summary.md).

---

## Project Structure

```
sql-revenue-leakage/
|-- README.md
|-- schema/
|   |-- create_tables.sql        -- DDL for all seven tables
|   |-- seed_data.sql            -- Sample data with intentional discrepancies
|-- analysis/
|   |-- 01_expired_contract_billing.sql
|   |-- 02_pricing_discrepancy.sql
|   |-- 03_duplicate_invoices.sql
|   |-- 04_discount_validation.sql
|   |-- 05_cancelled_contract_billing.sql
|   |-- 06_executive_summary.sql
|   |-- 07_revenue_at_risk.sql
|-- findings/
|   |-- summary.md               -- CFO-ready write-up of results
```

---

## How to Run

### Prerequisites

- PostgreSQL 12+ or MySQL 8.0+
- A SQL client (psql, DBeaver, pgAdmin, MySQL Workbench, etc.)

### Steps

```bash
# 1. Create a database
createdb revenue_leakage    # PostgreSQL
# or: CREATE DATABASE revenue_leakage;  (MySQL)

# 2. Build the schema
psql -d revenue_leakage -f schema/create_tables.sql

# 3. Load sample data
psql -d revenue_leakage -f schema/seed_data.sql

# 4. Run individual analyses
psql -d revenue_leakage -f analysis/01_expired_contract_billing.sql
psql -d revenue_leakage -f analysis/02_pricing_discrepancy.sql
# ... and so on

# 5. Run the executive summary (combines all leakage types)
psql -d revenue_leakage -f analysis/06_executive_summary.sql
```

Each analysis script is self-contained and prints results to standard output with descriptive headers.

---

## Tools Used

- **SQL Dialect:** Standard SQL (PostgreSQL / MySQL compatible)
- **Techniques:** CTEs, window functions, CASE expressions, correlated subqueries, date arithmetic, set operations (UNION ALL)
- **Presentation:** Markdown summary formatted for executive review

---

## Author

Nikita -- Data Analyst | SQL | Revenue Operations
