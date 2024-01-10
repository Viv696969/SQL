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
group by district
order by total_rev_from_doc_gen
limit 5
;