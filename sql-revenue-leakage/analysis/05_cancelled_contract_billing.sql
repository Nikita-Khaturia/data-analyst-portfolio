-- =============================================================================
-- Analysis 05: Cancelled / Terminated Contract Billing
-- =============================================================================
-- BUSINESS QUESTION:
-- Are we generating invoices against contracts that have been cancelled or
-- terminated?
--
-- When a customer cancels mid-term, the billing system should immediately stop
-- issuing invoices. Failure to do so results in disputed charges, refund
-- processing costs, and potential regulatory exposure.
--
-- This differs from Analysis 01 (expired contracts) because cancelled contracts
-- should have NO invoices at all after the cancellation event, whereas expired
-- contracts might legitimately have invoices up until the end date.
-- =============================================================================

-- Step 1: Find all invoices on cancelled or terminated contracts
WITH cancelled_billing AS (
    SELECT
        i.invoice_id,
        i.contract_id,
        c.customer_id,
        cu.name                     AS customer_name,
        cu.segment                  AS customer_segment,
        c.contract_type,
        c.status                    AS contract_status,
        c.start_date                AS contract_start,
        c.end_date                  AS contract_end,
        c.annual_value,
        i.invoice_date,
        i.total_amount,
        i.status                    AS invoice_status,
        -- Use window function to rank invoices per contract
        ROW_NUMBER() OVER (
            PARTITION BY i.contract_id
            ORDER BY i.invoice_date
        ) AS invoice_sequence
    FROM invoices i
    JOIN contracts c  ON i.contract_id = c.contract_id
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status IN ('Cancelled', 'Terminated')
)

SELECT
    invoice_id,
    contract_id,
    customer_name,
    customer_segment,
    contract_status,
    contract_start,
    contract_end,
    invoice_date,
    total_amount,
    invoice_status,
    invoice_sequence
FROM cancelled_billing
ORDER BY contract_status, customer_name, invoice_date;

-- Step 2: Summarise by contract with payment status
SELECT
    cu.name                         AS customer_name,
    cu.segment,
    c.contract_id,
    c.status                        AS contract_status,
    c.start_date,
    c.end_date,
    COUNT(i.invoice_id)             AS invoices_issued,
    SUM(i.total_amount)             AS total_billed,
    SUM(COALESCE(pay.amount_paid, 0)) AS total_collected,
    SUM(i.total_amount) - SUM(COALESCE(pay.amount_paid, 0)) AS outstanding
FROM invoices i
JOIN contracts c   ON i.contract_id = c.contract_id
JOIN customers cu  ON c.customer_id = cu.customer_id
LEFT JOIN payments pay ON i.invoice_id = pay.invoice_id
WHERE c.status IN ('Cancelled', 'Terminated')
GROUP BY cu.name, cu.segment, c.contract_id, c.status, c.start_date, c.end_date
ORDER BY total_billed DESC;

-- Step 3: Assess refund liability -- how much was actually paid on these
-- invalid invoices?
WITH refund_analysis AS (
    SELECT
        cu.name                     AS customer_name,
        c.contract_id,
        c.status                    AS contract_status,
        i.invoice_id,
        i.total_amount              AS billed_amount,
        COALESCE(pay.amount_paid, 0) AS paid_amount,
        CASE
            WHEN pay.amount_paid IS NOT NULL THEN 'Refund Required'
            WHEN i.status = 'Pending'        THEN 'Void Invoice'
            WHEN i.status = 'Overdue'        THEN 'Write Off'
            ELSE 'Review'
        END AS recommended_action
    FROM invoices i
    JOIN contracts c   ON i.contract_id = c.contract_id
    JOIN customers cu  ON c.customer_id = cu.customer_id
    LEFT JOIN payments pay ON i.invoice_id = pay.invoice_id
    WHERE c.status IN ('Cancelled', 'Terminated')
)
SELECT
    recommended_action,
    COUNT(*)            AS invoice_count,
    SUM(billed_amount)  AS total_billed,
    SUM(paid_amount)    AS total_paid
FROM refund_analysis
GROUP BY recommended_action
ORDER BY total_paid DESC;

-- Step 4: Grand total
SELECT
    'Cancelled Contract Billing'     AS leakage_category,
    COUNT(DISTINCT c.contract_id)    AS affected_contracts,
    COUNT(DISTINCT cu.customer_id)   AS affected_customers,
    COUNT(i.invoice_id)              AS total_invalid_invoices,
    SUM(i.total_amount)              AS total_leakage_amount
FROM invoices i
JOIN contracts c  ON i.contract_id = c.contract_id
JOIN customers cu ON c.customer_id = cu.customer_id
WHERE c.status IN ('Cancelled', 'Terminated');
