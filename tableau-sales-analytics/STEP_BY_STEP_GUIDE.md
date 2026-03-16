# Step-by-Step Guide: Building the "Sales Performance & Regional Analytics" Dashboard in Tableau Public

---

## Table of Contents

1. [Prerequisites and Data Overview](#1-prerequisites-and-data-overview)
2. [Connecting to the CSV Data Files](#2-connecting-to-the-csv-data-files)
3. [Creating a Data Relationship Between the Two CSVs](#3-creating-a-data-relationship-between-the-two-csvs)
4. [Creating Calculated Fields](#4-creating-calculated-fields)
5. [Sheet 1: Revenue by Region (Horizontal Bar Chart)](#5-sheet-1-revenue-by-region-horizontal-bar-chart)
6. [Sheet 2: Monthly Sales Trend (Line Chart with Area Fill)](#6-sheet-2-monthly-sales-trend-line-chart-with-area-fill)
7. [Sheet 3: Sales by Product Category (Treemap)](#7-sheet-3-sales-by-product-category-treemap)
8. [Sheet 4: Target vs Actual by Region (Grouped Bar Chart)](#8-sheet-4-target-vs-actual-by-region-grouped-bar-chart)
9. [Sheet 5: Top 10 Salespersons (Horizontal Bar with Color by Region)](#9-sheet-5-top-10-salespersons-horizontal-bar-with-color-by-region)
10. [Sheet 6: Profit Margin by Category (Bullet Chart)](#10-sheet-6-profit-margin-by-category-bullet-chart)
11. [Assembling the Dashboard](#11-assembling-the-dashboard)
12. [Publishing to Tableau Public](#12-publishing-to-tableau-public)
13. [Getting the Embed/Share Link](#13-getting-the-embedshare-link)
14. [Post-Publishing Checklist](#14-post-publishing-checklist)

---

## 1. Prerequisites and Data Overview

### What You Need

- **Tableau Public** (Desktop version) installed on your Mac
- The two CSV files located in `data/`:
  - `data/sales_data.csv` (1,000 rows of order-level transactions)
  - `data/targets.csv` (144 rows of monthly regional targets)
- A free Tableau Public account at [public.tableau.com](https://public.tableau.com)

### Data Dictionary: sales_data.csv

| Column | Type | Example Values |
|--------|------|---------------|
| `order_id` | String | ORD-100001 |
| `order_date` | Date | 2025-11-03 |
| `customer_name` | String | Charles Miller |
| `customer_segment` | String | Consumer, Corporate, Home Office |
| `region` | String | North, South, East, West |
| `state` | String | Nevada, Massachusetts, Florida |
| `city` | String | Las Vegas, Boston, Miami |
| `product_category` | String | Furniture, Office Supplies, Technology |
| `product_subcategory` | String | Bookcases, Chairs, Computers, Phones, Paper, Art, etc. (12 total) |
| `product_name` | String | IKEA KALLAX, MacBook Pro 14, etc. |
| `quantity` | Integer | 1-10 |
| `unit_price` | Decimal | 8.55 - 2443.42 |
| `discount` | Decimal | 0.0 - 0.5 (i.e., 0% to 50%) |
| `sales_amount` | Decimal | Total sale after discount |
| `profit` | Decimal | Can be negative |
| `shipping_cost` | Decimal | Cost of shipping |
| `ship_mode` | String | Standard Class, Second Class, First Class, Same Day |

Date range: **2023-01-01 to 2025-12-28** (3 full years).

### Data Dictionary: targets.csv

| Column | Type | Example Values |
|--------|------|---------------|
| `region` | String | North, South, East, West |
| `month` | String (YYYY-MM) | 2023-01, 2024-06, 2025-12 |
| `sales_target` | Decimal | 24814.14 - 65727.92 |

Coverage: Monthly targets for all 4 regions across 36 months (2023-01 through 2025-12).

---

## 2. Connecting to the CSV Data Files

### Step 2.1 -- Open Tableau Public

1. Launch **Tableau Public** from your Applications folder.
2. You will see the Start Page with a blue left sidebar titled **Connect**.

### Step 2.2 -- Connect to sales_data.csv

1. Under **Connect** > **To a File**, click **Text file**.
2. In the file dialog, navigate to:
   ```
   /Users/apple/Nikita/drive-download-20250921T130242Z-1-001/Claude/Portfolio/tableau-sales-analytics/data/
   ```
3. Select **sales_data.csv** and click **Open**.
4. Tableau will open the **Data Source** tab and show a preview of the data at the bottom.

[You should see: A table preview showing columns like order_id, order_date, customer_name, etc. The orange "Abc" icon appears next to string fields, the "#" icon next to numeric fields, and a calendar icon next to order_date.]

### Step 2.3 -- Verify Data Types

Check that Tableau detected these types correctly in the preview grid:

| Field | Expected Icon | Expected Type |
|-------|--------------|---------------|
| `order_date` | Calendar icon | Date |
| `quantity` | # | Number (whole) |
| `unit_price` | # | Number (decimal) |
| `discount` | # | Number (decimal) |
| `sales_amount` | # | Number (decimal) |
| `profit` | # | Number (decimal) |
| `shipping_cost` | # | Number (decimal) |
| All other fields | Abc | String |

**If `order_date` shows as a string (Abc icon):**
1. Click the **Abc** icon above the `order_date` column in the preview.
2. Select **Date** from the dropdown.

**If `discount` shows as a string:**
1. Click the **Abc** icon above `discount`.
2. Select **Number (decimal)**.

---

## 3. Creating a Data Relationship Between the Two CSVs

### Step 3.1 -- Add targets.csv

1. You should still be on the **Data Source** tab. At the top, you will see an orange box representing `sales_data.csv` in the canvas area.
2. In the left sidebar under **Connections**, click **Add** (the small link next to "Connections" heading at top-left).
3. Choose **Text file** again.
4. Navigate to the same `data/` folder and select **targets.csv**. Click **Open**.
5. You will now see `targets` appear in the left sidebar under your connection.

### Step 3.2 -- Create the Relationship

1. **Drag** `targets.csv` from the left sidebar into the canvas area (the white space next to the `sales_data` orange box).
2. Tableau will attempt to auto-detect a relationship and show a relationship dialog (the "noodle" connecting the two tables will appear).
3. **Double-click** the relationship line (the noodle) between the two tables to open the relationship editor.

### Step 3.3 -- Configure Relationship Fields

You need to match on two fields: **Region** and **Month/Date**. Since `sales_data` has a full date (`order_date`) and `targets` has a year-month string (`month`), you need to handle this carefully.

**Field Pair 1 -- Region:**
1. In the relationship editor, the first row should already show a field pair.
2. On the left side (sales_data), select **Region** from the dropdown.
3. On the right side (targets), select **Region** from the dropdown.

**Field Pair 2 -- Date to Month:**
1. Click **Add another field pair** (the "+" button or "Add" link at the bottom of the field pairs).
2. On the left side (sales_data), select **Order Date**.
3. On the right side (targets), select **Month**.
4. **Important:** Since `order_date` is a full date and `month` is "YYYY-MM" format, you need to change the date granularity:
   - Click the **Order Date** field on the left side of the relationship pair.
   - A dropdown will appear for the date part. Change it to **Month** (this truncates the date to year-month level so it matches the targets.csv month format).
   - If Tableau shows a "Date Part" vs "Date Truncation" option, choose the truncation option that produces "YYYY-MM" level matching (i.e., `Month` under the date truncation section, not the date part section).

[You should see: Two field pairs in the relationship editor -- Region = Region, and Order Date (Month) = Month. The relationship line between the two tables should now be solid, indicating a valid join.]

5. Click the **X** or click outside the dialog to close the relationship editor.

### Step 3.4 -- Verify the Relationship

1. Click on the `targets` table preview at the bottom of the Data Source page.
2. Scroll right to confirm you can see `sales_target` values.
3. Check that the record count looks reasonable (some rows may appear null if dates or regions do not match perfectly -- this is normal for outer-join behavior in relationships).

### Alternative Approach: Using a Blend Instead

If the relationship approach causes issues (e.g., data granularity mismatch), you can use **data blending** instead:

1. Instead of dragging targets onto the canvas, keep sales_data as your primary source.
2. Go to **Data** menu > **New Data Source** > **Text file** > select `targets.csv`.
3. Navigate to any sheet. In the **Data** pane on the left, you will see both data sources.
4. Click `sales_data` (primary) and then click `targets` (secondary -- it will show a small orange chain-link icon).
5. Go to **Data** menu > **Edit Blend Relationships**.
6. Set up a custom blend on **Region** and a calculated field for month matching.

The relationship approach (Step 3.1-3.3) is preferred and should work for this dataset.

---

## 4. Creating Calculated Fields

Before building any sheets, create these calculated fields so they are available everywhere.

### Step 4.1 -- Navigate to a Sheet

1. Click on **Sheet 1** tab at the bottom of the screen to leave the Data Source page.
2. You will see the worksheet view with the **Data** pane on the left showing all fields from both tables.

### Step 4.2 -- Create "Achievement %"

1. In the **Data** pane on the left, right-click on any empty area (or click the small dropdown arrow at the top of the Data pane).
2. Select **Create Calculated Field...**.
3. In the dialog:
   - **Name:** `Achievement %`
   - **Formula:**
     ```
     SUM([Sales Amount]) / SUM([Sales Target])
     ```
4. Click **OK**.
5. Right-click the newly created `Achievement %` field in the Data pane.
6. Select **Default Properties** > **Number Format**.
7. Choose **Percentage** with **1** decimal place. Click **OK**.

[You should see: "Achievement %" now appears under Measures in the Data pane with a green "#" icon.]

### Step 4.3 -- Create "Profit Margin %"

1. Right-click in the Data pane > **Create Calculated Field...**.
2. In the dialog:
   - **Name:** `Profit Margin %`
   - **Formula:**
     ```
     SUM([Profit]) / SUM([Sales Amount])
     ```
3. Click **OK**.
4. Right-click `Profit Margin %` > **Default Properties** > **Number Format** > **Percentage**, 1 decimal. Click **OK**.

### Step 4.4 -- Create "YoY Growth %"

Since the data spans 2023-2025, we can calculate year-over-year growth using table calculations:

1. Right-click in the Data pane > **Create Calculated Field...**.
2. In the dialog:
   - **Name:** `YoY Growth %`
   - **Formula:**
     ```
     (ZN(SUM([Sales Amount])) - LOOKUP(ZN(SUM([Sales Amount])), -1))
     / ABS(LOOKUP(ZN(SUM([Sales Amount])), -1))
     ```
3. Click **OK**.
4. Right-click `YoY Growth %` > **Default Properties** > **Number Format** > **Percentage**, 1 decimal. Click **OK**.

**Note:** This is a table calculation. When you use it on a sheet, you will need to set "Compute Using" to the appropriate dimension (typically Year of Order Date). We will configure this when we use it.

### Step 4.5 -- Create "Order Month" (Helper Field)

This will be useful for aligning sales data with the targets table:

1. Right-click in the Data pane > **Create Calculated Field...**.
2. In the dialog:
   - **Name:** `Order Month`
   - **Formula:**
     ```
     DATETRUNC('month', [Order Date])
     ```
3. Click **OK**.

---

## 5. Sheet 1: Revenue by Region (Horizontal Bar Chart)

### Step 5.1 -- Rename the Sheet

1. Double-click the **Sheet 1** tab at the bottom.
2. Type `Revenue by Region` and press **Enter**.

### Step 5.2 -- Build the Bar Chart

1. **Drag** `Region` from the Data pane to the **Rows** shelf.
   - [You should see: Four rows appear in the view -- East, North, South, West.]

2. **Drag** `Sales Amount` from the Data pane to the **Columns** shelf.
   - Tableau will automatically aggregate it as `SUM(Sales Amount)`.
   - [You should see: A horizontal bar chart with four bars, one per region. West should be the longest bar.]

### Step 5.3 -- Sort the Bars

1. Click the **sort descending** icon on the toolbar (looks like a bar chart icon with bars going from tall to short), OR:
2. Right-click the `Region` axis (the vertical axis on the left) > **Sort** > Sort By: **Field** > Field Name: **Sales Amount** > Aggregation: **Sum** > Sort Order: **Descending**. Click **OK**.

[You should see: Bars are now ordered West (top) > North > South > East (bottom).]

### Step 5.4 -- Add Color

1. **Drag** `Region` from the Data pane to the **Color** card on the Marks shelf.
2. Click the **Color** card > **Edit Colors...**.
3. In the Edit Colors dialog, select the **Seattle Grays** or **Blue** palette from the dropdown at top-right. Alternatively, assign manual colors:
   - West: `#1B4F72` (dark navy blue)
   - North: `#2E86C1` (medium blue)
   - South: `#5DADE2` (light blue)
   - East: `#AED6F1` (pale blue)
4. Click **OK**.

### Step 5.5 -- Add Data Labels

1. **Drag** `Sales Amount` from the Data pane to the **Label** card on the Marks shelf.
2. Click the **Label** card > check **Show mark labels**.
3. Click the **Label** card > click the "..." (three dots) next to **Text** > Format the label:
   - Click on the `SUM(Sales Amount)` pill in the label editor.
   - Change format to **Currency (Standard)** or **Number (Custom)** with $ prefix and no decimals: `$#,##0`
4. Under Alignment, set horizontal alignment to **Right** so labels appear at the end of bars.

### Step 5.6 -- Format the Axes and Title

1. Right-click the bottom axis (Sales Amount) > **Format...**.
   - Under **Scale** > **Numbers**, select **Currency (Custom)** > 0 decimal places > set to display as `$#,##0`.
2. Right-click the sheet title at the top > **Edit Title...** > Type: `Revenue by Region` > set font to **Tableau Bold, 14pt**. Click **OK**.
3. Right-click the bottom axis label ("Sales Amount") > **Edit Axis...** > Clear the title (leave blank) or set to "Total Revenue ($)". Click **OK**.

[You should see: A clean horizontal bar chart with four blue-shaded bars sorted from highest (West) to lowest (East), with dollar-formatted labels at the end of each bar.]

---

## 6. Sheet 2: Monthly Sales Trend (Line Chart with Area Fill)

### Step 6.1 -- Create a New Sheet

1. Click the **New Worksheet** icon (the tab with a "+" at the bottom of the screen).
2. Double-click the new tab and rename it to `Monthly Sales Trend`.

### Step 6.2 -- Build the Line Chart

1. **Drag** `Order Date` from the Data pane to the **Columns** shelf.
   - Tableau will default to `YEAR(Order Date)`. This is not what we want.
2. Right-click the `YEAR(Order Date)` pill on the Columns shelf > select **Month** (the second "Month" option in the list -- the one that shows "May 2015" format, which is the continuous/truncated month, not the discrete one).
   - If you see two "Month" options, choose the one under the **green** continuous date section (the lower group), not the blue discrete one.
   - Alternatively: Click the dropdown on the pill > **More** > **Month** (continuous).

   [You should see: The x-axis now shows a continuous timeline from Jan 2023 to Dec 2025.]

3. **Drag** `Sales Amount` from the Data pane to the **Rows** shelf.
   - [You should see: A single line trending from left to right across 36 months.]

### Step 6.3 -- Add Area Fill

1. On the **Marks** shelf, click the dropdown that currently says **Automatic** (or **Line**).
2. Change it to **Area**.
   - [You should see: The area under the line is now filled with color.]

### Step 6.4 -- Add Color and Formatting

1. Click the **Color** card on the Marks shelf.
2. Click the colored square and select a medium blue: `#2E86C1`.
3. Under **Effects** in the Color dialog, set **Opacity** to about **60-70%** so the area fill is semi-transparent.
4. Set **Border** to a slightly darker blue: `#1B4F72`.

### Step 6.5 -- Add a Trend Line (Optional)

1. Go to **Analytics** pane (tab next to the Data pane on the left).
2. **Drag** `Trend Line` from the Analytics pane and drop it on the view.
3. Choose **Linear** as the model.
4. Right-click the trend line > **Format Trend Lines** > set color to a dark blue dashed line.

### Step 6.6 -- Add Tooltips and Labels

1. **Drag** `Profit` from the Data pane to the **Tooltip** card on the Marks shelf. This adds profit information to the hover tooltip.
2. Click the **Tooltip** card > **Edit Tooltip...** > Customize the text:
   ```
   Month: <MONTH(Order Date)>
   Revenue: <SUM(Sales Amount)>
   Profit: <SUM(Profit)>
   ```
3. Click **OK**.

### Step 6.7 -- Format the Axes

1. Right-click the vertical axis > **Format...** > Numbers > **Currency (Custom)** > `$#,##0` > 0 decimals.
2. Right-click the vertical axis > **Edit Axis...** > Set title to `Monthly Revenue`.
3. Right-click the horizontal axis > **Edit Axis...** > Set title to blank (remove it since the date is self-explanatory).
4. Right-click the sheet title > **Edit Title** > `Monthly Sales Trend (2023-2025)` > **Tableau Bold, 14pt**.

[You should see: A smooth area chart showing monthly revenue over 36 months with a blue filled area, an upward trend visible, and Q4 peaks each year.]

---

## 7. Sheet 3: Sales by Product Category (Treemap)

### Step 7.1 -- Create a New Sheet

1. Click the **New Worksheet** icon at the bottom.
2. Rename the tab to `Sales by Category`.

### Step 7.2 -- Build the Treemap

1. On the **Marks** shelf, click the dropdown (says **Automatic**) and change it to **Square** (this is the Treemap mark type, sometimes called "Square").

   [You should see: The Marks card now shows "Square" as the mark type.]

2. **Drag** `Product Category` from the Data pane to the **Color** card on the Marks shelf.
3. **Drag** `Product Subcategory` from the Data pane to the **Detail** card on the Marks shelf (or directly onto the view).
4. **Drag** `Sales Amount` from the Data pane to the **Size** card on the Marks shelf.
5. **Drag** `Sales Amount` again from the Data pane to the **Label** card on the Marks shelf.

[You should see: A treemap where each rectangle represents a product subcategory. Rectangles are sized by sales amount and colored by their parent category (3 colors for Furniture, Office Supplies, Technology).]

### Step 7.3 -- Add Subcategory Labels

1. **Drag** `Product Subcategory` from the Data pane to the **Label** card on the Marks shelf.
2. Click the **Label** card > **Edit Label...** (click the "..." next to Text) > arrange the label:
   ```
   <Product Subcategory>
   <SUM(Sales Amount)>
   ```
3. Format `SUM(Sales Amount)` as currency: Click on it in the label editor > **Format** > **Currency (Custom)** > `$#,##0`.
4. Set the font for the subcategory name to **Bold, 10pt** and the sales amount to **Regular, 9pt**.
5. Click **OK**.

### Step 7.4 -- Apply Blue Color Palette

1. Click the **Color** card > **Edit Colors...**.
2. Assign blue-family colors to each category:
   - **Furniture:** `#1B4F72` (dark navy)
   - **Technology:** `#2E86C1` (medium blue)
   - **Office Supplies:** `#85C1E9` (light sky blue)
3. Click **OK**.
4. Click the **Color** card > set **Border** to **White** for clean separation between rectangles.

### Step 7.5 -- Title

1. Right-click title > **Edit Title** > `Sales by Product Category` > **Tableau Bold, 14pt**. Click **OK**.

[You should see: A treemap with three distinct blue shades, each rectangle labeled with the subcategory name and its sales value. Technology items like Computers and Phones should appear as the largest rectangles.]

---

## 8. Sheet 4: Target vs Actual by Region (Grouped Bar Chart)

### Step 8.1 -- Create a New Sheet

1. Click the **New Worksheet** icon.
2. Rename to `Target vs Actual`.

### Step 8.2 -- Build the Grouped Bar Chart

1. **Drag** `Region` from the Data pane to the **Columns** shelf.
2. **Drag** `Sales Amount` from the Data pane to the **Rows** shelf.
   - This creates SUM(Sales Amount) -- the "Actual" values.
3. **Drag** `Sales Target` (from the targets table) from the Data pane to the **Rows** shelf, placing it **right next to** the existing `SUM(Sales Amount)` pill.

   [You should see: Two separate bar charts side by side -- one for Sales Amount, one for Sales Target, each grouped by Region.]

4. Now we need to combine them. On the **Rows** shelf, there are two green pills: `SUM(Sales Amount)` and `SUM(Sales Target)`.
5. Right-click on the **second axis** (the right-side axis for Sales Target) > **Dual Axis**.

   **Wait -- actually, for a grouped bar chart, we want them side by side, NOT overlapping.** Let me correct the approach:

**Correct Method for Side-by-Side Grouped Bars:**

1. Clear the sheet (Ctrl+Z or Edit > Undo until blank).
2. **Drag** `Region` to the **Columns** shelf.
3. **Drag** `Measure Names` to the **Columns** shelf (place it to the right of Region).
4. **Drag** `Measure Values` to the **Rows** shelf.
5. On the **Measure Values** card (which appears below the Marks shelf), remove all measures EXCEPT:
   - `SUM(Sales Amount)`
   - `SUM(Sales Target)`
   - (Remove the others by dragging them off the card or right-clicking > Remove.)

[You should see: For each region, two bars side by side -- one for Sales Amount (Actual) and one for Sales Target.]

### Step 8.3 -- Filter Measure Names

1. If the `Measure Names` filter card does not automatically appear, **drag** `Measure Names` to the **Filters** shelf.
2. In the filter dialog, check ONLY:
   - `Sales Amount`
   - `Sales Target`
3. Click **OK**.

### Step 8.4 -- Apply Colors

1. `Measure Names` should already be on the **Color** card (Tableau often does this automatically). If not, **drag** `Measure Names` to the **Color** card.
2. Click **Color** > **Edit Colors...**:
   - **Sales Amount (Actual):** `#2E86C1` (medium blue)
   - **Sales Target:** `#AED6F1` (pale blue / light blue)
3. Click **OK**.

### Step 8.5 -- Add Data Labels

1. **Drag** `Measure Values` to the **Label** card.
2. Click the **Label** card > check **Show mark labels**.
3. Format labels as currency with no decimals.

### Step 8.6 -- Add Achievement % to Tooltip

1. **Drag** the calculated field `Achievement %` to the **Tooltip** card on the Marks shelf.
2. Click the **Tooltip** card > **Edit Tooltip...** > Add context:
   ```
   Region: <Region>
   <Measure Names>: <Measure Values>
   Achievement: <AGG(Achievement %)>
   ```
3. Click **OK**.

### Step 8.7 -- Format and Title

1. Right-click the vertical axis > **Format** > Numbers > `$#,##0`.
2. Right-click title > **Edit Title** > `Target vs Actual Sales by Region` > **Tableau Bold, 14pt**.

[You should see: Four groups of two bars each (North, South, East, West). Each group has a darker blue "Actual" bar and a lighter blue "Target" bar. West should have the tallest bars overall.]

---

## 9. Sheet 5: Top 10 Salespersons (Horizontal Bar with Color by Region)

### Step 9.1 -- Create a New Sheet

1. Click the **New Worksheet** icon.
2. Rename to `Top 10 Salespersons`.

### Step 9.2 -- Build the Bar Chart

1. **Drag** `Customer Name` from the Data pane to the **Rows** shelf.
   - Note: In this dataset, `customer_name` functions as the salesperson/customer identifier. All 180+ unique names will appear.

2. **Drag** `Sales Amount` from the Data pane to the **Columns** shelf.
   - [You should see: A horizontal bar chart with many bars -- one per customer name.]

### Step 9.3 -- Filter to Top 10

1. **Drag** `Customer Name` from the Data pane to the **Filters** shelf.
2. In the filter dialog, switch to the **Top** tab.
3. Set:
   - **By field:** Top **10** by **Sales Amount** > **Sum**
4. Click **OK**.

[You should see: Only 10 bars remain, showing the 10 customers with the highest total sales.]

### Step 9.4 -- Sort Descending

1. Click the **sort descending** toolbar icon, OR:
2. Right-click the `Customer Name` header on the left > **Sort** > By: **Field** > **Sales Amount** > **Sum** > **Descending**. Click **OK**.

### Step 9.5 -- Add Color by Region

1. **Drag** `Region` from the Data pane to the **Color** card on the Marks shelf.
2. Click **Color** > **Edit Colors...**:
   - West: `#1B4F72` (dark navy)
   - North: `#2E86C1` (medium blue)
   - South: `#5DADE2` (light blue)
   - East: `#AED6F1` (pale blue)
3. Click **OK**.

**Important Note:** Some customers may have orders in multiple regions. Each bar may show stacked color segments. This is expected -- it shows where each salesperson's revenue comes from.

### Step 9.6 -- Add Data Labels

1. **Drag** `Sales Amount` to the **Label** card.
2. Click **Label** > check **Show mark labels**.
3. Format as currency `$#,##0`.

### Step 9.7 -- Title and Polish

1. Right-click title > **Edit Title** > `Top 10 Customers by Revenue` > **Tableau Bold, 14pt**.
2. Right-click the bottom axis > **Edit Axis** > Title: clear or set to `Total Revenue ($)`.
3. Right-click the left axis label > **Edit Axis** > Title: clear (customer names are self-explanatory).

[You should see: 10 horizontal bars sorted from highest revenue at top to lowest at bottom. Each bar is colored (or stacked with color segments) by Region using the blue palette. A color legend appears on the right.]

---

## 10. Sheet 6: Profit Margin by Category (Bullet Chart)

We will create a bullet-style chart that shows Profit Margin % by Product Category and Product Subcategory.

### Step 10.1 -- Create a New Sheet

1. Click the **New Worksheet** icon.
2. Rename to `Profit Margin by Category`.

### Step 10.2 -- Build the Scatter Plot / Bar-Based Bullet

**Approach: Horizontal bar chart showing Profit Margin % per subcategory, colored by category.**

1. **Drag** `Product Subcategory` from the Data pane to the **Rows** shelf.
2. **Drag** the calculated field `Profit Margin %` from the Data pane to the **Columns** shelf.

   [You should see: A horizontal bar chart with 12 bars (one per subcategory), showing profit margin percentage on the x-axis.]

3. **Drag** `Product Category` from the Data pane to the **Color** card on the Marks shelf.

### Step 10.3 -- Sort by Profit Margin

1. Right-click `Product Subcategory` on the Rows shelf > **Sort** > By: **Field** > **Profit Margin %** > **Custom aggregation** (this might not appear -- if so, just sort by the axis).
2. Alternatively, click the **sort descending** icon on the toolbar.

### Step 10.4 -- Add a Reference Line for Average Margin

1. Switch to the **Analytics** pane (tab next to Data pane).
2. **Drag** `Reference Line` from the Analytics pane and drop it on the chart area.
3. In the dialog:
   - **Scope:** Entire Table
   - **Line:** Value = `AGG(Profit Margin %)` > Aggregation = **Average**
   - **Label:** choose **Value** or **Custom** and type "Avg Margin"
   - **Line style:** Dashed, color: `#E74C3C` (red) or dark gray
4. Click **OK**.

[You should see: A dashed vertical line showing the average profit margin across all subcategories.]

### Step 10.5 -- Add Labels and Tooltip

1. **Drag** `Profit Margin %` to the **Label** card.
2. Click **Label** > check **Show mark labels**.
3. **Drag** `Sales Amount` to the **Tooltip** card.
4. **Drag** `Profit` to the **Tooltip** card.
5. Click **Tooltip** > Edit:
   ```
   <Product Subcategory>
   Profit Margin: <AGG(Profit Margin %)>
   Revenue: <SUM(Sales Amount)>
   Profit: <SUM(Profit)>
   ```

### Step 10.6 -- Apply Blue Palette

1. Click **Color** > **Edit Colors...**:
   - Furniture: `#1B4F72`
   - Technology: `#2E86C1`
   - Office Supplies: `#85C1E9`
2. Click **OK**.

### Step 10.7 -- Format and Title

1. Right-click the bottom axis > **Format** > Numbers > **Percentage** > 1 decimal.
2. Right-click title > **Edit Title** > `Profit Margin by Product Category` > **Tableau Bold, 14pt**.

[You should see: 12 horizontal bars showing profit margin for each subcategory, sorted from highest to lowest. Copiers and Paper should be among the highest-margin subcategories. A dashed reference line shows the average margin. Colors distinguish the three product categories.]

---

## 11. Assembling the Dashboard

### Step 11.1 -- Create a New Dashboard

1. Click the **New Dashboard** icon at the bottom (the icon with the grid/window symbol, next to the New Worksheet icon).
2. A blank dashboard canvas will appear.

### Step 11.2 -- Set Dashboard Size

1. In the left sidebar under **Size**, click the dropdown (it may say "Desktop" or "Automatic").
2. Select **Fixed size**.
3. Set width to **1400** and height to **900** pixels.
   - This gives a good widescreen layout for Tableau Public.
   - Alternatively, choose **Automatic** if you want it responsive.

### Step 11.3 -- Set Up the 2x3 Grid Layout

We will arrange 6 sheets in a 2-column, 3-row grid.

**Layout Plan:**

```
+------------------------------------+------------------------------------+
|   Revenue by Region (Bar)          |   Monthly Sales Trend (Area)       |
|   Row 1, Left                      |   Row 1, Right                     |
+------------------------------------+------------------------------------+
|   Sales by Category (Treemap)      |   Target vs Actual (Grouped Bar)   |
|   Row 2, Left                      |   Row 2, Right                     |
+------------------------------------+------------------------------------+
|   Top 10 Salespersons (Bar)        |   Profit Margin by Category (Bar)  |
|   Row 3, Left                      |   Row 3, Right                     |
+------------------------------------+------------------------------------+
```

**Step-by-step placement:**

1. First, add a **Horizontal** layout container for the title bar:
   - From the left sidebar under **Objects**, **drag** a **Horizontal** object to the very top of the dashboard canvas.
   - It will appear as a thin gray bar at the top.

2. Add a **Vertical** container for the main grid:
   - **Drag** a **Vertical** object to the area below the horizontal title bar.

3. Now add **three Horizontal containers** inside the vertical container (one for each row):
   - **Drag** a **Horizontal** object into the vertical container. This is Row 1.
   - **Drag** another **Horizontal** object below Row 1 inside the vertical container. This is Row 2.
   - **Drag** another **Horizontal** object below Row 2. This is Row 3.

**Alternatively (simpler approach -- Tiled layout):**

1. Make sure the dashboard is in **Tiled** mode (check at the bottom of the left sidebar -- "Tiled" should be selected, not "Floating").
2. From the left sidebar under **Sheets**, **drag** `Revenue by Region` to the **top-left** area of the dashboard canvas.
   - [You should see: The sheet fills the entire dashboard.]
3. **Drag** `Monthly Sales Trend` to the **right side** of `Revenue by Region`.
   - A gray highlight will appear on the right half. Drop it there.
   - [You should see: Two sheets side by side, each taking half the width.]
4. **Drag** `Sales by Category` to the **bottom half** of `Revenue by Region` (below it).
   - A gray highlight will appear below the left sheet. Drop it there.
5. **Drag** `Target vs Actual` to the **right** of `Sales by Category` (or below `Monthly Sales Trend`).
6. **Drag** `Top 10 Salespersons` below `Sales by Category`.
7. **Drag** `Profit Margin by Category` to the right of `Top 10 Salespersons`.

**Tip:** If the layout is not forming a perfect grid, use the **Layout** tab on the left sidebar to manually adjust the position and size of each container/sheet. You can also hold **Shift** while dragging to swap objects.

[You should see: A 2x3 grid of six visualizations filling the dashboard canvas.]

### Step 11.4 -- Add a Title Bar

1. Click on the **Horizontal** container at the very top (if you created one) or create space at the top:
   - From the left sidebar under **Objects**, **drag** a **Text** object to the very top of the dashboard.
2. In the text editor that appears, type:
   ```
   Sales Performance & Regional Analytics Dashboard
   ```
3. Set the font to **Tableau Bold, 20pt**.
4. Set the color to `#1B4F72` (dark navy blue).
5. Set alignment to **Center**.
6. Click **OK**.
7. Resize the text box height to about **50-60 pixels** (grab the bottom edge and drag up so it does not take too much space).

### Step 11.5 -- Add a Region Filter

1. Click on any sheet in the dashboard that has `Region` (e.g., click on the `Revenue by Region` chart).
2. Click the small **funnel icon** in the top-right corner of that sheet (or go to the sheet's dropdown menu > **Filters** > **Region**).
   - Alternatively: In the sheet within the dashboard, click the dropdown arrow at the top-right of the `Revenue by Region` container > **Filters** > check **Region**.
3. A filter control will appear on the dashboard.
4. Right-click the Region filter > **Apply to Worksheets** > **All Using This Data Source**.
   - This makes the Region filter apply to ALL six sheets simultaneously.
5. Click the dropdown on the filter card > choose **Single Value (dropdown)** or **Multiple Values (dropdown)** depending on your preference.
   - **Multiple Values (dropdown)** is recommended so users can select multiple regions.

### Step 11.6 -- Add a Product Category Filter

1. Click on the `Sales by Category` treemap in the dashboard.
2. Click the dropdown arrow at the top-right > **Filters** > check **Product Category**.
3. A filter card appears. Right-click it > **Apply to Worksheets** > **All Using This Data Source**.
4. Set it to **Multiple Values (dropdown)**.

### Step 11.7 -- Add a Date Range Filter

1. Click on the `Monthly Sales Trend` chart in the dashboard.
2. Click the dropdown arrow at the top-right > **Filters** > check **Order Date**.
3. In the filter dialog that may appear, choose **Range of Dates** and click **OK**.
4. A date slider will appear on the dashboard. Right-click it > **Apply to Worksheets** > **All Using This Data Source**.
5. The slider lets users select a start and end date for the analysis period.

### Step 11.8 -- Position the Filters

1. **Drag** all three filter cards to a consistent location:
   - **Option A:** Place them all at the top, below the title bar, in a single horizontal row.
   - **Option B:** Place them in the right margin as a vertical column.
2. To move a filter: Click and drag its header to the desired position.
3. **Recommended layout:** Place all filters in a row below the title:
   - Drag the Region filter to below the title, left side.
   - Drag the Category filter to the right of Region.
   - Drag the Date Range filter to the right of Category.

### Step 11.9 -- Apply the Blue Color Scheme Globally

To ensure consistency:

1. Go to **Format** menu (top menu bar) > **Workbook Theme** (if available) or **Dashboard** > set background.
2. Click on an empty area of the dashboard > in the **Layout** tab on the left:
   - Set **Background** color to `#F7FBFF` (very light blue, almost white) for a subtle blue tint.
3. For each sheet's title within the dashboard:
   - Click the sheet title > right-click > **Format Title** > set color to `#1B4F72` (dark navy).
4. Ensure all sheets use the same blue palette you set earlier:
   - West / Dark: `#1B4F72`
   - North / Medium: `#2E86C1`
   - South / Light: `#5DADE2`
   - East / Pale: `#AED6F1`
   - Reference colors: `#85C1E9`, `#D4E6F1`

### Step 11.10 -- Add Borders and Padding

1. Click each sheet in the dashboard.
2. In the **Layout** tab on the left sidebar:
   - Set **Outer Padding** to `4` on all sides.
   - Set **Border** to a thin line (1px), color `#D4E6F1` (light blue-gray).
3. This creates clean visual separation between the six charts.

### Step 11.11 -- Hide Individual Sheet Titles (Optional)

If the individual sheet titles are redundant (because the chart content is self-explanatory):

1. Right-click any sheet title inside the dashboard > **Hide Title**.
2. Alternatively, keep titles but make them smaller (10pt instead of 14pt) since the dashboard has its own title bar.

### Step 11.12 -- Final Dashboard Review

Before publishing, check:

- [ ] All six charts are visible and properly sized.
- [ ] Filters work: Click a Region in the filter and verify all charts update.
- [ ] Colors are consistent across all sheets (same blue palette).
- [ ] Labels are readable and not overlapping.
- [ ] The title bar is prominent and centered.
- [ ] Tooltips appear when hovering over data points.
- [ ] The date filter slider works and filters all sheets.

[You should see: A polished 2x3 dashboard with a dark blue title, three filter controls, and six visualizations all using a coordinated blue color scheme. The layout should feel clean and professional.]

---

## 12. Publishing to Tableau Public

### Step 12.1 -- Sign In to Tableau Public

1. Go to **File** menu (top menu bar) > **Save to Tableau Public As...**.
2. If prompted, enter your **Tableau Public credentials** (email and password).
3. If you do not have an account, click **Create one for free** and sign up at [public.tableau.com/signup](https://public.tableau.com/app/discover).

### Step 12.2 -- Save/Publish

1. After signing in, a dialog will appear asking for the **workbook name**.
2. Type: `Sales Performance & Regional Analytics`
3. Click **Save**.
4. Tableau will upload the workbook and data to Tableau Public servers. This may take 1-3 minutes depending on your connection.

[You should see: A progress bar while uploading. When complete, your default browser will open to the published dashboard on Tableau Public.]

### Step 12.3 -- Verify the Published Dashboard

1. In your browser, the dashboard should appear fully interactive.
2. Test:
   - Click the Region filter and verify all charts update.
   - Hover over bars and data points to check tooltips.
   - Use the date range slider.
3. If anything looks wrong, go back to Tableau Public Desktop, fix it, and re-publish using **File** > **Save to Tableau Public As...** (same name will overwrite).

---

## 13. Getting the Embed/Share Link

### Step 13.1 -- Get the Share URL

1. On the Tableau Public page in your browser (where the dashboard was just published), look at the **bottom of the dashboard** for the sharing toolbar.
2. Click the **Share** icon (it looks like a square with an arrow pointing up, or a chain-link icon).
3. A popup will appear with:
   - **Link:** A URL like `https://public.tableau.com/views/SalesPerformanceRegionalAnalytics/Dashboard1`
   - **Embed Code:** An `<iframe>` snippet for embedding in websites.
4. **Copy the Link** URL.

### Step 13.2 -- Get the Embed Code

1. In the same Share popup, copy the **Embed Code**.
2. It will look something like:
   ```html
   <div class='tableauPlaceholder' id='viz...'>
     <noscript>...</noscript>
     <object class='tableauViz'>
       <param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' />
       <param name='embed_code_version' value='3' />
       <param name='site_root' value='' />
       <param name='name' value='SalesPerformanceRegionalAnalytics/Dashboard1' />
       ...
     </object>
   </div>
   <script src='https://public.tableau.com/javascripts/api/viz_v1.js'></script>
   ```
3. Save this embed code if you plan to put it on a personal website or portfolio page.

### Step 13.3 -- Alternative: Direct Profile URL

1. Go to your Tableau Public profile: `https://public.tableau.com/app/profile/YOUR_USERNAME`
2. Your published workbook will appear on your profile page.
3. Click on the workbook thumbnail to get the direct link.

---

## 14. Post-Publishing Checklist

After successfully publishing your dashboard, complete these final steps:

### Step 14.1 -- Take Screenshots

1. Open the published dashboard in your browser at full screen.
2. Take screenshots of:
   - **The full dashboard view** (all 6 charts visible)
   - **A filtered view** (e.g., West region selected) showing the interactivity
   - **A close-up of one or two individual charts** that look particularly good
3. Save the screenshots to:
   ```
   tableau-sales-analytics/screenshots/
   ```
   Suggested file names:
   - `dashboard_full_view.png`
   - `dashboard_filtered_west.png`
   - `revenue_by_region_detail.png`
   - `monthly_trend_detail.png`

**On Mac:** Press `Cmd + Shift + 4` then `Space` to capture a window, or `Cmd + Shift + 4` and drag to select a region.

### Step 14.2 -- Update the README.md

1. Open `tableau-sales-analytics/README.md` in a text editor.
2. Replace the placeholder link:
   ```
   > **Tableau Public Link:** [Dashboard will be published here after final review]
   ```
   with:
   ```
   > **Tableau Public Link:** [View Interactive Dashboard](YOUR_TABLEAU_PUBLIC_URL_HERE)
   ```
3. Optionally add a screenshot to the README:
   ```markdown
   ## Dashboard Preview

   ![Dashboard Full View](screenshots/dashboard_full_view.png)
   ```
4. Save the file.

### Step 14.3 -- Final Verification

- [ ] Dashboard is live and accessible at the Tableau Public URL.
- [ ] All filters are interactive on the published version.
- [ ] Screenshots are saved in the `screenshots/` folder.
- [ ] README.md has been updated with the live Tableau Public link.
- [ ] The workbook name on Tableau Public matches: "Sales Performance & Regional Analytics".

---

## Appendix: Color Reference (Blue Palette)

| Usage | Hex Code | Color Name |
|-------|----------|------------|
| Darkest (West / Primary) | `#1B4F72` | Dark Navy Blue |
| Dark (North / Secondary) | `#2E86C1` | Medium Blue |
| Medium (South) | `#5DADE2` | Light Blue |
| Light (East) | `#AED6F1` | Pale Blue |
| Accent / Category 3 | `#85C1E9` | Sky Blue |
| Background tint | `#F7FBFF` | Ice Blue |
| Border / Subtle | `#D4E6F1` | Light Blue Gray |
| Danger / Reference line | `#E74C3C` | Red (for negative margins) |

## Appendix: All Calculated Fields Summary

| Field Name | Formula | Format |
|------------|---------|--------|
| Achievement % | `SUM([Sales Amount]) / SUM([Sales Target])` | Percentage, 1 decimal |
| Profit Margin % | `SUM([Profit]) / SUM([Sales Amount])` | Percentage, 1 decimal |
| YoY Growth % | `(ZN(SUM([Sales Amount])) - LOOKUP(ZN(SUM([Sales Amount])), -1)) / ABS(LOOKUP(ZN(SUM([Sales Amount])), -1))` | Percentage, 1 decimal |
| Order Month | `DATETRUNC('month', [Order Date])` | Date |

## Appendix: Troubleshooting

**Problem: Targets data shows NULL in the dashboard.**
- Solution: Go back to the Data Source tab and verify the relationship. Make sure the date granularity on the `Order Date` side is set to "Month" (truncated), not "Month" (date part). Also verify both Region fields are spelled identically in both CSVs.

**Problem: YoY Growth % shows NULL or incorrect values.**
- Solution: This is a table calculation. Right-click the pill on the shelf > **Compute Using** > select `YEAR(Order Date)`. This tells Tableau to compute the lookup along the year dimension.

**Problem: Too many marks / performance is slow.**
- Solution: Add filters to limit the date range or aggregate to a higher level. For the treemap, make sure you are not placing too many dimensions on Detail.

**Problem: The dashboard layout shifts when resizing the browser.**
- Solution: On the Dashboard tab, set Size to **Fixed** (1400 x 900) rather than Automatic. This ensures the layout stays consistent on Tableau Public.

**Problem: Cannot save to Tableau Public.**
- Solution: Ensure you are connected to the internet and signed into your Tableau Public account. Tableau Public requires an internet connection to publish. If the file is too large, remove unused sheets or data source connections.
