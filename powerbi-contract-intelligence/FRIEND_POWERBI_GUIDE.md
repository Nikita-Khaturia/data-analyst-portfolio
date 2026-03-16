# Hey! Here's Exactly What I Need You to Build in Power BI

Thanks so much for helping me out with this! I need a Power BI dashboard for my portfolio that shows contract intelligence data (think M&A / corporate contract management). I've got all the data ready - you just need to import it and build the visuals. I'll walk you through every single step so you shouldn't need to ask me anything.

---

## Section 1: Setup

### 1.1 Install Power BI Desktop (if you don't have it)

1. Go to https://powerbi.microsoft.com/desktop/
2. Click **Download free**
3. It'll redirect you to the Microsoft Store - install from there
4. Open Power BI Desktop once installed (you do NOT need a paid license for this)

### 1.2 Import the 3 CSV Files

I'm sending you 3 CSV files. Save them all in one folder on your machine first.

**File 1: `contracts.csv`**
- 100 rows of contract data
- Columns: `contract_id`, `business_unit`, `vendor_name`, `contract_type`, `category`, `start_date`, `end_date`, `annual_value`, `total_contract_value`, `status`, `auto_renewal`, `renewal_notice_days`, `discount_pct`, `owner`, `priority`

**File 2: `renewal_tracker.csv`**
- 100 rows of renewal status data
- Columns: `contract_id`, `renewal_status`, `assigned_to`, `last_action_date`, `notes`

**File 3: `revenue_exposure.csv`**
- ~1756 rows of monthly revenue data
- Columns: `contract_id`, `month`, `revenue_amount`, `product_line`, `region`

**Import steps:**

1. Open Power BI Desktop
2. Click **Home** tab → **Get Data** → **Text/CSV**
3. Navigate to your folder, select `contracts.csv`, click **Open**
4. In the preview window, make sure it detected the columns correctly → click **Load**
5. Repeat steps 2-4 for `renewal_tracker.csv`
6. Repeat steps 2-4 for `revenue_exposure.csv`

You should now see all 3 tables listed in the **Fields** pane on the right side.

### 1.3 Fix Data Types

Before building anything, let's make sure the data types are correct:

1. Click on **Transform Data** in the Home ribbon (this opens Power Query Editor)
2. Select the **contracts** table on the left
3. Click on the `start_date` column header → in the ribbon go to **Transform** → **Data Type** → select **Date**
4. Click on the `end_date` column header → same thing → set to **Date**
5. Make sure `annual_value` and `total_contract_value` are set to **Decimal Number** (they probably already are)
6. Make sure `discount_pct` is set to **Decimal Number**
7. Select the **renewal_tracker** table on the left
8. Click on `last_action_date` → set to **Date**
9. Select the **revenue_exposure** table on the left
10. Click on `month` → set to **Date** (Power BI should parse "2024-01" as a date; if it doesn't, set it to **Text** and we'll handle it)
11. Make sure `revenue_amount` is set to **Decimal Number**
12. Click **Close & Apply** in the top left

### 1.4 Set Up Relationships Between Tables

1. In the left sidebar, click the **Model** icon (the one that looks like a little diagram, third icon down)
2. You should see 3 table boxes. Power BI may have auto-detected some relationships. **Delete any auto-detected relationships** by right-clicking the line between tables → **Delete**
3. Now create these relationships manually:

**Relationship 1: contracts → renewal_tracker**
- Drag `contract_id` from the **contracts** table onto `contract_id` in the **renewal_tracker** table
- Double-click the relationship line to edit:
  - Cardinality: **One to One (1:1)**
  - Cross filter direction: **Both**
  - Click **OK**

**Relationship 2: contracts → revenue_exposure**
- Drag `contract_id` from the **contracts** table onto `contract_id` in the **revenue_exposure** table
- Double-click the relationship line to edit:
  - Cardinality: **One to Many (1:*)**
  - Cross filter direction: **Both**
  - Click **OK**

Now go back to **Report** view (first icon in the left sidebar).

---

## Section 2: Create DAX Measures

