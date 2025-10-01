--- Joining staffing into fact
Create Or Replace View core.v_fact_daily_enriched As
Select
  f.date,
  f.branch,
  f.sales,
  f.footfall,
  Sum(s.staff_count) As total_staff,
  Sum(s.labor_hours) As total_labor_hours,
  Round(f.sales/ NullIf(Sum(s.labor_hours),0), 2) As sales_per_staffhour
From core.fact_daily f
Left Join staging.staffing_raw s
  On f.date = s.dates And f.branch = s.branch
Group By f.date, f.branch, f.sales, f.footfall;

Select * From core.v_fact_daily_enriched;

----- Creating manager view
Create Or Replace View core.v_ops_daily As
Select
  date,
  branch,
  sales,
  footfall,
  total_staff,
  total_labor_hours,
  sales_per_staffhour
From core.v_fact_daily_enriched
Order By date DESC, branch;

Select * From core.v_ops_daily;

---- Sanity Checks
SELECT * FROM core.v_ops_daily LIMIT 20;
SELECT * FROM core.v_ops_daily WHERE date = DATE '2025-03-29';

---- Filters
-- 1) Last 7 days:
SELECT * FROM core.v_ops_daily
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY date DESC, branch;

-- 2) Weekend focus
SELECT o.*
FROM core.v_ops_daily o
JOIN staging.master_daily_raw m
  ON o.date=m.date AND o.branch=m.branch
WHERE m.isweekend = 1
ORDER BY o.date DESC, o.branch;
