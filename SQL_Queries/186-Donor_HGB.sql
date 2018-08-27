Select  									
	Cast(Date as Date) [Date],								
	('Region '+ Cast(l.[RegionID] as Varchar(1))) 'Region',								
	l.[FinanceLocationName],								
	(p.First_Name+' '+p.LAST_NAME) Full_Name,								
	p.DOB,								
	c.motivationsk Motivationsk,								
	m.[MotivationName],								
	dt.[DonationDescription],								
	c.DonationTypeSk,								
	c.UNITNUMBER,								
	c.registrationID [Registration ID]								
	,[EMPLOYEE_ID]								
	  ,[BP_SYSTOLIC]								
	  ,[BP_DIASTOLIC]								
	  ,[HCT1]								
	  ,[HGB]								
	  ,[PULSE]								
	  ,[PHYSICAL_APPEARANCE]								
	  ,[LEFT_ARM_CONDITION]								
	  ,[HEIGHT]								
	  ,[RIGHT_ARM_CONDITION]								
	  ,[WEIGHT]								
	  ,[TEMPERATURE]								
	  ,[HGB_HEMOCUE]								
	  ,[HGB_HEMOCUE2]								
	  ,[HEMOCUE_FAILURE_ID]								
	  ,[HEMOCUE_FAILURE_ID2]								
	  ,[PHYSICAL_EXAM_COMMENTS]								
	  ,[HGB_HEMOCUE3]								
	  ,[HEMOCUE_FAILURE_ID3]								
	  ,[ONEBLOOD_PHYSICIAN_ID]								
	--count (*) as total_count 								
	from [INTEGRATION].[dbo].[INT_MKTCollectionDetails] c 								
	Inner join Stage.dbo.STG_RSAPhysicalExam RP on RP.REGISTRATION_ID = c.registrationID								
	left join STAGE.[dbo].[STG_RSAPerson] p on p.PERSON_ID = c.personid								
	Left Join [INTEGRATION].[dbo].[Int_DimDonationType] dt on dt.DonationTypeSk = c.DonationTypeSK								
	Left Join [INTEGRATION].[dbo].[INT_DIMMotivation] m on m.MotivationSK = c.motivationsk								
	left join [INTEGRATION].[dbo].[INT_DIMLocation] l	on l.locationsk = c.locationsk							
	inner join [INTEGRATION].[dbo].[DimDate] d on d.datekey = c.collectiondatesk 								
	where 								
	CollectionDateSK >= 20160216 and CollectionDateSK <=20180502								
	and p.Person_ID = 52985081								
	Order By Date								
