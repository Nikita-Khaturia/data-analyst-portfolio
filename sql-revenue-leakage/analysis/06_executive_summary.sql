-- =============================================================================
-- Analysis 06: Executive Summary -- All Revenue Leakage Combined
-- =============================================================================
-- This query unions every leakage category into a single result set for
-- executive reporting. Each row represents one leakage instance with its
-- category, customer, contract, and dollar amount.
--
-- The final summary section aggregates by category to produce the table
-- a CFO would see in a board deck.
-- =============================================================================

-- -------------------------------------------------------------------------
-- PART A: Unified leakage detail (all five categories)
-- -------------------------------------------------------------------------
WITH all_leakage AS (

    -- Category 1: Expired contract billing
    SELECT
        'Expired Contract Billing'  AS leakage_category,
        cu.customer_id,
        cu.name                     AS customer_name,
        cu.segment,
        i.invoice_id,
        i.contract_id,
        i.invoice_date,
        i.total_amount              AS leakage_amount
    FROM invoices i
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status = 'Expired'
      AND i.invoice_date > c.end_date

    UNION ALL

    -- Category 2: Pricing discrepancy (unit price vs tier price)
    SELECT
        'Pricing Discrepancy'       AS leakage_category,
        cu.customer_id,
        cu.name                     AS customer_name,
        cu.segment,
        il.invoice_id,
        i.contract_id,
        i.invoice_date,
        il.line_total - (il.quantity * pt.unit_price) AS leakage_amount
    FROM invoice_lines il
    JOIN invoices i       ON il.invoice_id = i.invoice_id
    JOIN contracts c      ON i.contract_id = c.contract_id
    JOIN customers cu     ON c.customer_id = cu.customer_id
    JOIN pricing_tiers pt ON il.pricing_tier_id = pt.tier_id
    WHERE il.unit_price <> pt.unit_price

    UNION ALL

    -- Category 3: Duplicate invoices
    -- For each duplicate group, the leakage is (count-1) * amount.
    -- We select the LATER invoice_id as the "duplicate."
    SELECT
        'Duplicate Invoice'         AS leakage_category,
        cu.customer_id,
        cu.name                     AS customer_name,
        cu.segment,
        dup.duplicate_id            AS invoice_id,
        dup.contract_id,
        dup.invoice_date,
        dup.total_amount            AS leakage_amount
    FROM (
        SELECT
            contract_id,
            customer_id,
            invoice_date,
            total_amount,
            MAX(invoice_id) AS duplicate_id
        FROM invoices
        GROUP BY contract_id, customer_id, invoice_date, total_amount
        HAVING COUNT(*) > 1
    ) dup
    JOIN contracts c  ON dup.contract_id = c.contract_id
    JOIN customers cu ON dup.customer_id = cu.customer_id

    UNION ALL

    -- Category 4: Discount not applied
    SELECT
        'Discount Not Applied'      AS leakage_category,
        cu.customer_id,
        cu.name                     AS customer_name,
        cu.segment,
        il.invoice_id,
        i.contract_id,
        i.invoice_date,
        ROUND(
            il.line_total
            - il.quantity * il.unit_price * (1 - c.discount_pct / 100),
            2
        )                           AS leakage_amount
    FROM invoice_lines il
    JOIN invoices i   ON il.invoice_id = i.invoice_id
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.discount_pct > 0
      AND il.line_total = il.quantity * il.unit_price
      AND c.status IN ('Active', 'Expired')

    UNION ALL

    -- Category 5: Cancelled / terminated contract billing
    SELECT
        'Cancelled Contract Billing' AS leakage_category,
        cu.customer_id,
        cu.name                      AS customer_name,
        cu.segment,
        i.invoice_id,
        i.contract_id,
        i.invoice_date,
        i.total_amount               AS leakage_amount
    FROM invoices i
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status IN ('Cancelled', 'Terminated')
)

-- -------------------------------------------------------------------------
-- PART B: Category-level summary
-- -------------------------------------------------------------------------
SELECT
    leakage_category,
    COUNT(DISTINCT customer_id)     AS affected_customers,
    COUNT(DISTINCT contract_id)     AS affected_contracts,
    COUNT(*)                        AS leakage_instances,
    ROUND(SUM(leakage_amount), 2)   AS total_leakage,
    ROUND(AVG(leakage_amount), 2)   AS avg_per_instance,
    ROUND(MAX(leakage_amount), 2)   AS max_single_instance
FROM all_leakage
GROUP BY leakage_category
ORDER BY total_leakage DESC;

