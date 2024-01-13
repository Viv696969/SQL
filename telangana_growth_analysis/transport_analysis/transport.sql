select * from fact_transport;

-- Investigate whether there is any correlation
--  between vehicle sales and specific months or seasons in different districts.
--  Are there any months or seasons that consistently 
--  show higher sale rates, and if yes, what could be the driving factors?
with cte as (
select 
 month,Mmm,quarter,
 fuel_type_petrol+fuel_type_diesel+fuel_type_electric+fuel_type_others as total_vehicle_sold
,district
 from fact_transport
 join dim_date d
 using(month)
 join dim_districts dis
 using(dist_code)
 )
 select 
 mmm,sum(total_vehicle_sold)/1000000 as total_ml
 from cte
 group by mmm
 order by total_ml desc 
 ;
 
 
--  How does the distribution of vehicles vary 
--  by vehicle class (MotorCycle, MotorCar, AutoRickshaw, Agriculture) 
--  across different districts? 
--  Are there any districts with a predominant preference for a specific vehicle class? 
--  Consider FY 2022 for analysis


-- create view transport_view as 
-- select 
-- *
--  from fact_transport
--  join dim_date d
--  using(month)
--  join dim_districts dis
--  using(dist_code)
--  where d.fiscal_year=2022;

-- for motor cycle 
select 
district,
sum(vehicleClass_MotorCycle)/100000 as total_motor_cycle_sold
from transport_view
group by district
order by total_motor_cycle_sold desc
limit 10;

-- for motor car
 select 
district,
sum(vehicleClass_MotorCar)/100000 as total_motor_car_sold
from transport_view
group by district
order by total_motor_car_sold desc
limit 10;

-- for vehicleClass_AutoRickshaw
 select 
district,
sum(vehicleClass_AutoRickshaw)/100000 as total_motor_rikshaw_sold
from transport_view
group by district
order by total_motor_rikshaw_sold desc
limit 10;

-- for Agriculture
select 
district,
sum(vehicleClass_Agriculture)/100000 as total_motor_agri_sold
from transport_view
group by district
order by total_motor_agri_sold desc
limit 10;


-- List down the top 3 and bottom 3 districts that have shown the highest
-- and lowest vehicle sales growth during FY 2022 compared to FY
-- 2021? (Consider and compare categories: Petrol, Diesel and Electric)

create temporary table transport_temp 
as select month,fuel_type_diesel,fuel_type_petrol,fuel_type_electric,fiscal_year,district
 from fact_transport
 join dim_date d
 using(month)
 join dim_districts dis
 using(dist_code);
 

create temporary table transport_2021 as
select
district,
sum(fuel_type_petrol) as petrol_sum_2021,
sum(fuel_type_diesel) as diesel_sum_2021,
sum(fuel_type_electric) as electric_sum_2021
from transport_temp
where fiscal_year=2021
group by district;



create temporary table transport_2022 as
 select 

district,
sum(fuel_type_petrol) as petrol_sum_2022,
sum(fuel_type_diesel) as diesel_sum_2022,
sum(fuel_type_electric) as electric_sum_2022
from transport_temp
where fiscal_year=2022
group by district;


with cte as (
select 
district,
sum(
	petrol_sum_2021+diesel_sum_2021+electric_sum_2021
) as total_2021,
sum(
	petrol_sum_2022+diesel_sum_2022+electric_sum_2022
) as total_2022

from transport_2021
join transport_2022
using(district)
group by district
)
select 
district,total_2021,total_2022
 from cte
 where total_2022>total_2021
 order by total_2022 asc
 limit 3;

