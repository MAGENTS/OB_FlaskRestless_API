	
use tempdb;	
go	
if object_id('tempdb.dbo.#Temp') is not null drop table tempdb.dbo.#Temp	
	
select 	
case when loc.RegionID is null then 'Unmapped' else cast(loc.RegionID as varchar(10)) end as Region,	
loc.FinanceLocationName as LocationName, 	
d.post_phlb_employee_id, 	
e.EmpFullName,	
isnull(per.FIRST_NAME,'')+' '+ Isnull(per.MIDDLE_INITIAL,'')+' '+Isnull(per.LAST_NAME,'') Donor_Name,	
r.REGISTRATION_ID,	
don.UNIT_NUMBER,	
d.Draw_time as CollectionDate,	
m.MachineName, mkt.MachineSerialNo,	
ap.PRT_VOL as [Actual Platelet Volume],	
ap.Platelet_yield as [Actual Platelet Yield], 	
qcp.value as [Actual Platelet Count]	
into tempdb.dbo.#Temp	
from Stage.Dbo.STG_RSARegistration r	
Inner join Stage.Dbo.STG_RSADRAW d on d.REGISTRATION_ID=r.REGISTRATION_ID	
inner join stage.dbo.STG_RSADonation don on don.REGISTRATION_ID=r.REGISTRATION_ID	
inner join STAGE.dbo.stg_rsaperson per on r.PERSON_ID = per.PERSON_ID	
inner join INTEGRATION.dbo.INT_MKTCollectionDetails mkt on mkt.REGISTRATIONID = r.REGISTRATION_ID	
left join INTEGRATION.dbo.INT_DIMMachine m on mkt.MachineID = m.MachineID	
left join Stage.Dbo.STG_RSAPlateletApheresis ap on mkt.registrationID=ap.Registration_id	
left join (select * from stage.dbo.stg_rsaclproductinventory where PRODUCT_CODE ='PLATAPHW') pi on pi.registration_id=ap.Registration_id	
left join stage.dbo.[STG_RSACLQCTestResults] qc on qc.PRODUCT_INVENTORY_ID = pi.PRODUCT_INVENTORY_ID	
	 and qc.BAG_TYPE='Parent Bag' and qc.RESULT<>0
inner join stage.dbo.[STG_RSACLQCproperties] qcp on qcp.qc_test_result_id=qc.qc_test_result_id 	
	and qcp.[KEY] = 'plateletCount' and qcp.value is not null and qcp.value <> ''
	
left join [INTEGRATION].dbo.[INT_DIMLocation] loc on mkt.LocationSK =loc.LocationSK 	
                              and loc.enddate is null 	
left join  [INTEGRATION].dbo.[INT_DIMEmployee] e on e.EmpRSAID = d.post_phlb_employee_id and e.enddate is null	
	
where r.REGISTRATION_DATE>= '2017-10-23' --'2016-05-01' AND r.REGISTRATION_DATE<'2016-11-01'	
ANd r.DONATION_TYPE_ID in (2,5,7,26)	
AND r.MOTIVATION_ID in (2,3)	
AND r.STEP_COMPLETED in (12)	
AND per.FIRST_NAME = 'Kenneth'	
AND per.LAST_NAME = 'Marinetti'	
	
select t.*, tt.Description as TestName, tr.Result as TestResult	
from tempdb.dbo.#Temp t	
left join STAGE.dbo.STG_RSATestResult_Full tr on t.UNIT_NUMBER = tr.unit_number	
left join [INTEGRATION].dbo.[INT_DIMTestTypes] tt on tt.TestID = tr.Test_ID	
