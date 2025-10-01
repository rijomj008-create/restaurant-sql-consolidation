--- Creating reference (Dimension) tables in ref
Create table ref.dim_branch (
  branch_id SmallSerial Primary Key,
  branch_name Text Unique Not Null
);

Insert Into ref.dim_branch (branch_name)
Values ('Liffey'), ('Lucan')
On Conflict Do Nothing;

--- Building Consolidated Fact Table
Drop Table If Exists core.fact_daily Cascade;
Create Table core.fact_daily (
  date DATE Not Null,
  branch_id SmallInt Not Null References ref.dim_branch(branch_id),
  branch TEXT Not Null,
  sales NUMERIC(12,2),
  footfall INTEGER,
  total_staff INTEGER,
  total_labour_hours NUMERIC,
  Primary Key (date, branch_id)
);

--- Inserting from raw master table
Insert Into core.fact_daily (date,branch_id,branch,sales,footfall)
Select m.date, b.branch_id, m.branch, m.sales, m.footfall
From staging.master_daily_raw m
Join ref.dim_branch b ON m.branch = b.branch_name;

Select * From core.fact_daily;
