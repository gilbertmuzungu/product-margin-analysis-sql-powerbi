
# ☕ Daily Grind — Pricing & Margin Analysis (2023–2025)

> **End-to-end data analysis project** | SQL · Power BI · Business Intelligence  
> *Identifying underperforming products and delivering pricing recommendations to recover profit margins*

---

## 📌 Table of Contents

- [Project Overview](#-project-overview)
- [Business Problem](#-business-problem)
- [Tools & Technologies](#-tools--technologies)
- [Repository Structure](#-repository-structure)
- [Data Sources](#-data-sources)
- [SQL Workflow](#-sql-workflow)
- [Power BI Dashboard](#-power-bi-dashboard)
- [Key Findings](#-key-findings)
- [Recommendations](#-recommendations)


---

## 📋 Project Overview

This project is a **full end-to-end business analytics engagement** for *Daily Grind*, a multi-region coffee products company. The analysis spans **three fiscal years (2023–2025)** and covers over **4,400 transactions** across **50 products** in 5 categories, serving **200 customers** across multiple regions.

The workflow follows a professional analytics pipeline:

```
Raw CSV Data  →  SQL Server (Clean & Transform)  →  Power BI (Visualize & Analyze)  →  Business Recommendations
```

---

## 🧩 Business Problem

The **Director of Operations** raised an urgent concern: *rising costs of goods sold (COGS)* and *tariff pressures* were quietly eroding profit margins — even as revenue appeared stable on the surface.

**Three specific deliverables were requested:**

1. 🔍 Identify all products with a **gross margin below 30%** in **Q3 2025**
2. 📊 Build a **year-over-year dashboard** tracking margin, revenue, and category performance
3. 💡 Provide **data-backed recommendations** — price increases or product discontinuation

---

## 🛠 Tools & Technologies

| Layer | Tool | Purpose |
|---|---|---|
| Data Storage | Microsoft SQL Server (SSMS) | Database setup, raw data ingestion |
| Data Transformation | SQL  | Cleaning, joining, calculated columns |
| Visualization | Power BI Desktop | Interactive dashboard, DAX measures |
| Data Format | CSV | Source files for all tables |
| Version Control | GitHub | Portfolio publishing |

---

## 📁 Repository Structure

```
daily-grind-margin-analysis/
│
├── data/
│   ├── customers.csv              # 200 customers with region and join date
│   ├── products.csv               # 50 products — names, categories, price, base cost
│   ├── Orders_2023.csv            # 1,603 order records
│   ├── Orders_2024.csv            # 1,570 order records
│   ├── Orders_2025.csv            # 1,283 order records
│   └── Public_Sales_Data.csv      # Unified, cleaned dataset (SQL output)
│
├── sql/
│   └── Pricing.sql                # Full SQL script: UNION ALL + joins + cleaning logic
│
├── powerbi/
│   └── Pricing.pbix               # Power BI report file
│
└── README.md
```

---

## 📂 Data Sources

### `customers.csv`
| Column | Description |
|---|---|
| CustomerID | Unique customer identifier (UUID) |
| Region | Geographic region (e.g., East, West) |
| CustomerJoinDate | Date the customer first joined |

### `products.csv`
| Column | Description |
|---|---|
| ProductID | Unique product identifier |
| ProductName | Full product name |
| ProductCategory | One of: Consumables, Grinders & Brewers, Accessories, Merchandise, Subscriptions |
| Price | Selling price |
| Base_Cost | Standard cost of goods |

### `Orders_2023 / 2024 / 2025.csv`
| Column | Description |
|---|---|
| OrderID | Unique order identifier (UUID) |
| CustomerID | Links to customers table |
| ProductID | Links to products table |
| OrderDate | Date of order |
| Quantity | Units ordered |
| Revenue | Recorded revenue (some nulls present) |
| COGS | Actual cost of goods sold for that transaction |

### `Public_Sales_Data.csv`
The final **unified and cleaned dataset** produced by the SQL script — ready for direct import into Power BI or further analysis. Contains all columns from the orders, customers, and products tables with calculated fields (`Cleaned_Revenue`, `Profit`).

---

## 🗄 SQL Workflow

**File:** `sql/Pricing.sql`

The SQL script handles all data preparation in two stages:

### Stage 1 — Unify Three Years of Orders
```sql
WITH all_orders AS (
  SELECT OrderID, CustomerID, ProductID, OrderDate, Quantity, Revenue, COGS FROM orders_2023
  UNION ALL
  SELECT OrderID, CustomerID, ProductID, OrderDate, Quantity, Revenue, COGS FROM orders_2024
  UNION ALL
  SELECT OrderID, CustomerID, ProductID, OrderDate, Quantity, Revenue, COGS FROM orders_2025
)
```
Using `UNION ALL` to stack all three annual order tables into one continuous dataset.

### Stage 2 — Build the Master Dataset
The CTE is then joined against both dimension tables:

- **LEFT JOIN `customers`** → brings in `Region` and `CustomerJoinDate`
- **LEFT JOIN `products`** → brings in `ProductName`, `ProductCategory`, `Price`, and `Base_Cost`

**Key transformations applied:**

| Transformation | Logic |
|---|---|
| `Cleaned_Revenue` | `CASE WHEN Revenue IS NULL THEN Price * Quantity ELSE Revenue END` — fills null revenue records using price × quantity |
| `Profit` | `ROUND(Revenue - COGS, 2)` — calculates gross profit per transaction |
| Null filter | `WHERE CustomerID IS NOT NULL` — removes orphaned records |

> 💡 **Why this matters:** Some orders had null revenue values in the source files. Rather than dropping those rows, a business rule was applied to impute revenue — preserving data volume while maintaining accuracy.

---

## 📊 Power BI Dashboard

**File:** `powerbi/Pricing.pbix`

The report connects directly to the SQL Server query and is structured across two pages:

### Page 1 — Executive Overview
- **KPI Cards**: Total Revenue, Total Profit, Customer Count, Gross Margin %
- **Stacked Area Chart**: Regional revenue/profit performance over time (weekly buckets for smoother trends)
- **Metric Selector**: A disconnected table + DAX `SWITCH` measure allows users to toggle the entire dashboard between Revenue, Profit, and Quantity with a single click

### Page 2 — Product Margin Drill-Down
- **Matrix Visual**: Product × Year/Quarter breakdown of gross margin %
- **Margin Threshold Highlighting**: Products falling below the 30% margin floor are visually flagged
- **Category Filter**: Slice by Consumables, Merchandise, Accessories, Grinders & Brewers, or Subscriptions

### DAX Highlights
```
-- Dynamic metric selector using SWITCH
Selected Metric = 
SWITCH(
    SELECTEDVALUE(MetricSelector[Metric]),
    "Revenue", [Total Revenue],
    "Profit", [Total Profit],
    "Quantity", [Total Quantity]
)

-- Gross Margin %
Gross Margin % = DIVIDE([Total Profit], [Total Revenue], 0)
```

---

## 🔍 Key Findings

### Products Flagged Below 30% Gross Margin in Q3 2025

| Product | Category | Issue |
|---|---|---|
| Logo Hoodie (Black) | Merchandise | Margin consistently declining toward 0% |
| Minimalist Keychain | Merchandise | COGS increase outpacing static price point |
| Branded Ceramic Mug (Large) | Merchandise | Margin erosion accelerating in 2025 |

### Root Cause
The data reveals a clear structural problem: **prices remained static across all three years while COGS increased year-over-year** — likely due to supplier cost pressures and tariff impacts. This is not a revenue problem; it is a **cost absorption problem that requires a pricing response**.

**Trend observed across the dashboard:**
- Revenue trending flat to slightly up (volume maintained)
- Profit trending down (margin compression)
- The gap between Revenue and COGS widening most sharply in the Merchandise category

---

## 💡 Recommendations

Based on the data, two actionable paths are recommended:

### ✅ Option 1: Immediate Price Increases (Preferred)
For the three flagged products, raise prices to restore a minimum 30% gross margin:

| Product | Current Price | Suggested Action |
|---|---|---|
| Logo Hoodie (Black) | $15.23 | Increase price or bundle with higher-margin item |
| Minimalist Keychain | $27.37 | Increase price — current COGS ($21.90) leaves minimal room |
| Branded Ceramic Mug | $43.20 | Review COGS with supplier; target price increase of 10–15% |

> The Subscriptions and Consumables categories remain healthy and should be used as cross-sell levers while Merchandise pricing is corrected.

### ⚠️ Option 2: Strategic Discontinuation
If price increases are not commercially viable (e.g., competitive price sensitivity), low-margin Merchandise SKUs should be **discontinued** to avoid further margin drag. The data shows these products contribute minimally to overall revenue volume, so discontinuation carries low revenue risk.

### 🔄 Ongoing Monitoring Recommendation
Set up a **quarterly margin review** process using this dashboard. The 30% threshold should serve as an automated alert trigger — any product dipping below it should be flagged for immediate pricing or sourcing review before the next quarter closes.

---




## 👤 About

**Gilbert Karani Muzungu**  
Data & Business Analyst | SQL · Power BI · Excel · Zapier Automation  
📍 Nakuru, Kenya · Open to remote opportunities

[![LinkedIn] https://www.linkedin.com/in/gilbert-karani
[![Portfolio] https://gilbert-karani-muzungu.netlify.app

---

*This project was built as part of an end-to-end analytics portfolio demonstrating SQL data engineering, Power BI dashboard development, and business-facing analytical storytelling.*
