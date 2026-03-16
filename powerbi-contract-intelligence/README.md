# M&A Contract Intelligence Dashboard

## Business Context

During mergers and acquisitions, organizations inherit hundreds of vendor contracts across multiple business units. Without centralized visibility, companies risk revenue leakage from missed renewals, unfavorable auto-renewal terms, and untracked contract expirations. This Power BI dashboard consolidates contract data from five business units into a single command center, enabling leadership to monitor contract health, quantify revenue exposure, and prioritize renewal actions during the critical M&A integration period.

## Dashboard Features

- **Executive KPI Summary** -- At-a-glance view of total contract value, active contract count, at-risk revenue, and renewal rate
- **30/60/90 Day Expiry Tracker** -- Identifies contracts approaching expiration within key time horizons so renewal teams can act before deadlines pass
- **Revenue Exposure Analysis** -- Links contract status to downstream revenue, quantifying the financial impact of each at-risk or expiring agreement
- **Auto-Renewal Risk Matrix** -- Flags contracts with auto-renewal clauses and short notice windows that could lock the organization into unfavorable terms
- **Business Unit Comparison** -- Breaks down contract health metrics by business unit to surface integration risks and prioritization targets
- **Renewal Pipeline** -- Tracks renewal workflow status (Not Started, In Progress, Completed, Escalated) with owner accountability

## KPIs Tracked

| KPI | Description |
|-----|-------------|
| Total Contract Value | Sum of all active and pending contract values |
| Active Contract Count | Number of contracts currently in force |
| At-Risk Revenue | Monthly revenue tied to expiring or at-risk contracts |
| Renewal Rate | Percentage of expiring contracts successfully renewed |
| Contracts Expiring (30/60/90 days) | Count of contracts within each expiry window |
| Average Contract Value | Mean annual value across the portfolio |
| Revenue at Risk % | At-risk revenue as a share of total portfolio revenue |

## Screenshots

> **Note:** Dashboard screenshots will be added after the Power BI report is finalized. The following views will be captured:
>
> - Executive summary page with KPI cards
> - Contract expiry timeline and renewal tracker
> - Revenue exposure drill-down by business unit
> - Auto-renewal risk matrix with conditional formatting

## How to Recreate in Power BI

1. **Download the data files** from the `data/` folder (`contracts.csv`, `revenue_exposure.csv`, `renewal_tracker.csv`)
2. **Open Power BI Desktop** and select Get Data > Text/CSV to import each file
3. **Configure the data model** by creating relationships between tables on `contract_id`
4. **Create DAX measures** as outlined in `powerbi_guide/dashboard_setup.md`
5. **Build the visualizations** following the step-by-step layout guide
6. **Apply the color theme and slicers** for a polished, interactive experience

Refer to the full guide at [`powerbi_guide/dashboard_setup.md`](powerbi_guide/dashboard_setup.md) for detailed instructions, DAX formulas, and visualization specifications.

## Tools & Technologies

- **Power BI Desktop** -- Report authoring, data modeling, DAX calculations
- **DAX** -- Measures for KPIs, time intelligence, and conditional logic
- **Excel / CSV** -- Source data format for contract, revenue, and renewal tracking data

## Data Files

| File | Description | Rows |
|------|-------------|------|
| `data/contracts.csv` | Master contract register with terms, values, and status | ~100 |
| `data/revenue_exposure.csv` | Monthly revenue linked to each contract | ~1,200 |
| `data/renewal_tracker.csv` | Renewal workflow status and ownership | ~100 |

## Author

Nikita -- Data Analyst | BI Developer

## License

This project is for portfolio and demonstration purposes.
