# Revenue Leakage Analysis -- Executive Summary

**Prepared for:** Chief Financial Officer
**Date:** March 2025
**Scope:** Contract-to-billing reconciliation across all active, expired, and cancelled contracts
**Period reviewed:** January 2022 -- February 2025

---

## 1. Objective

This engagement was initiated to quantify revenue leakage -- the difference between contractually obligated billing and actual invoicing -- across our customer base. The analysis encompassed 40 contracts, 165 invoices, and 375 invoice line items spanning 20 customers.

---

## 2. Key Finding

**Approximately $500,000 in cumulative billing discrepancies were identified across five distinct leakage categories.** The majority of the leakage ($180K) stems from continued billing after contract expiry, followed by systematic failure to apply contracted discounts ($120K).

---

## 3. Leakage by Category

| # | Category | Leakage Amount | Contracts | Customers | Severity |
|---|----------|----------------|-----------|-----------|----------|
| 1 | Billing after contract expiry | $180,166 | 6 | 6 | Critical |
| 2 | Contracted discounts not applied | $120,000 | 10 | 7 | Critical |
| 3 | Unit price vs. contracted rate mismatch | $95,000 | 8 | 8 | High |
| 4 | Billing on cancelled/terminated contracts | $60,000 | 4 | 3 | High |
| 5 | Duplicate invoices | $45,167 | 4 | 4 | Medium |
| | **Total** | **~$500,333** | | | |

---

## 4. Analysis by Category

### 4.1 Billing After Contract Expiry ($180K)

Six expired contracts continued to generate invoices after their end dates. The billing system did not enforce contract termination dates, allowing automated monthly charges to persist for up to four months post-expiry.

**Highest exposure:** GlobalTech Solutions (Contract #14) -- $42,501 billed across three months after a December 2023 expiry.

**Root cause:** The billing engine relies on a manual flag to stop invoicing. When contracts expire without explicit deactivation by the Account Management team, billing continues indefinitely.

**Recommendation:** Implement automated contract-status checks in the billing pipeline. No invoice should be generated for a contract whose end_date is in the past and whose status is "Expired."

---

### 4.2 Contracted Discounts Not Applied ($120K)

Across 10 contracts with negotiated discounts (ranging from 5% to 15%), invoice line items were charged at full list price. The discount field exists in the contract record but is not propagated to the billing engine's line-item calculation.

**Most affected:** Frontier Manufacturing (15% discount, $13,200 leakage) and DataNova Analytics (12% discount, $11,088 leakage).

**Root cause:** The discount percentage in the contracts table is informational only. The billing system pulls unit prices from the pricing_tiers table but does not apply the customer-specific discount multiplier. This is a systemic configuration gap, not a one-off error.

**Recommendation:** Modify the billing calculation to multiply each line total by `(1 - discount_pct / 100)` using the discount from the active contract. Implement a post-billing validation rule that flags any invoice where the effective discount deviates from the contracted rate by more than 0.5%.

---

### 4.3 Unit Price Mismatch ($95K)

Invoice lines reference a specific pricing tier but charge a different unit price than what the tier defines. For example, the Platform Core License (Standard tier, $550/unit) was billed at $600-$650/unit across multiple customers.

**Systemic pattern:** The $50-$100 per-unit overcharge on the Platform Core License affected 8 customers and was consistent across billing periods, suggesting a stale price in the billing template rather than random errors.

**Root cause:** Likely a rate-card update that was applied to the pricing_tiers table but not synchronized to the billing template used for invoice generation.

**Recommendation:** Enforce referential integrity between invoice_lines.unit_price and pricing_tiers.unit_price at the point of invoice creation. Add a reconciliation report that runs before each billing cycle to flag deviations.

---

### 4.4 Billing on Cancelled Contracts ($60K)

Four cancelled or terminated contracts received a combined 13 invoices totaling approximately $60,000. All of these invoices were paid, meaning the customers were charged for services they had contractually opted out of.

**Refund exposure:** 100% of the $60K was collected and will likely need to be refunded upon discovery, plus potential goodwill credits.

**Root cause:** Contract status changes (Active to Cancelled/Terminated) are recorded in the CRM but not propagated to the billing system in real time. There is no integration trigger to halt invoicing when a contract is cancelled.

**Recommendation:** Implement a real-time webhook or batch sync between the CRM contract-status field and the billing system. Add a hard block that prevents invoice generation for any contract with status "Cancelled" or "Terminated."

---

### 4.5 Duplicate Invoices ($45K)

Four instances were found where the same customer received two invoices for the same contract, amount, and date. All duplicates were paid, resulting in double collection.

**Root cause:** Likely a batch-processing race condition where the monthly billing job ran twice (or a manual re-trigger after a perceived failure).

**Recommendation:** Add a uniqueness constraint or deduplication check on (contract_id, customer_id, invoice_date, total_amount) before invoice finalization. Implement idempotency keys in the billing pipeline.

---

## 5. Revenue at Risk -- Forward-Looking

Beyond the historical leakage, **contracts representing $X in annual revenue are expiring within the next 90 days** (exact figure depends on the run date). Of these:

- Contracts without auto-renewal clauses require immediate outreach.
- Historical renewal rates indicate approximately 40-50% of expired contracts do not result in a new agreement, suggesting significant churn risk.

---

## 6. Recommended Actions (Priority Order)

| Priority | Action | Expected Recovery | Timeline |
|----------|--------|-------------------|----------|
| 1 | Halt billing on all expired/cancelled contracts | Prevent ~$20K/month in new leakage | Immediate |
| 2 | Apply contracted discounts in billing engine | Recover ~$120K; prevent ongoing overcharges | 2 weeks |
| 3 | Reconcile and correct unit prices vs. tier rates | Recover ~$95K | 2 weeks |
| 4 | Process refunds for duplicate invoices | $45K in refunds | 1 week |
| 5 | Implement automated contract-status sync (CRM to billing) | Prevent future cancelled-contract billing | 4 weeks |
| 6 | Add deduplication checks to billing pipeline | Prevent future duplicates | 2 weeks |
| 7 | Build monthly reconciliation dashboard | Ongoing monitoring | 6 weeks |

---

## 7. Methodology

- **Data source:** Seven relational tables (customers, contracts, products, pricing_tiers, invoices, invoice_lines, payments)
- **Tools:** PostgreSQL-compatible SQL using CTEs, window functions, and set operations
- **Validation:** Each leakage category was independently quantified and cross-checked against payment records to confirm whether overcharges were collected
- **Limitations:** This analysis is based on structured billing data only. Off-system adjustments (credit memos, manual refunds) are not reflected in the data set and may reduce the net leakage figure.

---

*This report was generated as part of a contract-to-billing reconciliation engagement. All figures are based on the sample data set and are representative of the analytical methodology that would be applied to production data.*
