			
			
use tempdb;			
go			
if object_id('tempdb.dbo.#temp') is not null drop table tempdb.dbo.#temp			
select tr.unit_number, tr.draw_date, 			
	min(case when test_id = 12 then result end) as t12, 		
	min(case when test_id = 26 then result end) as t26, 		
	min(case when test_id = 27 then result end) as t27, 		
	min(case when test_id = 11 then result end) as t11, min(case when test_id = 39 then result end) as t39, 		
	min(case when test_id = 40 then result end) as t40, min(case when test_id = 63 then result end) as t63 		
into tempdb.dbo.#temp			
from stage.dbo.STG_RSATestResult_Full tr			
left join STAGE.dbo.STG_RSADonation d on d.unit_number = tr.unit_number			
left join STAGE.dbo.STG_RSARegistration r on d.registration_id = r.registration_id			
where tr.test_id in (12, 26, 27, 11, 39, 40, 63)			
and tr.draw_date >= '2016-01-01' and tr.draw_date < '2017-01-01'			
group by tr.unit_number, tr.draw_date			
			
			
			
select month(draw_date) as Month, 			
	count(distinct case when t12 = 'N' and t26 = 'P' and (t27 = 'N' or t27 = 'NT' or t27 is null)		
		and (t11 = 'N' or t11 = 'NT' or t11 is null or t39 = 'N' or t39 = 'NT' or t39 is null)	
		and (t40 = 'N' or t40 = 'NT'  or t40 is null or t63 = 'N' or t63 = 'NT'  or t63 is null)	
		then unit_number end) FirstSection,	
	count(distinct case when t12 = 'P' and (t26 = 'N' or t26 = 'NT' or t26 is null) 		
		and (t27 = 'N' or t27 = 'NT'  or t27 = 'I' or t27 is null)	
		and (t11 = 'N' or t11 = 'NT' or t11 = 'P' or t11 is null or t39 = 'N' or t39 = 'NT' or t39 = 'P' or t39 is null)	
		and (t40 = 'N' or t40 = 'NT' or t40 = 'I' or t40 = 'IC' or t40 is null 	
			or t63 = 'N' or t63 = 'NT' or t63 = 'I' or t63 = 'IC' or t63 is null)
		then unit_number end) as SecondSection	
from tempdb.dbo.#temp			
group by month(draw_date)			
order by month(draw_date)			
			
			
select distinct draw_date, unit_number, t12, t26, t27, t11, t39, t40, t63			
from tempdb.dbo.#temp			
where t12 = 'N' and t26 = 'P' and (t27 = 'N' or t27 = 'NT' or t27 is null)			
		and (t11 = 'N' or t11 = 'NT' or t11 is null or t39 = 'N' or t39 = 'NT' or t39 is null)	
		and (t40 = 'N' or t40 = 'NT'  or t40 is null or t63 = 'N' or t63 = 'NT'  or t63 is null)	
			
select distinct draw_date, unit_number, t12, t26, t27, t11, t39, t40, t63			
from tempdb.dbo.#temp			
where 	t12 = 'P' and (t26 = 'N' or t26 = 'NT' or t26 is null) 		
		and (t27 = 'N' or t27 = 'NT'  or t27 = 'I' or t27 is null)	
		and (t11 = 'N' or t11 = 'NT' or t11 = 'P' or t11 is null or t39 = 'N' or t39 = 'NT' or t39 = 'P' or t39 is null)	
		and (t40 = 'N' or t40 = 'NT' or t40 = 'I' or t40 = 'IC' or t40 is null 	
			or t63 = 'N' or t63 = 'NT' or t63 = 'I' or t63 = 'IC' or t63 is null)
