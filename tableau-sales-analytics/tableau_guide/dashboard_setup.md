# Tableau Dashboard Setup Guide

## Sales Performance & Regional Analytics -- Step-by-Step Build

---

## 1. Data Connection

### Step 1: Connect to Sales Data
1. Open **Tableau Public** (or Tableau Desktop)
2. Under **Connect > To a File**, click **Text file**
3. Navigate to `data/sales_data.csv` and open it
4. In the Data Source pane:
   - Verify the table preview looks correct
   - Rename the data source to `Sales Data`
5. Check and fix data types:
   - `order_date` --> Date
   - `quantity` --> Number (Whole)
   - `unit_price`, `discount`, `sales_amount`, `profit`, `shipping_cost` --> Number (Decimal)
   - All other fields --> String

### Step 2: Add Targets Data
1. In the Data Source pane, click **Add** next to Connections (or drag a new file)
2. Select `data/targets.csv`
3. Create a relationship or join:
   - **Option A (Relationship):** Drag `targets.csv` next to `sales_data.csv`. Define the relationship:
     - `region` = `region`
     - Add a calculated join: `DATETRUNC('month', [order_date])` = `DATE([month] + "-01")`
   - **Option B (Blend):** Keep as a separate data source and use Data Blending:
     - Link on `region`
     - Link on month (create a calculated field in Sales Data: `STR(YEAR([order_date])) + "-" + RIGHT("0" + STR(MONTH([order_date])), 2)` to match the `month` field in Targets)
4. Rename the data source to `Targets`

---

## 2. Calculated Fields

Right-click in the Data pane and select **Create Calculated Field** for each of the following.

### Profit Margin
```
[profit] / [sales_amount]
```
- Name: `Profit Margin`
- Format: Percentage, 1 decimal place
- Note: Some rows will show negative margins (this is expected and intentional)

### YoY Growth
```
(ZN(SUM([sales_amount])) - LOOKUP(ZN(SUM([sales_amount])), -12))
/ ABS(LOOKUP(ZN(SUM([sales_amount])), -12))
```
- Name: `YoY Growth`
- Format: Percentage, 1 decimal place
- Note: Use this as a **Table Calculation**. Compute using Month of `order_date`. The first 12 months will be null.

### Target Achievement %
```
SUM([sales_amount]) / SUM([sales_target])
```
- Name: `Target Achievement %`
- Format: Percentage, 0 decimal places
- Note: Requires the Targets data source to be blended or joined

### Running Total Sales
```
RUNNING_SUM(SUM([sales_amount]))
```
- Name: `Running Total Sales`
- This is a **Table Calculation**. Compute using `order_date` (continuous month).

### Sales per Customer
```
SUM([sales_amount]) / COUNTD([customer_name])
```
- Name: `Sales per Customer`
- Format: Currency, 0 decimal places

### Additional Useful Calculated Fields

**Order Month:**
```
DATETRUNC('month', [order_date])
```

**Discount Band:**
```
IF [discount] = 0 THEN "No Discount"
ELSEIF [discount] <= 0.15 THEN "Low (1-15%)"
ELSEIF [discount] <= 0.3 THEN "Medium (16-30%)"
ELSE "High (31%+)"
END
```

**Profitable (Yes/No):**
```
IF [profit] >= 0 THEN "Profitable" ELSE "Unprofitable" END
```

---

## 3. Worksheets

### Worksheet 1: Regional Sales Map

1. Create a new worksheet, name it `Regional Sales Map`
2. Drag `state` to the canvas -- Tableau should generate a map automatically
3. If it does not, go to the **Marks** card and change the mark type to **Filled Map** (under the dropdown)
4. Drag `sales_amount` (SUM) to **Color** on the Marks card
5. Edit the color palette:
   - Click **Color > Edit Colors**
   - Choose a **Sequential** palette: Blue-Green or Orange-Blue Diverging
   - Set the range from light (low sales) to dark (high sales)
6. Drag `profit` (SUM) to **Label** on the Marks card (optional -- or leave for tooltip only)
7. Add to **Tooltip**: `state`, `SUM(sales_amount)`, `SUM(profit)`, `Profit Margin`, `COUNT(order_id)`
8. Edit Tooltip to display a clean format:
   ```
   State: <state>
   Total Sales: <SUM(sales_amount)>
   Total Profit: <SUM(profit)>
   Profit Margin: <AGG(Profit Margin)>
   Orders: <COUNT(order_id)>
   ```

### Worksheet 2: Monthly Revenue Trend with Target Line

