use stage				
				
IF OBJECT_ID('tempdb..#hsi') IS NOT NULL				
DROP TABLE #hsi				
select PRODUCT_INVENTORY_ID,ORDER_FORM_DETAILS_ID,LABEL_ID,HS_LAB_LOCATION_ID,SHIP_VALIDATE_DATE				
into #hsi				
from				
(				
	select PRODUCT_INVENTORY_ID,ORDER_FORM_DETAILS_ID,LABEL_ID,HS_LAB_LOCATION_ID,SHIP_VALIDATE_DATE,			
	row_number() over(partition by PRODUCT_INVENTORY_ID,ORDER_FORM_DETAILS_ID,LABEL_ID,HS_LAB_LOCATION_ID order by SHIP_VALIDATE_DATE desc) rn			
	from stage.dbo.STG_RSAShippedInventory  where cast(SHIP_VALIDATE_DATE as date) >='2017-01-01'			
and cast(SHIP_VALIDATE_DATE as date) < '2018-06-15'				
	) src			
where rn =1		
;


select *
from #hsi		
				
				
IF OBJECT_ID('tempdb..#tempReturns') IS NOT NULL				
    DROP TABLE #tempReturns				
				
		 select  ret.ORDER_ID,cust.CUSTOMER_ID,prodinv.PRODUCT_CODE,prodinv.product_inventory_id,prodinv.REFERENCE_PRODUCT_INV_ID,ret.return_location_id,lab.isbt_product_code,dd.datekey,lab.Abo_rh,UNIT_NUMBER 		
	   into  #tempReturns			
			    from  stage.dbo.STG_RSAHsReturns ret 	
  				inner join integration.[dbo].[DimDate] dd on cast(ret.RETURN_DATE as date) =cast(dd.date as date)
  				inner join stage.dbo.STG_RSAOrderMain main on ret.ORDER_ID = main.ORDER_ID
				inner join stage.dbo.STG_RSAorderform form on form.order_id =  main.ORDER_ID
				inner join stage.dbo.STG_RSAorderformdetails dtls on dtls.order_form_id = form.order_form_id 
				inner join stage.dbo.stg_rsashippedinventory ship on ship.order_form_details_id =dtls.order_form_details_id
				and  ship.product_inventory_id = ret.product_inventory_id
			  inner join stage.dbo.STG_RSAHSCustomers cust on cust.CUSTOMER_ID = isnull(main.BILL_TO_CUSTOMER,main.SHIP_TO_FACILITY)	
  				inner join stage.dbo.STG_RSACLProductInventory prodinv on prodinv.product_inventory_id=ret.product_inventory_id
  			    inner join stage.dbo.STG_RSADonation don on don.registration_id =prodinv.registration_id	
  				inner join stage.dbo.STG_RSALBLabel lab on lab.label_id = ship.label_id
		 where ret.return_Date >='20170101'		
  			and	  ret.return_date <'20180615'
				
				
				
IF OBJECT_ID('tempdb..#Shipped1') IS NOT NULL				
    DROP TABLE #Shipped1				
				
select  				
 distinct				
 UnitNumber,CollectionDate,cast(NULL  as date) AS  [DiscardDate],cast(NULL  as date) AS  [ExpirationDate], cast(NULL as varchar) as DiscardReason,				
 ShippedDate, CustomerName, ProductGroup,ProductCode,Product,				
 product_inventory_id,reference_product_inv_id,				
ISBT_PRODUCT_CODE as ISBTCode,ORDER_ID,ReturnDateKey				
 into #Shipped1				
from				
(				
select				
mkt.registrationid,cast(dd.date as Date) AS  [CollectionDate],mkt.unitnumber,				
NULL as [Discard_Date],				
cust.customername,				
inv.product_inventory_id as [Product_Inventory_ID],inv.reference_product_inv_id				
,prod.ProductGroup,prod.productcode,prod.description as Product,prod.productstatus				
,cast(rsainv.ship_validate_date as Date) AS[ShippedDate],lbl.ISBT_PRODUCT_CODE,odm.ORDER_ID,temp.datekey as ReturnDateKey				
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
left join INTEGRATION.dbo.[INT_DIMCustomer] cust on odm.SHIP_TO_FACILITY=cust.CustomerID 				
left join #tempReturns temp on unitnumber= temp.unit_number and odm.ORDER_ID=temp.ORDER_ID and ProductCode=temp.Product_Code				
where source='RSA' and cust.enddate is null				
and  cast(SHIP_VALIDATE_DATE as date) >='2017-01-01' and cast(SHIP_VALIDATE_DATE as date) < '2018-06-15'				
	='W036817751235'			
)				
 				
