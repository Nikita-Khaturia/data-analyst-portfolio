"""
Vendor Spend Analysis & Cost Optimization
==========================================
Analyzes pharmaceutical vendor transaction data to identify duplicate vendors,
pricing inconsistencies, and cost optimization opportunities (~15% savings target).

Usage:
    python vendor_spend_analysis.py

Output:
    - Console summary of findings
    - Charts saved to analysis/charts/
"""

import os
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend for script mode
import matplotlib.pyplot as plt
import seaborn as sns
from difflib import SequenceMatcher
import warnings

warnings.filterwarnings('ignore')
sns.set_style('whitegrid')
plt.rcParams['figure.figsize'] = (12, 6)
plt.rcParams['font.size'] = 11

# ============================================================
# Setup
# ============================================================
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(SCRIPT_DIR, '..', 'data')
CHART_DIR = os.path.join(SCRIPT_DIR, 'charts')
os.makedirs(CHART_DIR, exist_ok=True)

print("=" * 60)
print("  VENDOR SPEND ANALYSIS & COST OPTIMIZATION")
print("=" * 60)

# ============================================================
# 1. Load Data
# ============================================================
print("\n[1/7] Loading data...")
transactions = pd.read_csv(os.path.join(DATA_DIR, 'vendor_transactions.csv'))
vendor_master = pd.read_csv(os.path.join(DATA_DIR, 'vendor_master.csv'))

print(f"  Transactions: {transactions.shape[0]:,} rows, {transactions.shape[1]} columns")
print(f"  Vendor Master: {vendor_master.shape[0]} vendors")

# ============================================================
# 2. Data Cleaning
# ============================================================
print("\n[2/7] Cleaning data...")

transactions['transaction_date'] = pd.to_datetime(transactions['transaction_date'])
vendor_master['contract_start'] = pd.to_datetime(vendor_master['contract_start'])
vendor_master['contract_end'] = pd.to_datetime(vendor_master['contract_end'])

transactions['vendor_name'] = transactions['vendor_name'].str.strip()
vendor_master['vendor_name'] = vendor_master['vendor_name'].str.strip()

transactions['year'] = transactions['transaction_date'].dt.year
transactions['month'] = transactions['transaction_date'].dt.month
transactions['quarter'] = transactions['transaction_date'].dt.quarter
transactions['year_month'] = transactions['transaction_date'].dt.to_period('M')

total_spend = transactions['total_amount'].sum()
print(f"  Date range: {transactions['transaction_date'].min().date()} to {transactions['transaction_date'].max().date()}")
print(f"  Total transactions: {len(transactions):,}")
print(f"  Total spend: ${total_spend:,.2f}")

# ============================================================
# 3. Spend Overview Charts
# ============================================================
print("\n[3/7] Generating spend overview charts...")

# Chart 1: Top 15 Vendors by Spend
vendor_spend = transactions.groupby('vendor_name')['total_amount'].sum().sort_values(ascending=True)
top15 = vendor_spend.tail(15)

fig, ax = plt.subplots(figsize=(12, 8))
colors = sns.color_palette('Blues_d', len(top15))
bars = ax.barh(top15.index, top15.values, color=colors)
ax.set_xlabel('Total Spend ($)', fontsize=12)
ax.set_title('Top 15 Vendors by Total Spend', fontsize=14, fontweight='bold')
for bar in bars:
    width = bar.get_width()
    ax.text(width + max(top15.values) * 0.01, bar.get_y() + bar.get_height() / 2,
            f'${width:,.0f}', ha='left', va='center', fontsize=9)
plt.tight_layout()
plt.savefig(os.path.join(CHART_DIR, '01_top_vendors_spend.png'), dpi=150, bbox_inches='tight')
plt.close()

top5_spend = vendor_spend.tail(5).sum()
print(f"  Top 5 vendors: ${top5_spend:,.2f} ({top5_spend / total_spend * 100:.1f}% of total)")

# Chart 2: Spend by Category
category_spend = transactions.groupby('product_category')['total_amount'].sum().sort_values(ascending=False)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
colors_pie = sns.color_palette('Set2', len(category_spend))
ax1.pie(category_spend.values, labels=category_spend.index, autopct='%1.1f%%',
        colors=colors_pie, startangle=90, pctdistance=0.85)
