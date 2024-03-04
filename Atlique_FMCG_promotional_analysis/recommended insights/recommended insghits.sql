-- store performance insights

with cte as (
select 
store_id,
sum((discounted_price*quantity_sold_after_promo))/1000000 as rev_aft_promo,
sum((base_price*quantity_sold_before_promo))/1000000 as rev_bfor_promo
 from fact_events_view join dim_stores using(store_id)
 group by store_id
 -- order by incremental_revenue_in_ml desc
--  limit 10
 )
 select 
 store_id,rev_aft_promo-rev_bfor_promo as IR

 from cte
  order by IR;
 
 select * from fact_events_view
 where promo_type='BOGOF';
 
-- top cities 
select 
city,sum((discounted_price*quantity_sold_after_promo))/1000000 as incremental_revenue_in_ml
 from fact_events_view join dim_stores using(store_id)
 group by city
 order by incremental_revenue_in_ml desc
 ; 
 
 
select 
store_id,city,sum(quantity_sold_after_promo) as units_sold
 from fact_events join dim_stores using(store_id)
group by store_id,city
 order by units_sold asc
 limit 10
 ; 
 
-- variation accross stores  
with cte as ( 
select 
store_id,
sum(quantity_sold_after_promo)
from fact_events_view 
group by (store_id)
)
select * from cte join dim_stores using(store_id);

-- average units sold per city based on store

with cte as (
select 
city, sum(quantity_sold_after_promo) total_quantity_sold
 from fact_events_view join dim_stores using(store_id)
 group by city
 ),cte1 as (
 select count( distinct store_id) as cnt,city
from dim_stores
group  by city
),cte2 as (
select * from cte join cte1 using(city)
order by total_quantity_sold 
)
select 
 city,round((total_quantity_sold/cnt)) as avg_quantity_sold_per_store
from cte2
order by avg_quantity_sold_per_store desc
;
 
 
 select 
city, sum(quantity_sold_after_promo)/3 total_quantity_sold
 from fact_events_view join dim_stores using(store_id)
 where city='Mangalore'
 group by city;
 
-- Promotion Type Analysis

select 
*
 from fact_events_view
 join dim_stores using(store_id)
 join dim_campaigns using(campaign_id)
 join dim_products using(product_code);
 
 
 
select campaign_name,
	round(
    sum( quantity_sold_after_promo*discounted_price)/1000000,2
    ) as total_revenue
from fact_joined
group  by campaign_name
order by total_revenue desc ;

-- 	What are the top 2 promotion types that resulted in the highest Incremental Revenue?
with cte as (
select 
promo_type,
round(sum( quantity_sold_after_promo*discounted_price)/1000000,2) as revenue_after_promo,
round(sum( quantity_sold_before_promo*base_price)/1000000,2) as revenue_before_promotion
 from fact_joined
 group by promo_type
 -- order by total_revenue desc 
 )
 select promo_type,revenue_after_promo-revenue_before_promotion as IR
 from cte
 order by IR desc
 limit 2;
 
 select * from fact_joined;

select 
promo_type,
	sum(case 
		when campaign_name='Diwali' then 1
		else 0
	end )as diwali_sales,
	sum(case 
		when campaign_name='Sankranti' then 1
		else 0
	end )as sankranti_sales
-- product_name,category,promo_type
 from fact_joined
where promo_type='500 Cashback';

select distinct product_name,category
 from fact_joined 
-- where promo_type like '%off'
--  
 where promo_type not like "%off"
 ;
 

-- What are the bottom 2 promotion types in terms of their impact on Incremental Sold Units?
select 
promo_type,
sum(quantity_sold_after_promo)-sum(quantity_sold_before_promo) as ISU
 from fact_joined
 group by promo_type
 order by ISU asc
 ;
 
 select distinct product_name,campaign_name,promo_type from fact_joined ;
 
-- Is there a significant difference in the performance 
-- of discount-based promotions versus BOGOF (Buy One Get One Free) or cashback promotions?

select 
	round(sum(case 
		when promo_type like "%off" then discounted_price*quantity_sold_after_promo
		else 0
	end )/1000000,2) as offer_type,
round(	sum(case 
		when promo_type not like "%off" then discounted_price*quantity_sold_after_promo
		else 0
	end )/1000000 ,2)as bogof_or_cashback,
sum(case 
		when promo_type like "%off" then quantity_sold_after_promo
		else 0
	end ) as offer_type_promotion_units_sold,
sum(case 
		when promo_type not like "%off" then quantity_sold_after_promo
		else 0
	end )as bogof_or_cashback_type_promotion_units_sold
from fact_joined;

-- Which promotions strike the best 
-- balance between Incremental
--  Sold Units and maintaining healthy margins?

select 
promo_type,
sum(quantity_sold_after_promo) as units_sold,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as total_revenue_generated_in_mil
from fact_joined
group by promo_type;


select 
city,
promo_type,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as total_revenue_generated_in_mil
from fact_joined
group by city,promo_type
order by city;


