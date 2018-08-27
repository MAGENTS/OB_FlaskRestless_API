		
		
select 	
	Concat('Region ',l.RegionID) as [Region],
	l.FinanceLocationName,
	Convert(varchar(10),r.registration_date,101) as [Date],
	datename(dw, r.registration_date) as DayName,
	datename(m, r.registration_date) as Month,
	dt.DonationDescription as [Donation Type],
	m.MotivationName as [Motivation],
	count(r.registration_id) as Total,
	count(case when cast(r.registration_date as time) >= '00:00:00' and cast(r.registration_date as time) < '00:30:00' then 1 end) as [Total at 12:00am],
	count(case when cast(r.registration_date as time) >= '00:30:00' and cast(r.registration_date as time) < '01:00:00' then 1 end) as [Total at 12:30am],
	count(case when cast(r.registration_date as time) >= '01:00:00' and cast(r.registration_date as time) < '01:30:00' then 1 end) as [Total at 1:00am],
	count(case when cast(r.registration_date as time) >= '01:30:00' and cast(r.registration_date as time) < '02:00:00' then 1 end) as [Total at 1:30am],
	count(case when cast(r.registration_date as time) >= '02:00:00' and cast(r.registration_date as time) < '02:30:00' then 1 end) as [Total at 2:00am],
	count(case when cast(r.registration_date as time) >= '02:30:00' and cast(r.registration_date as time) < '03:00:00' then 1 end) as [Total at 2:30am],
	count(case when cast(r.registration_date as time) >= '03:00:00' and cast(r.registration_date as time) < '03:30:00' then 1 end) as [Total at 3:00am],
	count(case when cast(r.registration_date as time) >= '03:30:00' and cast(r.registration_date as time) < '04:00:00' then 1 end) as [Total at 3:30am],
	count(case when cast(r.registration_date as time) >= '04:00:00' and cast(r.registration_date as time) < '04:30:00' then 1 end) as [Total at 4:00am],
	count(case when cast(r.registration_date as time) >= '04:30:00' and cast(r.registration_date as time) < '05:00:00' then 1 end) as [Total at 4:30am],
	count(case when cast(r.registration_date as time) >= '05:00:00' and cast(r.registration_date as time) < '05:30:00' then 1 end) as [Total at 5:00am],
	count(case when cast(r.registration_date as time) >= '05:30:00' and cast(r.registration_date as time) < '06:00:00' then 1 end) as [Total at 5:30am],
	count(case when cast(r.registration_date as time) >= '06:00:00' and cast(r.registration_date as time) < '06:30:00' then 1 end) as [Total at 6:00am],
	count(case when cast(r.registration_date as time) >= '06:30:00' and cast(r.registration_date as time) < '07:00:00' then 1 end) as [Total at 6:30am],
	count(case when cast(r.registration_date as time) >= '07:00:00' and cast(r.registration_date as time) < '07:30:00' then 1 end) as [Total at 7:00am],
	count(case when cast(r.registration_date as time) >= '07:30:00' and cast(r.registration_date as time) < '08:00:00' then 1 end) as [Total at 7:30am],
		
	count(case when cast(r.registration_date as time) >= '08:00:00' and cast(r.registration_date as time) < '08:30:00' then 1 end) as [Total at 8:00am],
	count(case when cast(r.registration_date as time) >= '08:30:00' and cast(r.registration_date as time) < '09:00:00' then 1 end) as [Total at 8:30am],
	count(case when cast(r.registration_date as time) >= '09:00:00' and cast(r.registration_date as time) < '09:30:00' then 1 end) as [Total at 9:00am],
	count(case when cast(r.registration_date as time) >= '09:30:00' and cast(r.registration_date as time) < '10:00:00' then 1 end) as [Total at 9:30am],
	count(case when cast(r.registration_date as time) >= '10:00:00' and cast(r.registration_date as time) < '10:30:00' then 1 end) as [Total at 10:00am],
	count(case when cast(r.registration_date as time) >= '10:30:00' and cast(r.registration_date as time) < '11:00:00' then 1 end) as [Total at 10:30am],
	count(case when cast(r.registration_date as time) >= '11:00:00' and cast(r.registration_date as time) < '11:30:00' then 1 end) as [Total at 11:00am],
	count(case when cast(r.registration_date as time) >= '11:30:00' and cast(r.registration_date as time) < '12:00:00' then 1 end) as [Total at 11:30am],
	count(case when cast(r.registration_date as time) >= '12:00:00' and cast(r.registration_date as time) < '12:30:00' then 1 end) as [Total at 12:00pm],
	count(case when cast(r.registration_date as time) >= '12:30:00' and cast(r.registration_date as time) < '13:00:00' then 1 end) as [Total at 12:30pm],
	count(case when cast(r.registration_date as time) >= '13:00:00' and cast(r.registration_date as time) < '13:30:00' then 1 end) as [Total at 1:00pm],
	count(case when cast(r.registration_date as time) >= '13:30:00' and cast(r.registration_date as time) < '14:00:00' then 1 end) as [Total at 1:30pm],
	count(case when cast(r.registration_date as time) >= '14:00:00' and cast(r.registration_date as time) < '14:30:00' then 1 end) as [Total at 2:00pm],
	count(case when cast(r.registration_date as time) >= '14:30:00' and cast(r.registration_date as time) < '15:00:00' then 1 end) as [Total at 2:30pm],
	count(case when cast(r.registration_date as time) >= '15:00:00' and cast(r.registration_date as time) < '15:30:00' then 1 end) as [Total at 3:00pm],
	count(case when cast(r.registration_date as time) >= '15:30:00' and cast(r.registration_date as time) < '16:00:00' then 1 end) as [Total at 3:30pm],
	count(case when cast(r.registration_date as time) >= '16:00:00' and cast(r.registration_date as time) < '16:30:00' then 1 end) as [Total at 4:00pm],
	count(case when cast(r.registration_date as time) >= '16:30:00' and cast(r.registration_date as time) < '17:00:00' then 1 end) as [Total at 4:30pm],
	count(case when cast(r.registration_date as time) >= '17:00:00' and cast(r.registration_date as time) < '17:30:00' then 1 end) as [Total at 5:00pm],
	count(case when cast(r.registration_date as time) >= '17:30:00' and cast(r.registration_date as time) < '18:00:00' then 1 end) as [Total at 5:30pm],
	count(case when cast(r.registration_date as time) >= '18:00:00' and cast(r.registration_date as time) < '18:30:00' then 1 end) as [Total at 6:00pm],
	count(case when cast(r.registration_date as time) >= '18:30:00' and cast(r.registration_date as time) < '19:00:00' then 1 end) as [Total at 6:30pm],
	count(case when cast(r.registration_date as time) >= '19:00:00' and cast(r.registration_date as time) < '19:30:00' then 1 end) as [Total at 7:00pm],
	count(case when cast(r.registration_date as time) >= '19:30:00' and cast(r.registration_date as time) < '20:00:00' then 1 end) as [Total at 7:30pm],
	count(case when cast(r.registration_date as time) >= '20:00:00' and cast(r.registration_date as time) < '20:30:00' then 1 end) as [Total at 8:00pm],
	count(case when cast(r.registration_date as time) >= '20:30:00' and cast(r.registration_date as time) < '21:00:00' then 1 end) as [Total at 8:30pm],
	count(case when cast(r.registration_date as time) >= '21:00:00' and cast(r.registration_date as time) < '21:30:00' then 1 end) as [Total at 9:00pm],
	count(case when cast(r.registration_date as time) >= '21:30:00' and cast(r.registration_date as time) < '22:00:00' then 1 end) as [Total at 9:30pm],
	count(case when cast(r.registration_date as time) >= '22:00:00' and cast(r.registration_date as time) < '22:30:00' then 1 end) as [Total at 10:00pm],
	count(case when cast(r.registration_date as time) >= '22:30:00' and cast(r.registration_date as time) < '23:00:00' then 1 end) as [Total at 10:30pm],
	count(case when cast(r.registration_date as time) >= '23:00:00' and cast(r.registration_date as time) < '23:30:00' then 1 end) as [Total at 11:00pm],
	count(case when cast(r.registration_date as time) >= '23:30:00' and cast(r.registration_date as time) <= '23:59:59' then 1 end) as [Total at 11:30pm]
from STAGE.dbo.STG_RSARegistration_2017 r --STAGE.dbo.STG_RSADRAW dr 	
	inner join INTEGRATION.dbo.INT_MKTCollectionDetails mkt on mkt.registrationid = r.registration_id
	left join INTEGRATION.dbo.Int_DimDonationType dt on mkt.DonationTypeSK = dt.DonationTypeSK
	left join INTEGRATION.dbo.INT_DIMMotivation m on mkt.MotivationSK = m.MotivationSK
	left join INTEGRATION.dbo.INT_DIMLocation l on mkt.LocationSK = l.LocationSK
where mkt.CollectionDateSK >= 20170101 and mkt.CollectionDateSK < 20180101	
and Mkt.import = 0	
and l.LocationdepartmentNumber = 2820	
--and l.LocationSK in (63,12,64,44,67,65,71,72)	
--l.FinanceLocationName = 'Clermont Donor Center'	
group by 	
	m.MotivationName,Concat('Region ',l.RegionID), 	
	l.FinanceLocationName,	
Convert(varchar(10),r.registration_date,101),	
datename(dw, r.registration_date), 	
datename(m, r.registration_date),	
Convert(varchar(10),r.registration_date,101),	
dt.DonationDescription	
