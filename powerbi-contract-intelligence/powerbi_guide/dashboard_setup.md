# Power BI Dashboard Setup Guide

## M&A Contract Intelligence Dashboard -- Step-by-Step Build

---

## 1. Data Import

### Step 1: Import contracts.csv
1. Open Power BI Desktop
2. Click **Home > Get Data > Text/CSV**
3. Navigate to `data/contracts.csv` and click **Open**
4. In the preview window, verify:
   - Delimiter: Comma
   - Data types are correctly detected (dates as Date, values as Decimal Number)
5. Click **Transform Data** to open Power Query Editor
6. Rename the query to `Contracts`
7. Verify column types:
   - `start_date`, `end_date` --> Date
   - `annual_value`, `total_contract_value`, `discount_pct` --> Decimal Number
   - `renewal_notice_days` --> Whole Number
8. Click **Close & Apply**

### Step 2: Import revenue_exposure.csv
1. Click **Home > Get Data > Text/CSV**
2. Navigate to `data/revenue_exposure.csv`
3. In Power Query Editor:
   - Rename query to `Revenue Exposure`
   - Change `month` column to **Text** (keep as YYYY-MM format)
   - Change `revenue_amount` to **Decimal Number**
4. Add a custom column for proper date: `= Date.FromText([month] & "-01")`
   - Name it `month_date` and set type to **Date**
5. Click **Close & Apply**

### Step 3: Import renewal_tracker.csv
1. Click **Home > Get Data > Text/CSV**
2. Navigate to `data/renewal_tracker.csv`
3. In Power Query Editor:
   - Rename query to `Renewal Tracker`
   - Change `last_action_date` to **Date**
4. Click **Close & Apply**

---

## 2. Data Model Relationships

Open **Model View** (left sidebar) and create the following relationships:

| From Table | From Column | To Table | To Column | Cardinality | Cross Filter |
|------------|-------------|----------|-----------|-------------|-------------|
| Revenue Exposure | contract_id | Contracts | contract_id | Many-to-One | Both |
| Renewal Tracker | contract_id | Contracts | contract_id | One-to-One | Both |

### Create a Date Table
Go to **Modeling > New Table** and enter:

```dax
DateTable =
ADDCOLUMNS(
    CALENDAR(DATE(2023,1,1), DATE(2026,12,31)),
    "Year", YEAR([Date]),
    "Month", MONTH([Date]),
    "MonthName", FORMAT([Date], "MMM"),
    "Quarter", "Q" & FORMAT([Date], "Q"),
    "YearMonth", FORMAT([Date], "YYYY-MM")
)
```

Mark it as a Date Table: **Table Tools > Mark as Date Table > Date column**

Create relationships:
- `DateTable[Date]` --> `Contracts[end_date]` (Many-to-One, inactive)
- `DateTable[Date]` --> `Contracts[start_date]` (Many-to-One, inactive)

---

## 3. DAX Measures

Create a new Measures table: **Home > Enter Data** --> name it `_Measures`, then add these measures.

### Total Contract Value
```dax
Total Contract Value =
SUM(Contracts[total_contract_value])
```

### Active Contract Count
```dax
Active Contract Count =
CALCULATE(
    COUNTROWS(Contracts),
    Contracts[status] IN {"Active", "Pending Renewal", "At Risk"}
)
```

### At-Risk Revenue
```dax
At-Risk Revenue =
CALCULATE(
    SUM('Revenue Exposure'[revenue_amount]),
    Contracts[status] IN {"At Risk", "Pending Renewal", "Expired"},
    FILTER(
        'Revenue Exposure',
        'Revenue Exposure'[month_date] >= TODAY() - 30
    )
)
```

### Renewal Rate
```dax
Renewal Rate =
VAR _RenewedOrCompleted =
    CALCULATE(
        COUNTROWS('Renewal Tracker'),
        'Renewal Tracker'[renewal_status] = "Completed"
    )
VAR _TotalEligible =
    CALCULATE(
        COUNTROWS(Contracts),
        Contracts[status] IN {"Active", "Expired", "Pending Renewal", "At Risk"}
    )
RETURN
DIVIDE(_RenewedOrCompleted, _TotalEligible, 0)
```

### Contracts Expiring in 30 Days
```dax
Expiring in 30 Days =
CALCULATE(
    COUNTROWS(Contracts),
    Contracts[end_date] >= TODAY(),
    Contracts[end_date] <= TODAY() + 30,
    Contracts[status] <> "Cancelled"
)
```

