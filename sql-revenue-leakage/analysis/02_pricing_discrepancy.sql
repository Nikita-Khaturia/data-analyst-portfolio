-- =============================================================================
-- Analysis 02: Pricing Discrepancy Detection
-- =============================================================================
-- BUSINESS QUESTION:
-- Are invoice line items being charged at the correct unit price according to
-- the contracted pricing tier?
--
-- Pricing drift occurs when the billing system uses a stale rate card, a manual
-- override is applied incorrectly, or a tier upgrade is not reflected in the
-- invoice engine. Even small per-unit differences compound over high volumes.
-- =============================================================================

-- Step 1: Compare billed unit_price on each line to the tier's published price
WITH pricing_comparison AS (
    SELECT
        il.line_id,
        il.invoice_id,
        i.invoice_date,
        i.contract_id,
        cu.name                         AS customer_name,
        cu.segment                      AS customer_segment,
        p.product_name,
        pt.tier_name,
        pt.unit_price                   AS tier_unit_price,
        il.unit_price                   AS billed_unit_price,
        il.quantity,
        il.line_total                   AS billed_line_total,
        -- What the line total SHOULD have been (before discount)
        il.quantity * pt.unit_price     AS expected_line_total,
        -- Variance
        il.line_total - (il.quantity * pt.unit_price) AS price_variance
    FROM invoice_lines il
    JOIN invoices i      ON il.invoice_id = i.invoice_id
    JOIN contracts c     ON i.contract_id = c.contract_id
    JOIN customers cu    ON c.customer_id = cu.customer_id
    JOIN products p      ON il.product_id = p.product_id
    JOIN pricing_tiers pt ON il.pricing_tier_id = pt.tier_id
    WHERE il.unit_price <> pt.unit_price  -- only lines with a mismatch
)

SELECT
    line_id,
    invoice_id,
    invoice_date,
    contract_id,
    customer_name,
    product_name,
    tier_name,
    tier_unit_price,
    billed_unit_price,
    quantity,
    expected_line_total,
    billed_line_total,
    price_variance
FROM pricing_comparison
ORDER BY ABS(price_variance) DESC, customer_name;

-- Step 2: Summarise pricing variance by customer
WITH pricing_variance AS (
    SELECT
        cu.customer_id,
        cu.name                         AS customer_name,
        cu.segment,
        il.line_id,
        il.quantity,
        il.unit_price                   AS billed_price,
        pt.unit_price                   AS tier_price,
        il.line_total - (il.quantity * pt.unit_price) AS variance
    FROM invoice_lines il
    JOIN invoices i       ON il.invoice_id = i.invoice_id
    JOIN contracts c      ON i.contract_id = c.contract_id
    JOIN customers cu     ON c.customer_id = cu.customer_id
    JOIN pricing_tiers pt ON il.pricing_tier_id = pt.tier_id
    WHERE il.unit_price <> pt.unit_price
)
SELECT
    customer_name,
    segment,
    COUNT(line_id)         AS mismatched_lines,
    SUM(variance)          AS total_overcharge,
    ROUND(AVG(variance), 2) AS avg_variance_per_line
FROM pricing_variance
GROUP BY customer_id, customer_name, segment
ORDER BY total_overcharge DESC;

-- Step 3: Summarise by product to find systemic issues
WITH product_pricing_issues AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        pt.tier_name,
        pt.unit_price   AS correct_price,
        il.unit_price   AS billed_price,
        il.unit_price - pt.unit_price AS per_unit_diff,
        COUNT(*)         AS occurrence_count,
        SUM(il.line_total - (il.quantity * pt.unit_price)) AS total_variance
    FROM invoice_lines il
    JOIN products p       ON il.product_id = p.product_id
    JOIN pricing_tiers pt ON il.pricing_tier_id = pt.tier_id
    WHERE il.unit_price <> pt.unit_price
    GROUP BY p.product_id, p.product_name, p.category,
             pt.tier_name, pt.unit_price, il.unit_price
)
SELECT
    product_name,
    category,
    tier_name,
    correct_price,
    billed_price,
    per_unit_diff,
    occurrence_count,
    total_variance
FROM product_pricing_issues
ORDER BY total_variance DESC;

-- Step 4: Grand total
SELECT
    'Pricing Discrepancy'            AS leakage_category,
    COUNT(DISTINCT cu.customer_id)   AS affected_customers,
    COUNT(il.line_id)                AS mismatched_lines,
    SUM(il.line_total - (il.quantity * pt.unit_price)) AS total_leakage_amount
FROM invoice_lines il
JOIN invoices i       ON il.invoice_id = i.invoice_id
JOIN contracts c      ON i.contract_id = c.contract_id
JOIN customers cu     ON c.customer_id = cu.customer_id
JOIN pricing_tiers pt ON il.pricing_tier_id = pt.tier_id
WHERE il.unit_price <> pt.unit_price;
