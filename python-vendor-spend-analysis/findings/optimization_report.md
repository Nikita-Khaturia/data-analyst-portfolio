# Vendor Spend Optimization Report
## Executive Summary

**Prepared for:** Pharmaceutical Division Leadership
**Analysis Period:** January 2023 -- December 2024
**Total Spend Analyzed:** ~$12.2M across 500+ transactions and 20 vendors

---

## Overview

Following the recent merger, a comprehensive analysis of vendor transaction data was conducted to identify redundancies, pricing inconsistencies, and cost optimization opportunities across the combined vendor base. The analysis revealed significant overlap in vendors and products, with actionable savings estimated at approximately **15% of total annual spend**.

---

## Savings Identified by Category

| # | Optimization Category | Est. Annual Savings | % of Total Spend | Difficulty | Timeline |
|---|---|---|---|---|---|
| 1 | Vendor Consolidation | $782,000 | 6.4% | Medium | 0-3 months |
| 2 | Price Standardization | $614,000 | 5.0% | Low | 0-3 months |
| 3 | Payment Term Optimization | $287,000 | 2.3% | Low | 3-6 months |
| 4 | Volume Discount Renegotiation | $168,000 | 1.4% | Medium | 3-6 months |
| | **Total** | **$1,851,000** | **15.1%** | | |

---

## Key Findings

### Duplicate Vendors Identified

Four pairs of vendors were flagged as duplicates or near-duplicates based on name similarity and overlapping product catalogs:

| Vendor A (Preferred) | Vendor B (Duplicate) | Category | Avg Price Premium (B vs A) |
|---|---|---|---|
| PharmaCorp Inc | Pharma Corp International | Raw Materials | +18-22% |
| ChemSource LLC | Chemical Source Labs | Chemical Compounds | +12-18% |
| MedPack Solutions | MedPack Global | Packaging | +10-16% |
| LabTech Instruments | Lab Technologies Inc | Lab Equipment | +14-20% |

These duplicates likely originated from the two legacy organizations maintaining separate vendor relationships for identical product needs.

### Product Overlap

- **12+ products** are currently sourced from multiple vendors at varying prices
- Price spreads range from **8% to 35%** for the same product across different vendors
- Highest-spread products: HPLC Columns, Acetaminophen API, Dissolution Apparatus

### Payment Terms

Three vendors operate on unfavorable payment terms:

| Vendor | Current Terms | Recommended Terms | Working Capital Impact |
|---|---|---|---|
| Chemical Source Labs | Net-90 | Net-30 | High |
| Pharma Corp International | Net-60 | Net-30 | Medium |
| TransGlobal Freight | Net-90 | Net-30 | Medium |

### Spend Concentration

- Top 5 vendors account for **62%** of total spend
- Q4 spending is **25-30% higher** than average quarters (seasonal procurement pattern)
- Raw Materials and Chemical Compounds represent **58%** of total category spend

---

## Top 5 Actionable Recommendations

### 1. Consolidate Duplicate Vendor Pairs
**Savings: $782,000 | Timeline: 0-3 months**

Immediately begin routing all purchases from the four identified duplicate vendors to their lower-cost counterparts. Require procurement to use only the preferred vendor for each product category. Notify duplicate vendors of contract non-renewal.

### 2. Standardize Product Pricing
**Savings: $614,000 | Timeline: 0-3 months**

For the 12 products sourced from multiple vendors, negotiate with all suppliers to match or beat the best available unit price. Use competitive pricing data as leverage. Any vendor unwilling to match should be deprioritized.

### 3. Renegotiate Payment Terms
**Savings: $287,000 | Timeline: 3-6 months**

Approach the three vendors on Net-60/Net-90 terms to renegotiate to Net-30. Offer longer contract commitments or volume guarantees in exchange. The working capital savings at a 5% cost of capital are substantial.

### 4. Negotiate Volume Discounts
**Savings: $168,000 | Timeline: 3-6 months**

Post-consolidation, the combined purchasing volume with preferred vendors should qualify for volume discount tiers. Target a minimum 3% discount on consolidated spend, with stretch targets of 5% for top-tier relationships.

### 5. Implement Vendor Scorecarding
**Savings: Preventive | Timeline: 6-12 months**

Establish a quarterly vendor performance review process covering:
- Price competitiveness (benchmark against market rates)
- Delivery reliability (on-time, in-full metrics)
- Quality metrics (rejection rates, compliance)
- Payment term compliance

This prevents future vendor sprawl and ensures ongoing optimization.

---

## Methodology

- **Data Sources:** Vendor transaction records (500+ rows), vendor master data (20 vendors)
- **Tools:** Python, Pandas, NumPy, Matplotlib, Seaborn
- **Duplicate Detection:** String similarity matching using Python's difflib (SequenceMatcher)
- **Price Analysis:** Mean unit price comparison across vendors for identical products
- **Working Capital Model:** 5% annual cost of capital applied to excess payment days beyond Net-30

---

## Next Steps

1. Review findings with Procurement leadership
2. Validate duplicate vendor pairs with category managers
3. Develop vendor consolidation transition plan
4. Issue RFQ/RFP for renegotiated pricing and terms
5. Establish vendor performance dashboard (quarterly cadence)

---

*Report generated from automated analysis. All savings figures are estimates based on historical transaction data and should be validated with current market conditions and contract terms.*
