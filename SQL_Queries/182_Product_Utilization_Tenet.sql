--declare @UnitNumber  varchar (20)				
--set @UnitNumber='W036817687598'				
				
				
				
IF OBJECT_ID('tempdb..#hsi') IS NOT NULL		
DROP TABLE #hsi		
select PRODUCT_INVENTORY_ID,ORDER_FORM_DETAILS_ID,LABEL_ID,HS_LAB_LOCATION_ID,SHIP_VALIDATE_DATE		
into #hsi		
from		
(		
	select PRODUCT_INVENTORY_ID,ORDER_FORM_DETAILS_ID,LABEL_ID,HS_LAB_LOCATION_ID,SHIP_VALIDATE_DATE,		
	row_number() over(partition by PRODUCT_INVENTORY_ID,ORDER_FORM_DETAILS_ID,LABEL_ID,HS_LAB_LOCATION_ID order by SHIP_VALIDATE_DATE desc) rn	
	from stage.dbo.STG_RSAShippedInventory  where cast(SHIP_VALIDATE_DATE as date) >='2016-01-01'		
and cast(SHIP_VALIDATE_DATE as date) < '2018-05-31'		
	) src		
where rn =1		
				
				
IF OBJECT_ID('tempdb..#Shipped1') IS NOT NULL				
    DROP TABLE #Shipped1				
				
select  				
 distinct				
 UnitNumber,CollectionDate,cast('9999-01-01' as date) AS  [DiscardDate], cast(NULL as varchar) as DiscardReason,				
 ShippedDate, CustomerName, ProductGroup,ProductCode,Product,				
 product_inventory_id,reference_product_inv_id,				
ISBT_PRODUCT_CODE as ISBTCode,ORDER_ID				
 into #Shipped1				
from				
(				
select				
mkt.registrationid,cast(dd.date as Date) AS  [CollectionDate],mkt.unitnumber,				
NULL as [Discard_Date],				
cust.customername,				
inv.product_inventory_id as [Product_Inventory_ID],inv.reference_product_inv_id				
,prod.ProductGroup,prod.productcode,prod.description as Product,prod.productstatus				
,cast(rsainv.ship_validate_date as Date) AS[ShippedDate],lbl.ISBT_PRODUCT_CODE,odm.ORDER_ID				
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt inner join 				
STAGE.dbo.STG_RSARegistration reg on mkt.registrationid=reg.registration_id				
inner join INTEGRATION.dbo.DimDate dd on dd.date = cast(reg.REGISTRATION_DATE as date)				
left join stage.dbo.STG_RSACLProductInventory inv on inv.REGISTRATION_ID=reg.REGISTRATION_ID				
left join #hsi rsainv on rsainv.product_inventory_id=inv.product_inventory_id				
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id				
left join [STAGE].[dbo].[STG_RSALBCodabarISBTMap] map on map.ISBT_code=lbl.ISBT_PRODUCT_CODE				
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code				
left  join stage.dbo.STG_RSAOrderFormDetails odt on rsainv.ORDER_FORM_DETAILS_ID=odt.ORDER_FORM_DETAILS_ID				
left join stage.dbo.STG_RSAOrderForm odf on odf.ORDER_FORM_ID=odt.ORDER_FORM_ID 				
left join stage.dbo.STG_RSAOrderMain odm on odm.ORDER_ID=odf.ORDER_ID				
inner join INTEGRATION.dbo.[INT_DIMCustomer] cust on odm.SHIP_TO_FACILITY=cust.CustomerID 				
and cust.enddate is null				
and cust.Territory = 'TENET'   				
and  (prod.ProductGroup ='SDP'	or (ProductGroup ='ACRODOSE' or ClassifierGroup ='PLATELET POOL'))	                                                                                                                                                                          		
--and mkt.collectiondatesk between 20160101 and 20180531				
and  cast(SHIP_VALIDATE_DATE as date) >='2016-01-01' and cast(SHIP_VALIDATE_DATE as date) < '2018-05-31'				
)				
a where ShippedDate is not null				
order by unitnumber				
				
				
				
