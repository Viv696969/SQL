SELECT 
*
 FROM telanaga.fact_ts_ipass;

-- List down the top 5 sectors that have witnessed the most significant
-- investments in FY 2022
select
sector,
sum(investment_in_cr) as total_invst
from fact_ts_ipass t join dim_date d 
on d.month=t.date
where fiscal_year=2022
group by sector
order by total_invst desc
limit 5;

-- List down the top 3 districts that have attracted the most significant
-- sector investments during FY 2019 to 2022? What factors could have
-- led to the substantial investments in these particular districts?

create temporary table tsipass_temp
as  select

t.*,d.fiscal_year,dis.district

 from fact_ts_ipass t join dim_date d
on  d.month=t.date
join dim_districts dis
using(dist_code);

with cte as (
select 
district,sector,
sum(investment_in_cr) over(partition by district, order by investment_in_cr desc) as investment
from tsipass_temp
where fiscal_year between 2019 and 2022
)
select 
*,
dense_rank() over(order by investment desc) as rank_
from cte
;

-- Are there any particular sectors that have shown substantial
-- growth in multiple districts in FY 2022?
with cte as (
select 
sector,
dist_code,
sum(investment_in_cr) as total_investment
 from tsipass_temp
where fiscal_year=2022
 group by sector,dist_code
 order by total_investment desc
 ),
 cte1 as (
 select 
 *,
dense_rank() over(partition by sector order by total_investment desc) as rnk
 from cte
 )
 select * from cte1
where rnk in (1,2,3)
order by total_investment desc,rnk asc ;

select 
district,
sum(investment_in_cr) as total_investment
 from tsipass_temp
 where fiscal_year between 2019 and 2022
 group by district
 order by total_investment desc 
 limit 3;
 
with cte as ( 
select 
mmm,
sector,
sum(investment_in_cr) as total

from tsipass_temp t
join dim_date d
on d.month=t.date
group by mmm,sector
),
cte1 as (
select *,
dense_rank() over (partition by mmm order by total desc) as rnk
 from cte
 )
 select * from cte1
 where rnk in (1,2,3);
 
 
 create temporary table top_sectors as 
 select 
 sector,
 sum(investment_in_cr) as total
 from tsipass_temp
 where fiscal_year=2022
 group by sector
 order by total desc
 limit 5;
 
 select * from top_sectors;
 with cte as (
 select 
 sector,
 district,
 sum(investment_in_cr) as total_investment
 from tsipass_temp
 where fiscal_year=2022 
 -- and sector in (select sector from top_sectors order by total desc )
 group by sector,district
 order by total_investment desc
 ),cte1 as (
 select 
 *,
 dense_rank() over(partition by sector order by total_investment desc) as rnk
 from cte
 )
 select * from cte1 where rnk <=3;
 

 