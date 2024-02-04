-- store performance insights

select 
store_id,city,sum((discounted_price*quantity_sold_after_promo))/1000000 as incremental_revenue_in_ml
 from fact_events_view join dim_stores using(store_id)
 group by store_id,city
 order by incremental_revenue_in_ml desc
 limit 10
 ; 
 
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
 select count(store_id) as cnt,city
from dim_stores
group  by city
),cte2 as (
select * from cte join cte1 using(city)
order by total_quantity_sold 
)
select 
city,round((total_quantity_sold/cnt)) as avg_quantity_sold_per_store
from cte2
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
 
 
 
select campaign_name,round(sum( quantity_sold_after_promo*discounted_price)/1000000,2) as total_revenue
from fact_joined
group  by campaign_name
order by total_revenue desc ;

-- 	What are the top 2 promotion types that resulted in the highest Incremental Revenue?
select 
promo_type,round(sum( quantity_sold_after_promo*discounted_price)/1000000,2) as total_revenue
 from fact_joined
 group by promo_type
 order by total_revenue desc
 ;

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
promo_type,sum(quantity_sold_after_promo) as total_sold_units
 from fact_joined
 group by promo_type
 order by total_sold_units asc
 ;
 
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


