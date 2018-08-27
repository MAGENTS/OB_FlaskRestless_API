	
IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp	
select x.*, max(r3.registration_date) as last_platelet_donation, max(r4.registration_date) as last_RBC_donation, 	
	0 as center_donations, 0 as mobile_donations, 0 as deferrals, 
	0 as texts_received, 0 as emails_received, 0 as direct_mail_received
into tempdb.dbo.#temp	
from (	
select distinct per.Person_ID, p.City, p.State, p.Zip, p.Gender, eth.Description as Ethnicity,	
	count(distinct r.REGISTRATION_ID) as total_platelet_donations,
	count(distinct r2.REGISTRATION_ID) as total_RBC_donations
from Test.dbo.adhoc198Per per	
left join Stage.Dbo.STG_RSARegistration r on r.person_id=per.person_id 	
	and r.DONATION_TYPE_ID in (2, 5, 7, 26) and r.STEP_COMPLETED in (8, 12)
left join Stage.Dbo.STG_RSARegistration r2 on r2.person_id=per.person_id 	
	and r2.DONATION_TYPE_ID in (1, 3, 38, 37) and r2.STEP_COMPLETED in (8, 12)
left join Stage.Dbo.stg_rsaPerson p on per.person_id=p.person_id	
	
left join INTEGRATION.dbo.INT_MKTCollectionDetails mkt on mkt.personid=per.person_id-- mkt.REGISTRATIONID = r.REGISTRATION_ID	
left join [INTEGRATION].dbo.[INT_DIMLocation] loc on mkt.LocationSK =loc.LocationSK --and loc.enddate is null	
left join [INTEGRATION].[dbo].INT_DIMEthnicity eth on eth.rsaethnicid = p.ethnic_id --eth.EthnicSK = mkt.EthnicSK	
group by per.Person_ID, p.City, p.State, p.Zip, p.Gender, eth.Description	
) x	
left join Stage.Dbo.STG_RSARegistration r3 on r3.person_id=x.person_id 	
	and r3.DONATION_TYPE_ID in (2, 5, 7, 26) and r3.STEP_COMPLETED in (8, 12)
left join Stage.Dbo.STG_RSARegistration r4 on r4.person_id=x.person_id 	
	and r4.DONATION_TYPE_ID in (1, 3, 38, 37) and r4.STEP_COMPLETED in (8, 12)
group by x.Person_ID, x.City, x.State, x.Zip, x.Gender, x.Ethnicity, x.total_platelet_donations, x.total_RBC_donations	
	
	
IF OBJECT_ID('tempdb..#temp2') IS NOT NULL DROP TABLE #temp2	
select t.person_id, 	
	count(distinct case when r5.branch_id is not null  then r5.REGISTRATION_ID end) as cd,
	count(distinct case when r5.drive_id is not null  then r5.REGISTRATION_ID end) as md,
	count(distinct case when df.DeferralType = 'H' or df.DeferralType = 'P' then r5.REGISTRATION_ID end) as nd
into tempdb.dbo.#temp2	
from #temp t	
left join Stage.Dbo.STG_RSARegistration r5 on r5.person_id=t.person_id 	
	and r5.DONATION_TYPE_ID in (2, 5, 7, 26, 1, 3, 38, 37) and r5.STEP_COMPLETED in (8, 12)
left join STAGE.dbo.STG_RSA_DonorDeferral dd on r5.registration_id = dd.registration_id	
left join INTEGRATION.dbo.INT_DIMDeferral df on dd.Deferral_Code = df.DeferralCode	
group by t.person_id	
	
update #temp set center_donations = t2.cd, mobile_donations = t2.md, deferrals = t2.nd	
from #temp t left join #temp2 t2 on t.person_id = t2.person_id	
	
IF OBJECT_ID('tempdb..#temp3') IS NOT NULL DROP TABLE #temp3	
select t.person_id,	
	count(distinct case when CommunicationMethodID = 25 then CampaignMastersk end) as tr,
	count(distinct case when CommunicationMethodID = 2 then CampaignMastersk end) as er,
	count(distinct case when CommunicationMethodID = 5 then CampaignMastersk end) as dr
into tempdb.dbo.#temp3	
from #temp t	
left join work.dbo.[TMP_DonorCamp] c on c.donorexternalkey=t.person_id 	
group by t.person_id	
	
update #temp set texts_received = t3.tr, emails_received = t3.er, direct_mail_received = t3.dr	
from #temp t left join #temp3 t3 on t.person_id = t3.person_id	
	
select * from #temp	
