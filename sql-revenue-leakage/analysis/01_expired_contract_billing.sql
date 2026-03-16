-- =============================================================================
-- Analysis 01: Expired Contract Billing
-- =============================================================================
-- BUSINESS QUESTION:
-- Are we continuing to invoice customers after their contracts have expired?
--
-- This is a common source of revenue leakage where the billing system continues
-- generating invoices on auto-pilot even after the contractual obligation has
-- ended. The customer may dispute these charges later, leading to write-offs,
-- or they may pay unknowingly -- creating compliance and relationship risk.
-- =============================================================================

-- Step 1: Identify all invoices dated after contract end_date
-- on contracts with status = 'Expired'
WITH expired_contract_invoices AS (
    SELECT
        i.invoice_id,
        i.contract_id,
        c.customer_id,
        cu.name                     AS customer_name,
        cu.segment                  AS customer_segment,
        c.status                    AS contract_status,
        c.start_date                AS contract_start,
        c.end_date                  AS contract_end,
        c.annual_value              AS contract_annual_value,
        i.invoice_date,
        i.total_amount              AS invoice_amount,
        i.status                    AS invoice_status,
        -- How many days past expiry was this invoice raised?
        CAST(i.invoice_date - c.end_date AS INT) AS days_past_expiry
    FROM invoices i
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status = 'Expired'
      AND i.invoice_date > c.end_date
)

SELECT
    invoice_id,
    contract_id,
    customer_name,
    customer_segment,
    contract_end,
    invoice_date,
    days_past_expiry,
    invoice_amount,
    invoice_status
FROM expired_contract_invoices
ORDER BY invoice_amount DESC, customer_name, invoice_date;

-- Step 2: Summary by customer -- total leakage per customer
SELECT
    cu.name                         AS customer_name,
    cu.segment                      AS customer_segment,
    c.contract_id,
    c.end_date                      AS contract_expired_on,
    COUNT(i.invoice_id)             AS invoices_after_expiry,
    SUM(i.total_amount)             AS total_leaked_amount,
    MIN(i.invoice_date)             AS first_post_expiry_invoice,
    MAX(i.invoice_date)             AS last_post_expiry_invoice
FROM invoices i
JOIN contracts c  ON i.contract_id = c.contract_id
JOIN customers cu ON c.customer_id = cu.customer_id
WHERE c.status = 'Expired'
  AND i.invoice_date > c.end_date
GROUP BY cu.name, cu.segment, c.contract_id, c.end_date
ORDER BY total_leaked_amount DESC;

-- Step 3: Grand total
SELECT
    'Expired Contract Billing'      AS leakage_category,
    COUNT(DISTINCT c.contract_id)   AS affected_contracts,
    COUNT(DISTINCT cu.customer_id)  AS affected_customers,
    COUNT(i.invoice_id)             AS total_invoices,
    SUM(i.total_amount)             AS total_leakage_amount
FROM invoices i
JOIN contracts c  ON i.contract_id = c.contract_id
JOIN customers cu ON c.customer_id = cu.customer_id
WHERE c.status = 'Expired'
  AND i.invoice_date > c.end_date;