### Contracts Expiring in 60 Days
```dax
Expiring in 60 Days =
CALCULATE(
    COUNTROWS(Contracts),
    Contracts[end_date] >= TODAY(),
    Contracts[end_date] <= TODAY() + 60,
    Contracts[status] <> "Cancelled"
)
```

### Contracts Expiring in 90 Days
```dax
Expiring in 90 Days =
CALCULATE(
    COUNTROWS(Contracts),
    Contracts[end_date] >= TODAY(),
    Contracts[end_date] <= TODAY() + 90,
    Contracts[status] <> "Cancelled"
)
```

### Average Contract Value
```dax
Average Contract Value =
AVERAGE(Contracts[annual_value])
```

### Revenue at Risk %
```dax
Revenue at Risk % =
VAR _TotalRevenue = SUM('Revenue Exposure'[revenue_amount])
VAR _AtRiskRevenue = [At-Risk Revenue]
RETURN
DIVIDE(_AtRiskRevenue, _TotalRevenue, 0)
```

### Additional Useful Measures

```dax
Contract Count = COUNTROWS(Contracts)
```

```dax
Auto Renewal Count =
CALCULATE(
    COUNTROWS(Contracts),
    Contracts[auto_renewal] = "Y",
    Contracts[status] <> "Cancelled"
)
```

```dax
Days Until Expiry =
MIN(Contracts[end_date]) - TODAY()
```

---

## 4. Visualizations

### Page 1: Executive Summary

#### Layout
- Top row: 4 KPI cards spanning the full width
- Middle row: Contract expiry timeline (left 60%), Renewal donut charts (right 40%)
- Bottom row: Revenue exposure by BU (left 50%), Contract status pie (right 50%)

#### 4 KPI Cards (Top Row)

**Card 1 -- Total Contract Value**
- Visual: Card
- Field: `[Total Contract Value]`
- Format: Currency, 0 decimal places
- Title: "Total Contract Value"
- Background color: #1B3A5C (dark navy)
- Font color: White

**Card 2 -- Active Contracts**
- Visual: Card
- Field: `[Active Contract Count]`
- Format: Whole Number
- Title: "Active Contracts"
- Background color: #2E7D32 (green)

**Card 3 -- At-Risk Revenue**
- Visual: Card
- Field: `[At-Risk Revenue]`
- Format: Currency, 0 decimal places
- Title: "Revenue at Risk"
- Background color: #C62828 (red)

**Card 4 -- Renewal Rate**
- Visual: Card
- Field: `[Renewal Rate]`
- Format: Percentage, 1 decimal place
- Title: "Renewal Rate"
- Background color: #F57F17 (amber)

