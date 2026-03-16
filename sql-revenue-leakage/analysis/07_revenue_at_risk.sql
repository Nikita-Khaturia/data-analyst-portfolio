-- =============================================================================
-- Analysis 07: Revenue at Risk -- Forward-Looking Contract Expiry Analysis
-- =============================================================================
-- BUSINESS QUESTION:
-- Which contracts are expiring in the next 30, 60, and 90 days, and what is
-- the total annual revenue at risk if they are not renewed?
--
-- This analysis supports proactive retention efforts by identifying contracts
-- approaching expiry, segmented by renewal urgency and customer value.
--
-- NOTE: The reference date used below is '2025-03-09' (today). Adjust this
-- value if running the analysis on a different date.
-- =============================================================================

-- Step 1: Classify contracts by days-to-expiry bucket
WITH contract_expiry AS (
    SELECT
        c.contract_id,
        cu.customer_id,
        cu.name                         AS customer_name,
        cu.segment,
        cu.region,
        c.contract_type,
        c.start_date,
        c.end_date,
        c.annual_value,
        c.discount_pct,
        c.auto_renewal,
        c.status,
        -- Days until expiry (negative = already expired)
        CAST(c.end_date - CURRENT_DATE AS INT) AS days_to_expiry,
        CASE
            WHEN CAST(c.end_date - CURRENT_DATE AS INT) <= 0  THEN 'EXPIRED'
            WHEN CAST(c.end_date - CURRENT_DATE AS INT) <= 30 THEN '0-30 days'
            WHEN CAST(c.end_date - CURRENT_DATE AS INT) <= 60 THEN '31-60 days'
            WHEN CAST(c.end_date - CURRENT_DATE AS INT) <= 90 THEN '61-90 days'
            ELSE '90+ days'
        END AS urgency_bucket
    FROM contracts c
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status = 'Active'
)

SELECT
    contract_id,
    customer_name,
    segment,
    region,
    contract_type,
    end_date,
    days_to_expiry,
    urgency_bucket,
    annual_value,
    auto_renewal,
    CASE
        WHEN auto_renewal = TRUE  THEN 'Auto-renews (verify terms)'
        WHEN days_to_expiry <= 30 THEN 'URGENT: Manual renewal needed'
        WHEN days_to_expiry <= 60 THEN 'HIGH: Begin renewal discussion'
        ELSE 'MEDIUM: Schedule review'
    END AS recommended_action
FROM contract_expiry
WHERE days_to_expiry <= 90
ORDER BY days_to_expiry ASC, annual_value DESC;

-- Step 2: Aggregate revenue at risk by urgency bucket
WITH risk_buckets AS (
    SELECT
        CASE
            WHEN CAST(c.end_date - CURRENT_DATE AS INT) <= 0  THEN 'EXPIRED'
            WHEN CAST(c.end_date - CURRENT_DATE AS INT) <= 30 THEN '0-30 days'
            WHEN CAST(c.end_date - CURRENT_DATE AS INT) <= 60 THEN '31-60 days'
            WHEN CAST(c.end_date - CURRENT_DATE AS INT) <= 90 THEN '61-90 days'
        END AS urgency_bucket,
        c.contract_id,
        c.annual_value,
        c.auto_renewal,
        cu.segment
    FROM contracts c
    JOIN customers cu ON c.customer_id = cu.customer_id
    WHERE c.status = 'Active'
      AND CAST(c.end_date - CURRENT_DATE AS INT) <= 90
)
SELECT
    urgency_bucket,
    COUNT(contract_id)                  AS contracts,
    SUM(annual_value)                   AS total_annual_revenue_at_risk,
    SUM(CASE WHEN auto_renewal = TRUE
             THEN annual_value ELSE 0
        END)                            AS auto_renewal_revenue,
    SUM(CASE WHEN auto_renewal = FALSE
             THEN annual_value ELSE 0
        END)                            AS manual_renewal_revenue,
    SUM(CASE WHEN segment = 'Enterprise'
             THEN annual_value ELSE 0
        END)                            AS enterprise_at_risk,
    SUM(CASE WHEN segment = 'Mid-Market'
             THEN annual_value ELSE 0
        END)                            AS midmarket_at_risk,
    SUM(CASE WHEN segment = 'SMB'
             THEN annual_value ELSE 0
        END)                            AS smb_at_risk
FROM risk_buckets
GROUP BY urgency_bucket
ORDER BY
    CASE urgency_bucket
        WHEN 'EXPIRED'   THEN 1
        WHEN '0-30 days' THEN 2
        WHEN '31-60 days' THEN 3
        WHEN '61-90 days' THEN 4
    END;

-- Step 3: Historical renewal rate as a benchmark
-- What percentage of expired contracts were followed by a new active contract
-- for the same customer?
WITH expired AS (
    SELECT
        c.customer_id,
        c.contract_id   AS expired_contract_id,
        c.end_date       AS expired_date,
        c.annual_value   AS expired_value
    FROM contracts c
    WHERE c.status = 'Expired'
),
renewed AS (
    SELECT
        e.customer_id,
        e.expired_contract_id,
        e.expired_value,
        CASE WHEN a.contract_id IS NOT NULL THEN 1 ELSE 0 END AS was_renewed
    FROM expired e
    LEFT JOIN contracts a
        ON  a.customer_id = e.customer_id
        AND a.status = 'Active'
        AND a.start_date >= e.expired_date
)
SELECT
    COUNT(*)                            AS total_expired_contracts,
    SUM(was_renewed)                    AS subsequently_renewed,
    COUNT(*) - SUM(was_renewed)         AS churned,
    ROUND(
        100.0 * SUM(was_renewed) / COUNT(*),
        1
    )                                   AS renewal_rate_pct,
    SUM(CASE WHEN was_renewed = 0
             THEN expired_value ELSE 0
        END)                            AS churned_annual_revenue
FROM renewed;

-- Step 4: Net revenue impact projection
-- Combining at-risk revenue with historical renewal rate to estimate
-- likely churn revenue in the next 90 days.
WITH risk AS (
    SELECT SUM(c.annual_value) AS total_at_risk
    FROM contracts c
    WHERE c.status = 'Active'
      AND c.auto_renewal = FALSE
      AND CAST(c.end_date - CURRENT_DATE AS INT) BETWEEN 0 AND 90
),
history AS (
    SELECT
        ROUND(
            100.0 * SUM(
                CASE WHEN a.contract_id IS NOT NULL THEN 1 ELSE 0 END
            ) / COUNT(*),
            1
        ) AS renewal_rate
    FROM contracts e
    LEFT JOIN contracts a
        ON  a.customer_id = e.customer_id
        AND a.status = 'Active'
        AND a.start_date >= e.end_date
    WHERE e.status = 'Expired'
)
SELECT
    r.total_at_risk                     AS manual_renewal_revenue_at_risk,
    h.renewal_rate                      AS historical_renewal_rate_pct,
    ROUND(
        r.total_at_risk * (1 - h.renewal_rate / 100),
        2
    )                                   AS projected_churn_revenue
FROM risk r
CROSS JOIN history h;
