-- =============================================================================
-- Analysis 03: Duplicate Invoice Detection
-- =============================================================================
-- BUSINESS QUESTION:
-- Have any customers been invoiced more than once for the same charge?
--
-- Duplicate invoices typically arise from system glitches during batch billing
-- runs, manual re-entry errors, or integration failures between CRM and ERP.
-- Even when caught downstream, they inflate revenue recognition and create
-- reconciliation overhead.
--
-- Detection criteria: same contract_id, same customer_id, same total_amount,
-- same invoice_date.
-- =============================================================================

-- Step 1: Find groups of invoices that share the same key attributes
WITH invoice_groups AS (
    SELECT
        contract_id,
        customer_id,
        invoice_date,
        total_amount,
        COUNT(*)            AS invoice_count,
        MIN(invoice_id)     AS first_invoice_id,
        MAX(invoice_id)     AS duplicate_invoice_id
    FROM invoices
    GROUP BY contract_id, customer_id, invoice_date, total_amount
    HAVING COUNT(*) > 1
),

-- Step 2: Enrich with customer and contract details
duplicate_details AS (
    SELECT
        ig.contract_id,
        cu.name                 AS customer_name,
        cu.segment              AS customer_segment,
        c.contract_type,
        ig.invoice_date,
        ig.total_amount,
        ig.invoice_count,
        ig.first_invoice_id,
        ig.duplicate_invoice_id,
        -- The duplicate amount is (count - 1) * total_amount
        (ig.invoice_count - 1) * ig.total_amount AS duplicate_leakage
    FROM invoice_groups ig
    JOIN contracts c   ON ig.contract_id = c.contract_id
    JOIN customers cu  ON ig.customer_id = cu.customer_id
)

SELECT
    customer_name,
    customer_segment,
    contract_id,
    contract_type,
    invoice_date,
    total_amount          AS invoice_amount,
    invoice_count,
    first_invoice_id      AS original_invoice,
    duplicate_invoice_id  AS duplicate_invoice,
    duplicate_leakage
FROM duplicate_details
ORDER BY duplicate_leakage DESC;

-- Step 3: Check if duplicate invoices were also paid (double payment risk)
WITH duplicates AS (
    SELECT
        contract_id,
        customer_id,
        invoice_date,
        total_amount,
        MIN(invoice_id) AS original_id,
        MAX(invoice_id) AS duplicate_id
    FROM invoices
    GROUP BY contract_id, customer_id, invoice_date, total_amount
    HAVING COUNT(*) > 1
)
SELECT
    d.contract_id,
    cu.name                 AS customer_name,
    d.invoice_date,
    d.total_amount,
    d.original_id,
    orig_inv.status         AS original_status,
    COALESCE(orig_pay.amount_paid, 0)  AS original_paid,
    d.duplicate_id,
    dup_inv.status          AS duplicate_status,
    COALESCE(dup_pay.amount_paid, 0)   AS duplicate_paid,
    CASE
        WHEN dup_pay.amount_paid IS NOT NULL THEN 'DOUBLE PAYMENT - REFUND NEEDED'
        WHEN dup_inv.status = 'Pending'      THEN 'VOID BEFORE PAYMENT'
        ELSE 'REVIEW REQUIRED'
    END AS recommended_action
FROM duplicates d
JOIN customers cu    ON d.customer_id = cu.customer_id
JOIN invoices orig_inv ON d.original_id = orig_inv.invoice_id
JOIN invoices dup_inv  ON d.duplicate_id = dup_inv.invoice_id
LEFT JOIN payments orig_pay ON d.original_id = orig_pay.invoice_id
LEFT JOIN payments dup_pay  ON d.duplicate_id = dup_pay.invoice_id
ORDER BY d.total_amount DESC;

-- Step 4: Grand total
SELECT
    'Duplicate Invoices'             AS leakage_category,
    COUNT(*)                         AS duplicate_pairs,
    COUNT(DISTINCT d.customer_id)    AS affected_customers,
    SUM(d.total_amount)              AS total_duplicate_amount
FROM (
    SELECT
        customer_id,
        total_amount
    FROM invoices
    GROUP BY contract_id, customer_id, invoice_date, total_amount
    HAVING COUNT(*) > 1
) d;