IF OBJECT_ID('tempdb..#Shipped') IS NOT NULL				
    DROP TABLE #Shipped				
				
				
select  UnitNumber,cast(CollectionDate as date) CollectionDate,DiscardDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product				
, product_inventory_id,reference_product_inv_id,ISBTCode, ORDER_ID,				
datediff(day, cast(CollectionDate as date), ShippedDate) as ProductAge,				
'FirstShipped' as Disposition,1 as Step				
into #Shipped				
from				
(				
  select UnitNumber,CollectionDate,DiscardDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product, product_inventory_id,reference_product_inv_id,ISBTCode,ORDER_ID,				
    row_number() over(partition by UnitNumber,productcode order by ORDER_ID) rn				
				
  from #Shipped1 				
 ) src				
where rn =1				
				
				
update #Shipped set ProductGroup='ACRODOSE' where ProductGroup is null and product='PLATELETS POOLED LEUKOCYTES REDUCED - 5d'				
update #Shipped set ProductGroup='ACRODOSE' where ProductGroup is null and product='IRR POOLED LEUKO PLATELET CONC-5d'				
				
				
				
				
IF OBJECT_ID('tempdb..#Returned') IS NOT NULL				
    DROP TABLE #Returned				
				
				
select				
				
sh.UnitNumber,sh.CollectionDate,cast('9999-01-01' as date) AS  [DiscardDate],				
cast(NULL as varchar) as DiscardReason,				
cast(ret.return_Date as Date) AS [ReturnedDate],sh.CustomerName,sh.ProductGroup,sh.ProductCode,sh.Product				
,inv.product_inventory_id as [Product_Inventory_ID],inv.reference_product_inv_id,sh.ISBTCode,  main.ORDER_ID,				
ProductAge,				
'Returned' as Disposition,'2' as Step				
				
into  #Returned				
	          			
from 				
				
#Shipped sh inner join stage.dbo.STG_RSACLProductInventory inv 				
on inv.product_inventory_id=sh.Product_Inventory_ID				
inner join stage.dbo.STG_RSAHsReturns ret on ret.product_inventory_id=sh.product_inventory_id 				
and inv.product_inventory_id=ret.product_inventory_id				
		  		inner join stage.dbo.STG_RSAOrderMain main on ret.ORDER_ID = main.ORDER_ID and ret.ORDER_ID=sh.ORDER_ID
				inner join stage.dbo.STG_RSAorderform form on form.order_id =  main.ORDER_ID
				inner join stage.dbo.STG_RSAorderformdetails dtls on dtls.order_form_id = form.order_form_id 
				inner join #hsi ship on ship.order_form_details_id =dtls.order_form_details_id
				and  ship.product_inventory_id = ret.product_inventory_id
				
	where ret.return_Date >='2016-01-01' and	  ret.return_date <'2018-05-31'		
				
				
				
				
IF OBJECT_ID('tempdb..#Reshipped1') IS NOT NULL				
    DROP TABLE #Reshipped1				
				
select  				
 distinct				
 UnitNumber,CollectionDate,cast('9999-01-01' as date) AS  [DiscardDate], cast(NULL as varchar) as DiscardReason,				
 ShippedDate, CustomerName, ProductGroup,ProductCode,Product,				
 product_inventory_id,reference_product_inv_id,				
ISBT_PRODUCT_CODE as ISBTCode,ORDER_ID,ProductAge				
 into #Reshipped1				
