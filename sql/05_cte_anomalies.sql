--- 1) Zero Sales but staff present
With base As (
  Select * From core.v_fact_daily_enriched
)
Select date, branch, sales, total_labor_hours
From base
Where sales = 0 And total_labor_hours > 0;

-- Checking across history
Select branch, Count (*) As num_zero_sales_date
From core.v_fact_daily_enriched
Where sales = 0 And total_labor_hours > 0
Group By branch;

-- Recurrence check
Select date, branch, sales, total_labor_hours
From core.v_fact_daily_enriched
Where sales = 0 And total_labor_hours > 0
Order By date;

--- 2) Busy days but underperforming:
With branch_avg As (
  Select branch, Avg(sales) As avg_sales, Avg(footfall) As avg_ff
  From core.v_fact_daily_enriched
  Group By branch
)
Select b.date, b.branch, b.sales, b.footfall
From core.v_fact_daily_enriched b
Join branch_avg a Using (branch)
Where b.footfall > a.avg_ff
  And b.sales < a.avg_sales;

--- 3) Extreme Outliers
With stats As (
  Select branch, Avg(sales) As avg_sales,
         StdDev_Pop(sales) As std_sales
  From core.v_fact_daily_enriched
  Group by branch
)
Select f.date, f.branch, f.sales, s.avg_sales, s.std_sales,
       Round((f.sales - s.avg_sales)/NullIf(s.std_sales,0), 2) As z_score
From core.v_fact_daily_enriched f
Join stats s Using (branch)
Where Abs(f.sales - s.avg_sales) > 3 * s.std_sales
Order By f.branch, f.date;

--- 4) High Labor Low Efficiency
With branch_avg As (
  Select branch, Avg(sales_per_staffhour) As avg_spsh
  From core.v_fact_daily_enriched
  Group By branch
)
Select f.date, f.branch, f.sales, f.total_labor_hours, f.sales_per_staffhour
From core.v_fact_daily_enriched f
Join branch_avg a Using (branch)
Where f.total_labor_hours > 1.25 * (Select Avg(total_labor_hours) 
     From core.v_fact_daily_enriched Where branch = f.branch )
     And f.sales_per_staffhour < a.avg_spsh;

--- Using Std Dev
With branch_stats As (
  Select branch, 
       Avg(total_labor_hours) As avg_labor,
       Stddev_pop(total_labor_hours) As std_labor,
       Avg(sales_per_staffhour) As avg_spsh
  From core.v_fact_daily_enriched
  Group by branch
)
Select f.date, f.branch, f.sales, f.total_labor_hours, f.sales_per_staffhour,
       Round((f.total_labor_hours - s.avg_labor)/ NullIf (s.std_labor,0), 2) As z_labor
From core.v_fact_daily_enriched f
Join branch_stats s Using (branch)
Where f.total_labor_hours > s.avg_labor + s.std_labor
  And f.sales_per_staffhour < s.avg_spsh
Order by f.branch, f.date;

--- 5) Sales recorded but no staff logged
Select date, branch, total_staff
From core.v_fact_daily_enriched
Where sales > 0 And total_staff Is Null;

--- 6) Branch Comparison gap
With s As (
  Select branch, Avg(sales_per_staffhour) As avg_spsh
  From core.v_fact_daily_enriched
  Group By branch
)
Select
  Max(Case When branch='Liffey' Then avg_spsh End) As liffey_avg_spsh,
  Max(Case When branch='Lucan' Then avg_spsh End) As lucan_avg_spsh,
  Round(Max(Case When branch='Liffey' Then avg_spsh End) - Max(Case When branch='Lucan' Then avg_spsh End),2) As abs_gap,
  Round(100 * (Max(Case When branch='Liffey' Then avg_spsh End) - Max(Case When branch='Lucan' Then avg_spsh End))/ NullIf (Max(Case When branch='Liffey' Then avg_spsh End),0),2) As pct_gap_vs_liffey
From s;

--- Daily Head-To-Head
With d As (
 Select date,branch, sales_per_staffhour
 From core.v_fact_daily_enriched
),
pairs As (
  Select a.date,
         a.sales_per_staffhour AS spsh_liffey,
         b.sales_per_staffhour AS spsh_lucan
  From d a
  Join d b
    on a.date=b.date
   And a.branch='Liffey'
   And b.branch='Lucan'
)
Select
  Count (*) As comparable_days,
  Count (*) Filter (Where spsh_lucan < spsh_liffey) As days_lucan_lower,
  Round (100 * Count(*) Filter (Where spsh_lucan < spsh_liffey) / Count(*),1) As pct_days_lucan_lower,
  Count(*) Filter (Where spsh_liffey < spsh_lucan) As days_liffey_lower,
  Round (100 * Count(*) Filter (Where spsh_liffey < spsh_lucan) / Count(*),1) As pct_days_liffey_lower
From pairs;

--- Breaking it down by Day of Week
With by_dow As (
  Select branch,
         To_Char(date, 'Day') As dow,
         Avg(sales_per_staffhour) As avg_spsh
  From core.v_fact_daily_enriched
  Group By branch, To_Char(date, 'Day')
)
Select
  Trim(d.dow) As dow,
  Max (Case When branch = 'Liffey' Then avg_spsh End) As liffey_spsh,
  Max (Case When branch = 'Lucan' Then avg_spsh End) As lucan_spsh,
  Round (
    Max (Case When branch = 'Liffey' Then avg_spsh End) 
  - Max (Case When branch = 'Lucan' Then avg_spsh End), 2) As gap_liffey_minus_lucan
From by_dow d
Group by d.dow
Order By ARRAY_POSITION(
           Array['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'], 
           Trim(d.dow)
         ); 
