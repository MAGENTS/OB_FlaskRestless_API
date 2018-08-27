Select							
Cast(dt.date as Date) [Date],
dt.weekofMonth WeekofMonth,
dt.WeekOfYear,
dt.MonthName,
dt.Year,
Concat('Region ',loc.Regionid) as Region,
loc.[LocationDepartmentName],
Loc.FinanceLocationName,
count(*) as Procedures
From[INTEGRATION].[dbo].[INT_MKTCollectionDetails] mkt
left join [INTEGRATION].[dbo].[INT_DIMLocation] loc on loc.locationsk = mkt.locationsk
left join [INTEGRATION].[dbo].[Int_DimDonationType] DDT on DDT.DonationTypeSk =mkt.DonationTypeSK
inner join [INTEGRATION].[dbo].[DimDate] dt on mkt.collectiondatesk = dt.datekey
Where		
mkt.motivationsk = 4
--and loc.FinanceLocationName in ('Boca Raton Donor Center','Lantana Donor Center','Coral Springs Donor Center','Ft. Lauderdale-Commercial Donor Center','Plantation Donor Center','Pompano Beach Donor Center') 
and mkt.CollectionDatesk >= 20170101 and CollectionDateSK < 20180101 
--and mkt.DonationTypeSK in (1,3,43,44)
Group by 		
dt.date,
dt.weekofMonth,
dt.WeekOfYear,
dt.MonthName,
dt.Year,
loc.Regionid,
loc.[LocationDepartmentName],
Loc.FinanceLocationName