ax1.set_title('Spend Distribution by Category', fontsize=13, fontweight='bold')

ax2.bar(category_spend.index, category_spend.values, color=colors_pie)
ax2.set_ylabel('Total Spend ($)', fontsize=11)
ax2.set_title('Spend by Category (Dollar Values)', fontsize=13, fontweight='bold')
ax2.tick_params(axis='x', rotation=30)
plt.tight_layout()
plt.savefig(os.path.join(CHART_DIR, '02_spend_by_category.png'), dpi=150, bbox_inches='tight')
plt.close()

# Chart 3: Monthly Trend
monthly_spend = transactions.groupby('year_month')['total_amount'].sum()

fig, ax = plt.subplots(figsize=(14, 6))
x_labels = [str(p) for p in monthly_spend.index]
ax.plot(x_labels, monthly_spend.values, marker='o', linewidth=2, color='#2196F3', markersize=6)
ax.fill_between(range(len(x_labels)), monthly_spend.values, alpha=0.15, color='#2196F3')
ax.set_xlabel('Month', fontsize=12)
ax.set_ylabel('Total Spend ($)', fontsize=12)
ax.set_title('Monthly Spend Trend (2023-2024)', fontsize=14, fontweight='bold')
ax.tick_params(axis='x', rotation=45)
for i, label in enumerate(x_labels):
    month_num = int(label.split('-')[1])
    if month_num >= 10:
        ax.axvspan(i - 0.5, i + 0.5, alpha=0.1, color='red')
plt.tight_layout()
plt.savefig(os.path.join(CHART_DIR, '03_monthly_trend.png'), dpi=150, bbox_inches='tight')
plt.close()

q4_spend = transactions[transactions['quarter'] == 4]['total_amount'].sum()
other_q_avg = transactions[transactions['quarter'] != 4].groupby('quarter')['total_amount'].sum().mean()
print(f"  Q4 spend is {q4_spend / other_q_avg * 100 - 100:.1f}% higher than average quarter")

# ============================================================
# 4. Duplicate Vendor Identification
# ============================================================
print("\n[4/7] Identifying duplicate vendors...")


def similarity_ratio(name1, name2):
    """Calculate string similarity between two vendor names."""
    clean1 = name1.lower().replace('inc', '').replace('llc', '').replace('corp', '').replace('co', '').strip()
    clean2 = name2.lower().replace('inc', '').replace('llc', '').replace('corp', '').replace('co', '').strip()
    return SequenceMatcher(None, clean1, clean2).ratio()


vendor_names = transactions['vendor_name'].unique()

similar_pairs = []
for i in range(len(vendor_names)):
    for j in range(i + 1, len(vendor_names)):
        ratio = similarity_ratio(vendor_names[i], vendor_names[j])
        if ratio > 0.55:
            similar_pairs.append({
                'Vendor A': vendor_names[i],
                'Vendor B': vendor_names[j],
                'Similarity': round(ratio * 100, 1)
            })

print(f"  Found {len(similar_pairs)} potential duplicate pairs (>55% name similarity)")

duplicate_pairs = [
    ('PharmaCorp Inc', 'Pharma Corp International'),
    ('ChemSource LLC', 'Chemical Source Labs'),
    ('MedPack Solutions', 'MedPack Global'),
    ('LabTech Instruments', 'Lab Technologies Inc'),
]

for vendor_a, vendor_b in duplicate_pairs:
    print(f"    - {vendor_a} <-> {vendor_b}")

# ============================================================
# 5. Product Overlap Analysis
# ============================================================
print("\n[5/7] Analyzing product overlap...")

product_vendor_count = transactions.groupby('product_name')['vendor_name'].nunique()
multi_vendor_products = product_vendor_count[product_vendor_count > 1].sort_values(ascending=False)
print(f"  Products sourced from 2+ vendors: {len(multi_vendor_products)}")

