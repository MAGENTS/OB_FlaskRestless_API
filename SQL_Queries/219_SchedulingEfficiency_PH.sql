	
select distinct e.EmpFullName, 	
count(distinct case when dd.DayName = 'Saturday' then dd.[Date] end) as NumOfSaturdays,
count(distinct case when dd.DayName = 'Sunday' then dd.[Date] end) as NumOfSaturdays
from integration.dbo.VW_INT_FCTOverTime fct	
INNER JOIN Integration.dbo.VW_INT_DIMDATE dd ON (dd.DateKey=fct.EventDateSK)	
left join integration.dbo.INT_DimEmployee e on e.EmpKRNnumber = fct.KronosPersonNum	
where cast(dd.[Date] as date) >= '2017-07-30' and cast(dd.[Date] as date) < '2018-07-31'	
and DayName in ('Saturday', 'Sunday')	
and fct.scheduledlocation <> 'PTO' and fct.scheduledlocation <>'No Schedule'	
and e.EmpKRNSupervisornumber = '106607'	
group by e.EmpFullName	
order by e.EmpFullName	
;
