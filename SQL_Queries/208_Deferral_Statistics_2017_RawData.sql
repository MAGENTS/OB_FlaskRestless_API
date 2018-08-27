			
			
			
--driveid 2163360			
			
use stage			
			
IF OBJECT_ID('tempdb..#Reg') IS NOT NULL			
    DROP TABLE #Reg			
			
			
select distinct 			
			
qcr.DescShort as Region,			
			
mkt.DriveID as RSADriveID,			
sht.DriveID as HemaDriveID,			
DriveName,			
--l.FinanceLocationName as [LocationName], 			
EmpFullName as TeamLeaderName,			
ppl.FullName as AccountRepName,			
mkt.AccountInternalName,			
			
			
cast(FromDateTime as date) as DriveDate,			
RIGHT('0'+CAST(DATEPART(hour, sht.ShiftStart) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftStart)as varchar(2)),2) as DriveStartime,			
RIGHT('0'+CAST(DATEPART(hour, sht.ShiftEnd) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftEnd)as varchar(2)),2) as DriveEndtime,			
			
      			
			
		count(mkt.registrationid) as TotalReg,	
		count(case when CompletedFlag<12 and postphlebempid is null	 then 1 end) as [TotalDef],
			
		count(case when cast(r.registration_date as time) < RIGHT('0'+CAST(DATEPART(hour, sht.ShiftStart) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftStart)as varchar(2)),2)  then 1 end) as [Before Drive Start Reg],	
		count(case when cast(r.registration_date as time) < RIGHT('0'+CAST(DATEPART(hour, sht.ShiftStart) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftStart)as varchar(2)),2)  and CompletedFlag<12 and postphlebempid is null then 1 end) as [Before Drive Start Def],	
			
			
		count(case when cast(r.registration_date as time) >= RIGHT('0'+CAST(DATEPART(hour, sht.ShiftStart) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftStart)as varchar(2)),2) and cast(r.registration_date as time) < RIGHT('0'+CAST(DATEPART(hour, DATEADD(HOUR,-1,sht.ShiftEnd)) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, DATEADD(HOUR,-1,sht.ShiftEnd))as varchar(2)),2) then 1 end) as [All Day Reg Except Last Hour],	
		count(case when cast(r.registration_date as time) >= RIGHT('0'+CAST(DATEPART(hour, sht.ShiftStart) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftStart)as varchar(2)),2) and cast(r.registration_date as time) < RIGHT('0'+CAST(DATEPART(hour, DATEADD(HOUR,-1,sht.ShiftEnd)) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, DATEADD(HOUR,-1,sht.ShiftEnd))as varchar(2)),2)  and CompletedFlag<12 and postphlebempid is null then 1 end) as [All Day Def Except Last Hour],	
			
		count(case when cast(r.registration_date as time) >= RIGHT('0'+CAST(DATEPART(hour, DATEADD(HOUR,-1,sht.ShiftEnd)) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, DATEADD(HOUR,-1,sht.ShiftEnd))as varchar(2)),2) and cast(r.registration_date as time) <= RIGHT('0'+CAST(DATEPART(hour, sht.ShiftEnd) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftEnd)as varchar(2)),2) then 1 end) as [Last Hour Reg],	
		count(case when cast(r.registration_date as time) >= RIGHT('0'+CAST(DATEPART(hour, DATEADD(HOUR,-1,sht.ShiftEnd)) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, DATEADD(HOUR,-1,sht.ShiftEnd))as varchar(2)),2) and cast(r.registration_date as time) <= RIGHT('0'+CAST(DATEPART(hour, sht.ShiftEnd) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftEnd)as varchar(2)),2)  and CompletedFlag<12 and postphlebempid is null then 1 end) as [Last Hour Def],	
			
		count(case when cast(r.registration_date as time) >= RIGHT('0'+CAST(DATEPART(hour, DATEADD(minute,-30,sht.ShiftEnd)) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, DATEADD(minute,-30,sht.ShiftEnd))as varchar(2)),2) and cast(r.registration_date as time) <= RIGHT('0'+CAST(DATEPART(hour, sht.ShiftEnd) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftEnd)as varchar(2)),2) then 1 end) as [Last 30 Min Reg],	
		count(case when cast(r.registration_date as time) >= RIGHT('0'+CAST(DATEPART(hour, DATEADD(minute,-30,sht.ShiftEnd)) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, DATEADD(minute,-30,sht.ShiftEnd))as varchar(2)),2) and cast(r.registration_date as time) <= RIGHT('0'+CAST(DATEPART(hour, sht.ShiftEnd) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftEnd)as varchar(2)),2)  and CompletedFlag<12 and postphlebempid is null then 1 end) as [Last 30 Min Def],	
			
		count(case when cast(r.registration_date as time) > RIGHT('0'+CAST(DATEPART(hour, sht.ShiftEnd) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftEnd)as varchar(2)),2)  then 1 end) as [After Drive End Reg],	
		count(case when cast(r.registration_date as time) > RIGHT('0'+CAST(DATEPART(hour, sht.ShiftEnd) as varchar(2)),2) + ':' +  RIGHT('0'+CAST(DATEPART(minute, sht.ShiftEnd)as varchar(2)),2)  and CompletedFlag<12 and postphlebempid is null then 1 end) as [After Drive End Def],	
			
			
			
		--count(case when cast(r.registration_date as time) < '16:00'  then 1 end) as [Before Drive Start Reg],	
		--count(case when cast(r.registration_date as time) >='16:00' and cast(r.registration_date as time) <   '19:30'  then 1 end) as [All Day Reg Except Last Hour],	
		--count(case when cast(r.registration_date as time) >= '19:30' and cast(r.registration_date as time) <='20:30' then 1 end) as [Last Hour Reg],	
		--count(case when cast(r.registration_date as time) >='20:00' and cast(r.registration_date as time) <= '20:30' then 1 end) as [Last 30 Min Reg],	
		--count(case when cast(r.registration_date as time) > '20:30'  then 1 end) as [After Drive End Reg],	
			
			
			
			
		count(case when cast(r.registration_date as time) >= '00:00:00' and cast(r.registration_date as time) < '00:30:00' then 1 end) as [Total Reg at 12:30am],	
		count(case when cast(r.registration_date as time) >= '00:00:00' and cast(r.registration_date as time) < '00:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 12:30am],	
			
		count(case when cast(r.registration_date as time) >= '00:30:00' and cast(r.registration_date as time) < '01:00:00' then 1 end) as [Total Reg at 1:00am],	
		count(case when cast(r.registration_date as time) >= '00:30:00' and cast(r.registration_date as time) < '01:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 1:00am],	
			
		count(case when cast(r.registration_date as time) >= '01:00:00' and cast(r.registration_date as time) < '01:30:00' then 1 end) as [Total Reg at 1:30am],	
		count(case when cast(r.registration_date as time) >= '01:00:00' and cast(r.registration_date as time) < '01:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 1:30am],	
			
		count(case when cast(r.registration_date as time) >= '01:30:00' and cast(r.registration_date as time) < '02:00:00' then 1 end) as [Total Reg at 2:00am],	
		count(case when cast(r.registration_date as time) >= '01:30:00' and cast(r.registration_date as time) < '02:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 2:00am],	
			
		count(case when cast(r.registration_date as time) >= '02:00:00' and cast(r.registration_date as time) < '02:30:00' then 1 end) as [Total Reg at 2:30am],	
		count(case when cast(r.registration_date as time) >= '02:00:00' and cast(r.registration_date as time) < '02:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 2:30am],	
			
		count(case when cast(r.registration_date as time) >= '02:30:00' and cast(r.registration_date as time) < '03:00:00' then 1 end) as [Total Reg at 3:00am],	
		count(case when cast(r.registration_date as time) >= '02:30:00' and cast(r.registration_date as time) < '03:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 3:00am],	
			
		count(case when cast(r.registration_date as time) >= '03:00:00' and cast(r.registration_date as time) < '03:30:00' then 1 end) as [Total Reg at 3:30am],	
		count(case when cast(r.registration_date as time) >= '03:00:00' and cast(r.registration_date as time) < '03:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 3:30am],	
			
		count(case when cast(r.registration_date as time) >= '03:30:00' and cast(r.registration_date as time) < '04:00:00' then 1 end) as [Total Reg at 4:00am],	
		count(case when cast(r.registration_date as time) >= '03:30:00' and cast(r.registration_date as time) < '04:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 4:00am],	
			
		count(case when cast(r.registration_date as time) >= '04:00:00' and cast(r.registration_date as time) < '04:30:00' then 1 end) as [Total Reg at 4:30am],	
		count(case when cast(r.registration_date as time) >= '04:00:00' and cast(r.registration_date as time) < '04:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 4:30am],	
			
		count(case when cast(r.registration_date as time) >= '04:30:00' and cast(r.registration_date as time) < '05:00:00' then 1 end) as [Total Reg at 5:00am],	
		count(case when cast(r.registration_date as time) >= '04:30:00' and cast(r.registration_date as time) < '05:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 5:00am],	
			
		count(case when cast(r.registration_date as time) >= '05:00:00' and cast(r.registration_date as time) < '05:30:00' then 1 end) as [Total Reg at 5:30am],	
		count(case when cast(r.registration_date as time) >= '05:00:00' and cast(r.registration_date as time) < '05:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 5:30am],	
			
		count(case when cast(r.registration_date as time) >= '05:30:00' and cast(r.registration_date as time) < '06:00:00' then 1 end) as [Total Reg at 6:00am],	
		count(case when cast(r.registration_date as time) >= '05:30:00' and cast(r.registration_date as time) < '06:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 6:00am],	
			
		count(case when cast(r.registration_date as time) >= '06:00:00' and cast(r.registration_date as time) < '06:30:00' then 1 end) as [Total Reg at 6:30am],	
		count(case when cast(r.registration_date as time) >= '06:00:00' and cast(r.registration_date as time) < '06:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 6:30am],	
			
		count(case when cast(r.registration_date as time) >= '06:30:00' and cast(r.registration_date as time) < '07:00:00' then 1 end) as [Total Reg at 7:00am],	
		count(case when cast(r.registration_date as time) >= '06:30:00' and cast(r.registration_date as time) < '07:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 7:00am],	
			
		count(case when cast(r.registration_date as time) >= '07:00:00' and cast(r.registration_date as time) < '07:30:00' then 1 end) as [Total Reg at 7:30am],	
		count(case when cast(r.registration_date as time) >= '07:00:00' and cast(r.registration_date as time) < '07:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 7:30am],	
			
		count(case when cast(r.registration_date as time) >= '07:30:00' and cast(r.registration_date as time) < '08:00:00' then 1 end) as [Total Reg at 8:00am],	
		count(case when cast(r.registration_date as time) >= '07:30:00' and cast(r.registration_date as time) < '08:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 8:00am],	
			
		count(case when cast(r.registration_date as time) >= '08:00:00' and cast(r.registration_date as time) < '08:30:00' then 1 end) as [Total Reg at 8:30am],	
		count(case when cast(r.registration_date as time) >= '08:00:00' and cast(r.registration_date as time) < '08:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 8:30am],	
			
		count(case when cast(r.registration_date as time) >= '08:30:00' and cast(r.registration_date as time) < '09:00:00' then 1 end) as [Total Reg at 9:00am],	
		count(case when cast(r.registration_date as time) >= '08:30:00' and cast(r.registration_date as time) < '09:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 9:00am],	
			
		count(case when cast(r.registration_date as time) >= '09:00:00' and cast(r.registration_date as time) < '09:30:00' then 1 end) as [Total Reg at 9:30am],	
		count(case when cast(r.registration_date as time) >= '09:00:00' and cast(r.registration_date as time) < '09:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 9:30am],	
			
		count(case when cast(r.registration_date as time) >= '09:30:00' and cast(r.registration_date as time) < '10:00:00' then 1 end) as [Total Reg at 10:00am],	
		count(case when cast(r.registration_date as time) >= '09:30:00' and cast(r.registration_date as time) < '10:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 10:00am],	
			
		count(case when cast(r.registration_date as time) >= '10:00:00' and cast(r.registration_date as time) < '10:30:00' then 1 end) as [Total Reg at 10:30am],	
		count(case when cast(r.registration_date as time) >= '10:00:00' and cast(r.registration_date as time) < '10:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 10:30am],	
			
		count(case when cast(r.registration_date as time) >= '10:30:00' and cast(r.registration_date as time) < '11:00:00' then 1 end) as [Total Reg at 11:00am],	
		count(case when cast(r.registration_date as time) >= '10:30:00' and cast(r.registration_date as time) < '11:00:00'  and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 11:00am],	
			
		count(case when cast(r.registration_date as time) >= '11:00:00' and cast(r.registration_date as time) < '11:30:00' then 1 end) as [Total Reg at 11:30am],	
		count(case when cast(r.registration_date as time) >= '11:00:00' and cast(r.registration_date as time) < '11:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 11:30am],	
			
		count(case when cast(r.registration_date as time) >= '11:30:00' and cast(r.registration_date as time) < '12:00:00' then 1 end) as [Total Reg at 12:00pm],	
		count(case when cast(r.registration_date as time) >= '11:30:00' and cast(r.registration_date as time) < '12:00:00'  and CompletedFlag<12 and postphlebempid is null then  1 end) as [Total Def at 12:00pm],	
			
		count(case when cast(r.registration_date as time) >= '12:00:00' and cast(r.registration_date as time) < '12:30:00' then 1 end) as [Total Reg at 12:30pm],	
		count(case when cast(r.registration_date as time) >= '12:00:00' and cast(r.registration_date as time) < '12:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 12:30pm],	
			
		count(case when cast(r.registration_date as time) >= '12:30:00' and cast(r.registration_date as time) < '13:00:00' then 1 end) as [Total Reg at 1:00pm],	
		count(case when cast(r.registration_date as time) >= '12:30:00' and cast(r.registration_date as time) < '13:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 1:00pm],	
			
		count(case when cast(r.registration_date as time) >= '13:00:00' and cast(r.registration_date as time) < '13:30:00' then 1 end) as [Total Reg at 1:30pm],	
		count(case when cast(r.registration_date as time) >= '13:00:00' and cast(r.registration_date as time) < '13:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 1:30pm],	
			
		count(case when cast(r.registration_date as time) >= '13:30:00' and cast(r.registration_date as time) < '14:00:00' then 1 end) as [Total Reg at 2:00pm],	
		count(case when cast(r.registration_date as time) >= '13:30:00' and cast(r.registration_date as time) < '14:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 2:00pm],	
			
		count(case when cast(r.registration_date as time) >= '14:00:00' and cast(r.registration_date as time) < '14:30:00' then 1 end) as [Total Reg at 2:30pm],	
		count(case when cast(r.registration_date as time) >= '14:00:00' and cast(r.registration_date as time) < '14:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 2:30pm],	
			
		count(case when cast(r.registration_date as time) >= '14:30:00' and cast(r.registration_date as time) < '15:00:00' then 1 end) as [Total Reg at 3:00pm],	
		count(case when cast(r.registration_date as time) >= '14:30:00' and cast(r.registration_date as time) < '15:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 3:00pm],	
			
		count(case when cast(r.registration_date as time) >= '15:00:00' and cast(r.registration_date as time) < '15:30:00' then 1 end) as [Total Reg at 3:30pm],	
		count(case when cast(r.registration_date as time) >= '15:00:00' and cast(r.registration_date as time) < '15:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 3:30pm],	
			
		count(case when cast(r.registration_date as time) >= '15:30:00' and cast(r.registration_date as time) < '16:00:00' then 1 end) as [Total Reg at 4:00pm],	
		count(case when cast(r.registration_date as time) >= '15:30:00' and cast(r.registration_date as time) < '16:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 4:00pm],	
			
		count(case when cast(r.registration_date as time) >= '16:00:00' and cast(r.registration_date as time) < '16:30:00' then 1 end) as [Total Reg at 4:30pm],	
		count(case when cast(r.registration_date as time) >= '16:00:00' and cast(r.registration_date as time) < '16:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 4:30pm],	
			
		count(case when cast(r.registration_date as time) >= '16:30:00' and cast(r.registration_date as time) < '17:00:00' then 1 end) as [Total Reg at 5:00pm],	
		count(case when cast(r.registration_date as time) >= '16:30:00' and cast(r.registration_date as time) < '17:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 5:00pm],	
			
		count(case when cast(r.registration_date as time) >= '17:00:00' and cast(r.registration_date as time) < '17:30:00' then 1 end) as [Total Reg at 5:30pm],	
		count(case when cast(r.registration_date as time) >= '17:00:00' and cast(r.registration_date as time) < '17:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 5:30pm],	
			
		count(case when cast(r.registration_date as time) >= '17:30:00' and cast(r.registration_date as time) < '18:00:00' then 1 end) as [Total Reg at 6:00pm],	
		count(case when cast(r.registration_date as time) >= '17:30:00' and cast(r.registration_date as time) < '18:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 6:00pm],	
			
		count(case when cast(r.registration_date as time) >= '18:00:00' and cast(r.registration_date as time) < '18:30:00' then 1 end) as [Total Reg at 6:30pm],	
		count(case when cast(r.registration_date as time) >= '18:00:00' and cast(r.registration_date as time) < '18:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 6:30pm],	
			
		count(case when cast(r.registration_date as time) >= '18:30:00' and cast(r.registration_date as time) < '19:00:00' then 1 end) as [Total Reg at 7:00pm],	
		count(case when cast(r.registration_date as time) >= '18:30:00' and cast(r.registration_date as time) < '19:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 7:00pm],	
			
		count(case when cast(r.registration_date as time) >= '19:00:00' and cast(r.registration_date as time) < '19:30:00' then 1 end) as [Total Reg at 7:30pm],	
		count(case when cast(r.registration_date as time) >= '19:00:00' and cast(r.registration_date as time) < '19:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 7:30pm],	
			
		count(case when cast(r.registration_date as time) >= '19:30:00' and cast(r.registration_date as time) < '20:00:00' then 1 end) as [Total Reg at 8:00pm],	
		count(case when cast(r.registration_date as time) >= '19:30:00' and cast(r.registration_date as time) < '20:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 8:00pm],	
			
		count(case when cast(r.registration_date as time) >= '20:00:00' and cast(r.registration_date as time) < '20:30:00' then 1 end) as [Total Reg at 8:30pm],	
		count(case when cast(r.registration_date as time) >= '20:00:00' and cast(r.registration_date as time) < '20:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 8:30pm],	
			
		count(case when cast(r.registration_date as time) >= '20:30:00' and cast(r.registration_date as time) < '21:00:00' then 1 end) as [Total Reg at 9:00pm],	
		count(case when cast(r.registration_date as time) >= '20:30:00' and cast(r.registration_date as time) < '21:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 9:00pm],	
			
		count(case when cast(r.registration_date as time) >= '21:00:00' and cast(r.registration_date as time) < '21:30:00' then 1 end) as [Total Reg at 9:30pm],	
		count(case when cast(r.registration_date as time) >= '21:00:00' and cast(r.registration_date as time) < '21:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as[Total Def at 9:30pm],	
			
		count(case when cast(r.registration_date as time) >= '21:30:00' and cast(r.registration_date as time) < '22:00:00' then 1 end) as [Total Reg at 10:00pm],	
		count(case when cast(r.registration_date as time) >= '21:30:00' and cast(r.registration_date as time) < '22:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 10:00pm],	
			
		count(case when cast(r.registration_date as time) >= '22:00:00' and cast(r.registration_date as time) < '22:30:00' then 1 end) as [Total Reg at 10:30pm],	
		count(case when cast(r.registration_date as time) >= '22:00:00' and cast(r.registration_date as time) < '22:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 10:30pm],	
			
		count(case when cast(r.registration_date as time) >= '22:30:00' and cast(r.registration_date as time) < '23:00:00' then 1 end) as [Total Reg at 11:00pm],	
		count(case when cast(r.registration_date as time) >= '22:30:00' and cast(r.registration_date as time) < '23:00:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 11:00pm],	
			
		count(case when cast(r.registration_date as time) >= '23:00:00' and cast(r.registration_date as time) < '23:30:00' then 1 end) as [Total Reg at 11:30pm],	
		count(case when cast(r.registration_date as time) >= '23:00:00' and cast(r.registration_date as time) < '23:30:00' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 11:30pm],	
			
		count(case when cast(r.registration_date as time) >= '23:30:00' and cast(r.registration_date as time) <= '23:59:59' then 1 end) as [Total Reg at 12:00am],	
		count(case when cast(r.registration_date as time) >= '23:30:00' and cast(r.registration_date as time) <= '23:59:59' and CompletedFlag<12 and postphlebempid is null then 1 end) as [Total Def at 12:00am]	
			
into #Reg			
			
from  integration.dbo.INT_MKTCollectionDetails mkt			
left join  STAGE.dbo.STG_RSARegistration_2017 r on r.REGISTRATION_ID=mkt.registrationID			
left join stage.dbo.STG_Hemadriveshiftdetail sht on sht.shiftid+1000000=mkt.driveid			
left join stage.[dbo].[STG_HemaDrivemaster] dm on dm.driveid=sht.driveid			
Left Join stage.dbo.STG_HemaCenterdetail cd ON cd.centerid=dm.centerid			
      Left Join STG_HemaQuickCodes qcr ON qcr.codeid=cd.OrgCenter			
	  left  join [INTEGRATION].dbo.[INT_DIMLocation] loc on loc.locationsk=mkt.locationsk		
	  left join  stage.[dbo].[STG_HemaAccounts] acc on acc.accountid=mkt.accountid		
	  left join integration.dbo.INT_DIMAccountType typ on typ.codeid=acc.accounttype		
			
	  left join stage.dbo.STG_RSA_DonorDeferral def on mkt.REGISTRATIONID=def.registration_id		
			
	  left join (select * from Integration.dbo.[INT_DIMEmployee] where Enddate IS NULL ) emp on emp.empRSAID=mkt.TeamLeadEmpID		
	  --left join INTEGRATION.dbo.Int_DimLocation l on mkt.LocationSK = l.LocationSK		
	  left outer join STG_Hemapeople ppl on acc.RecruiterID = ppl.PersonID		
where import=0			
and cast(FromDateTime as date) between '2017-01-01' and '2017-12-31'			
			
			
			
			
			
group by			
qcr.DescShort ,			
mkt.DriveID ,			
TeamLeadEmpID,			
ppl.FullName,			
EmpFullName,			
sht.DriveID ,			
DriveName,			
--l.FinanceLocationName,			
mkt.AccountID,			
mkt.AccountInternalName,			
typ.descshort ,			
FromDateTime,			
ShiftStart,			
ShiftEnd			
			
--58933 Summary (1st tab)			
--select * from #Reg 			
  			
			
			
			
--88360 Detail (2nd tab)			
 select 			
			
reg.Region,			
 reg.RSADriveID,reg.HemaDriveID			
 ,reg.DriveName,reg.AccountRepName,TeamLeaderName,reg.AccountInternalName,			
 DriveDate,DriveStartime,DriveEndTime			
 ,case when emp1.EmpFullName is not null then  emp1.EmpFullName end as DHQEmployeeName			
 ,case when emp2.EmpFullName  is not null then emp2.EmpFullName end  as PhyEmployeeName, count(1) as TotalDef			
 			
  from #Reg reg 			
  	inner  join INTEGRATION.dbo.DimDate dd on dd.date = DriveDate		
 inner join  integration.dbo.INT_MKTCollectionDetails mkt on mkt.driveid=reg.RSADriveID  and mkt.CollectionDateSK=dd.DateKey			
 LEFT OUTER JOIN integration.dbo.VW_INT_DIMEmployee emp1 ON (mkt.DHQEmpID=emp1.EmpRSAID AND emp1.EndDate IS NULL)			
  LEFT OUTER JOIN integration.dbo.VW_INT_DIMEmployee emp2 ON (mkt.PhyEmpID=emp2.EmpRSAID AND emp2.EndDate IS NULL)			
  			
where  CompletedFlag<12 and postphlebempid is null			
			
  group by  			
  reg.Region,			
 reg.RSADriveID,reg.HemaDriveID			
 ,reg.DriveName,reg.AccountRepName,reg.AccountInternalName,TeamLeaderName,			
 DriveDate,DriveStartime,DriveEndTime,TotalReg, TotalDef,emp1.EmpFullName,emp2.EmpFullName			