from				
(				
				
select				
ret.CollectionDate,ret.unitnumber,				
NULL as [Discard_Date],				
cust.customername,				
inv.product_inventory_id as [Product_Inventory_ID],inv.reference_product_inv_id				
,prod.ProductGroup,prod.productcode,prod.description as Product,prod.productstatus				
,cast(rsainv.ship_validate_date as Date) AS[ShippedDate],lbl.ISBT_PRODUCT_CODE,odm.ORDER_ID,ProductAge				
from #Returned ret				
left join stage.dbo.STG_RSACLProductInventory inv on inv.product_inventory_id=ret.product_inventory_id				
left join #hsi rsainv on rsainv.product_inventory_id=inv.product_inventory_id				
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id				
left join [STAGE].[dbo].[STG_RSALBCodabarISBTMap] map on map.ISBT_code=lbl.ISBT_PRODUCT_CODE				
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code				
left  join stage.dbo.STG_RSAOrderFormDetails odt on rsainv.ORDER_FORM_DETAILS_ID=odt.ORDER_FORM_DETAILS_ID				
left join stage.dbo.STG_RSAOrderForm odf on odf.ORDER_FORM_ID=odt.ORDER_FORM_ID 				
left join stage.dbo.STG_RSAOrderMain odm on odm.ORDER_ID=odf.ORDER_ID 				
and ret.ORDER_ID<>odf.ORDER_ID and cast(rsainv.ship_validate_date as Date)>=ret.ReturnedDate				
inner join INTEGRATION.dbo.[INT_DIMCustomer] cust on odm.SHIP_TO_FACILITY=cust.CustomerID 				
and cust.enddate is null				
and ret.ORDER_ID is not null				
				
)a				
				
				
IF OBJECT_ID('tempdb..#Reshipped') IS NOT NULL				
    DROP TABLE #Reshipped				
				
				
select  UnitNumber,cast(CollectionDate as date) CollectionDate,DiscardDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product				
, product_inventory_id,reference_product_inv_id,ISBTCode, ORDER_ID,ProductAge,				
'Re-Shipped' as Disposition,3 as Step				
into #Reshipped				
from				
(				
  select UnitNumber,CollectionDate,DiscardDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product, product_inventory_id,reference_product_inv_id,ISBTCode,ORDER_ID,ProductAge,				
    row_number() over(partition by UnitNumber,productcode order by ShippedDate) rn				
  from #Reshipped1 				
 ) src				
where rn =1				
				
				
				
				
				
IF OBJECT_ID('tempdb..#Reshipped1C') IS NOT NULL				
    DROP TABLE #Reshipped1C				
				
select  				
 distinct				
 UnitNumber,CollectionDate,cast('9999-01-01' as date) AS  [DiscardDate], cast(NULL as varchar) as DiscardReason,				
 ShippedDate, CustomerName, ProductGroup,ProductCode,Product,				
 product_inventory_id,reference_product_inv_id,				
ISBT_PRODUCT_CODE as ISBTCode,ORDER_ID,ProductAge				
 into #Reshipped1C				
from				
(				
select				
ret.CollectionDate,ret.unitnumber,				
NULL as [Discard_Date],				
cust.customername,				
inv.product_inventory_id as [Product_Inventory_ID],inv.reference_product_inv_id				
,prod.ProductGroup,prod.productcode,prod.description as Product,prod.productstatus				
,cast(rsainv.ship_validate_date as Date) AS[ShippedDate],lbl.ISBT_PRODUCT_CODE,odm.ORDER_ID,ProductAge				
from #Returned ret				
left join stage.dbo.STG_RSACLProductInventory inv on inv.reference_product_inv_id=ret.product_inventory_id				
left join #hsi rsainv on rsainv.product_inventory_id=inv.product_inventory_id				
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id				
left join [STAGE].[dbo].[STG_RSALBCodabarISBTMap] map on map.ISBT_code=lbl.ISBT_PRODUCT_CODE				
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code				
left  join stage.dbo.STG_RSAOrderFormDetails odt on rsainv.ORDER_FORM_DETAILS_ID=odt.ORDER_FORM_DETAILS_ID				
left join stage.dbo.STG_RSAOrderForm odf on odf.ORDER_FORM_ID=odt.ORDER_FORM_ID 				
left join stage.dbo.STG_RSAOrderMain odm on odm.ORDER_ID=odf.ORDER_ID and ret.ORDER_ID<>odf.ORDER_ID 				
inner join INTEGRATION.dbo.[INT_DIMCustomer] cust on odm.SHIP_TO_FACILITY=cust.CustomerID 				
and cust.enddate is null				
and ret.ORDER_ID is not null				
)a				
				
				
IF OBJECT_ID('tempdb..#ReshippedC') IS NOT NULL				
    DROP TABLE #ReshippedC				
				
				
