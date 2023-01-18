--show the the dataset structure
select * from Data1;
select * from Data2;

--number of rows into dataset
select count(*) from data1
select count(*) from data2

--dataset from uttar pradesh and gujarat
select * from data1 where state in('uttar pradesh','Gujarat')

--total population of india in 2011
select sum(population) as 'total population' from data2;

--average growth percentage of country
select avg(growth)*100 as 'growth_percentage' from data1;

--state wise avg growth percentage
select state,avg(growth)*100 from data1 group by state;

--avg sex ratio (using group by,having,order by clause)

select state,round(avg(sex_ratio),0)as sex_ratio from data1 group by state having state=
'uttar pradesh'

select state,round(avg(sex_ratio),0)as sex_ratio from data1 group by state order by
sex_ratio desc ;

--avg literacy rate (using group by,having,order by clause)
select state,round(avg(Literacy),0)as literacy_rate from data1 group by state order by
literacy_rate desc ;

select state,round(avg(Literacy),0)as literacy_rate from data1 group by state 
having avg(Literacy)>=90 order by literacy_rate desc ;

--top3 literate state

select top 3 state,round(avg(Literacy),0)as literacy_rate from data1 group by state order by
literacy_rate desc ;

--bottom 3 literate state

select top 3 state,round(avg(Literacy),0)as literacy_rate from data1 group by state order by
literacy_rate  ;

--creating a temporary table and inserting the data

drop table if exists #literate_state 

create table #literate_state
(state nvarchar(255),literacy_rate float)

insert into #literate_state
select state,round(avg(Literacy),0)as literacy_rate from data1 group by state order by
literacy_rate desc ;

select * from #literate_state;

--union operator

select* from(
select top 3 * from #literate_state  order by literacy_rate desc) x 
union
select * from (
select top 3 * from #literate_state  order by literacy_rate) y

--state starting with letter A (use of like ,or ,% operator)

select distinct state from data1 where state like  'a%'or state like'b%'or state like'u%';


--state starting and ending with letter u and h (use of like ,or ,% operator)
select distinct state from data1 where state like  'u%' and state like'%h';

--inner join

select a.state,a.district,a.sex_ratio,b.population from data1 a join data2 b
on a.District=b.District;

--find out number of males and females in the population

                    --Back end Calculation
                          --sex_ratio=female\male.......1
                          --population=female+male......2
                          --female=population-male......3
						  --female=sex_ratio*male
						  --population-male=sex_ratio*male
						  --population=sex_ratio*male+male
						  --population=male(sex_ratio+1)
						  --popu*lation\(sex_ratio+1)=male.......male
                          --female=population-population\(sex_ratio+1)
						 --(population*(sex_ratio))\(sex_ratio+1)=female.....female

select d.state,sum(d.male) as total_male,sum(d.female) as total_female from 
(select c.state,c.district,c.Population,round(c.population/(c.sex_ratio+1),0) as male,
round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as female from 
(select a.state,a.district,a.sex_ratio/1000 as sex_ratio,b.population from data1 a join data2 b
on a.District=b.District) c) d 
group by d.state;

--find out number of total literate and illerate people

                              --literacy ratio=total literate/population.....1
							  --total literate=literacy ratio*population.....2
						      --total illerate=population-literacy ratio*population.....3

select d.state,round(sum(d.total_literate),0) as literate,round(sum(d.total_illerate),0)
as illerate from
(select c.state,c.district,c.literacy_ratio,c.population,(c.literacy_ratio * c.population)as 
total_literate,(c.population-c.literacy_ratio*c.population) as total_illerate from  
(select a.state,a.district,a.Literacy/100 as literacy_ratio,b.population from
data1 a join data2 b on a.District=b.District) c ) d group by d.state

--find out previous census's population
                                     
					--current population=previous population+previous population*growth
					--previous population=current population/(1+growth)

select sum( round(e.current_population/(1+e.growth),0)) as  previous_population,
sum(e.current_population) as current_population from
(select d.state,d.growth,sum(d.current_population) as current_population,
sum( round(d.current_population/(1+d.growth),0)) as  previous_population from
(select c.state,c.district,c.growth,c.population as current_population,round(c.population/(1+c.growth),0)as previous_population from (select a.state,a.district,b.population,a.growth
from data1 a join data2 b on a.District=b.District) c)d group by d.state , d.Growth)e

--find out population per square km(previous and current)
select z.total_area/z.previous_population as previous ,z.total_area/z.current_population 
as currenty from
(select m.*,n.total_area from(
select '1' as keyy,q.* from(
select sum( round(e.current_population/(1+e.growth),0)) as  previous_population,
sum(e.current_population) as current_population from
(select d.state,d.growth,sum(d.current_population) as current_population,
sum( round(d.current_population/(1+d.growth),0)) as  previous_population from
(select c.state,c.district,c.growth,c.population as current_population,round(c.population/(1+c.growth),0)as previous_population from (select a.state,a.district,b.population,a.growth
from data1 a join data2 b on a.District=b.District) c)d group by d.state , d.Growth)e)q)m join (

select '1' as keyy,r.*from (
select sum(Area_km2) as total_area from data2)r)n on m.keyy=n.keyy)z

---window functions(RANK FUNCTION)

---find out top 3 literacy rate's district of state

select a.* from 
(select state,district,literacy,rank() over(partition by state order by literacy desc) 
as rank from data1) a where a.rank in (1,2,3)




