
create view by_state_and_party_2014 as 
select state_id,party_id,sum(general_votes) as `general_votes` ,
sum(postal_votes) as `postal_votes`,sum(total_votes) as `total_votes`,sum(total_electors) 
as `total_electors`
from results_2014
group by state_id,party_id
order by state_id;

create view by_state_and_pc_2014 as 
select state_id,pc_id,sum(general_votes) as `general_votes` ,
sum(postal_votes) as `postal_votes`,sum(total_votes) as `total_votes`,sum(total_electors) 
as `total_electors`
from results_2014
group by state_id,pc_id
order by state_id;

select * from by_state_and_party_2014;


create view by_state_and_category_2014 as 
select state_id,category_id,sum(general_votes) as `general_votes` ,
sum(postal_votes) as `postal_votes`,sum(total_votes) as `total_votes`,sum(total_electors) 
as `total_electors`
from results_2014
group by state_id,category_id
order by state_id,category_id;

-- 2019

create view by_state_and_party_2019 as  
select state_id,party_id,sum(general_votes) as `general_votes` ,
sum(postal_votes) as `postal_votes`,sum(total_votes) as `total_votes`,sum(total_electors) 
as `total_electors`
from results_2019
group by state_id,party_id
order by state_id,party_id;

create view by_state_and_pc_2019 as 
select state_id,pc_id,sum(general_votes) as `general_votes` ,
sum(postal_votes) as `postal_votes`,sum(total_votes) as `total_votes`,sum(total_electors) 
as `total_electors`
from results_2019
group by state_id,pc_id
order by state_id;

select * from by_state_and_party_2014;


create view by_state_and_category_2019 as 
select state_id,category_id,sum(general_votes) as `general_votes` ,
sum(postal_votes) as `postal_votes`,sum(total_votes) as `total_votes`,sum(total_electors) 
as `total_electors`
from results_2019
group by state_id,category_id
order by state_id,category_id;