Click on the **contracts** table in the Fields pane. Then for each measure below, go to **Home** → **New Measure** and paste the formula exactly as written.

### Measure 1: Total Contract Value

```
Total Contract Value = SUM(contracts[total_contract_value])
```

### Measure 2: At-Risk Revenue

This calculates the total contract value for contracts expiring within the next 90 days:

```
At-Risk Revenue =
CALCULATE(
    SUM(contracts[annual_value]),
    FILTER(
        contracts,
        contracts[end_date] <= TODAY() + 90
        && contracts[end_date] >= TODAY()
        && contracts[status] <> "Expired"
        && contracts[status] <> "Cancelled"
    )
)
```

### Measure 3: Active Contracts Count

```
Active Contracts Count =
CALCULATE(
    COUNTROWS(contracts),
    contracts[status] = "Active"
)
```

### Measure 4: Renewal Rate %

```
Renewal Rate % =
VAR _TotalEligible =
    CALCULATE(
        COUNTROWS(contracts),
        contracts[status] IN { "Active", "Pending Renewal", "Expired" }
    )
VAR _Renewed =
    CALCULATE(
        COUNTROWS(renewal_tracker),
        renewal_tracker[renewal_status] = "Completed"
    )
RETURN
    IF(_TotalEligible > 0, DIVIDE(_Renewed, _TotalEligible, 0) * 100, 0)
```

### Measure 5: Average Contract Duration

```
Average Contract Duration =
AVERAGEX(
    contracts,
    DATEDIFF(contracts[start_date], contracts[end_date], MONTH)
)
```

### Measure 6: Revenue by Status

```
Revenue by Status =
CALCULATE(
    SUM(contracts[total_contract_value]),
    ALLEXCEPT(contracts, contracts[status])
)
```

### Measure 7: Days Until Expiry (helper for conditional formatting later)

```
Days Until Expiry =
MIN(
    DATEDIFF(TODAY(), contracts[end_date], DAY)
)
```

### Measure 8: Contracts Expiring in 30 Days

```
Expiring 30 Days =
CALCULATE(
    COUNTROWS(contracts),
    FILTER(
        contracts,
        contracts[end_date] >= TODAY()
        && contracts[end_date] <= TODAY() + 30
        && contracts[status] <> "Expired"
        && contracts[status] <> "Cancelled"
    )
)
```

### Measure 9: Contracts Expiring in 60 Days

```
Expiring 60 Days =
CALCULATE(
    COUNTROWS(contracts),
    FILTER(
        contracts,
        contracts[end_date] >= TODAY()
        && contracts[end_date] <= TODAY() + 60
        && contracts[status] <> "Expired"
        && contracts[status] <> "Cancelled"
    )
)
```

### Measure 10: Contracts Expiring in 90 Days

```
Expiring 90 Days =
CALCULATE(
    COUNTROWS(contracts),
    FILTER(
        contracts,
        contracts[end_date] >= TODAY()
        && contracts[end_date] <= TODAY() + 90
        && contracts[status] <> "Expired"
        && contracts[status] <> "Cancelled"
    )
)
```

After creating all measures, you should see them listed under the **contracts** table in the Fields pane with a little calculator icon.

---

## Section 3: Build the Visuals

### PAGE 1 - Executive Overview

Right-click on the current page tab at the bottom and rename it to **Executive Overview**.

#### 3.1 Apply the Dark Theme First (do this before placing visuals)

1. Go to **View** tab → **Themes** → **Customize current theme**
2. Under **Name**, type: `Contract Intelligence Dark`
3. Click **Colors & Background** (or the equivalent section):
   - Set **Page background** color to `#1a1a2e`
4. Click **Text**:
   - Set default text color to `#FFFFFF` (white)
5. Click **Apply**

Then, also set the page background directly:
1. With no visual selected, look at the **Format** pane on the right (the paint roller icon)
2. Expand **Canvas background**
3. Set Color to `#1a1a2e`
4. Set Transparency to **0%**
5. Expand **Wallpaper**
6. Set Color to `#1a1a2e`