-- -------------------------------------------------------------------------
-- PART C: Grand total across all categories
-- -------------------------------------------------------------------------
SELECT
    'ALL CATEGORIES'                AS leakage_category,
    COUNT(DISTINCT customer_id)     AS affected_customers,
    COUNT(DISTINCT contract_id)     AS affected_contracts,
    COUNT(*)                        AS leakage_instances,
    ROUND(SUM(leakage_amount), 2)   AS total_leakage
FROM (
    SELECT cu.customer_id, i.contract_id, i.total_amount AS leakage_amount
    FROM invoices i
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status = 'Expired' AND i.invoice_date > c.end_date

    UNION ALL

    SELECT cu.customer_id, i.contract_id,
           il.line_total - (il.quantity * pt.unit_price)
    FROM invoice_lines il
    JOIN invoices i       ON il.invoice_id = i.invoice_id
    JOIN contracts c      ON i.contract_id = c.contract_id
    JOIN customers cu     ON c.customer_id = cu.customer_id
    JOIN pricing_tiers pt ON il.pricing_tier_id = pt.tier_id
    WHERE il.unit_price <> pt.unit_price

    UNION ALL

    SELECT cu.customer_id, dup.contract_id, dup.total_amount
    FROM (
        SELECT contract_id, customer_id, invoice_date, total_amount,
               MAX(invoice_id) AS dup_id
        FROM invoices
        GROUP BY contract_id, customer_id, invoice_date, total_amount
        HAVING COUNT(*) > 1
    ) dup
    JOIN customers cu ON dup.customer_id = cu.customer_id

    UNION ALL

    SELECT cu.customer_id, i.contract_id,
           ROUND(il.line_total - il.quantity * il.unit_price * (1 - c.discount_pct/100), 2)
    FROM invoice_lines il
    JOIN invoices i   ON il.invoice_id = i.invoice_id
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.discount_pct > 0
      AND il.line_total = il.quantity * il.unit_price
      AND c.status IN ('Active', 'Expired')

    UNION ALL

    SELECT cu.customer_id, i.contract_id, i.total_amount
    FROM invoices i
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status IN ('Cancelled', 'Terminated')
) combined;

-- -------------------------------------------------------------------------
-- PART D: Top 10 customers by total leakage exposure
-- -------------------------------------------------------------------------
SELECT
    customer_name,
    segment,
    COUNT(DISTINCT leakage_category)    AS categories_affected,
    COUNT(*)                            AS total_instances,
    ROUND(SUM(leakage_amount), 2)       AS total_leakage
FROM (
    SELECT 'Expired Contract Billing' AS leakage_category,
           cu.name AS customer_name, cu.segment, i.total_amount AS leakage_amount
    FROM invoices i
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status = 'Expired' AND i.invoice_date > c.end_date

    UNION ALL

    SELECT 'Pricing Discrepancy',
           cu.name, cu.segment,
           il.line_total - (il.quantity * pt.unit_price)
    FROM invoice_lines il
    JOIN invoices i       ON il.invoice_id = i.invoice_id
    JOIN contracts c      ON i.contract_id = c.contract_id
    JOIN customers cu     ON c.customer_id = cu.customer_id
    JOIN pricing_tiers pt ON il.pricing_tier_id = pt.tier_id
    WHERE il.unit_price <> pt.unit_price

    UNION ALL

    SELECT 'Duplicate Invoice', cu.name, cu.segment, dup.total_amount
    FROM (
        SELECT contract_id, customer_id, total_amount,
               MAX(invoice_id) AS dup_id
        FROM invoices
        GROUP BY contract_id, customer_id, invoice_date, total_amount
        HAVING COUNT(*) > 1
    ) dup
    JOIN customers cu ON dup.customer_id = cu.customer_id

    UNION ALL

    SELECT 'Discount Not Applied', cu.name, cu.segment,
           ROUND(il.line_total - il.quantity * il.unit_price * (1 - c.discount_pct/100), 2)
    FROM invoice_lines il
    JOIN invoices i   ON il.invoice_id = i.invoice_id
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.discount_pct > 0
      AND il.line_total = il.quantity * il.unit_price
      AND c.status IN ('Active', 'Expired')

    UNION ALL

    SELECT 'Cancelled Contract Billing', cu.name, cu.segment, i.total_amount
    FROM invoices i
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status IN ('Cancelled', 'Terminated')
) all_leakage
GROUP BY customer_name, segment
ORDER BY total_leakage DESC
LIMIT 10;
