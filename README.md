# Branch Comparison & Consolidation (SQL Engineering)

## 🛑 Problem
At **Blue Sapphire Tech Ltd. (Sheela Palace Group)**, each restaurant branch (Lucan and Liffey) was maintaining sales, staffing, and footfall data separately in Excel.  
This created key problems:
- No consolidated view to compare branches.
- Operational blind spots (e.g., zero-sales days not flagged).
- Staffing inefficiencies on peak days.
- Missed opportunities to replicate high-performing events across branches.

Managers needed a **single source of truth** with daily KPIs and anomaly detection to guide staffing, marketing, and branch-level strategy.

---

## 📊 Dataset
- **Source**: 6 months of operational data collected and maintained by restaurant floor teams under my supervision.  
- **Collection process**: I designed the Excel structure, defined data entry rules, and ensured prompt daily entry by staff.  
- **Content**:  
  - Daily **sales** and **footfall** per branch.  
  - **Staffing by shift** and labor hours.  
  - Operational context (weekends, events, weather).  

This structured dataset became the foundation for a PostgreSQL pipeline.

---

## 🔧 Method
1. **Database schema design**  
   - `staging`: raw CSV imports (master daily, staffing).  
   - `ref`: branch dimension (`dim_branch`).  
   - `core`: consolidated fact table (`fact_daily`).  

2. **ETL process**  
   - Imported CSVs into staging tables.  
   - Joined to dimension tables and built consolidated fact tables.  
   - Created `v_fact_daily_enriched` view with KPIs like `sales_per_staffhour`.

3. **Anomaly detection (CTEs)**  
   - Zero sales but staff present.  
   - Busy days with high footfall but below-average sales.  
   - Extreme outliers (>3σ deviations in sales).  
   - High labor hours with below-average efficiency.  
   - Branch comparison (average SPSH, head-to-head, day-of-week breakdown).

4. **Manager-ready view**  
   - Built `v_ops_daily`: a simple table with daily KPIs (sales, footfall, staff, SPSH), sorted by date.  
   - Used as a daily reference by managers.

---

## 📈 Results
- **Zero-sales anomaly**: flagged 1 day with **74 staff hours logged but zero sales** → uncovered POS logging error.  
- **Underperforming busy days**: identified 7+ instances where high footfall wasn’t matched with sales → guided staffing changes.  
- **Event-driven spikes**: detected 3 festival-related sales outliers at Liffey and 1 at Lucan → recommended replicating promos.  
- **High labor inefficiency**: highlighted days where staff hours exceeded average + 1σ but efficiency was below average → reduced wasted labor costs.  
- **Branch comparison**:  
  - Lucan stronger on **Fri/Sat (pub nights)**.  
  - Liffey stronger on **Sundays (family dining)**.  
  - Daily SPSH differences balanced overall (~50/50 head-to-head).  

---

## 💡 Business Impact
- **Data governance**: Established a structured 6-month operational dataset from scratch.  
- **Cost savings**: Detected anomalies that wasted staff hours and corrected POS errors.  
- **Efficiency**: Optimized staffing schedules by aligning with actual busy/quiet days.  
- **Revenue growth**: Replicated successful festival campaigns across branches.  
- **Decision-making**: Delivered a daily KPI view (`v_ops_daily`) → managers could see sales, footfall, and labor efficiency in one place.  


---

## 📂 Repo Structure

```text
restaurant-sql-consolidation/
├─ sql/
│  ├─ 00_create_schemas.sql          # create schemas: staging, core, ref  
│  ├─ 01_create_staging_tables.sql   # move raw data from public -> staging  
│  ├─ 02_load_data_instructions.md   # notes for CSV imports  
│  ├─ 03_build_core_tables.sql       # dim_branch + fact_daily + loads  
│  ├─ 04_views_kpis.sql              # v_fact_daily_enriched + v_ops_daily  
│  ├─ 05_cte_anomalies.sql           # anomaly & branch-comparison queries  
│  └─ 99_drop_all.sql                # cleanup (drop schemas)  
├─ erd/  
│  ├─ tech_schema.png                # staging/ref/core (full)  
│  └─ manager_schema.png             # simplified (dim + fact + ops view)  
├─ results/  
│  ├─ zero_sales_staff_present.png  
│  ├─ outliers_3sigma.png  
│  ├─ busy_underperforming.csv  
│  └─ branch_head_to_head.png  
└─ README.md
```

---

## ⚙️ Tech Stack
- **PostgreSQL** (schema design, joins, CTEs, anomaly detection)  
- **pgAdmin** (SQL development, ERD export)  
- **dbdiagram.io** (ERD diagrams for repo)  
- **Excel** (source data collection & governance)  

---

## 🏷️ Attribution
This project was delivered during my role at **Blue Sapphire Tech Ltd.**, supporting the **Sheela Palace restaurant group** in Ireland.  