a where ShippedDate is not null				
order by unitnumber				
				
				
IF OBJECT_ID('tempdb..#Shipped') IS NOT NULL				
    DROP TABLE #Shipped				
				
				
select  UnitNumber,cast(CollectionDate as date) CollectionDate,DiscardDate,ExpirationDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product				
, product_inventory_id,reference_product_inv_id,ISBTCode, ORDER_ID,				
datediff(day, cast(CollectionDate as date), ShippedDate) as ProductAge,				
 'FirstShipped'  as Disposition,				
1 as Step,cast(NULL as varchar) as ReturnStatus				
into #Shipped				
from				
(				
  select UnitNumber,CollectionDate,DiscardDate,ExpirationDate,DiscardReason,ShippedDate,CustomerName,ProductGroup,ProductCode,Product, product_inventory_id,reference_product_inv_id,ISBTCode,ORDER_ID,ReturnDateKey,				
    row_number() over(partition by UnitNumber,productcode,ORDER_ID order by ORDER_ID) rn				
				
  from #Shipped1 				
 ) src				
where rn =1				
				
				
				
IF OBJECT_ID('tempdb..#Returned') IS NOT NULL				
    DROP TABLE #Returned				
				
select				
				
sh.UnitNumber,sh.CollectionDate,cast(NULL  as date) AS  [DiscardDate],cast(NULL  as date) AS  [ExpirationDate],				
cast(NULL as varchar) as DiscardReason,				
cast(ret.return_Date as Date) AS [ReturnedDate],sh.CustomerName,sh.ProductGroup,sh.ProductCode,sh.Product				
,inv.product_inventory_id as [Product_Inventory_ID],inv.reference_product_inv_id,sh.ISBTCode,  main.ORDER_ID,				
ProductAge,				
'Returned' as Disposition,'2' as Step,				
case 				
when ret.dispostion_reason=2 then 'D'  				
else 'I' 				
end  ReturnStatus				
				
into  #Returned				
	          			
from 				
				
#Shipped sh left join stage.dbo.STG_RSACLProductInventory inv 				
on inv.product_inventory_id=sh.Product_Inventory_ID				
left join stage.dbo.STG_RSAHsReturns ret on ret.product_inventory_id=sh.product_inventory_id 				
and inv.product_inventory_id=ret.product_inventory_id				
left join stage.dbo.STG_RSAOrderMain main on ret.ORDER_ID = main.ORDER_ID and ret.ORDER_ID=sh.ORDER_ID				
left join stage.dbo.STG_RSAorderform form on form.order_id =  main.order_id				
inner join stage.dbo.STG_RSAorderformdetails dtls on dtls.order_form_id = form.order_form_id 				
inner join #hsi ship on ship.order_form_details_id =dtls.order_form_details_id				
and  ship.product_inventory_id = ret.product_inventory_id				
where ret.return_Date >='2017-01-01' and	  ret.return_date <'2018-06-15'			
				
				
				
				
IF OBJECT_ID('tempdb..#Discarded') IS NOT NULL				
    DROP TABLE #Discarded				
				
select  				
 distinct				
 UnitNumber,cast(CollectionDate as date) CollectionDate,cast(Discard_Date as Date) AS  [DiscardDate],ExpirationDate,				
 DiscardReason,				
 cast(NULL  as date) as [ShippedDate], cast(NULL as varchar(100)) as CustomerName, ProductGroup,ProductCode,Product,product_inventory_id,reference_product_inv_id,				
ISBT_PRODUCT_CODE as ISBTCode,cast(NULL as varchar) as ORDER_ID,				
NULL as ProductAge,				
'Discarded' as Disposition,'6' as Step,cast(NULL as varchar) as ReturnStatus				
 into #Discarded				
from				
				
