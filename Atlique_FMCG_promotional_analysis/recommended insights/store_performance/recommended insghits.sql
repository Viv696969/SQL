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
 group by city
 