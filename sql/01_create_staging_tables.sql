-- Putting tables into the new schema

Drop Table If Exists staging.master_daily_raw;
Create Table staging.master_daily_raw As 
Select * From public.master_daily;

Drop Table If Exists staging.staffing_raw;
Create Table staging.staffing_raw As 
Select * From public.staffing_by_shift;