select  UnitNumber,cast(CollectionDate as date) CollectionDate,DiscardDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product				
, product_inventory_id,reference_product_inv_id,ISBTCode, ORDER_ID,ProductAge,				
				
'Re-Shipped' as Disposition,3 as Step				
into #ReshippedC				
from				
(				
  select UnitNumber,CollectionDate,DiscardDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product, product_inventory_id,reference_product_inv_id,ISBTCode,ORDER_ID,ProductAge,				
    row_number() over(partition by UnitNumber,productcode order by ShippedDate) rn				
  from #Reshipped1C 				
 ) src				
where rn =1				
				
				
insert into #Shipped --(Reshipped one)				
				
select UnitNumber,CollectionDate,DiscardDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product,Product_Inventory_ID,REFERENCE_PRODUCT_INV_ID,ISBTCode,ORDER_ID,ProductAge,'Shipped' as Disposition,4 as Step 				
from #Reshipped res where Disposition='Re-Shipped'				
and  exists (select  1 from #Shipped				
Where unitnumber= res.unitnumber and CustomerName<>res.CustomerName) 				
				
				
				
insert into #Shipped --(Reshipped one)				
				
select UnitNumber,CollectionDate,DiscardDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product,Product_Inventory_ID,REFERENCE_PRODUCT_INV_ID,ISBTCode,ORDER_ID,ProductAge,'Shipped' as Disposition,4 as Step 				
from #ReshippedC res where Disposition='Re-Shipped'				
and  exists (select  1 from #Shipped				
Where unitnumber= res.unitnumber 				
				
) 				
				
				
update  res				
	set res.CustomerName = sh.CustomerName			
	from			
	#Reshipped res 			
	inner join #shipped sh on sh.UnitNumber=res.UnitNumber 			
	where sh.step=1 			
	and sh.Product_Inventory_ID=res.Product_Inventory_ID			
				
				
	update  res			
	set res.CustomerName = sh.CustomerName			
	from			
	#ReshippedC res 			
	inner join #shipped sh on sh.UnitNumber=res.UnitNumber 			
	where sh.step=1 			
	and sh.Product_Inventory_ID=res.REFERENCE_PRODUCT_INV_ID			
				
				
				
				
				
IF OBJECT_ID('tempdb..#Discarded') IS NOT NULL				
    DROP TABLE #Discarded				
				
select  				
 distinct				
 UnitNumber,cast(CollectionDate as date) CollectionDate,cast(Discard_Date as Date) AS  [DiscardDate],				
 DiscardReason,				
 cast('9999-01-01' as date) as [ShippedDate], cast(NULL as varchar) as CustomerName, ProductGroup,ProductCode,Product,product_inventory_id,reference_product_inv_id,				
ISBT_PRODUCT_CODE as ISBTCode,cast(NULL as varchar) as ORDER_ID,				
NULL as ProductAge,				
'Discarded' as Disposition,'6' as Step				
 into #Discarded				
