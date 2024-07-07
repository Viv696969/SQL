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

with cte as (
select pc_id,party_id,sum(total_votes) as votes 
from results_2014
group  by pc_id,party_id
),
cte1 as (
select pc_id,party_id,sum(total_votes) as votes 
from results_2019
group  by pc_id,party_id
),cte_final  as (
select cte.pc_id,cte.party_id,cte1.votes-cte.votes as vote_diff 
 from cte join cte1
on cte.pc_id=cte1.pc_id and cte1.party_id=cte.party_id
where cte1.votes>cte.votes
order by vote_diff desc 
),cte_last as (
select *,
dense_rank() over(partition by pc_id order by vote_diff desc) as `rank`,
sum(vote_diff) over(partition by pc_id order by vote_diff desc) as vote_sum
from cte_final
)
select * from cte_last where `rank` in (1,2)
order by vote_sum desc;


select pc_name,sum(total_votes) as nota_votes from results_2014
join pc on pc.pc_id=results_2014.pc_id
where candidate is 
null
group by pc_name
order by nota_votes desc
limit 5
;

select pc_name,sum(total_votes) as nota_votes from results_2019
join pc on pc.pc_id=results_2019.pc_id
where candidate='NOTA'
group by pc_name
order by nota_votes desc
limit 5
;

with cte as (
select state_id,party_id,total_votes,
sum(total_votes) over(partition by state_id) as sum_for_state
 from by_state_and_party_2019
 ),cte2 as (
 select state_id,party_id,(total_votes/sum_for_state)*100 as vote_contro from cte
  having vote_contro <10
 order by vote_contro desc
 ),
 cte_parties as (
 select distinct party_id from cte2
 )
select distinct pc_name
from results_2019 join pc 
on pc.pc_id=results_2019.pc_id
where party_id in (select party_id from cte_parties);
--  select distinct party_id from cte2;


select state_id,pc_id,sum(general_votes) as `general_votes`,sum(postal_votes) as `postal_votes`,
sum(total_votes) as `total_votes` ,max(total_electors) as `total_electors`
 from results_2019
 group by state_id,pc_id
 order by state_id,pc_id;

select state_id,pc_id,sum(general_votes) ,sum(postal_votes),
sum(total_votes)  ,max(total_electors) 
 from results_2014
 group by state_id,pc_id
 order by state_id,pc_id;
 
with cte as ( 
select party_id,sum(total_votes) as `total_votes_2014` 
from by_state_and_party_2014
group by party_id
order by `total_votes_2014` desc
),
cte_2014 as 
(
	select party_id,total_votes_2014*100/sum(total_votes_2014) over() as `vote%_2014`
    from cte
    order by `vote%_2014` desc
    
),
cte_2 as (
	select party_id,sum(total_votes) as `total_votes_2019` 
from by_state_and_party_2019
group by party_id
order by `total_votes_2019` desc
),
cte_2019 as (
	select party_id,total_votes_2019*100/sum(total_votes_2019) over() as `vote%_2019`
    from cte_2
    order by `vote%_2019` desc
)
select pp.party, `vote%_2014`,`vote%_2019` from cte_2014 join cte_2019 
on cte_2014.party_id=cte_2019.party_id join party pp on pp.party_id=cte_2019.party_id
order by `vote%_2014` desc 
limit 5;

with cte as ( 
select state_id,party_id,sum(total_votes) as `total_votes_2014` 
from by_state_and_party_2014
group by state_id,party_id
order by state_id desc
),cte_2014 as 
(
	select state_id,party_id,total_votes_2014*100/sum(total_votes_2014) 
    over(partition by state_id) as `vote%_2014`
    from cte
    order by `vote%_2014` desc
    
),
 cte_2 as ( 
select state_id,party_id,sum(total_votes) as `total_votes_2019` 
from by_state_and_party_2019
group by state_id,party_id
order by state_id desc
),cte_2019 as 
(
	select state_id,party_id,total_votes_2019*100/sum(total_votes_2019) 
    over(partition by state_id) as `vote%_2019`
    from cte_2
    order by `vote%_2019` desc
    
),cte_final  as (
select * 
,dense_rank() over(partition by state_id order by `vote%_2019`+`vote%_2014` desc) as `rank`
from cte_2019 c1 join cte_2014 c2 using(state_id,party_id)
order by state_id,`rank`
)
select s.state,p.party,`vote%_2019`,`vote%_2014` from cte_final
join party p using(party_id) join states s using(state_id)
where `rank` in (1,2)
order by s.state ,`rank`
;

select 
p.pc_name,total_votes*100/total_electors as `voter turnout ratio`
 from state_pc_aggregated_2014 join pc p using(pc_id)
 order by  `voter turnout ratio` desc
 limit 5;


select s.state , sum(total_votes)*100/sum(total_electors) as `voter tunout ratio`
from state_pc_aggregated_2019 join states s using(state_id)
group by s.state
order by  `voter tunout ratio` desc;











 

