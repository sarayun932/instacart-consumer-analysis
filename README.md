# 🛒 Instacart Consumer Purchasing Pattern Analysis

## Project Overview
Analysis of 3.4M+ grocery orders from Instacart to uncover consumer purchasing behaviors and business insights using MySQL.

## Objectives
- Identify top-performing food categories
- Discover peak shopping times by day and hour
- Measure product loyalty through reorder rates
- Segment customers by purchase frequency
- Analyze purchase cycles across customer segments

## Dataset
- **Source:** [Instacart Market Basket Analysis – Kaggle](https://www.kaggle.com/competitions/instacart-market-basket-analysis)
- **Size:** 3.4M+ orders, 49K+ products, 206K+ customers

| Table | Rows |
|---|---|
| orders | 3,421,083 |
| order_products | 1,384,617 |
| products | 49,688 |
| aisles | 134 |
| departments | 21 |

## Tools
- **MySQL** – data storage & querying
- **Python (pandas, SQLAlchemy)** – CSV to MySQL data loading
- **MySQL Workbench** – query execution & result validation

## Key Findings

### Q1. Top Food Departments by Order Volume
- **Produce** ranked #1 with 409,087 orders — nearly 2x the second category
- Fresh and dairy categories dominate, reflecting essential grocery behavior

### Q2. Peak Shopping Times
- Orders peak between **10AM–2PM**, especially on **Sundays and Mondays**
- Late night orders (12AM–5AM) are minimal across all days

### Q3. Highest Reorder Rate Products
- **Organic Low Fat Milk** leads with a 91.3% reorder rate
- 9 out of 10 top products are milk variants → dairy staples drive repeat purchases
- **Banana** stands out as a high-volume (18,726 orders) AND high-loyalty (88.4%) product

### Q4. Customer Segmentation
| Segment | Customers | Share |
|---|---|---|
| Heavy User (10+ orders) | 110,728 | 53.7% |
| Regular User (5–9 orders) | 71,495 | 34.7% |
| Light User (1–4 orders) | 23,986 | 11.6% |

- Over half of customers are Heavy Users → strong retention platform

### Q5. Average Purchase Cycle by Segment
| Segment | Avg Days Between Orders |
|---|---|
| Heavy User | 11.9 days |
| Regular User | 18.1 days |
| Light User | 20.0 days |

- Heavy Users shop roughly every **2 weeks**
- Converting Regular → Heavy Users (closing the 6-day gap) is the highest-ROI retention opportunity

## Business Implications
1. **Prioritize produce and dairy** in inventory and promotional planning
2. **Schedule promotions on Sunday/Monday mornings** to capture peak traffic
3. **Target Regular Users** with reorder reminders around day 15–17 to accelerate purchase cycles
4. **Leverage high-reorder staples** (milk, banana) as anchors for subscription or bundle offers

## File Structure
```
instacart-consumer-analysis/
└── Market.sql    ── table setup + Q1~Q5 analysis queries
```
