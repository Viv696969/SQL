-- How does the revenue generated from document registration
--  vary across districts in Telangana?
--  List down the top 5 districts that showed the 
--  highest revenue growth between FY 2019 and 2022.

select 
district,
sum(documents_registered_rev) as total_rev_from_doc_gen
from fact_stamps s
join dim_date d #joining dim date
using (month) 
join dim_districts di #joining districts table
using(dist_code)
where d.fiscal_year between 2019 and 2022
group by district
order by total_rev_from_doc_gen desc

limit 5
;

-- How does the revenue generated from document registration 
-- compare to the revenue generated from e-stamp challans across districts?
-- List down the top 5 districts where e-stamps revenue contributes 
-- significantly more to the revenue than the documents in FY 2022?


select 
district,
sum(documents_registered_rev) as total_rev_from_docs,
sum(estamps_challans_rev) as total_rev_from_challans
 from fact_stamps s
 join dim_date d 
 using(month)
 join dim_districts dis
 using(dist_code)
 where d.fiscal_year=2022
 group by dis.district
 having total_rev_from_challans > total_rev_from_docs
 order by total_rev_from_challans desc
 limit 5
 ;
 
--  
-- Is there any alteration of e-Stamp challan count and document registration count pattern
-- since the implementation of e-Stamp challan? 
-- If so, what suggestions would you propose to the government?
--  

select * from fact_stamps
where estamps_challans_cnt!=0 and estamps_challans_rev!=0
order by month;

select 
month,
sum(documents_registered_cnt) as total_docs_registered
from fact_stamps
where estamps_challans_cnt=0 and estamps_challans_rev=0
group by month
;

select 
month,
sum(documents_registered_cnt) as total_docs_registered,
sum(estamps_challans_cnt) as total_estamps_registered
from fact_stamps
where estamps_challans_cnt!=0 and estamps_challans_rev!=0
group by month
order by month
;


-- Categorize districts into three segments
-- based on their stamp registration revenue generation 
-- during the fiscal year 2021 to 2022.

with cte as (
select 
d.district,
sum(estamps_challans_rev) as total_stamp_rev
from fact_stamps
join dim_districts d
using(dist_code)
join dim_date dt
using(month)
where dt.fiscal_year in (2021,2022)
group by d.district
)
select 
*,
ntile(3) over(order by total_stamp_rev desc) as district_group
from cte;


create temporary table stamps
as select 
*
from fact_stamps
join dim_districts d
using(dist_code)
join dim_date dt
using(month);

select 
month ,
sum(documents_registered_cnt) as total_docs_registered,
sum(estamps_challans_cnt) as total_stamps_registered
 from stamps
 group by month;