1. Create a new worksheet, name it `Monthly Revenue Trend`
2. Drag `order_date` to **Columns** -- right-click and set to **Month (continuous)**
3. Drag `sales_amount` (SUM) to **Rows**
4. On the Marks card, set mark type to **Line**
5. **Add the target line (Dual Axis):**
   - Drag `sales_target` (from Targets data source) to the right side of the chart until you see the dual-axis indicator, then drop
   - Right-click the right axis and select **Synchronize Axis**
   - On the second Marks card (for targets), change the mark type to **Line**, set to dashed
   - Color the actuals line blue (#4A7FB5) and the target line gray (#9E9E9E) with dashed style
6. Add a **Reference Line** for average sales:
   - Right-click the axis > Add Reference Line > Entire Table > Average
7. Format:
   - Title: "Monthly Revenue vs. Target"
   - Add axis labels: "Revenue ($)"
   - Remove the right axis header (since axes are synced)

### Worksheet 3: Product Category Performance (Treemap)

1. Create a new worksheet, name it `Product Category Treemap`
2. Change the mark type to **Treemap** (from the dropdown on the Marks card)
3. Drag `product_category` to **Color**
4. Drag `product_subcategory` to **Label** and to **Detail**
5. Drag `sales_amount` (SUM) to **Size**
6. Drag `Profit Margin` to **Color**
   - Edit color: use a **Diverging** palette (Red-Green)
   - Center at 0 so negative margins show red, positive show green
7. Add to Label: `product_subcategory`, `SUM(sales_amount)`
8. Tooltip: add `SUM(profit)`, `Profit Margin`, `COUNT(order_id)`

### Worksheet 4: Top & Bottom Performers (Bar Chart)

1. Create a new worksheet, name it `Top Bottom Performers`
2. Drag `product_subcategory` to **Rows**
3. Drag `profit` (SUM) to **Columns**
4. Sort descending by `SUM(profit)`
5. Drag `Profitable (Yes/No)` calculated field to **Color**
   - Set "Profitable" = Green (#2E7D32), "Unprofitable" = Red (#C62828)
6. **Create a combined set for Top 5 and Bottom 5:**
   - Right-click `product_subcategory` > Create > Set
   - Name: `Top 5 by Profit` -- Condition tab: By Field, `profit`, Sum, Top 5
   - Create another: `Bottom 5 by Profit` -- Bottom 5
   - Create a combined set: right-click one set > Create Combined Set > union of both
   - Drag the combined set to Filters and select **In**
7. Add data labels showing profit values
8. Title: "Top & Bottom 5 Subcategories by Profit"

### Worksheet 5: Customer Segment Analysis (Stacked Bar)

1. Create a new worksheet, name it `Customer Segment Analysis`
2. Drag `customer_segment` to **Columns**
3. Drag `sales_amount` (SUM) to **Rows**
4. Drag `product_category` to **Color**
5. Set mark type to **Bar** (stacked is the default)
6. Color palette:
   - Technology: #1565C0 (blue)
   - Furniture: #F57F17 (amber)
   - Office Supplies: #2E7D32 (green)
7. Add `profit` (SUM) as a **Reference Line** per cell (to show profit overlay)
8. Tooltip: `customer_segment`, `product_category`, `SUM(sales_amount)`, `SUM(profit)`, `Profit Margin`
9. Title: "Revenue by Customer Segment & Category"

### Worksheet 6: Discount vs. Profit Scatter Plot

1. Create a new worksheet, name it `Discount vs Profit`
2. Drag `discount` to **Columns** (change to Dimension, then to Continuous)
3. Drag `profit` to **Rows**
4. Set aggregation to **Attribute** or change both to disaggregated (Analysis > Aggregate Measures: uncheck)
5. Change mark type to **Circle**
6. Drag `product_category` to **Color**
7. Drag `sales_amount` to **Size** (so larger deals show as bigger circles)
8. Reduce opacity to ~50% (Color > transparency slider)
9. **Add a trend line:**
   - Right-click the chart area > Trend Lines > Show Trend Lines
   - Set to Linear, per color (one trend line per category)
10. **Add a reference line at Profit = 0:**
    - Right-click Y axis > Add Reference Line > Value: 0 > Line style: dashed red
11. Title: "Discount Impact on Profitability"
12. Caption: "Each circle represents a single order. Orders below the red line are unprofitable."

---

## 4. Dashboard Assembly

### Create the Dashboard
1. Click the **New Dashboard** tab at the bottom of Tableau
2. Set the dashboard size:
   - **Size:** Fixed > 1400 x 900 pixels (or choose Automatic for responsive)
3. Name it `Sales Performance & Regional Analytics`

### Layout

Drag worksheets from the left pane onto the dashboard canvas in this arrangement:

```
+-----------------------------------------------------------+
|  [Title: Sales Performance & Regional Analytics]          |
|  [Filters Row: Region | Segment | Category | Date Range]  |
+-----------------------------------------------------------+
|  Regional Sales Map          |  Monthly Revenue Trend     |
|  (filled map)                |  (dual axis line chart)    |
|  ~50% width                  |  ~50% width                |
+------------------------------+----------------------------+
|  Product Category     | Top/Bottom    | Customer Segment  |
|  Treemap              | Performers    | Stacked Bar       |
|  ~35% width           | ~30% width    | ~35% width        |
+------------------------------+----------------------------+
|  Discount vs. Profit Scatter Plot (full width)            |
+-----------------------------------------------------------+
```

### Dashboard Actions
1. **Filter Action -- Map to All:**
   - Dashboard > Actions > Add Action > Filter
   - Source: `Regional Sales Map`
   - Target: All other worksheets
   - Run on: Select
   - Clearing: Show all values

2. **Filter Action -- Segment to All:**
   - Source: `Customer Segment Analysis`
   - Target: All other worksheets
   - Run on: Select

3. **Highlight Action -- Category:**
   - Dashboard > Actions > Add Action > Highlight
   - Source: `Product Category Treemap`
   - Target: All worksheets
   - Run on: Hover

---

## 5. Filter & Parameter Setup

### Filters (Add to Dashboard)

Drag these fields as **Quick Filters** to the top of the dashboard:

| Filter | Field | Style |
|--------|-------|-------|
| Region | `region` | Single Value Dropdown or Multiple Values (Checkbox) |
| Customer Segment | `customer_segment` | Single Value Dropdown |
| Product Category | `product_category` | Multiple Values (Checkbox) |
| Date Range | `order_date` | Range of Dates (slider) |

**Apply each filter to all worksheets:**
- Click the filter dropdown arrow > Apply to Worksheets > All Using This Data Source

### Parameters

**Create a Top N Parameter:**
1. Right-click in the Data pane > Create Parameter
2. Name: `Top N`
3. Data type: Integer
4. Current value: 5
5. Allowable values: Range, Min 3, Max 20, Step 1
6. Right-click > Show Parameter
7. Use in the Top/Bottom Performers worksheet:
   - Edit the Set condition to use the parameter instead of a fixed number

**Create a Date Granularity Parameter:**
1. Name: `Date Granularity`
2. Data type: String
3. Allowable values: List -- "Month", "Quarter", "Year"
4. Create a calculated field:
   ```
   CASE [Date Granularity]
   WHEN "Month" THEN DATETRUNC('month', [order_date])
   WHEN "Quarter" THEN DATETRUNC('quarter', [order_date])
   WHEN "Year" THEN DATETRUNC('year', [order_date])
   END
   ```
5. Use this field in the Revenue Trend chart instead of raw `order_date`

---

## 6. Formatting & Polish

### Color Palette
| Purpose | Color | Hex |
|---------|-------|-----|
| Primary (Technology) | Royal Blue | #1565C0 |
| Furniture | Amber | #F57F17 |
| Office Supplies | Forest Green | #2E7D32 |
| Positive / Profitable | Green | #43A047 |
| Negative / Loss | Red | #E53935 |
| Target Line | Medium Gray | #9E9E9E |
| Dashboard Background | Light Gray | #F5F5F5 |
| Card/Chart Background | White | #FFFFFF |

### Font Standards
- **Dashboard Title:** 18pt, Bold, Dark Gray (#333333)
- **Worksheet Titles:** 12pt, Bold
- **Axis Labels:** 9pt, Regular
- **Tooltip Text:** 10pt

### Final Touches
1. Add a **Dashboard Title** text box at the top: "Sales Performance & Regional Analytics"
2. Add a **Subtitle** in smaller gray text: "FY 2023-2025 | All Regions"
3. Add **Borders** to each worksheet container (light gray, 1px)
4. Set **Padding** to 8px for each container
5. Hide worksheet titles that are redundant with the dashboard layout
6. Add a small **Logo/Branding** image in the top-left corner (optional)

---

## 7. Publishing to Tableau Public

1. Ensure your Tableau Public account is set up at [public.tableau.com](https://public.tableau.com)
2. In Tableau, go to **File > Save to Tableau Public As...**
3. Sign in with your Tableau Public credentials
4. Name the workbook: "Sales Performance & Regional Analytics"
5. Click **Save**
6. Your browser will open the published dashboard
7. Copy the URL and add it to the project README
8. Set visibility to **Public** so recruiters and hiring managers can view it
9. Add relevant tags: `sales`, `analytics`, `regional`, `dashboard`, `portfolio`

### Embedding
To embed in a portfolio website, use the embed code from Tableau Public:
```html
<div class='tableauPlaceholder'>
  <object class='tableauViz' style='display:none;'>
    <param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' />
    <param name='embed_code_version' value='3' />
    <param name='site_root' value='' />
    <param name='name' value='YOUR_WORKBOOK_NAME' />
    <param name='tabs' value='no' />
    <param name='toolbar' value='yes' />
  </object>
</div>
```

Replace `YOUR_WORKBOOK_NAME` with your actual workbook path from the URL.
