# Sales Performance & Regional Analytics Dashboard

## Business Context

A mid-size retail company operating across four U.S. regions needed a unified view of sales performance to support quarterly business reviews and territory planning. Leadership required visibility into regional revenue trends, product profitability, customer segment behavior, and target achievement -- all in a single interactive dashboard. This Tableau project delivers those insights, transforming raw transactional data into actionable intelligence that drives pricing, discount, and inventory decisions.

## Key Insights Discovered

- **West region consistently outperforms** other regions in both revenue and profit margin, driven by strong Technology category sales
- **Furniture category shows thin or negative margins** in several states, primarily due to aggressive discounting above 20%
- **Corporate segment delivers the highest average order value** but Consumer segment drives the most volume
- **Seasonal revenue spikes in Q4** (November-December) account for roughly 28% of annual sales
- **Discounts above 30% almost always result in negative profit**, suggesting the discount policy needs guardrails
- **Home Office segment is the fastest-growing** customer group year-over-year, up 18% in 2025 vs. 2024
- **Standard Class shipping dominates** (60% of orders) but Same Day shipping correlates with higher-value orders

## View on Tableau Public

> **Tableau Public Link:** [Dashboard will be published here after final review]
>
> Once published, the interactive version allows filtering by region, date range, product category, and customer segment.

## Dashboard Components

1. **Regional Sales Map** -- Filled map showing sales intensity by state with tooltip details
2. **Monthly Revenue Trend** -- Dual-axis line chart comparing actual sales vs. monthly targets
3. **Product Category Treemap** -- Size by revenue, color by profit margin
4. **Top & Bottom Performers** -- Horizontal bar chart highlighting best and worst subcategories
5. **Customer Segment Analysis** -- Stacked bar showing revenue and profit contribution by segment
6. **Discount vs. Profit Scatter Plot** -- Reveals the discount threshold where profitability turns negative

## How to Recreate

1. Download the data files from the `data/` folder
2. Open Tableau Public (free) and connect to `sales_data.csv`
3. Add `targets.csv` as a secondary data source
4. Follow the step-by-step guide in [`tableau_guide/dashboard_setup.md`](tableau_guide/dashboard_setup.md)
5. Publish to Tableau Public from File > Save to Tableau Public

## Tools & Technologies

- **Tableau Public** -- Dashboard design, calculated fields, interactive filtering
- **Excel / CSV** -- Source data for sales transactions and regional targets

## Data Files

| File | Description | Rows |
|------|-------------|------|
| `data/sales_data.csv` | Order-level sales transactions (2023-2025) | ~1,000 |
| `data/targets.csv` | Monthly sales targets by region | ~144 |

## Author

Nikita -- Data Analyst | BI Developer

## License

This project is for portfolio and demonstration purposes.
