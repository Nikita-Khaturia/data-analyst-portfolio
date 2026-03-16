-- =============================================================================
-- Analysis 04: Discount Validation
-- =============================================================================
-- BUSINESS QUESTION:
-- Are contracted discount percentages being correctly applied to invoice lines?
--
-- Many billing systems apply discounts as a separate step or rely on manual
-- configuration per customer. When a new contract is signed with a discount
-- but the billing profile is not updated, the customer is overcharged.
--
-- Logic: For a contract with discount_pct = D%, each invoice line's line_total
-- should equal quantity * unit_price * (1 - D/100). If line_total equals
-- quantity * unit_price (i.e., no discount applied), we flag it.
-- =============================================================================

-- Step 1: Identify lines where the contracted discount was NOT applied
WITH discount_check AS (
    SELECT
        il.line_id,
        il.invoice_id,
        i.invoice_date,
        i.contract_id,
        c.discount_pct,
        cu.customer_id,
        cu.name                         AS customer_name,
        cu.segment                      AS customer_segment,
        p.product_name,
        il.quantity,
        il.unit_price,
        il.line_total                   AS billed_total,
        -- Expected total WITH discount
        ROUND(il.quantity * il.unit_price * (1 - c.discount_pct / 100), 2)
                                        AS expected_total_with_discount,
        -- Full-price total (no discount)
        il.quantity * il.unit_price     AS full_price_total,
        -- The overcharge is the difference between what was billed and what
        -- should have been billed after discount
        ROUND(
            il.line_total
            - il.quantity * il.unit_price * (1 - c.discount_pct / 100),
            2
        )                               AS discount_not_applied_amount
    FROM invoice_lines il
    JOIN invoices i   ON il.invoice_id = i.invoice_id
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    JOIN products p   ON il.product_id = p.product_id
    WHERE c.discount_pct > 0                                -- contract has a discount
      AND il.line_total = il.quantity * il.unit_price        -- but full price was charged
      AND c.status IN ('Active', 'Expired')                 -- exclude cancelled (separate analysis)
)

SELECT
    line_id,
    invoice_id,
    invoice_date,
    contract_id,
    customer_name,
    customer_segment,
    discount_pct                    AS contracted_discount_pct,
    product_name,
    quantity,
    unit_price,
    full_price_total                AS billed_at_full_price,
    expected_total_with_discount    AS should_have_been,
    discount_not_applied_amount     AS overcharge
FROM discount_check
ORDER BY discount_not_applied_amount DESC, customer_name;

-- Step 2: Summarise by customer
WITH discount_leakage AS (
    SELECT
        cu.customer_id,
        cu.name                     AS customer_name,
        cu.segment,
        c.contract_id,
        c.discount_pct,
        il.line_id,
        ROUND(
            il.line_total
            - il.quantity * il.unit_price * (1 - c.discount_pct / 100),
            2
        ) AS overcharge
    FROM invoice_lines il
    JOIN invoices i   ON il.invoice_id = i.invoice_id
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.discount_pct > 0
      AND il.line_total = il.quantity * il.unit_price
      AND c.status IN ('Active', 'Expired')
)
SELECT
    customer_name,
    segment,
    contract_id,
    discount_pct                    AS contracted_discount,
    COUNT(line_id)                  AS affected_lines,
    SUM(overcharge)                 AS total_overcharge,
    ROUND(AVG(overcharge), 2)       AS avg_overcharge_per_line
FROM discount_leakage
GROUP BY customer_id, customer_name, segment, contract_id, discount_pct
ORDER BY total_overcharge DESC;

-- Step 3: Summarise by discount tier to find systemic gaps
WITH discount_analysis AS (
    SELECT
        c.discount_pct,
        c.contract_id,
        cu.customer_id,
        ROUND(
            il.line_total
            - il.quantity * il.unit_price * (1 - c.discount_pct / 100),
            2
        ) AS overcharge
    FROM invoice_lines il
    JOIN invoices i   ON il.invoice_id = i.invoice_id
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.discount_pct > 0
      AND il.line_total = il.quantity * il.unit_price
      AND c.status IN ('Active', 'Expired')
)
SELECT
    discount_pct                     AS discount_tier,
    COUNT(DISTINCT contract_id)      AS contracts_affected,
    COUNT(DISTINCT customer_id)      AS customers_affected,
    SUM(overcharge)                  AS total_leakage
FROM discount_analysis
GROUP BY discount_pct
ORDER BY total_leakage DESC;

-- Step 4: Grand total
SELECT
    'Discount Not Applied'           AS leakage_category,
    COUNT(DISTINCT cu.customer_id)   AS affected_customers,
    COUNT(DISTINCT c.contract_id)    AS affected_contracts,
    COUNT(il.line_id)                AS affected_lines,
    SUM(
        ROUND(
            il.line_total
            - il.quantity * il.unit_price * (1 - c.discount_pct / 100),
            2
        )
    )                                AS total_leakage_amount
FROM invoice_lines il
JOIN invoices i   ON il.invoice_id = i.invoice_id
JOIN contracts c  ON i.contract_id = c.contract_id
JOIN customers cu ON c.customer_id = cu.customer_id
WHERE c.discount_pct > 0
  AND il.line_total = il.quantity * il.unit_price
  AND c.status IN ('Active', 'Expired');
