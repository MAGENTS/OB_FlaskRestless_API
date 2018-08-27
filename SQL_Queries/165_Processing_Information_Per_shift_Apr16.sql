			
select distinct ic.CenterName, convert(varchar(10), fs.Create_Date, 110) as ProcessDate, --convert(char(10), mkt.drawtime, 112) as DrawDate, 			
	bt.rsa_bag_type, --bku.bag_type_id,		
	p.description as Process, --fs.Create_Date as ProcessDate,		
	count(distinct case when convert(varchar(8), fs.Create_Date, 108) >= '02:00:00' and convert(varchar(8), fs.Create_Date, 108)		
		< '11:00:00' then mkt.unitnumber end) as '2am - 11am',	
	count(distinct case when convert(varchar(8), fs.Create_Date, 108) >= '11:00:00' and convert(varchar(8), fs.Create_Date, 108)		
		< '21:00:00' then mkt.unitnumber end) as '11am - 9pm',	
	count(distinct case when (convert(varchar(8), fs.Create_Date, 108) >= '21:00:00' and convert(varchar(8), fs.Create_Date, 108)		
		< '24:00:00') or (convert(varchar(8), fs.Create_Date, 108) >= '00:00:00' and convert(varchar(8), fs.Create_Date, 108)	
		< '02:00:00') then mkt.unitnumber end)	
			 as '9pm - 2am'
	--count(distinct mkt.unitnumber) as TotalCount		
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt			
inner join STAGE.dbo.STG_RSABagKitUsage bku on bku.registration_ID = mkt.registrationID			
left join stage.dbo.STG_RSABagKitType bt on bt.uidpk = bku.bag_type_id			
inner join stage.dbo.STG_RSACLProductInventory inv on inv.registration_ID = mkt.registrationID			
left join INTEGRATION.dbo.INT_DIMInventoryCenter ic on inv.center_id = ic.rsacenterid			
inner join stage.dbo.STG_RSACLFRACSTEPS fs on inv.product_inventory_id = fs.product_inventory_id			
left join stage.dbo.STG_RSACLPROCESSES p on fs.Process_Id = p.frac_step_process_id			
where /*inv.create_date in			
	(select min(inv1.create_date)		
          from stage.dbo.STG_RSACLProductInventory inv1			
         where inv1.registration_id = inv.registration_id) */			
			
bku.bag_type_id in (30, 32, 34)			
and mkt.DonationTypeSK = 1 and mkt.MotivationSK != 4 and mkt.import = 0			
and mkt.CollectionDateSK >= 20180401 --and mkt.drawtime < '2018-02-01'			
and (p.description = 'Check-In' or p.description like '%validation%')			
group by ic.CenterName, --convert(char(10), mkt.drawtime, 112), 			
	bt.rsa_bag_type, --bku.bag_type_id, 		
	p.description, convert(varchar(10), fs.Create_Date, 110)		
order by ic.CenterName, convert(varchar(10), fs.Create_Date, 110)--, convert(char(10), mkt.drawtime, 112)			
