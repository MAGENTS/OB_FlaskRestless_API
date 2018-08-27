			
			
IF OBJECT_ID('tempdb..#t1') IS NOT NULL DROP TABLE #t1			
select distinct ic.CenterName, unitnumber, mkt.registrationID, --convert(char(10), mkt.drawtime, 112) as DrawDate,  			
	mkt.drawtime as DrawDate, mkt.withdrawltime,		
	bt.abo + ' ' + bt.rh as BloodType, mkt.ParentVolume		
into tempdb..#t1			
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt			
left join STAGE.dbo.STG_RSABagKitUsage bku on bku.registration_ID = mkt.registrationID			
left join stage.dbo.STG_RSACLProductInventory inv on inv.registration_ID = mkt.registrationID			
left join INTEGRATION.dbo.INT_DIMInventoryCenter ic on inv.center_id = ic.rsacenterid			
left join stage.dbo.STG_RSARegistrationPersonArchive p on p.registration_id = mkt.registrationid			
left join [INTEGRATION].[dbo].INT_DimBloodType bt on bt.BloodTypeSK = mkt.BloodTypeSK			
where inv.create_date in			
	(select min(inv1.create_date)		
          from stage.dbo.STG_RSACLProductInventory inv1			
         where inv1.registration_id = inv.registration_id)			
and bku.bag_type_id in (34)			
and mkt.DonationTypeSK = 1 and mkt.MotivationSK != 4 and mkt.import = 0			
and datediff(ss, mkt.drawtime, inv.create_date)/3600.0 <= 6			
and mkt.drawtime >= '2018-05-01' and mkt.drawtime < '2018-06-01'			
			
			
IF OBJECT_ID('tempdb..#t2') IS NOT NULL DROP TABLE #t2			
select distinct t1.CenterName, t1.unitnumber, t1.registrationID, t1.DrawDate, t1.withdrawltime, t1.BloodType, t1.ParentVolume, cpp.value as PlasmaVolume			
into tempdb..#t2			
from tempdb..#t1 t1			
inner join stage.dbo.STG_RSACLProductInventory inv on inv.registration_ID = t1.registrationID			
inner join stage.dbo.STG_RSACLProductInventory inv2 on inv2.reference_product_inv_id = inv.product_inventory_id and inv.Product_Code = 'PLASMA'			
inner join STAGE.dbo.STG_RSACLProductProperties cpp on cpp.product_inventory_id  = inv2.product_inventory_id			
	and cpp.[key] = 'volume' and cpp.value is not null and cpp.value <> ''		
			
			
IF OBJECT_ID('tempdb..#t3') IS NOT NULL DROP TABLE #t3			
select distinct t2.*, p.Description as ProductMade			
into tempdb..#t3			
from tempdb..#t2 t2			
inner join stage.dbo.STG_RSACLProductInventory inv on inv.registration_ID = t2.registrationID 			
left join INTEGRATION.dbo.INT_DIMProducts p on p.ProductCode = inv.Product_Code			
	and p.Description in ('RECOVERED PLASMA FROZEN WITHIN 24 HOURS', 'PLASMA FROZEN WITHIN 24 HOURS', 'SOURCE LEUKOCYTES - RESEARCH')		
			
select CenterName, convert(char(10), DrawDate, 112) as DrawDate,			
	count(distinct case when (ParentVolume <= 449 or ParentVolume >= 551)		
		or datediff(ss, DrawDate, withdrawltime)/60.0 > 15	
		or PlasmaVolume < 215	
		or (ProductMade in ('RECOVERED PLASMA FROZEN WITHIN 24 HOURS', 'PLASMA FROZEN WITHIN 24 HOURS') and BloodType like 'AB%')	
		or ProductMade in ('SOURCE LEUKOCYTES - RESEARCH')	
			then unitnumber end) as LV_OD_123_64
from tempdb..#t3			
group by CenterName, convert(char(10), DrawDate, 112)			
order by CenterName, convert(char(10), DrawDate, 112)			
			
			
			
			
			
			
IF OBJECT_ID('tempdb..#t1') IS NOT NULL DROP TABLE #t1			
select distinct ic.CenterName, unitnumber, mkt.registrationID, --convert(char(10), mkt.drawtime, 112) as DrawDate,  			
	mkt.drawtime as DrawDate, mkt.withdrawltime,		
	bt.abo + ' ' + bt.rh as BloodType, mkt.ParentVolume		