# Build overlap data for chart
overlap_analysis = []
for product in multi_vendor_products.index:
    prod_data = transactions[transactions['product_name'] == product]
    vendor_prices = prod_data.groupby('vendor_name').agg(
        avg_price=('unit_price', 'mean'),
        total_spend=('total_amount', 'sum'),
        num_transactions=('transaction_id', 'count')
    ).round(2)

    best_price = vendor_prices['avg_price'].min()
    worst_price = vendor_prices['avg_price'].max()
    price_spread = ((worst_price - best_price) / best_price) * 100

    for vendor, row in vendor_prices.iterrows():
        overlap_analysis.append({
            'Product': product,
            'Vendor': vendor,
            'Avg Unit Price': row['avg_price'],
            'Total Spend': row['total_spend'],
            'Transactions': row['num_transactions'],
            'Price Spread %': round(price_spread, 1),
            'Is Best Price': 'Yes' if row['avg_price'] == best_price else 'No'
        })

overlap_df = pd.DataFrame(overlap_analysis)

# Chart 4: Price comparison
top_spread_products = overlap_df.groupby('Product')['Price Spread %'].first().sort_values(ascending=False).head(8).index
plot_data = overlap_df[overlap_df['Product'].isin(top_spread_products)]

fig, ax = plt.subplots(figsize=(14, 8))
products_list = list(top_spread_products)
vendors_in_plot = plot_data['Vendor'].unique()
n_vendors = len(vendors_in_plot)
bar_width = 0.8 / max(n_vendors, 1)
colors_grouped = sns.color_palette('husl', n_vendors)

for idx, vendor in enumerate(vendors_in_plot):
    vendor_data = plot_data[plot_data['Vendor'] == vendor]
    positions = []
    prices = []
    for i, product in enumerate(products_list):
        prod_vendor = vendor_data[vendor_data['Product'] == product]
        if len(prod_vendor) > 0:
            positions.append(i + idx * bar_width)
            prices.append(prod_vendor['Avg Unit Price'].values[0])
    if positions:
        ax.bar(positions, prices, bar_width, label=vendor, color=colors_grouped[idx], alpha=0.85)

ax.set_xlabel('Product', fontsize=12)
ax.set_ylabel('Average Unit Price ($)', fontsize=12)
ax.set_title('Price Comparison Across Vendors for Overlapping Products', fontsize=14, fontweight='bold')
ax.set_xticks([i + bar_width * (n_vendors - 1) / 2 for i in range(len(products_list))])
ax.set_xticklabels(products_list, rotation=35, ha='right', fontsize=9)
ax.legend(title='Vendor', bbox_to_anchor=(1.02, 1), loc='upper left', fontsize=8)
plt.tight_layout()
plt.savefig(os.path.join(CHART_DIR, '04_price_comparison.png'), dpi=150, bbox_inches='tight')
plt.close()

# ============================================================
# 6. Cost Optimization Calculations
# ============================================================
print("\n[6/7] Calculating optimization opportunities...")

# 1. Vendor Consolidation
consolidation_savings = 0
for vendor_a, vendor_b in duplicate_pairs:
    txn_a = transactions[transactions['vendor_name'] == vendor_a]
    txn_b = transactions[transactions['vendor_name'] == vendor_b]
    shared_products = set(txn_a['product_name'].unique()) & set(txn_b['product_name'].unique())

    for product in shared_products:
        price_a = txn_a[txn_a['product_name'] == product]['unit_price'].mean()
        price_b = txn_b[txn_b['product_name'] == product]['unit_price'].mean()

        if price_a <= price_b:
            b_qty = txn_b[txn_b['product_name'] == product]['quantity'].sum()
            consolidation_savings += (price_b - price_a) * b_qty
        else:
            a_qty = txn_a[txn_a['product_name'] == product]['quantity'].sum()
            consolidation_savings += (price_a - price_b) * a_qty

print(f"  Vendor Consolidation:         ${consolidation_savings:>12,.2f}")

# 2. Price Standardization
standardization_savings = 0
for product in multi_vendor_products.index:
    prod_data = transactions[transactions['product_name'] == product]
    best_price = prod_data.groupby('vendor_name')['unit_price'].mean().min()

    for vendor in prod_data['vendor_name'].unique():
        v_data = prod_data[prod_data['vendor_name'] == vendor]
        v_avg_price = v_data['unit_price'].mean()
        if v_avg_price > best_price:
            v_qty = v_data['quantity'].sum()
            standardization_savings += (v_avg_price - best_price) * v_qty

