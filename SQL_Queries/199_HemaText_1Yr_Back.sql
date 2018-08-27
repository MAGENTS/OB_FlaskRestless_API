		
-- Summary within 7 days		
IF OBJECT_ID('tempdb..#temp2') IS NOT NULL DROP TABLE #temp2		
select distinct convert(varchar(10), c.CampaignSentDate, 120) as CampaignSentDate, cm.MarketingID,		
	count(distinct c.donorid) as TotalNumber,	
	count(distinct case when datediff(day, convert(varchar(10), c.CampaignSentDate, 120), convert(date, convert(varchar(10), fct.CollectionDateSK, 110))) <= 7	
		and datediff(day, convert(varchar(10), c.CampaignSentDate, 120), convert(date, convert(varchar(10), fct.CollectionDateSK, 110))) >= 0
		then fct.RSAPersonID end) as DonatedWithin7Days
into #temp2		
from work.dbo.[TMP_DonorCamp] c		
left join INTEGRATION.dbo.Int_dimcampaignmaster_HT cm on cm.CampaignMastersk = c.CampaignMastersk		
left join INTEGRATION.dbo.INT_DIMCampaignCommunication ccm on ccm.CommunicationMethodID = c.CommunicationMethodID		
left join [INTEGRATION].[dbo].[INT_MKT_FCTCampaignDonationDetail_HT] fct on fct.CampaignMastersk = cm.CampaignMastersk 		
	and fct.RSAPersonID = c.donorexternalkey	
	and c.CampaignFolderID = fct.CampaignFolderID	
where c.CommunicationMethodID = 25		
group by convert(varchar(10), c.CampaignSentDate, 120), cm.MarketingID		
		
-- Summary prior to 1 year and within 7 days		
/*		
select x.CampaignSentDate, x.MarketingID, count(distinct donorid) as TotalNumber,		
	count(distinct x.RSAPersonID) as DonatedPrior1Year,	
	count(distinct case when datediff(day, convert(varchar(10), x.CampaignSentDate, 110), convert(varchar(10), fct2.CollectionDateSK, 110)) <= 7	
		and datediff(day, convert(varchar(10), x.CampaignSentDate, 110), convert(varchar(10), fct2.CollectionDateSK, 110)) >= 0
		then fct2.RSAPersonID end) as DonatedWithin7Days
from (		
select distinct c.CampaignSentDate, cm.MarketingID,		
	c.donorid,	
	case when datediff(day, convert(varchar(10), mkt.CollectionDateSK, 110), convert(varchar(10), c.CampaignSentDate, 110)) > 365	
		
		--then fct.RSAPersonID end as RSAPersonID,
		then mkt.personid end as RSAPersonID,
		
	c.CampaignMastersk, c.CampaignFolderID	
from work.dbo.[TMP_DonorCamp] c		
left join INTEGRATION.dbo.Int_dimcampaignmaster_HT cm on cm.CampaignMastersk = c.CampaignMastersk		
left join INTEGRATION.dbo.INT_DIMCampaignCommunication ccm on ccm.CommunicationMethodID = c.CommunicationMethodID		
left join [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt on mkt.personid = c.donorexternalkey		
/*left join [INTEGRATION].[dbo].[INT_MKT_FCTCampaignDonationDetail_HT] fct on fct.CampaignMastersk = cm.CampaignMastersk 		
	and fct.RSAPersonID = c.donorexternalkey	
	and c.CampaignFolderID = fct.CampaignFolderID	*/
where c.CommunicationMethodID = 25		
) x		
left join [INTEGRATION].[dbo].[INT_MKT_FCTCampaignDonationDetail_HT] fct2 on fct2.CampaignMastersk = x.CampaignMastersk 		
	and fct2.RSAPersonID = x.RSAPersonID	
	and x.CampaignFolderID = fct2.CampaignFolderID	
	and x.RSAPersonID is not null	
group by x.CampaignSentDate, x.MarketingID		
*/		
		
		
IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp		
select distinct convert(varchar(10), c.CampaignSentDate, 120) as CampSentDate, mkt.personid, cm.MarketingID, 		
	max(convert(date, convert(varchar(10), mkt.CollectionDateSK, 120))) as LastDonation	
into #temp		
from work.dbo.[TMP_DonorCamp] c		
left join INTEGRATION.dbo.Int_dimcampaignmaster_HT cm on cm.CampaignMastersk = c.CampaignMastersk		
left join [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt on mkt.personid = c.donorexternalkey		
where c.CommunicationMethodID = 25		
and convert(date, convert(varchar(10), mkt.CollectionDateSK, 120)) < convert(varchar(10), c.CampaignSentDate, 120)		
group by convert(varchar(10), c.CampaignSentDate, 120), mkt.personid,  cm.MarketingID		
		
/*		
delete from #temp 		
where personid in (select personid from #temp t1		
	where datediff(day, t1.LastDonation, t1.CampSentDate) <= 365)*/	
		
delete from #temp		
where datediff(day, LastDonation, CampSentDate) <= 365		
		
IF OBJECT_ID('tempdb..#temp3') IS NOT NULL DROP TABLE #temp3		
select t.CampSentDate, t.MarketingID, --count(distinct c.donorexternalkey) as TotalNumber, 		
	count(distinct t.personid) as DonatedPrior1Year,	
	count(distinct case when datediff(day, convert(varchar(10), t.CampSentDate, 120), convert(date, convert(varchar(10), fct2.CollectionDateSK, 120))) <= 7	
		and datediff(day, convert(varchar(10), CampSentDate, 120), convert(date, convert(varchar(10), fct2.CollectionDateSK, 120))) >= 0
		then t.personid end) as DonatedWithin7Days
into #temp3		
from #temp t		
--from work.dbo.[TMP_DonorCamp] c		
--left join #temp t on t.personid = c.donorexternalkey		
left join [INTEGRATION].[dbo].[INT_MKT_FCTCampaignDonationDetail_HT] fct2 on --fct2.CampaignMastersk = c.CampaignMastersk 			
	fct2.RSAPersonID = t.personid	
group by t.CampSentDate, t.MarketingID		
		
		
select distinct t2.*, t3.DonatedPrior1Year, t3.DonatedWithin7Days		
from #temp2 t2		
left join #temp3 t3 on t2.CampaignSentDate = t3.CampSentDate and t2.MarketingID = t3.MarketingID		