#### 3.2 KPI Card 1: Total Contract Value

1. Click on an empty area of the canvas
2. In the **Visualizations** pane, click the **Card** visual (it looks like a single number)
3. Drag the **Total Contract Value** measure into the **Fields** well
4. Resize the card and position it in the **top-left** corner (roughly top 15% of the page, left quarter)
5. Format it:
   - Select the card → click the **Format** tab (paint roller icon)
   - **General** → **Effects** → **Background**: set color to `#16213e`, transparency 0%
   - **General** → **Effects** → **Border**: Turn ON, color `#4fc3f7`, width 1px, rounded corners 8px
   - **Visual** → **Callout value**: Font color `#4fc3f7`, font size 28
   - **Visual** → **Category label**: Turn ON, text "Total Contract Value", font color `#FFFFFF`, font size 10

#### 3.3 KPI Card 2: Active Contracts

1. Add another **Card** visual
2. Drag **Active Contracts Count** into the Fields well
3. Position it next to the first card (top area, second from left)
4. Apply the same formatting as Card 1:
   - Background: `#16213e`
   - Border: `#4fc3f7`, 1px, 8px rounded
   - Callout value: `#4fc3f7`, font size 28
   - Category label: "Active Contracts", white, size 10

#### 3.4 KPI Card 3: At-Risk Revenue

1. Add another **Card** visual
2. Drag **At-Risk Revenue** into the Fields well
3. Position it third from left in the top row
4. Same formatting BUT change the callout value color to `#ff6b6b` (red) to indicate risk
   - Background: `#16213e`
   - Border: `#ff6b6b`, 1px, 8px rounded
   - Callout value: `#ff6b6b`, font size 28
   - Category label: "At-Risk Revenue", white, size 10

#### 3.5 KPI Card 4: Renewal Rate

1. Add another **Card** visual
2. Drag **Renewal Rate %** into the Fields well
3. Position it in the top row, far right
4. Format:
   - Background: `#16213e`
   - Border: `#4fc3f7`, 1px, 8px rounded
   - Callout value: `#66bb6a` (green), font size 28
   - Category label: "Renewal Rate %", white, size 10

#### 3.6 Donut Chart: Contract Value by Status

1. Click on an empty area below the KPI cards, on the **left side**
2. Select the **Donut chart** visual from the Visualizations pane
3. Drag `status` (from contracts) into the **Legend** well
4. Drag **Total Contract Value** measure into the **Values** well
5. Resize it to fill roughly the **bottom-left quarter** of the page (below the KPI cards)
6. Format:
   - **Visual** → **Legend**: Position **Bottom**, font color `#FFFFFF`, font size 9
   - **Visual** → **Slices** → set custom colors:
     - Active: `#4fc3f7`
     - At Risk: `#ff6b6b`
     - Pending Renewal: `#ffa726`
     - Expired: `#78909c`
     - Cancelled: `#455a64`
   - **Visual** → **Detail labels**: Font color `#FFFFFF`, font size 9, label content **Category, percent of total**
   - **General** → **Effects** → **Background**: `#16213e`, transparency 0%
   - **General** → **Title**: ON, text "Contract Value by Status", font color `#FFFFFF`, font size 12, bold

#### 3.7 Bar Chart: Revenue Exposure by Business Unit

1. Click empty area on the **right side**, middle of page
2. Select the **Clustered bar chart** visual
3. Drag `business_unit` (from contracts) into the **Y-axis** well
4. Drag **Total Contract Value** measure into the **X-axis** well
5. Resize to fill roughly the **middle-right area** of the page
6. Format:
   - **Visual** → **Bars** → set default color to `#4fc3f7`
   - **Visual** → **Y-axis**: Font color `#FFFFFF`, font size 9
   - **Visual** → **X-axis**: Font color `#FFFFFF`, font size 9
   - **Visual** → **Data labels**: Turn ON, font color `#FFFFFF`, font size 8
   - **General** → **Effects** → **Background**: `#16213e`, transparency 0%
   - **General** → **Title**: ON, text "Revenue Exposure by Business Unit", font color `#FFFFFF`, font size 12, bold
   - **Visual** → **Gridlines**: Color `#2a2a4a`

