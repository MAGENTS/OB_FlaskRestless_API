			
select distinct c.CampaignSentDate, cm.MarketingID, cm.CampaignName, cm.CampignTouchPointName as CampaignTouchPointName, 			
	ccm.Name as CommunicationType, --c.donorexternalkey as PersonID,		
	count(distinct c.donorid) as TotalNumber,		
	count(distinct case when datediff(day, convert(varchar(10), c.CampaignSentDate, 110), convert(varchar(10), fct.CollectionDateSK, 110)) <= 7		
		and datediff(day, convert(varchar(10), c.CampaignSentDate, 110), convert(varchar(10), fct.CollectionDateSK, 110)) >= 0	
		then fct.RSAPersonID end) as DonatedWithin7Days	
from work.dbo.[TMP_DonorCamp] c			
left join INTEGRATION.dbo.Int_dimcampaignmaster_HT cm on cm.CampaignMastersk = c.CampaignMastersk			
left join INTEGRATION.dbo.INT_DIMCampaignCommunication ccm on ccm.CommunicationMethodID = c.CommunicationMethodID			
			
left join [INTEGRATION].[dbo].[INT_MKT_FCTCampaignDonationDetail_HT] fct on fct.CampaignMastersk = cm.CampaignMastersk 			
	and fct.RSAPersonID = c.donorexternalkey		
	and c.CampaignFolderID = fct.CampaignFolderID		
where c.campaignsentdate >= '2018-04-01' and c.campaignsentdate < '2018-06-11'			
--and cm.MarketingID = '107434'			
group by c.CampaignSentDate, cm.MarketingID, cm.CampaignName, cm.CampignTouchPointName, ccm.Name			
			
			
			
IF OBJECT_ID('tempdb..#stg_rsaperson') IS NOT NULL			
      DROP TABLE #stg_rsaperson			
			
select distinct c.donorexternalkey as PersonID, Min(Reg.REGISTRATION_DATE) as MIN_REGISTRATION_DATE			
into #stg_rsaperson			
from work.dbo.[TMP_DonorCamp] c			
inner join STAGE.dbo.STG_RSARegistration reg on reg.person_id = c.donorexternalkey			
where c.campaignsentdate >= '2018-04-01' and c.campaignsentdate < '2018-06-11'			
Group by c.donorexternalkey			
			
select distinct r.PersonID, 			
	fct.Gender, datediff(day,  fct.DateofBirth, convert(char(8), fct.CollectionDateSK, 112))/365 as Age,		
	eth.Description as Ethnicity, p.Address1, p.Address2, p.Zip,		
	isnull(bt.abo, '') + ' ' + isnull(bt.rh, '') as BloodType, 		
	isnull(p.total_donations, 0) + isnull(p.total_donations_other, 0) as LifetimeDonations,		
	case when (r.MIN_REGISTRATION_DATE >= '2018-04-01' and r.MIN_REGISTRATION_DATE < '2018-06-11')		
		--and (r.MAX_REGISTRATION_DATE >= '2018-03-01' and r.MAX_REGISTRATION_DATE < '2018-04-01') 	
		then 1 else 0 end as FirstTimeDonor,	
	--convert(varchar(10), fct.CollectionDateSK, 110) as CollectionDate,		
			
		--	and datediff(day, convert(varchar(10), c.CampaignSentDate, 110), convert(varchar(10), fct.CollectionDateSK, 110)) >= 0
			
	convert(datetime, convert(varchar(10), fct.CollectionDateSK, 110)) as CollectionDate,		
	Case l.RegionID When 1 Then 'Region 1' When 2 Then 'Region 2' When 3 Then 'Region 3' When 4 Then 'Region 4' When 5 Then 'Region 5'		
		When 6 Then 'Region 6' When 7 Then 'Region 7' When 8 Then 'Region 8' END as Region, 	
	l.FinanceLocationName, l.LocationDepartmentName, am.AccountName, am.AffiliationName,		
	dt.DonationDescription, fct.CompletedFlag, m.MotivationName as Motivation,		
	case when l.LocationDepartmentName = 'Center' then l.ZipCode else mkt.AccountZipCode end as DonationLocationZipCode		
from work.dbo.[TMP_DonorCamp] c			
inner join tempdb..#stg_rsaperson r on r.PersonID = c.donorexternalkey	 --p.Person_ID		
inner join INTEGRATION.dbo.Int_dimcampaignmaster_HT cm on cm.CampaignMastersk = c.CampaignMastersk			
inner join [INTEGRATION].[dbo].[INT_MKT_FCTCampaignDonationDetail_HT] fct on fct.RSAPersonID = c.donorexternalkey --cm.CampaignMastersk = fct.CampaignMastersk --			
	and fct.CollectionDateSK is not null		
left join INTEGRATION.dbo.INT_MKTCollectionDetails mkt on mkt.UnitNumber = fct.UnitNumber			
left join [INTEGRATION].[dbo].INT_DIMEthnicity eth on eth.EthnicSK = fct.EthnicSK			
left join [INTEGRATION].[dbo].INT_DIMBloodType bt on bt.BloodTypeSK = fct.BloodTypeSK			
left join INTEGRATION.dbo.INT_DimLocation l on l.LocationSK = fct.LocationSK			
left join stage.dbo.STG_RSARegistrationPersonArchive p on p.registration_id = mkt.registrationid --p.Person_ID = r.Person_ID			
left join integration.dbo.Int_DimDonationType dt on dt.DonationTypeSK=fct.DonationTypeSK			
left join INTEGRATION.dbo.INT_DIMAccountAffiliationMaster am on am.AccountAffiliationSK = fct.AccountAffiliationSK			
left join INTEGRATION.dbo.INT_DimMotivation m on m.MotivationSK = fct.MotivationSK			
where c.campaignsentdate >= '2018-04-01' and c.campaignsentdate < '2018-06-11'			
and fct.CollectionDateSK >= 20180401 and fct.CollectionDateSK < 20180611			
