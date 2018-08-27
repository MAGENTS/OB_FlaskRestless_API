		
--drop table #temp		
--drop table #temp1		
		
use tempdb;		
go		
if object_id('tempdb.dbo.#temp') is not null drop table tempdb.dbo.#temp		
if object_id('tempdb.dbo.#temp1') is not null drop table tempdb.dbo.#temp1		
		
select reg.person_id,MAX(reg.REGISTRATION_DATE)REGISTRATION_DATE,COUNT(1)total_platelet_donations 		
		
into #temp1		
from STAGE.dbo.STG_RSARegistration reg		
                     inner join stage.dbo.STG_RSAPerson per on reg.person_id = per.person_id		
where  		
reg.DONATION_TYPE_ID in (2,5,7,26)		
 and STEP_COMPLETED >= 8		
 and per.GENDER in ('m','f')		
 and reg.REGISTRATION_DATE >= '2018-01-01'		
 and reg.REGISTRATION_DATE < '2018-03-09'		
group by reg.person_id		
		
		
select reg.PERSON_ID,		
Isnull(per.Zip,'') as Zip, 		
Cast('' as varchar (250)) Region,		
cast('' as Varchar(250)) location,dt.DESCRIPTION ,reg.BRANCH_ID,		
t1.REGISTRATION_DATE  Donation_Date,t1.total_platelet_donations ,reg.DRIVE_ID,per.GENDER, 		
eth.[Description] as Ethnicity, isnull(per.abo,'')+''+ Isnull(per.rh,'') as BloodType, dt.[Description] as DonationDescription,		
datediff(day, per.DOB, convert(varchar(10), t1.REGISTRATION_DATE, 120))/365 as Age,		
--case when datediff(day, per.DOB, convert(varchar(10), t1.REGISTRATION_DATE, 120))/365 between 16 and 21 then '16-21' end as AgeGroup		
isnull(per.total_donations, 0) + isnull(per.total_donations_other, 0) as LifetimeDonations,		
(isnull(per.total_donations, 0) + isnull(per.total_donations_other, 0) + 		
	case when dr.draw_time is null then 0	
	when dr.machine_id = 12 and dr.draw_time is not null then 1 else 2 end)/8 as GallonLevel,	
null as TotalCenterWalkIn		
into #temp 		
from STAGE.[dbo].[STG_RSARegistration] reg		
inner join STAGE.dbo.stg_rsaperson per on reg.PERSON_ID = per.PERSON_ID		
left join STAGE.dbo.stg_rsadraw dr on reg.registration_id = dr.registration_id		
left outer join STAGE.dbo.STG_RSADrives d on d.DRIVE_ID=reg.DRIVE_ID		
inner Join STAGE.dbo.STG_RSADonationType dt on reg.DONATION_TYPE_ID=dt.DONATION_TYPE_ID		
Inner join #temp1 t1 on reg.PERSON_ID=t1.PERSON_ID and reg.REGISTRATION_DATE=t1.REGISTRATION_DATE		
left join Integration.dbo.INT_DIMEthnicity eth on eth.RSAEthnicID = per.ethnic_id		
		
 where  reg.DONATION_TYPE_ID in (2,5,7,26)		
and STEP_COMPLETED >= 8		
and per.GENDER in ('m','f')		
and reg.REGISTRATION_DATE >= '2018-01-01'		
and reg.REGISTRATION_DATE  < '2018-03-09'		
		
update t Set t.location=lk.FinanceLocationName,		
Region=Case lk.RegionID When 1 Then 'Region 1'		
  When 2 Then 'Region 2' 		
  When 3 Then 'Region 3' 		
  When 4 Then 'Region 4'		
  When 5 Then 'Region 5'		
  When 6 Then 'Region 6'		
  When 7 Then 'Region 7'		
  When 8 Then 'Region 8' END		
from #temp t		
left outer join integration.dbo.INT_DIMLocation lk on  lk.RSALocationID=t.BRANCH_ID		
where t.DRIVE_ID is  null and lk.locationdepartmentname='Center'and	endDate is null	
		
update t Set t.location=lk.FinanceLocationName,		
Region=Case lk.RegionID When 1 Then 'Region 1'		
  When 2 Then 'Region 2' 		
  When 3 Then 'Region 3' 		
  When 4 Then 'Region 4'		
  When 5 Then 'Region 5'		
  When 6 Then 'Region 6'		
  When 7 Then 'Region 7' 		
  When 8 Then 'Region 8'END		