#### Contract Expiry Timeline (Bar Chart)
- Visual: **Clustered Bar Chart**
- Axis: `end_date` (grouped by Month)
- Values: `Contract Count`
- Filter: `end_date` between TODAY and TODAY + 180
- Conditional formatting on bars:
  - 0-30 days: Red (#C62828)
  - 31-60 days: Orange (#F57F17)
  - 61-90 days: Yellow (#FDD835)
  - 91+ days: Green (#2E7D32)
- Title: "Contract Expiry Timeline (Next 6 Months)"

#### 30/60/90 Day Renewal Tracker (3 Donut Charts)
- Visual: Three **Donut Charts** side by side
- Each donut:
  - Legend: `renewal_status`
  - Values: Count of `contract_id`
  - Filter by respective expiry window (0-30, 31-60, 61-90)
- Color coding:
  - Completed: Green
  - In Progress: Blue
  - Not Started: Gray
  - Escalated: Red
- Titles: "0-30 Days", "31-60 Days", "61-90 Days"

#### Revenue Exposure by Business Unit (Stacked Bar)
- Visual: **Stacked Bar Chart**
- Axis: `business_unit`
- Values: `revenue_amount`
- Legend: `status` (from Contracts table)
- Colors:
  - Active: #2E7D32 (green)
  - At Risk: #C62828 (red)
  - Pending Renewal: #F57F17 (orange)
  - Expired: #9E9E9E (gray)
  - Cancelled: #424242 (dark gray)
- Title: "Revenue Exposure by Business Unit"

#### Contract Status Breakdown (Pie Chart)
- Visual: **Pie Chart**
- Legend: `status`
- Values: `Contract Count`
- Use same color scheme as above
- Show data labels as percentage
- Title: "Contract Status Distribution"

### Page 2: Contract Detail & Risk

#### Auto-Renewal Risk Matrix (Table)
- Visual: **Table**
- Columns: `contract_id`, `vendor_name`, `business_unit`, `end_date`, `annual_value`, `auto_renewal`, `renewal_notice_days`, `status`
- Sort by: `end_date` ascending
- Conditional formatting:
  - `end_date`: Red background if within 30 days, Yellow if within 60, Green if 90+
  - `auto_renewal`: Red background if "Y" and `status` is "Active" or "At Risk"
  - `annual_value`: Data bars (blue gradient)
- Filter: Exclude "Cancelled" status
- Title: "Auto-Renewal Risk Matrix"

#### Top 10 Contracts by Value (Table)
- Visual: **Table**
- Columns: `contract_id`, `vendor_name`, `contract_type`, `annual_value`, `total_contract_value`, `status`, `owner`, `priority`
- Top N filter: Top 10 by `total_contract_value`
- Conditional formatting:
  - `priority`: Icon set (Red flag = High, Yellow = Medium, Green = Low)
  - `total_contract_value`: Data bars
- Title: "Top 10 Contracts by Value"

---

## 5. Slicer Setup

Add the following slicers to the top or left panel of each page:

| Slicer | Field | Style | Default |
|--------|-------|-------|---------|
| Business Unit | `Contracts[business_unit]` | Dropdown | All |
| Contract Type | `Contracts[contract_type]` | Dropdown | All |
| Date Range | `Contracts[end_date]` | Date Range (Between) | Last 12 months |
| Priority | `Contracts[priority]` | Buttons (horizontal) | All |
| Status | `Contracts[status]` | Checkbox list | All |

**Slicer sync:** If using multiple pages, go to **View > Sync Slicers** and sync Business Unit and Priority slicers across all pages.

---

## 6. Color Theme

Apply a consistent theme for a professional look.

### Recommended Palette

| Purpose | Color | Hex |
|---------|-------|-----|
| Primary (headers, accents) | Dark Navy | #1B3A5C |
| Secondary | Steel Blue | #4A7FB5 |
| Active / Positive | Forest Green | #2E7D32 |
| At Risk / Warning | Amber | #F57F17 |
| Expired / Danger | Crimson Red | #C62828 |
| Neutral / Cancelled | Medium Gray | #9E9E9E |
| Background | Light Gray | #F5F5F5 |
| Card Background | White | #FFFFFF |

### Apply Custom Theme
1. Go to **View > Themes > Customize Current Theme**
2. Set the data colors to the palette above
3. Set the default font to **Segoe UI** (or Segoe UI Semibold for titles)
4. Set page background to #F5F5F5
5. Save as `contract-intelligence-theme.json` for reuse

---

## 7. Page Layout Suggestions

### Page 1: Executive Summary
```
+------------------------------------------------------+
| [BU Slicer] [Type Slicer] [Date Slicer] [Priority]  |
+------------------------------------------------------+
| KPI 1   | KPI 2   | KPI 3   | KPI 4                 |
+------------------------------------------------------+
| Contract Expiry Timeline       | 30/60/90 Donuts     |
| (bar chart)                    | (3 mini donuts)     |
+------------------------------------------------------+
| Revenue Exposure by BU         | Status Pie Chart    |
| (stacked bar)                  |                     |
+------------------------------------------------------+
```

### Page 2: Contract Detail & Risk
```
+------------------------------------------------------+
| [BU Slicer] [Type Slicer] [Status Slicer]            |
+------------------------------------------------------+
| Auto-Renewal Risk Matrix                             |
| (full-width table with conditional formatting)       |
+------------------------------------------------------+
| Top 10 Contracts by Value                            |
| (full-width table with data bars)                    |
+------------------------------------------------------+
```

### General Tips
- Set page size to **16:9** (default) for presentations
- Use **Bookmarks** to create a "30 Day View" and "90 Day View" toggle
- Add a **Text Box** at the top with the dashboard title and last-refreshed date
- Use **Drill-through** on the Contracts table: right-click a contract to see its full revenue history
- Enable **Tooltips**: hover over a bar in the expiry chart to see vendor name, value, and owner

---

## 8. Publishing (Optional)

1. Save the `.pbix` file
2. Go to **Home > Publish**
3. Select your Power BI Service workspace
4. Set up **Scheduled Refresh** if connecting to a live data source
5. Share the dashboard link with stakeholders or embed in Teams/SharePoint