(				
select				
mkt.registrationid,cast(dd.date as Date) AS  [CollectionDate],mkt.unitnumber,dd1.date as [Discard_Date],ExpirationDate,				
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
--where dis.unitnumber='W036817751235'				
where				
 exists (select  1 from #Shipped				
Where unitnumber= mkt.unitnumber and productcode +'D'=inv.product_code) 				
				
and  exists (select  1 from #Returned				
Where unitnumber= mkt.unitnumber and productcode+'D'=inv.product_code) 				
				
)				
				
a 				
order by unitnumber				
				
				
IF OBJECT_ID('tempdb..#Temp') IS NOT NULL				
    DROP TABLE #Temp				
				
select unitnumber,product_inventory_id,REFERENCE_PRODUCT_INV_ID,ORDER_ID				
into #Temp				
from				
(				
  select unitnumber,product_inventory_id,REFERENCE_PRODUCT_INV_ID,ORDER_ID,				
  row_number() over(partition by unitnumber,product_inventory_id,REFERENCE_PRODUCT_INV_ID order by ORDER_ID desc) rn				
  from #Returned 				
  ) src				
where rn =1				
				
--Update ReturnStatus in #Returned exclusively for discarded units which was not marked in STG_RSAHsReturns				
update  ret set ret.ReturnStatus = 'D'				
--select ret.*				
from				
#Returned ret 				
inner join #Discarded dis on dis.UnitNumber=ret.UnitNumber 				
and dis.REFERENCE_PRODUCT_INV_ID=ret.Product_Inventory_ID				
inner join #Temp tem on tem.UnitNumber=ret.UnitNumber and tem.Product_Inventory_ID=ret.Product_Inventory_ID and tem.ORDER_ID=ret.ORDER_ID				
where ret.ReturnStatus='I' and dis.ReturnStatus is null				
--and ret.unitnumber='W036817063829'				
				
				
				
update  mkt				
set mkt.CustomerName = b.CustomerName,mkt.ORDER_ID=b.Order_id,Returnstatus='D'				
				
				
from				
#Discarded mkt 				
inner join  				
				
(select unitnumber,CustomerName,productcode,Order_id from				
		(		
			select unitnumber,Step,CustomerName,productcode,Order_id,dense_rank() over(partition by UnitNumber,productcode,Order_id order by Step desc) rn	
			from work.dbo.Ship_Ret_Dis_Territory	
			--where unitnumber='W036817751235' 	
			where customername is not null	
				
		)		
		a		
	where rn=1			
)				
				
b				
				
 on				
	b.UnitNumber=mkt.UnitNumber and b.productcode +'D'=mkt.productcode  			
	inner join #Returned ret on ret.Order_id=b.Order_id			
	and ret.ReturnStatus='D'			
	where mkt.Disposition='Discarded'			
				
				
				
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
select * from #Discarded 				
				
)				
a 				
				
				
drop table work.dbo.Ship_Ret_Dis_Territory				
select a.* ,case when ShippedDate is not null then ShippedDate else				
	DiscardDate end TransactionDate			
into work.dbo.Ship_Ret_Dis_Territory 				
from #Result a				
order by UnitNumber,Step				
				
				
update  final				
set final.ProductAge = sh.ProductAge				
				
from				
work.dbo.Ship_Ret_Dis_Territory final 				
inner join #shipped sh on sh.UnitNumber=final.UnitNumber 				
where sh.step=1 and final.disposition<>'Discarded'				
and sh.Product_Inventory_ID=final.Product_Inventory_ID				
				
				
update  final				
set final.ProductAge = sh.ProductAge				
				
from				
work.dbo.Ship_Ret_Dis_Territory final 				
inner join #shipped sh on sh.UnitNumber=final.UnitNumber 				
where sh.step=1 and final.disposition<>'Discarded'				
and sh.Product_Inventory_ID=final.Product_Inventory_ID				
				
				
update  final				
set final.ProductAge = sh.ProductAge				
				
from				
work.dbo.Ship_Ret_Dis_Territory final 				
inner join #shipped sh on sh.UnitNumber=final.UnitNumber 				
where sh.step=1 and final.disposition='Discarded'				
and sh.productcode+'D'=final.productcode				
				
				
				
