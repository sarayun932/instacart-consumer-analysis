# ================================================
# Instacart Consumer Analysis — Statistical Validation
# Purpose: Validate whether the difference in reorder rates
#          between Organic and Non-Organic products is
#          statistically significant
# ================================================

import pandas as pd
from scipy import stats
from statsmodels.stats.proportion import proportions_ztest

# ------------------------------------------------
# Q6-B: Proportion Z-test
# H0: Organic and Non-Organic reorder rates are equal
# H1: Organic reorder rate is significantly higher
# ------------------------------------------------

# Values from SQL query results
organic_reorders     = int(405617 * 0.647)   # total organic orders * reorder rate
nonorganic_reorders  = int(979000 * 0.579)   # total non-organic orders * reorder rate

organic_total        = 405617
nonorganic_total     = 979000

count = [organic_reorders, nonorganic_reorders]
nobs  = [organic_total, nonorganic_total]

# Run two-proportion z-test (one-sided: organic > non-organic)
stat, p_value = proportions_ztest(count, nobs, alternative='larger')

print("=" * 50)
print("Q6-B: Organic vs Non-Organic Reorder Rate Test")
print("=" * 50)
print(f"Organic reorder rate    : 64.7%")
print(f"Non-Organic reorder rate: 57.9%")
print(f"Difference              : +6.8%p")
print(f"Z-statistic             : {stat:.4f}")
print(f"P-value                 : {p_value:.10f}")
print()
if p_value < 0.05:
    print("✅ Result: Statistically SIGNIFICANT (p < 0.05)")
    print("   → Organic products have a significantly higher reorder rate")
else:
    print("❌ Result: Not significant (p >= 0.05)")
print("=" * 50)


# ================================================
# Visualization
# Purpose: Present key findings visually for portfolio
# ================================================

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')  # for saving files without display issues

# ------------------------------------------------
# Chart 1: Top 10 Most Ordered Departments (Q1)
# ------------------------------------------------
departments = ['produce', 'dairy eggs', 'snacks', 'beverages',
               'frozen', 'pantry', 'bakery', 'canned goods',
               'deli', 'dry goods pasta']
orders = [409087, 217051, 118862, 114046,
          100426, 81242, 48394, 46799, 44291, 38713]

fig, ax = plt.subplots(figsize=(10, 6))
bars = ax.barh(departments[::-1], orders[::-1], color='#4C9BE8')
ax.set_xlabel('Total Orders', fontsize=12)
ax.set_title('Top 10 Most Ordered Food Departments', fontsize=14, fontweight='bold')
ax.bar_label(bars, fmt='{:,.0f}', padding=3, fontsize=9)
ax.set_xlim(0, 460000)
plt.tight_layout()
plt.savefig('chart1_top_departments.png', dpi=150)
plt.close()
print("✅ Chart 1 saved: chart1_top_departments.png")

# ------------------------------------------------
# Chart 2: Organic Share by Department (Q6)
# ------------------------------------------------
dept_names = ['produce', 'bulk', 'canned goods', 'babies',
              'dry goods pasta', 'dairy eggs', 'frozen',
              'pantry', 'bakery', 'snacks']
organic_pct = [51.5, 46.4, 43.9, 41.1,
               24.7, 28.4, 17.0, 20.8, 16.9, 15.3]

colors = ['#2ECC71' if p >= 40 else '#A8D8A8' if p >= 20 else '#D5ECD4'
          for p in organic_pct]

fig, ax = plt.subplots(figsize=(10, 6))
bars = ax.barh(dept_names[::-1], organic_pct[::-1], color=colors[::-1])
ax.axvline(x=50, color='red', linestyle='--', linewidth=1.2, label='50% threshold')
ax.set_xlabel('Organic Share (%)', fontsize=12)
ax.set_title('Organic Product Share by Department', fontsize=14, fontweight='bold')
ax.bar_label(bars, fmt='{:.1f}%', padding=3, fontsize=9)
ax.set_xlim(0, 65)
ax.legend()
plt.tight_layout()
plt.savefig('chart2_organic_share.png', dpi=150)
plt.close()
print("✅ Chart 2 saved: chart2_organic_share.png")

# ------------------------------------------------
# Chart 3: Organic vs Non-Organic Reorder Rate (Q6-B)
# ------------------------------------------------
categories = ['Non-Organic', 'Organic']
reorder_rates = [57.9, 64.7]
colors = ['#95A5A6', '#2ECC71']

fig, ax = plt.subplots(figsize=(7, 5))
bars = ax.bar(categories, reorder_rates, color=colors, width=0.4)
ax.set_ylabel('Reorder Rate (%)', fontsize=12)
ax.set_title('Reorder Rate: Organic vs Non-Organic\n(z = 74.30, p < 0.001)',
             fontsize=13, fontweight='bold')
ax.set_ylim(50, 70)
ax.bar_label(bars, fmt='{:.1f}%', padding=3, fontsize=11, fontweight='bold')
ax.annotate('+6.8%p', xy=(0.5, 65.5), ha='center', fontsize=12,
            color='#E74C3C', fontweight='bold')
plt.tight_layout()
plt.savefig('chart3_reorder_rate.png', dpi=150)
plt.close()
print("✅ Chart 3 saved: chart3_reorder_rate.png")

print("\n🎉 All charts saved!")