from				
(				
select				
mkt.registrationid,cast(dd.date as Date) AS  [CollectionDate],mkt.unitnumber,dd1.date as [Discard_Date],				
 isnull(rea.discardRSADesc,rea.DiscardDesc) as DiscardReason,				
inv.product_inventory_id as [Product_Inventory_ID],reference_product_inv_id				
,prod.ProductGroup,prod.productcode,prod.description as Product,prod.productstatus				
,NULL AS [ShippedDate],lbl.ISBT_PRODUCT_CODE				
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt inner join 				
STAGE.dbo.STG_RSARegistration reg on mkt.registrationid=reg.registration_id				
inner join INTEGRATION.dbo.DimDate dd on dd.date = cast(reg.REGISTRATION_DATE as date)				
left join stage.dbo.STG_RSACLProductInventory inv on inv.REGISTRATION_ID=reg.REGISTRATION_ID				
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id				
left join [STAGE].[dbo].[STG_RSALBCodabarISBTMap] map on map.ISBT_code=lbl.ISBT_PRODUCT_CODE				
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code				
inner join  [INTEGRATION].[dbo].[INT_FCTProductDiscardsWithReason] dis on dis.unitnumber=mkt.unitnumber 				
inner join INTEGRATION.dbo.[VW_INT_DIMDiscardReason] rea on dis.discardsk=rea.discardsk 				
and Prod.ProductCode=inv.product_code and dis.prodsk=prod.prodsk				
left join INTEGRATION.dbo.DimDate dd1 on dd1.Datekey = dis.discarddatesk                                                                                                                                                                                                  				
--where mkt.collectiondatesk between 20160101 and 20180531				
where				
				
 exists (select  1 from #Shipped				
Where unitnumber= mkt.unitnumber and productcode +'D'=inv.product_code) 				
				
and  exists (select  1 from #Returned				
Where unitnumber= mkt.unitnumber and productcode+'D'=inv.product_code) 				
				
)				
a 				
order by unitnumber				
				
				
				
				
IF OBJECT_ID('tempdb..#Result') IS NOT NULL				
    DROP TABLE #Result				
				
select * into 				
#Result				
from  				
(				
				
select * from #Shipped 				
union all				
select * from #Returned where ORDER_ID is not null				
union all				
select * from #Reshipped				
union all				
select * from #ReshippedC				
union all				
select * from #Discarded 				
				
)				
a 				
				
				
drop table work.dbo.Ship_Ret_Dis				
select *  into work.dbo.Ship_Ret_Dis from #Result 				
order by UnitNumber,Step				
				
				
update  mkt				
set mkt.CustomerName = b.CustomerName				
				
from				
work.dbo.Ship_Ret_Dis mkt 				
inner join  				
				
(select unitnumber,CustomerName,productcode,Order_id from				
		(		
			select unitnumber,Step,CustomerName,productcode,Order_id,dense_rank() over(partition by UnitNumber,productcode order by Step desc) rn	
			from work.dbo.Ship_Ret_Dis	
			where customername is not null	
				
		)		
		a		
	where rn=1			
)				
				
b				
				
 on				
	b.UnitNumber=mkt.UnitNumber and b.productcode +'D'=mkt.productcode  			
		inner join #Returned ret on ret.Order_id=b.Order_id		
	where mkt.Disposition='Discarded'			
				
delete  from work.dbo.Ship_Ret_Dis where CustomerName is  null and Disposition='Discarded'				
				
update  final				
	set final.ProductAge = sh.ProductAge			
				
	from			
	work.dbo.Ship_Ret_Dis final 			
	inner join #shipped sh on sh.UnitNumber=final.UnitNumber 			
	where sh.step=1 and final.disposition<>'Discarded'			
	and sh.Product_Inventory_ID=final.Product_Inventory_ID			
				
				
	update  final			
	set final.ProductAge = sh.ProductAge			
				
	from			
	work.dbo.Ship_Ret_Dis final 			
	inner join #shipped sh on sh.UnitNumber=final.UnitNumber 			
	where sh.step=1 and final.disposition='Discarded'			
	and sh.productcode+'D'=final.productcode			
				
				
	select UnitNumber,			
	--FORMAT(cast(CollectionDate as Date) ,'MM/dd/yyyy') 			
	CollectionDate,			
	--FORMAT(cast(ShippedDate as Date),'MM/dd/yyyy') 			
	ShippedDate,CustomerName,			
	--FORMAT(cast(DiscardDate as Date),'MM/dd/yyyy') 			
	DiscardDate,	DiscardReason,		
	ProductGroup,ProductCode,			
	Product,			
	ISBTCode,ProductAge,Disposition			
	from work.dbo.Ship_Ret_Dis			
	where  Disposition<>'Shipped'			
	order by CollectionDate asc			