IF OBJECT_ID('tempdb..#Reshipped') IS NOT NULL				
DROP TABLE #Reshipped				
				
select * 				
into #Reshipped				
from work.dbo.Ship_Ret_Dis_Territory where Disposition in ('FirstShipped','Returned')				
and returnstatus<>'D'				
--and unitnumber='W239618018737'				
order by customername,order_id,TransactionDate,product_inventory_id				
				
--select * from #Reshipped				
update #Reshipped set disposition='Re-Shipped',Step=3				
				
insert into work.dbo.Ship_Ret_Dis_Territory 				
select *  from #Reshipped				
				
				
Update #Discarded set ReturnStatus='D' where CustomerName is  null and Disposition='Discarded'				
				
				
				
				
				
				
				
				
				
--where unitnumber='W036818039710' 				
				
				
				
				
				
				
				
IF OBJECT_ID('tempdb..#TotalExpired') IS NOT NULL				
    DROP TABLE #TotalExpired				
				
  				
select 				
				
UnitNumber,				
cast(dt1.Date as date) as DrawDate,				
ExpirationDate				
,cast(dt.Date as date) as DiscardDate,				
				
dt.[Year],				
dt.[Monthname],cast(dt.Month as int)  as Month 				
,pro.ProductGroup				
--,Description as Product				
				
--,count(1) as [TotalExpired]				
				
--into #TotalExpired				
				
from integration.dbo.[INT_FCTProductDiscardsWithReason] dis				
inner join Integration.dbo.DimDate dt on dis.discarddatesk=dt.DateKey				
inner join Integration.dbo.DimDate dt1 on dis.DrawDateSK=dt1.DateKey				
left join INTEGRATION.dbo.INT_DIMDiscardReason rea on dis.DiscardSk=rea.DiscardSk				
left join INTEGRATION.dbo.INT_DIMProducts pro on  dis.Prodsk=pro.ProdSK 				
where isnull(discardRSADesc,DiscardDesc)='Expired' 				
and ProductGroup not in  ('LPC','RECOVERED PLASMA')				
and discarddatesk between 20170101 and 20180615				
				
				
				
				
				
				
				
				
				
IF OBJECT_ID('tempdb..#TotalExpiredOutOfReturn') IS NOT NULL				
DROP TABLE #TotalExpiredOutOfReturn				
				
				
select 				
				
--UnitNumber,				
--CollectionDate as DrawDate,				
--ExpirationDate,				
--cast(dt.Date as date) as DiscardDate,				
				
				
dt.[Year],				
dt.[Monthname],cast(dt.Month as int) as Month				
,ProductGroup				
--,Product 				
				
,count(1) as [TotalExpiredOutOfReturn]				
into #TotalExpiredOutOfReturn				
				
				
from 				
(				
select distinct a.unitnumber,b.DiscardDate,a.CollectionDate,b.ExpirationDate,a.ProductGroup,a.Product from 				
(select distinct unitnumber,CollectionDate,ExpirationDate,DiscardDate,ProductGroup,Product from work.dbo.Ship_Ret_Dis_Territory where disposition in  ('Returned')) a 				
left join 				
(select distinct unitnumber,ProductGroup,Product,CollectionDate,ExpirationDate,DiscardDate from work.dbo.Ship_Ret_Dis_Territory where disposition in  ('Discarded') and DiscardReason='Expired') b				
on a.unitnumber=b.unitnumber and a.Product=b.Product				
)				
b				
inner join Integration.dbo.DimDate dt on b.DiscardDate=dt.date				
where 				
DiscardDate is not null 				
				
				
group by cast(dt.Month as int),dt.Monthname,dt.Year,ProductGroup				
				
				
				
				
				
select TotExp.Year,TotExp.MonthName,TotExp.Month,TotExp.ProductGroup,TotalExpired,isnull(TotalExpiredOutOfReturn,0) TotalExpiredOutOfReturn 				
from #TotalExpired TotExp left join 				
#TotalExpiredOutOfReturn TotExpRet on 				
TotExpRet.Month=TotExp.Month and TotExpRet.Year=TotExp.Year and TotExpRet.ProductGroup=TotExp.ProductGroup				
order by TotExp.Year,TotExp.Month,TotExp.ProductGroup				
