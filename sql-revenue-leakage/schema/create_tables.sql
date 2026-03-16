-- =============================================================================
-- Revenue Leakage Identification -- Schema Definition
-- =============================================================================
-- Compatible with PostgreSQL 12+ and MySQL 8.0+
-- =============================================================================

-- Drop tables if they exist (in dependency order)
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS invoice_lines;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS pricing_tiers;
DROP TABLE IF EXISTS contracts;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- -----------------------------------------------------------------------------
-- 1. customers
-- Core customer master. Segment and region drive pricing and discount rules.
-- -----------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id     INT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    segment         VARCHAR(20)  NOT NULL,   -- Enterprise | Mid-Market | SMB
    region          VARCHAR(30)  NOT NULL,
    created_date    DATE         NOT NULL
);

-- -----------------------------------------------------------------------------
-- 2. products
-- Product catalog. Each product belongs to a category.
-- -----------------------------------------------------------------------------
CREATE TABLE products (
    product_id      INT PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50)  NOT NULL
);

-- -----------------------------------------------------------------------------
-- 3. contracts
-- Governs the commercial relationship: term, value, discount, and status.
-- status: Active | Expired | Cancelled | Terminated
-- -----------------------------------------------------------------------------
CREATE TABLE contracts (
    contract_id     INT PRIMARY KEY,
    customer_id     INT          NOT NULL,
    contract_type   VARCHAR(30)  NOT NULL,   -- Annual | Multi-Year | Month-to-Month
    start_date      DATE         NOT NULL,
    end_date        DATE         NOT NULL,
    annual_value    DECIMAL(12,2) NOT NULL,
    discount_pct    DECIMAL(5,2) DEFAULT 0,
    auto_renewal    BOOLEAN      DEFAULT FALSE,
    status          VARCHAR(20)  NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- -----------------------------------------------------------------------------
-- 4. pricing_tiers
-- Unit pricing for each product over time. Overlapping effective dates in the
-- seed data are intentional -- they represent a common data-quality issue.
-- -----------------------------------------------------------------------------
CREATE TABLE pricing_tiers (
    tier_id         INT PRIMARY KEY,
    product_id      INT          NOT NULL,
    tier_name       VARCHAR(50)  NOT NULL,   -- Standard | Premium | Legacy
    unit_price      DECIMAL(10,2) NOT NULL,
    effective_from  DATE         NOT NULL,
    effective_to    DATE,                     -- NULL = currently active
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- -----------------------------------------------------------------------------
-- 5. invoices
-- Header-level billing records tied to a contract and customer.
-- status: Paid | Pending | Overdue | Void
-- -----------------------------------------------------------------------------
CREATE TABLE invoices (
    invoice_id      INT PRIMARY KEY,
    contract_id     INT          NOT NULL,
    customer_id     INT          NOT NULL,
    invoice_date    DATE         NOT NULL,
    total_amount    DECIMAL(12,2) NOT NULL,
    status          VARCHAR(20)  NOT NULL,
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- -----------------------------------------------------------------------------
-- 6. invoice_lines
-- Line-item detail. Links to the pricing tier that *should* have governed the
-- charge. Discrepancies between line unit_price and tier unit_price are seeded.
-- -----------------------------------------------------------------------------
CREATE TABLE invoice_lines (
    line_id         INT PRIMARY KEY,
    invoice_id      INT          NOT NULL,
    product_id      INT          NOT NULL,
    quantity        INT          NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL,
    line_total      DECIMAL(12,2) NOT NULL,
    pricing_tier_id INT,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (pricing_tier_id) REFERENCES pricing_tiers(tier_id)
);

-- -----------------------------------------------------------------------------
-- 7. payments
-- Cash receipts against invoices. payment_method helps with reconciliation.
-- -----------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id      INT PRIMARY KEY,
    invoice_id      INT          NOT NULL,
    payment_date    DATE         NOT NULL,
    amount_paid     DECIMAL(12,2) NOT NULL,
    payment_method  VARCHAR(30)  NOT NULL,   -- ACH | Wire | Credit Card | Check
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
);