#### 3.8 Line Chart: Contract Expiry Timeline (Next 12 Months)

1. Click empty area on the **bottom-right** of the page
2. Select the **Line chart** visual
3. Drag `end_date` (from contracts) into the **X-axis** well
   - IMPORTANT: Power BI might auto-create a date hierarchy (Year > Quarter > Month). Right-click `end_date` in the X-axis well and select **end_date** (not the hierarchy) - you want the raw dates, or select "Month" level from the hierarchy
4. Drag `contract_id` (from contracts) into the **Y-axis** well
   - In the Y-axis well, click the dropdown on `contract_id` and change it to **Count**
5. Resize to fill the **bottom-right area**
6. Format:
   - **Visual** → **Lines** → color `#4fc3f7`, width 3
   - **Visual** → **Markers**: Turn ON, color `#4fc3f7`
   - **Visual** → **X-axis**: Font color `#FFFFFF`, font size 9, title "Expiry Month"
   - **Visual** → **Y-axis**: Font color `#FFFFFF`, font size 9, title "Number of Contracts"
   - **Visual** → **Data labels**: Turn ON, font color `#FFFFFF`, font size 8
   - **General** → **Effects** → **Background**: `#16213e`, transparency 0%
   - **General** → **Title**: ON, text "Contract Expiry Timeline", font color `#FFFFFF`, font size 12, bold
   - **Visual** → **Gridlines**: Color `#2a2a4a`

#### 3.9 Add the Page Title

1. Go to **Insert** tab → **Text box**
2. Type: **M&A Contract Intelligence Dashboard**
3. Position it at the very top of the page, spanning the full width, above the KPI cards
4. Format the text: Font size **20**, Bold, color `#FFFFFF`
5. Set the text box background to **transparent** (or `#1a1a2e`)

#### 3.10 Add Slicers to Page 1

**Slicer 1: Business Unit**
1. Click empty space (maybe top-right, or just to the right of the title)
2. Select the **Slicer** visual
3. Drag `business_unit` (from contracts) into the **Field** well
4. Click the dropdown arrow on the slicer header → change style to **Dropdown**
5. Format:
   - **Visual** → **Slicer header**: Text "Business Unit", font color `#FFFFFF`, background `#16213e`
   - **Visual** → **Values**: Font color `#FFFFFF`, background `#16213e`
   - **General** → **Effects** → **Background**: `#16213e`
   - **General** → **Effects** → **Border**: ON, color `#4fc3f7`, 1px

**Slicer 2: Contract Type**
1. Add another **Slicer** next to the first
2. Drag `contract_type` (from contracts) into the **Field** well
3. Set style to **Dropdown**
4. Same formatting as Slicer 1

**Slicer 3: Date Range**
1. Add another **Slicer**
2. Drag `end_date` (from contracts) into the **Field** well
3. It should automatically become a date range slider (Between style)
4. Same dark formatting

Make these slicers small - they shouldn't take up much room. Tuck them between the title and the KPI cards, or in a thin strip along the top.

---

### PAGE 2 - Contract Intelligence

1. At the bottom of the screen, click the **+** icon to add a new page
2. Right-click the new page tab and rename it to **Contract Intelligence**
3. Set the page background: With no visual selected, Format pane → **Canvas background** → color `#1a1a2e`, transparency 0%. **Wallpaper** → color `#1a1a2e`

#### 3.11 Table: Contracts Expiring (with Conditional Formatting)

This is the main visual on this page - make it big (top half of the page).

1. Select the **Table** visual from Visualizations pane
2. Drag these fields (from the **contracts** table) into the **Columns** well, in this exact order:
   - `contract_id`
   - `vendor_name`
   - `business_unit`
   - `contract_type`
   - `end_date`
   - `annual_value`
   - `status`
   - `owner`
