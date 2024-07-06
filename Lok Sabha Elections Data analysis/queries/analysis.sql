-- 1
with cte as (
select pc_id,round((sum(total_votes)/sum(total_electors))*100,2) as `voter turnout ratio`
from by_state_and_pc_2014
group by pc_id
order by `voter turnout ratio`
limit 5)
select pc.pc_id,pc_name,`voter turnout ratio` from cte join pc on pc.pc_id=cte.pc_id;

with cte as (
select pc_id,round((sum(total_votes)/sum(total_electors))*100,2) as `voter turnout ratio`
from by_state_and_pc_2019
group by pc_id
order by `voter turnout ratio` desc
limit 5)
select pc_name,`voter turnout ratio` from cte join pc on pc.pc_id=cte.pc_id
order by `voter turnout ratio`desc;

with cte as (
select state_id,round((sum(total_votes)/sum(total_electors))*100,2) as `voter turnout ratio`
from results_2019
group by state_id
order by `voter turnout ratio` 
-- limit 5 
)
select state,`voter turnout ratio`
 from cte join states s 
 on s.state_id=cte.state_id order by `voter turnout ratio` desc;
 
 
 
-- 3
with cte as (
select pc_id,party_id ,sum(total_votes) as total_votes_sum
from results_2014
group by pc_id,party_id
),cte1 as (
select pc_id,party_id,total_votes_sum,
dense_rank() over(partition by pc_id order by total_votes_sum desc ) as `rank`
from cte
),pc_2014 as (
select * from cte1 where `rank`=1
),
cte2 as (
select pc_id,party_id ,sum(total_votes) as total_votes_sum
from results_2019
group by pc_id,party_id
),cte3 as (
select pc_id,party_id,total_votes_sum,
dense_rank() over(partition by pc_id order by total_votes_sum desc ) as `rank`
from cte2
),pc_2019 as (
select * from cte3 where `rank`=1
),cte_final as (
select pc1.pc_id, pc1.party_id as party_2014, pc2.party_id as party_2019 
,pc1.total_votes_sum as total_2014,pc2.total_votes_sum as total_2019
 from pc_2014 as pc1 join pc_2019 pc2 
using(pc_id)
where pc1.party_id=pc2.party_id
)
select pc_name,party,round(((total_2019-total_2014)*100)/total_2014,2) as `% increase in 2019`
from cte_final
join pc on pc.pc_id=cte_final.pc_id join party on cte_final.party_2014=party.party_id
order by `% increase in 2019` desc
limit 10;
-- select  pc_name,party,
-- round(((total_2019-total_2014)*100)/total_2014,2) as `% increase in 2019`
-- from cte_last
-- order by `% increase in 2019` desc;

-- 4 
with cte as (
select pc_id,party_id ,sum(total_votes) as total_votes_sum
from results_2014
group by pc_id,party_id
),cte1 as (
select pc_id,party_id,total_votes_sum,
dense_rank() over(partition by pc_id order by total_votes_sum desc ) as `rank`
from cte
),pc_2014 as (
select * from cte1 where `rank`=1
),
cte2 as (
select pc_id,party_id ,sum(total_votes) as total_votes_sum
from results_2019
group by pc_id,party_id
),cte3 as (
select pc_id,party_id,total_votes_sum,
dense_rank() over(partition by pc_id order by total_votes_sum desc ) as `rank`
from cte2
),pc_2019 as (
select * from cte3 where `rank`=1
),cte_final as (
select pc1.pc_id, pc1.party_id as party_2014, pc2.party_id as party_2019 
,pc1.total_votes_sum as total_2014,pc2.total_votes_sum as total_2019
 from pc_2014 as pc1 join pc_2019 pc2 
using(pc_id)
where pc1.party_id!=pc2.party_id
)
select pc_name,p.party as party_of_2014,p2.party as party_of_2019,
round(((total_2019-total_2014)*100)/total_2014,2) as `%difference`
from cte_final
join pc on pc.pc_id=cte_final.pc_id join party p on cte_final.party_2014=p.party_id join party p2 on
p2.party_id=cte_final.party_2019
order by `%difference` desc
limit 10;


with cte as (
select candidate,sum(total_votes) as votes from results_2014
where candidate is not null
group by candidate
order by votes desc
),cte1  as (
select *,
lead(votes) over() as runner_up_votes
 from cte
 )
select candidate,votes-runner_up_votes as diff
from cte1
order by diff desc 
limit 5;



with cte as (
select candidate,sum(total_votes) as votes from results_2019
where candidate is not null and  candidate!='NOTA'
group by candidate
order by votes desc
),cte1  as (
select *,
lead(votes) over() as runner_up_votes
 from cte
 )
select candidate,votes-runner_up_votes as diff
from cte1
order by diff desc 
limit 5;



