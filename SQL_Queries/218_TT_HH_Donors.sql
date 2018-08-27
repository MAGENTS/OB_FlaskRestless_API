drop table test.dbo.adhoc_218	
	
	
select distinct l.RegionID, mkt.personid as DonorId, isnull(per.FIRST_NAME,'')+' '+ Isnull(per.MIDDLE_INITIAL,'')+' '+Isnull(per.LAST_NAME,'') DonorName,	
per.Gender, per.DOB, per.Address1, per.Apartment_Number, per.Address2, per.City, per.State, per.Zip, per.Home_Phone, per.Work_Phone, per.Work_Ext,
m.MotivationName, 
l.FinanceLocationName, 
convert(date, convert(varchar(10), max(mkt.CollectionDateSK), 120)) as LastDonationDate, rx2.Comments as [Frequency of Donation from Rx]
--into test.dbo.adhoc_218
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt	
inner join [STAGE].[dbo].STG_RSAPerson per on per.person_id = mkt.personid	
inner join [INTEGRATION].[dbo].INT_DimMotivation m on m.MotivationSK = mkt.MotivationSK	
inner join [INTEGRATION].[dbo].INT_DimLocation l on l.LocationSK = mkt.LocationSK	
left join (select person_id, max(UIDPK) as ud from stage.[dbo].[STG_RSAPrescription] group by person_id) rx on rx.person_id = per.person_id 	
left join  stage.[dbo].[STG_RSAPrescription] rx2 on rx2.UIDPK = rx.ud	
where mkt.CollectionDateSK >= 20170701	
and mkt.MotivationSK in (5, 6) 	and import=0 
--and mkt.LocationSK in (35, 50, 51)	
and l.RegionID = 6	
group by l.RegionID, mkt.personid, isnull(per.FIRST_NAME,'')+' '+ Isnull(per.MIDDLE_INITIAL,'')+' '+Isnull(per.LAST_NAME,''),	
per.Gender, per.DOB, per.Address1, per.Apartment_Number, per.Address2, per.City, per.State, per.Zip, per.Home_Phone, per.Work_Phone, per.Work_Ext,
m.MotivationName, l.FinanceLocationName, rx2.Comments
;