from #temp t		
left outer join STAGE.dbo.STG_RSADriveCollectionArea da on t.DRIVE_ID=da.DRIVE_ID		
left outer join integration.dbo.INT_DIMLocation lk on  lk.RSALocationID=da.DISTRICT_ID		
where t.DRIVE_ID is not null and lk.locationdepartmentname='Mobile'	 and	endDate is null
		
--drop table #temp2		
--drop table #temp3		
--use tempdb;		
		
if object_id('tempdb.dbo.#temp2') is not null drop table tempdb.dbo.#temp2		
select t.Person_ID, count(distinct AppointmentDateSK) as TotalAppts, 		
	count(distinct case when Unitnumber is null then AppointmentDateSK end) as TotalNoShow,	
	count(distinct case when Unitnumber is not null then Unitnumber end) as TotalShow,	
	--null as TotalCenterWalkIn, --0 as AvgTimeBetnAppts	
	count(distinct case when com.communicationMethodID = 2 then com.CampaignFolderID end) as NoEmailsRecd,	
	count(distinct case when com.communicationMethodID = 5 then com.CampaignFolderID end) as NoDirectMailsRecd,	
	count(distinct case when com.communicationMethodID = 25 then com.CampaignFolderID end) as NoTestsRecd,	
	max(du.logins) as NoPortalLogins	
into #temp2		
from #temp t		
left join Integration.dbo.INT_MKTFCTDonorAppointmentDtl dtl on t.Person_ID = dtl.PersonID		
left join work.dbo.[TMP_DonorCamp] com on com.donorexternalkey = t.Person_ID		
left join [STAGE].[dbo].[STG_HTDonorBecs] bec on bec.donor_code = t.Person_ID		
left join stage.[dbo].[STG_HTDonorUsers] du on bec.id = du.becs_id		
where AppointmentDateSK >= 20170822 and AppointmentDateSK < 20180309 and Active = 1		
group by t.Person_ID		
		
if object_id('tempdb.dbo.#temp3') is not null drop table tempdb.dbo.#temp3		
select t2.Person_ID, count(distinct Registration_id) as TotalDon		
into #temp3		
from #temp2 t2 left join STAGE.[dbo].[STG_RSARegistration] r on t2.Person_ID = r.Person_ID		
where registration_date >= '2017-08-22' and REGISTRATION_DATE  < '2018-03-09' --and STEP_COMPLETED >= 12		
		
group by t2.Person_ID		
		
update t set t.TotalCenterWalkIn = isnull(t3.TotalDon, 0) - isnull(t2.TotalShow, 0)		
from #temp t left join #temp2 t2 on t2.Person_Id = t.Person_Id left join #temp3 t3 on t2.Person_Id = t3.Person_Id		
		
if object_id('tempdb.dbo.#temp6') is not null drop table tempdb.dbo.#temp6		
select distinct camp.donorexternalkey, cm.CampignTouchPointName as CampaignTouchPointName, 		
	Cast('' as datetime) as NextDonationDate	
into #temp6		
from work.dbo.[TMP_DonorCamp] camp 		
left join [INTEGRATION].[dbo].[Int_dimcampaignmaster_HT] cm on cm.CampaignMasterSK = camp.CampaignMasterSK		
where cm.CampaignMastersk in (106724,106725,106726,106727)		
		
update #temp6 set NextDonationDate = r.nextDate		
from #temp6 t6 left join 		
(select Person_ID, min(registration_date) as nextDate from STAGE.[dbo].[STG_RSARegistration]		
	where registration_date >= '2018-03-09' group by Person_ID) r on t6.donorexternalkey = r.Person_ID	
		
select t.Person_ID, Donation_Date, Zip, Location, Region, GENDER, Ethnicity, BloodType, total_platelet_donations,		
	DonationDescription, LifetimeDonations, GallonLevel, Age, t2.TotalAppts, t2.TotalNoShow, t2.TotalShow, t.TotalCenterWalkIn,	
	t2.NoEmailsRecd, t2.NoDirectMailsRecd, t2.NoTestsRecd, NoPortalLogins, t6.CampaignTouchPointName, t6.NextDonationDate	
from #temp t left join #temp2 t2 on t.Person_ID = t2.Person_ID		
left join #temp6 t6 on t.Person_ID = t6.donorexternalkey		
order by region	desc	