3. Also drag the **Days Until Expiry** measure into Columns
4. Resize to fill the **top ~50%** of the page
5. Add a visual-level filter so it only shows upcoming expirations:
   - With the table selected, in the **Filters** pane (right side), find `end_date`
   - Set filter type to **Advanced filtering**
   - Set: `end_date` **is on or after** → type today's date
   - AND `end_date` **is on or before** → type a date 90 days from today
   - Click **Apply filter**
   - ALSO add a filter on `status`: select all values EXCEPT "Expired" and "Cancelled"

6. **Conditional Formatting on Days Until Expiry** (this is the key part!):
   - In the **Columns** well, click the dropdown arrow on **Days Until Expiry** → select **Conditional formatting** → **Background color**
   - Select **Rules**
   - Set up 3 rules:
     - If value **is less than or equal to** `30` → color `#c62828` (dark red)
     - If value **is greater than** `30` AND **is less than or equal to** `60` → color `#f57f17` (amber/yellow)
     - If value **is greater than** `60` AND **is less than or equal to** `90` → color `#2e7d32` (dark green)
   - Click **OK**

7. Also add conditional formatting on **annual_value**:
   - Click dropdown on `annual_value` → **Conditional formatting** → **Data bars**
   - Positive bar color: `#4fc3f7`
   - Click **OK**