into tempdb..#t1			
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt			
left join STAGE.dbo.STG_RSABagKitUsage bku on bku.registration_ID = mkt.registrationID			
left join stage.dbo.STG_RSACLProductInventory inv on inv.registration_ID = mkt.registrationID			
left join INTEGRATION.dbo.INT_DIMInventoryCenter ic on inv.center_id = ic.rsacenterid			
left join stage.dbo.STG_RSARegistrationPersonArchive p on p.registration_id = mkt.registrationid			
left join [INTEGRATION].[dbo].INT_DimBloodType bt on bt.BloodTypeSK = mkt.BloodTypeSK			
where inv.create_date in			
	(select min(inv1.create_date)		
          from stage.dbo.STG_RSACLProductInventory inv1			
         where inv1.registration_id = inv.registration_id)			
and bku.bag_type_id in (30, 32, 34)			
and mkt.DonationTypeSK = 1 and mkt.MotivationSK != 4 and mkt.import = 0			
and datediff(ss, mkt.drawtime, inv.create_date)/3600.0 <= 6			
and mkt.drawtime >= '2018-05-01' and mkt.drawtime < '2018-06-01'			
			
			
IF OBJECT_ID('tempdb..#t2') IS NOT NULL DROP TABLE #t2			
select distinct t1.CenterName, t1.unitnumber, t1.registrationID, t1.DrawDate, t1.withdrawltime, t1.BloodType, t1.ParentVolume, cpp.value as PlasmaVolume			
into tempdb..#t2			
from tempdb..#t1 t1			
inner join stage.dbo.STG_RSACLProductInventory inv on inv.registration_ID = t1.registrationID			
inner join stage.dbo.STG_RSACLProductInventory inv2 on inv2.reference_product_inv_id = inv.product_inventory_id and inv.Product_Code = 'PLASMA'			
inner join STAGE.dbo.STG_RSACLProductProperties cpp on cpp.product_inventory_id  = inv2.product_inventory_id			
	and cpp.[key] = 'volume' and cpp.value is not null and cpp.value <> ''		
			
			
IF OBJECT_ID('tempdb..#t3') IS NOT NULL DROP TABLE #t3			
select distinct t2.*, p.Description as ProductMade			
into tempdb..#t3			
from tempdb..#t2 t2			
inner join stage.dbo.STG_RSACLProductInventory inv on inv.registration_ID = t2.registrationID 			
left join INTEGRATION.dbo.INT_DIMProducts p on p.ProductCode = inv.Product_Code			
	and p.Description in ('RECOVERED PLASMA FROZEN WITHIN 24 HOURS', 'PLASMA FROZEN WITHIN 24 HOURS', 'SOURCE LEUKOCYTES - RESEARCH')		
			
			
			
select CenterName, convert(char(10), DrawDate, 112) as DrawDate,			
	count(distinct case when (ParentVolume <= 449 or ParentVolume >= 551)		
		or datediff(ss, DrawDate, withdrawltime)/60.0 > 15	
		or PlasmaVolume < 215	
		or (ProductMade in ('RECOVERED PLASMA FROZEN WITHIN 24 HOURS', 'PLASMA FROZEN WITHIN 24 HOURS') and BloodType like 'AB%')	
		or ProductMade in ('SOURCE LEUKOCYTES - RESEARCH')	
			then unitnumber end) as LV_OD_129
from tempdb..#t3			
group by CenterName, convert(char(10), DrawDate, 112)			
order by CenterName, convert(char(10), DrawDate, 112)			
			
			
			
			
			
			
select distinct CenterName, convert(char(10), DrawDate, 112) as DrawDate, unitnumber,			
	case when (ParentVolume <= 449 or ParentVolume >= 551) then ParentVolume end as ParentVolume,		
	case when datediff(ss, DrawDate, withdrawltime)/60.0 > 15 then '>15 minutes' end as '>15 minutes',		
	case when PlasmaVolume < 215 then PlasmaVolume end as PlasmaVolume,		
	case when (ProductMade in ('RECOVERED PLASMA FROZEN WITHIN 24 HOURS', 'PLASMA FROZEN WITHIN 24 HOURS') and BloodType like 'AB%')		
		then ProductMade end as 'AB',	
	case when ProductMade in ('SOURCE LEUKOCYTES - RESEARCH') then ProductMade end as 'Source Leukocytes'		
from tempdb..#t3			
where (ParentVolume <= 449 or ParentVolume >= 551)			
		or datediff(ss, DrawDate, withdrawltime)/60.0 > 15	
		or PlasmaVolume < 215	
		or (ProductMade is not null and BloodType like 'AB%')	
order by CenterName, convert(char(10), DrawDate, 112)			