print(f"  Price Standardization:        ${standardization_savings:>12,.2f}")

# 3. Payment Term Optimization
cost_of_capital = 0.05
payment_term_days = {'Net-30': 30, 'Net-45': 45, 'Net-60': 60, 'Net-90': 90}
baseline_days = 30

term_analysis = transactions.groupby(['vendor_name', 'payment_terms']).agg(
    total_spend=('total_amount', 'sum')
).reset_index()
term_analysis['term_days'] = term_analysis['payment_terms'].map(payment_term_days)
term_analysis['excess_days'] = term_analysis['term_days'] - baseline_days
term_analysis['working_capital_cost'] = (
    term_analysis['total_spend'] * (term_analysis['excess_days'] / 365) * cost_of_capital
)
payment_savings = term_analysis[term_analysis['excess_days'] > 0]['working_capital_cost'].sum()
print(f"  Payment Term Optimization:    ${payment_savings:>12,.2f}")

# 4. Volume Discount
volume_discount_rate = 0.03
consolidated_spend = sum([
    transactions[transactions['vendor_name'].isin([a, b])]['total_amount'].sum()
    for a, b in duplicate_pairs
])
volume_savings = consolidated_spend * volume_discount_rate
print(f"  Volume Discount Renegotiation: ${volume_savings:>12,.2f}")

total_savings = consolidation_savings + standardization_savings + payment_savings + volume_savings
savings_pct = (total_savings / total_spend) * 100

# Chart 5: Savings breakdown
savings_categories = {
    'Vendor Consolidation': consolidation_savings,
    'Price Standardization': standardization_savings,
    'Payment Term Optimization': payment_savings,
    'Volume Discount Renegotiation': volume_savings
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

cats = list(savings_categories.keys())
vals = list(savings_categories.values())
colors_bar = ['#1976D2', '#388E3C', '#F57C00', '#7B1FA2']

bars = ax1.barh(cats, vals, color=colors_bar, height=0.6)
for bar, val in zip(bars, vals):
    ax1.text(val + max(vals) * 0.02, bar.get_y() + bar.get_height() / 2,
             f'${val:,.0f}', ha='left', va='center', fontsize=11, fontweight='bold')
ax1.set_xlabel('Estimated Annual Savings ($)', fontsize=12)
ax1.set_title('Cost Optimization Opportunities', fontsize=14, fontweight='bold')
ax1.invert_yaxis()

sizes = [total_savings, total_spend - total_savings]
labels = [f'Savings\n${total_savings:,.0f}\n({savings_pct:.1f}%)',
          f'Remaining Spend\n${total_spend - total_savings:,.0f}']
colors_donut = ['#4CAF50', '#E0E0E0']
ax2.pie(sizes, labels=labels, colors=colors_donut, autopct='', startangle=90,
        wedgeprops=dict(width=0.4))
ax2.set_title('Total Savings as % of Spend', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig(os.path.join(CHART_DIR, '05_savings_breakdown.png'), dpi=150, bbox_inches='tight')
plt.close()

# ============================================================
# 7. Summary
# ============================================================
print("\n" + "=" * 60)
print("  SUMMARY")
print("=" * 60)
print(f"  Total Annual Spend:         ${total_spend:>14,.2f}")
print(f"  Total Identified Savings:   ${total_savings:>14,.2f}")
print(f"  Savings as % of Spend:      {savings_pct:>14.1f}%")
print("=" * 60)
print(f"\n  Charts saved to: {CHART_DIR}")
print("\n  Recommendations:")
print("  1. Consolidate 4 duplicate vendor pairs")
print("  2. Standardize pricing to best available rates")
print("  3. Renegotiate Net-60/90 payment terms to Net-30")
print("  4. Leverage consolidated volume for 3-5% discounts")
print("  5. Implement quarterly vendor scorecarding")
print("\n" + "=" * 60)
