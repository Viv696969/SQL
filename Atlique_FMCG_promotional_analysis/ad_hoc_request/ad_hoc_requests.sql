-- 1.	Provide a list of products 
-- with a base price
--  greater than 500 and that are
--  featured in promo type of 'BOGOF' (Buy One Get One Free). 
--  This information will help us identify high-value products 
--  that are currently being heavily discounted, which can be useful 
--  for evaluating our pricing and promotion strategies.

select 
distinct product_name,base_price
from fact_joined
where promo_type="BOGOF" and base_price>500;

-- 2.Generate a report that provides an overview
--  of the number of stores in each city.
--  The results will be sorted in descending order of store counts,
--  allowing us to identify the cities with the highest store presence.
--  The report includes two essential fields: 
--  city and store count, which will assist in optimizing our retail operations.

select city,count(store_id) as number_of_stores
from dim_stores
group  by city
order by number_of_stores desc;

-- 3.Generate a report that displays each campaign along with the total revenue
--  generated before and after the campaign?
--  The report includes three key fields: campaign_name, total_revenue(before_promotion),
-- total_revenue(after_promotion). 
-- This report should help in evaluating the 
-- financial impact of our promotional campaigns.
--  (Display the values in millions)

select 
campaign_name,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue_after_promotion,
round(sum(base_price*quantity_sold_before_promo)/1000000,2) as revenue_before_promotion
from fact_joined
group by campaign_name;

-- addition ananlysis to find revenue growth in percentage 
with cte as(
select 
campaign_name,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue_after_promotion,
round(sum(base_price*quantity_sold_before_promo)/1000000,2) as revenue_before_promotion
from fact_joined
group by campaign_name
)
select
campaign_name,
concat(
round(
	(revenue_after_promotion-revenue_before_promotion)*100/revenue_before_promotion
	,2) 
    ," %")  as growth_percent
from cte;


-- 4.Produce a report that calculates 
-- the Incremental Sold Quantity (ISU%) 
-- for each category during the Diwali campaign.
-- Additionally, provide rankings for the categories based on their ISU%.
-- The report will include three key fields: category, isuo/o,
-- and rank order. 
-- This information will assist in assessing 
-- the category-wise success and impact of the Diwali campaign on incremental sales.

with cte as (
select 
category,
 sum(quantity_sold_after_promo) as qty_sold_after_promo,
sum(quantity_sold_before_promo) as qty_sold_before_promo,
(sum(quantity_sold_after_promo)-sum(quantity_sold_before_promo)) as difference
from fact_joined
where campaign_name='Diwali'
group by category
),cte1 as (
select *,
round(difference*100/qty_sold_before_promo,2) as `isu%`
 from cte
)
select 
category,`isu%`,
dense_rank() over (order by `isu%` desc) as `rank`
from cte1;