8. Format the table:
   - **Visual** → **Style presets**: Select **None** (we'll style manually)
   - **Visual** → **Column headers**: Background `#16213e`, font color `#4fc3f7`, font size 10, bold
   - **Visual** → **Values**: Background `#0d1117`, alternate background `#16213e`, font color `#FFFFFF`, font size 9
   - **Visual** → **Grid**: Vertical gridline color `#2a2a4a`, horizontal gridline color `#2a2a4a`
   - **General** → **Effects** → **Background**: `#16213e`, transparency 0%
   - **General** → **Title**: ON, text "Contracts Expiring Next 90 Days - Action Required", font color `#ff6b6b`, font size 14, bold

#### 3.12 Stacked Bar Chart: Revenue by Contract Type and Business Unit

1. Click empty area in the **bottom-left** of Page 2
2. Select the **Stacked bar chart** visual
3. Drag `business_unit` (from contracts) into the **Y-axis** well
4. Drag **Total Contract Value** measure into the **X-axis** well
5. Drag `contract_type` (from contracts) into the **Legend** well
6. Resize to fill **bottom-left half** of the page
7. Format:
   - **Visual** → **Bars** → set colors by legend:
     - Service: `#4fc3f7`
     - License: `#66bb6a`
     - Subscription: `#ffa726`
     - Lease: `#ab47bc`
   - **Visual** → **Legend**: Position **Top**, font color `#FFFFFF`, font size 9
   - **Visual** → **Y-axis**: Font color `#FFFFFF`, font size 9
   - **Visual** → **X-axis**: Font color `#FFFFFF`, font size 9
   - **Visual** → **Gridlines**: Color `#2a2a4a`
   - **General** → **Effects** → **Background**: `#16213e`, transparency 0%
   - **General** → **Title**: ON, text "Revenue by Contract Type & Business Unit", font color `#FFFFFF`, font size 12, bold

#### 3.13 Gauge Chart: Renewal Rate vs Target

1. Click empty area in the **bottom-right** of Page 2
2. Select the **Gauge** visual from Visualizations pane
3. Drag the **Renewal Rate %** measure into the **Value** well
4. In the **Target value** well, just type `85` directly (or create a quick measure):
   - Actually, easier method: Go to **Home** → **New Measure** and type:
     ```
     Renewal Target = 85
     ```
   - Then drag **Renewal Target** into the **Target value** well
5. Set the **Min value** to `0` and the **Max value** to `100` (in the format pane under **Gauge axis**)
6. Format:
   - **Visual** → **Gauge** → **Fill color**: `#4fc3f7`
   - **Visual** → **Gauge** → **Target**: Color `#ff6b6b`, line width 3
   - **Visual** → **Callout value**: Font color `#FFFFFF`, font size 24
   - **Visual** → **Target label**: Turn ON, font color `#ff6b6b`
   - **General** → **Effects** → **Background**: `#16213e`, transparency 0%
   - **General** → **Effects** → **Border**: ON, color `#4fc3f7`, 1px, rounded 8px
   - **General** → **Title**: ON, text "Renewal Rate vs 85% Target", font color `#FFFFFF`, font size 12, bold

#### 3.14 Add Page 2 Title

1. **Insert** → **Text box**
2. Type: **Contract Intelligence & Renewal Tracking**
3. Position at the very top of the page, full width
4. Font size **18**, Bold, color `#FFFFFF`, background transparent

#### 3.15 Add Slicers to Page 2 (same as Page 1)

Add the same 3 slicers as Page 1 (Business Unit dropdown, Contract Type dropdown, Date Range) in a row near the top. Same formatting.

**Pro tip for syncing slicers across pages:**
1. Go to **View** tab → click **Sync slicers**
2. A pane opens on the left showing a table of pages
3. For each slicer, check the boxes for BOTH pages so they stay in sync

---

## Section 4: Final Formatting & Polish

### 4.1 Make Everything Look Consistent

Go through both pages and double check:

- [ ] ALL backgrounds on all visuals are `#16213e` (the card/chart background)
- [ ] ALL page backgrounds are `#1a1a2e` (slightly darker than the chart backgrounds)
- [ ] ALL text is white `#FFFFFF` except for the accent colors mentioned above
- [ ] ALL borders on visuals use `#4fc3f7` (accent blue)
- [ ] NO visual has that default gray Power BI border or white background

### 4.2 Check Interactions

1. Click on a bar in the bar chart on Page 1 - the other visuals should cross-filter
2. If they don't, go to **Format** tab (in the ribbon, with the visual selected) → **Edit interactions** → make sure all other visuals are set to **Filter** (funnel icon)

### 4.3 Final Layout Check

**Page 1 (Executive Overview) should look like this from top to bottom:**
```
+------------------------------------------------------------------+
|  [Title: M&A Contract Intelligence Dashboard]                     |
|  [Slicer: BU] [Slicer: Type] [Slicer: Date Range]               |
+------------------------------------------------------------------+
|  [KPI: Total  ] [KPI: Active ] [KPI: At-Risk] [KPI: Renewal     |
|   Contract Val]  Contracts  ]   Revenue    ]   Rate %         ]  |
+------------------------------------------------------------------+
|  [Donut Chart:        ]  |  [Bar Chart: Revenue Exposure         |
|   Contract Value       ]  |   by Business Unit                ]  |
|   by Status            ]  |                                    ]  |
+---------------------------+--------------------------------------+
|                           |  [Line Chart: Contract Expiry        |
|                           |   Timeline                        ]  |
+---------------------------+--------------------------------------+
```

**Page 2 (Contract Intelligence) should look like this:**
```
+------------------------------------------------------------------+
|  [Title: Contract Intelligence & Renewal Tracking]                |
|  [Slicer: BU] [Slicer: Type] [Slicer: Date Range]               |
+------------------------------------------------------------------+
|  [Table: Contracts Expiring Next 90 Days - Action Required     ] |
|  [contract_id | vendor | BU | type | end_date | value | days  ] |
|  [  ... red/yellow/green conditional formatting on days col ...  ]|
+------------------------------------------------------------------+
|  [Stacked Bar: Revenue by   ] | [Gauge: Renewal Rate           ] |
|   Contract Type & BU       ]  |  vs 85% Target               ]  |
+-------------------------------+----------------------------------+
```

---

## Section 5: Save and Export

### 5.1 Save the File

1. **File** → **Save As**
2. Name the file: `MA_Contract_Intelligence_Dashboard.pbix`
3. Save it somewhere easy to find

### 5.2 Take Screenshots

I need exactly 2 screenshots - one per page.

**Screenshot 1:**
1. Make sure you're on the **Executive Overview** page
2. Clear any slicer selections so all data is showing
3. Click **View** tab → uncheck **Gridlines** and **Snap to grid** (so they don't show)
4. Press **Windows key + Shift + S** (Snipping Tool) → select **Full screen snip** or carefully drag to capture just the Power BI canvas area
5. Open the snip in Paint or any editor → Save As → **PNG**
6. Name it: `dashboard_page1_overview.png`

**Screenshot 2:**
1. Switch to the **Contract Intelligence** page
2. Same thing - clear slicers, snip the canvas
3. Save as: `dashboard_page2_intelligence.png`

**Important:** Try to capture JUST the canvas/dashboard area, not the Power BI ribbon/menus/field panes. If you can't crop perfectly that's fine, but try your best.

### 5.3 Alternative Screenshot Method (cleaner)

If you want really clean screenshots:
1. **File** → **Export** → **Export to PDF** (this gives you a clean version)
2. Then screenshot from the PDF

OR even better:
1. Click **View** → **Fit to page** to make sure everything is nicely sized
2. Press **Ctrl + Shift + E** to export the current page as an image (if your version supports this)

### 5.4 Send Me These Files

Send me exactly these 3 files:
1. `MA_Contract_Intelligence_Dashboard.pbix` (the Power BI file)
2. `dashboard_page1_overview.png` (screenshot of Executive Overview)
3. `dashboard_page2_intelligence.png` (screenshot of Contract Intelligence)

---

## Quick Reference: All the Colors

| Element | Hex Code | Where It's Used |
|---------|----------|-----------------|
| Page Background | `#1a1a2e` | Dark navy - canvas/wallpaper on both pages |
| Visual Background | `#16213e` | Slightly lighter navy - background of each chart/card |
| Accent Blue | `#4fc3f7` | Borders, bar colors, main KPI values, line chart |
| White | `#FFFFFF` | All text labels, axis labels, category labels |
| Risk Red | `#ff6b6b` | At-Risk KPI card, expiry warning title |
| Conditional Red | `#c62828` | Table: contracts expiring in 0-30 days |
| Conditional Amber | `#f57f17` | Table: contracts expiring in 31-60 days |
| Conditional Green | `#2e7d32` | Table: contracts expiring in 61-90 days |
| Success Green | `#66bb6a` | Renewal Rate KPI value |
| Warning Orange | `#ffa726` | Pending Renewal in donut, Subscription bars |
| Purple | `#ab47bc` | Lease type in stacked bar |
| Muted Gray | `#78909c` | Expired status in donut |
| Dark Gray | `#455a64` | Cancelled status in donut |
| Gridlines | `#2a2a4a` | All chart gridlines |
| Alt Row | `#0d1117` | Alternating row color in the table |

---

## Quick Reference: All DAX Measures

| # | Measure Name | Formula |
|---|-------------|---------|
| 1 | Total Contract Value | `SUM(contracts[total_contract_value])` |
| 2 | At-Risk Revenue | `CALCULATE(SUM(contracts[annual_value]), FILTER(contracts, contracts[end_date] <= TODAY() + 90 && contracts[end_date] >= TODAY() && contracts[status] <> "Expired" && contracts[status] <> "Cancelled"))` |
| 3 | Active Contracts Count | `CALCULATE(COUNTROWS(contracts), contracts[status] = "Active")` |
| 4 | Renewal Rate % | See full formula in Section 2 |
| 5 | Average Contract Duration | `AVERAGEX(contracts, DATEDIFF(contracts[start_date], contracts[end_date], MONTH))` |
| 6 | Revenue by Status | `CALCULATE(SUM(contracts[total_contract_value]), ALLEXCEPT(contracts, contracts[status]))` |
| 7 | Days Until Expiry | `MIN(DATEDIFF(TODAY(), contracts[end_date], DAY))` |
| 8 | Expiring 30 Days | See full formula in Section 2 |
| 9 | Expiring 60 Days | See full formula in Section 2 |
| 10 | Expiring 90 Days | See full formula in Section 2 |
| 11 | Renewal Target | `85` |

---

Thanks again for doing this! If anything looks weird or a formula throws an error, just send me a screenshot and I'll troubleshoot. But if you follow these steps exactly, it should work perfectly. You're a legend!