-- 	Which product categories saw the most significant lift in sales from the promotions?
with cte as (
select 
category,
sum(discounted_price*quantity_sold_after_promo)/1000000 as revenue_after_promotion,
sum(base_price*quantity_sold_before_promo)/1000000 as revenue_before_promotion,
sum(base_price*quantity_sold_before_promo)/1000000 + sum(discounted_price*quantity_sold_after_promo)/1000000 as xyz
from fact_joined
group by category
-- having revenue_after_promotion>revenue_before_promotion 
)
select *,
((revenue_after_promotion-revenue_before_promotion)*100/revenue_before_promotion)
 from cte;

select distinct product_name from fact_joined where category like 'per%';


-- Are there specific products that respond exceptionally well or poorly to promotions?
select product_name,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue_after_promotion,
round(sum(base_price*quantity_sold_before_promo)/1000000,2) as revenue_before_promotion
from fact_joined 
group by product_name
having revenue_after_promotion < revenue_before_promotion
-- order by revenue_after_promotion desc
;

select product_name,
sum(quantity_sold_after_promo) as sum
from fact_joined
-- where category like 'per%'
group  by product_name;


-- What is the correlation between product category and promotion type effectiveness?
select 
category,
promo_type,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue_after_promotion
from fact_joined
group by category,promo_type
order by category;

-- top products in each category
with cte as (
select 
category , product_name as product,round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue_after_promotion
-- dense_rank() over(partition by category order by )  
from fact_joined
group by category,product_name
),cte2 as (
select category , product,revenue_after_promotion,
dense_rank() over(partition by category order by revenue_after_promotion desc ) as rnk
from cte
)
select * from cte2 where rnk<3;

select distinct category from dim_products;

select campaign_name  , sum(quantity_sold_after_promo)
from fact_joined where product_name like '%rod'
group by campaign_name;

select sum(quantity_sold_after_promo) from fact_joined where product_name like '%rod';



with cte as (
select campaign_name,product_name,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue_after_promotion
from fact_joined
group  by campaign_name,product_name
),cte1 as (
select 
*,
dense_rank() over(partition by campaign_name order by revenue_after_promotion desc) as rank_
from cte
)
select campaign_name,product_name,revenue_after_promotion

from cte1 where rank_<=3;

with cte as (
select campaign_name,city,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue_after_promotion
from fact_joined
group  by campaign_name,city
),cte1 as (
select 
*,
dense_rank() over(partition by campaign_name order by revenue_after_promotion desc) as rank_
from cte
)
select campaign_name,city,revenue_after_promotion

from cte1 where rank_<=3;

with cte as (
select city,product_name,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue_after_promotion
from fact_joined
group  by city,product_name
),cte1 as (
select 
*,
dense_rank() over(partition by city order by revenue_after_promotion desc) as rank_
from cte
)
select city,product_name,revenue_after_promotion

from cte1 where rank_<=4;

with cte as (
select city,product_name,
sum(quantity_sold_after_promo) as total_quantity
from fact_joined
group by city,product_name
),cte1 as (
select 
*,
dense_rank() over(partition by city order by total_quantity desc) as rnk_
from cte
)
select * from cte1 where rnk_<3;

with cte as (
select 
product_name,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue
from fact_joined
where campaign_name='diwali'
group by  product_name

),
cte1 as (
select 
product_name,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue
from fact_joined
where campaign_name='sankranti'
group by  product_name
)
select * from cte join cte1 using(product_name);


select distinct promo_type,campaign_name,product_name from fact_joined;
-- where product_name like "%atta%";

-- with cte as (
select campaign_name,promo_type,product_name,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as revenue,
sum(quantity_sold_after_promo) as quantity_sold
from fact_joined
where product_name ='Atliq_Suflower_Oil (1L)' or product_name ='Atliq_Farm_Chakki_Atta (1KG)'
group by campaign_name,promo_type,product_name;


with cte as (
select 
store_id,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as rev_after_promo,
round(sum(base_price*quantity_sold_before_promo)/1000000,2) as rev_bfor_promo
from fact_joined
group by store_id
)
select 
store_id,rev_after_promo-rev_bfor_promo as incremental_rev_in_mil
from cte
order by incremental_rev_in_mil desc
limit 10;


with cte as (
select store_id,
sum(quantity_sold_after_promo) as qty_sold_after_promo,
sum(quantity_sold_before_promo) as qty_sold_before_promo
from fact_joined
group by store_id
)
select 
store_id, qty_sold_after_promo-qty_sold_before_promo as ISU
from cte
order by ISU
limit 10;

with cte as (
select 
city,promo_type,
round(sum(discounted_price*quantity_sold_after_promo)/1000000,2) as rev_after_promo,
round(sum(base_price*quantity_sold_before_promo)/1000000,2) as rev_bfor_promo
from fact_joined
group by city,promo_type
)
select 
city,promo_type,rev_after_promo-rev_bfor_promo as incremental_rev_in_million
from cte
order by city
;


