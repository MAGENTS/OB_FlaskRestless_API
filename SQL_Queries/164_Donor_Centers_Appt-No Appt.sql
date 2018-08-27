
-------- Donor with Appointments----------------------------------
IF OBJECT_ID('tempdb..#TempWithApp') IS NOT NULL
    DROP TABLE #TempWithApp
 (Select 
     mkt.CollectionDetailSK
    ,mkt.DonationTypeSK
    ,mkt.CollectionDateSK
    ,mkt.LocationSK
    ,mkt.motivationsk
    ,mkt.personid
    ,mkt.registrationID
    ,mkt.UnitNumber
    ,mkt.StagingAreaSK
 ,'With Appointment' [Appointment Type]
 into #TempWithApp
 from INTEGRATION.[dbo].[INT_MKTCollectionDetails] mkt
   inner join INTEGRATION.dbo.INT_MKTFCTDonorAppointmentDtl da on da.PersonID = mkt.personid and mkt.CollectionDateSK = da.AppointmentDateSk
   inner join INTEGRATION.dbo.INT_DIMLocation loc on mkt.locationsk = loc.locationsk 
 where mkt.CollectionDateSK >= 20160101 and mkt.CollectionDateSK < 20180101
   --mkt.CollectionDateSK =20180403
   and cast(ApptDateTime as date) >= '2016-01-01' and cast(ApptDateTime as date) < '2018-01-01'
   --= '2018-04-03'
   and loc.LocationdepartmentNumber = 2820
   and da.Active = 1
   ---and da.DonorPresented = 1 
   --and Appointmentcancelled =1
)

------------------Donor without Appointments ------------------------------------------
IF OBJECT_ID('tempdb..#Temp_without') IS NOT NULL
    DROP TABLE #Temp_without

Select 
   m.CollectionDetailSK
    ,m.DonationTypeSK
    ,m.CollectionDateSK
    ,m.LocationSK
    ,m.motivationsk
    ,m.personid
    ,m.registrationID
    ,m.UnitNumber
    ,m.StagingAreaSK
 ,'Without Appointment' [Appointment Type]
   into #Temp_without
 from  INTEGRATION.[dbo].[INT_MKTCollectionDetails] m 
   inner join INTEGRATION.dbo.INT_DIMLocation l on m.locationsk = l.locationsk
where  m.CollectionDateSK >= 20160101 and m.CollectionDateSK < 20180101
   and l.LocationdepartmentNumber = 2820 
   and m.registrationID not in (Select registrationID from #TempWithApp)

---------------------------Data with and without appointments -----------------------------------
IF OBJECT_ID('tempdb..#TempMain') IS NOT NULL
    DROP TABLE #TempMain   

Select * into #TempMain
from (
Select * from #TempWithApp
Union All
Select * from #Temp_without
) xyz

select count(*) from #TempMain
------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Donorlist') IS NOT NULL
    DROP TABLE #Donorlist          
select distinct Person_id into #Donorlist from [STAGE].dbo.[STG_RSARegistration]
where REGISTRATION_DATE < '2016-01-01'




IF OBJECT_ID('tempdb..#Firsttimedonor_1') IS NOT NULL
    DROP TABLE #Firsttimedonor_1  
select *,ROW_NUMBER() OVER(PARTITION by Personid ORDER BY CollectiondateSK) [DonorStatus] into #Firsttimedonor_1
 from #TempMain
where personid not in (select Person_id  from #Donorlist )
 

-------- Final firsttime donors -----------------------------------
IF OBJECT_ID('tempdb..#First_Main') IS NOT NULL
    DROP TABLE #First_Main  
Select * into #First_Main from #Firsttimedonor_1
where DonorStatus = 1

------------- Not first time donors--------------------------------
IF OBJECT_ID('tempdb..#NotFirst') IS NOT NULL
    DROP TABLE #NotFirst  
Select * into #NotFirst
from #TempMain
where UnitNumber not in (select unitnumber from #First_Main)


------------------------- #Maintemp Output --------------------------------------------------------------------------

Select * into #MainTemp from
(
Select * from #First_Main
union all 
Select *, 0 [DonorStatus] from #NotFirst
) xyz

--------------------------------------------- output ------------------------------------------------------

Select 
  dt.Month,
  dt.Monthname,
  dt.Year,
  dt.[Date],
  --loc.RegionID,
  Case When loc.RegionID=1 then 'Region1'
  When loc.RegionID=2 then 'Region2'
  When loc.RegionID=3 then 'Region3'
  When loc.RegionID=4 then 'Region4'
  When loc.RegionID=5 then 'Region5'
  When loc.RegionID=6 then 'Region6'
  When loc.RegionID=7 then 'Region7'
  When loc.RegionID=8 then 'Region8'
  Else 'Null' END Region,
  loc.FinanceLocationName,
  registrationID,
  UnitNumber,
  mkt.personid PesrsonID,
  ddt.DonationDescription,
  dm.MotivationName,
  [Appointment Type],
  [DonorStatus]
   from #MainTemp mkt
  left join INTEGRATION.[dbo].[Int_DimDonationType] ddt on ddt.DonationTypeSk = mkt.DonationTypeSK
  left join INTEGRATION.[dbo].[INT_DIMMotivation] dm on dm.MotivationSK = mkt.motivationsk
  left join INTEGRATION.[dbo].[INT_DIMLocation] loc on loc.LocationSK = mkt.LocationSK
  Inner join INTEGRATION.[dbo].[DimDate] dt on dt.DateKey=mkt.CollectionDateSK
  --Group by 
  --dt.Month,
  --dt.Monthname,
  --dt.Year,
  --loc.RegionID,
  --loc.FinanceLocationName,
  --ddt.DonationDescription,
  --dm.MotivationName,
  --[Appointment Type]