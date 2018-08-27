IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp			
SELECT distinct t.unitnumber, mkt.registrationid, lb.ISBT_PRODUCT_CODE, prd.productcode, inv.PRODUCT_CODE, inv.create_date, 			
	null as discarddatesk,		
	convert(char(50), null, 120) as ActivityDate,		
	convert(varchar(200), '') as DiscardReason, 		
	'                          '  as Status, INV.PRODUCT_INVENTORY_ID		
into  #temp			
  FROM Test.dbo.[Adhoc BH Returned Units Jan thru May 2018] t			
  left join [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt on t.unitnumber = mkt.unitnumber			
  left JOIN [STAGE].[dbo].[STG_RSACLProductInventory] INV on inv.registration_ID = mkt.registrationID			
  left join [STAGE].[dbo].[STG_RSALBLabel] LB on INV.PRODUCT_INVENTORY_ID=LB.PRODUCT_INVENTORY_ID 			
  left JOIN [INTEGRATION].[dbo].[INT_DIMProducts] PRD ON PRD.PRODUCTCODE=INV.PRODUCT_CODE			
  --WHERE prd.[Description] like '%liquid%' --and prd.productstatus = 50 			
  WHERE lb.ISBT_PRODUCT_CODE in ('E2457', 'E2469', 'E2474', 'E8854')			
			
			
IF OBJECT_ID('tempdb..#temp2') IS NOT NULL DROP TABLE #temp2			
SELECT DISTINCT t1.unitnumber, t1.registrationid, convert(datetime, max(convert(char(50), dis.discarddatesk, 120))) as aDate,			
	dr.DiscardDesc as DiscardReason, 'Discarded                         ' as Status		
into #temp2			
from #temp t1			
  inner join [INTEGRATION].[dbo].[INT_FCTProductDiscardsWithReason] dis on t1.registrationid = dis.registrationid --t1.PRODUCT_INVENTORY_ID=dis.PRODUCTINVENTORYID 			
  inner join [INTEGRATION].[dbo].INT_DIMDiscardReason dr on dis.DiscardSK = dr.Discardsk			
group by t1.unitnumber, t1.registrationid, dr.DiscardDesc			
			
			
insert into #temp2			
select distinct t1.unitnumber, t1.registrationid, max(rsainv.ship_validate_date) as aDate, null as DiscardReason, 'Shipped' as Status			
from #temp t1						
inner join stage.dbo.stg_rsashippedinventory rsainv on rsainv.product_inventory_id=t1.product_inventory_id			
where rsainv.ship_validate_date is not null			
and t1.unitnumber not in (select unitnumber from #temp2 where Status like 'Discarded%')			
group by t1.unitnumber, t1.registrationid			
			
insert into #temp2			
select distinct t1.unitnumber, t1.registrationid, max(s.ship_date) as aDate, null as DiscardReason, 'Shipped Plasma' as Status			
from #temp t1			
			
inner join stage.[dbo].[STG_RSACLRECPLASMAINVENTORY] psinv on psinv.product_inventory_id=t1.product_inventory_id			
inner join stage.[dbo].[STG_RSACLRECPLASMACARTON] ctn on ctn.carton_id = psinv.carton_id			
inner join stage.dbo.STG_RSACLRecPlasmaShipping s on s.shipment_id = ctn.shipment_id			
where s.ship_date is not null			
and t1.unitnumber not in (select unitnumber from #temp2 where Status like 'Discarded%')			
group by t1.unitnumber, t1.registrationid			
			
insert into #temp2			
select distinct t1.unitnumber, t1.registrationid, max(r.Return_Date) as aDate, null as DiscardReason, 'Returned' as Status			
from #temp t1			
			
inner join stage.dbo.STG_RSAHSReturns r on r.Product_Inventory_Id = t1.Product_Inventory_Id			
where r.Return_Date is not null			
and t1.unitnumber not in (select unitnumber from #temp2 where Status like 'Discarded%')			
group by t1.unitnumber, t1.registrationid			
			
			
insert into #temp2			
select distinct t1.unitnumber, t1.registrationid, max(inv.create_date) as aDate, null as DiscardReason, 'Quarantine' as Status			
from #temp t1			
inner join stage.dbo.STG_RSACLProductInventory inv on t1.product_inventory_id = inv.product_inventory_id 			
inner join stage.dbo.STG_RSACLProductProperties pp on pp.product_inventory_id = inv.product_inventory_id 			
	and pp.value is not null and pp.[key] = 'isolate' and pp.[value] = 'Yes'		
where inv.create_date is not null			
and t1.unitnumber not in (select unitnumber from #temp2 where Status like 'Discarded%')			
group by t1.unitnumber, t1.registrationid			
			
insert into #temp2			
select distinct t1.unitnumber, t1.registrationid, max(lbl.label_date) as aDate, null as DiscardReason, 'Available' as Status			
from #temp t1			
inner join stage.dbo.STG_RSACLProductInventory inv on t1.product_inventory_id = inv.product_inventory_id  --t1.registrationid = inv.REGISTRATION_ID			
inner join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=t1.product_inventory_id 			
			and lbl.ISBT_PRODUCT_CODE is not null and lbl.ISBT_PRODUCT_CODE <> '' 
inner join stage.dbo.STG_RSACLProductProperties pp on pp.product_inventory_id = inv.product_inventory_id 			
		and pp.value is not null and pp.[key] = 'volume'	
inner join stage.dbo.STG_RSACLProductInventory inv2 on inv2.product_inventory_id = inv.reference_product_inv_id			
where lbl.label_date is not null			
and t1.unitnumber not in (select unitnumber from #temp2 where Status like 'Discarded%')			
group by t1.unitnumber, t1.registrationid			
			
insert into #temp2			
select distinct t1.unitnumber, t1.registrationid, max(inv.Create_Date) as aDate, null as DiscardReason, 'Created' as Status			
from #temp t1			
inner join stage.dbo.STG_RSACLProductInventory inv on t1.product_inventory_id = inv.product_inventory_id  			
			
--			and lbl.ISBT_PRODUCT_CODE is not null and lbl.ISBT_PRODUCT_CODE <> '' 
inner join stage.dbo.STG_RSACLProductProperties pp on pp.product_inventory_id = inv.product_inventory_id 			
		and pp.value is not null and pp.[key] = 'volume'	
where inv.Create_Date is not null			
and t1.unitnumber not in (select unitnumber from #temp2 where Status like 'Discarded%')			
group by t1.unitnumber, t1.registrationid			
			
IF OBJECT_ID('tempdb..#temp3') IS NOT NULL DROP TABLE #temp3			
select x.unitnumber, x.bDate, tt.Status, tt.DiscardReason			
into #temp3			
from(			
select unitnumber, max(convert(datetime,aDate)) as bDate			
from  #temp2			
group by unitnumber) x			
inner join #temp2 tt on x.unitnumber = tt.unitnumber and x.bDate = tt.aDate			
			
update #temp			
set ActivityDate = convert(char(50), t3.bDate, 120), Status = t3.status, DiscardReason = t3.DiscardReason			
from #temp t			
inner join #temp3 t3 on t3.unitnumber = t.unitnumber and t.discarddatesk is null			
			
select unitnumber, ISBT_PRODUCT_CODE, PRODUCT_CODE, ActivityDate, Status, DiscardReason			
from  #temp 			
