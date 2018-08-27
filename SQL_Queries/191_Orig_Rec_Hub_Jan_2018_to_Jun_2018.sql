			
--Make sure below 4 tables are refreshed.			
			
			
--select * from stage.[dbo].[STG_RSACLRECPLASMACARTON]			
--select * from stage.[dbo].[STG_RSACLRECPLASMAINVENTORY] 			
--select * from stage.[dbo].[STG_RSACLRECPLASMASHIPPING]			
			
 --select * from stage.[dbo].[STG_RSACLStorage] 			
 --select * from stage.[dbo].[STG_RSACLProductStorage] 			
			
IF OBJECT_ID('tempdb..#Transfer') IS NOT NULL			
    DROP TABLE #Transfer			
			
select  product_inventory_id,shelf_id, barcode_id,storage_id ,In_Transit_source_center_id,Create_date			
into #Transfer			
from			
(			
  select product_inventory_id,shelf_id, barcode_id,Pst.storage_id ,In_Transit_source_center_id,Create_date,			
    dense_rank() over(partition by product_inventory_id order by Create_date desc) rn			
   from  stage.[dbo].[STG_RSACLStorage] St 
   left join stage.[dbo].[STG_RSACLProductStorage] PSt 
	on  Pst.storage_id = St.storage_id 
	--and St.barcode_id = 'IN TRANSIT TO' 			
where  St.Create_Date between '2017-01-01' and '2018-08-30' 			
  ) src			
where rn =1			
--select * from #Transfer where pRODUCT_INVENTORY_ID=35676037			
			
--select * from #Transfer order by create_date desc			
			
			
IF OBJECT_ID('tempdb..#Temp') IS NOT NULL			
    DROP TABLE #Temp			
			
select fct.UnitNumber,fct.RSAProductCode as ProductCode,Inv.product_inventory_id,fct.RSAProductDescription as ProductDescription			
,CenterName as OriginalHub,Shelf_ID as ReceivingHub,Trans.Create_Date as TransferDate,lab.LABEL_DATE LabelDate,lab.exp_date ExpiryDate,fct.ABO_RH as ABO,			
datediff(day,Trans.Create_Date,lab.exp_date)as DaystoExpire			
 into #Temp			
 from (select distinct unitnumber,RSAProductCode,RSAProductDescription,ExpiryDate,LabelDate,ABO_RH,RSAStorageLocationCode from integration.[dbo].[INT_FCT_BIO_InventoryDetail]) fct 			
			
inner join integration.dbo.INT_MKTCollectionDetails mkt on fct.unitnumber=mkt.unitnumber			
--left join EBIimport.[dbo].[RSA_ISBT_COMPONENT_MAP] map on map.Product_Code=fct.RSAProductCode			
left join stage.dbo.STG_RSACLProductInventory Inv on Inv.Registration_id=mkt.Registrationid and Inv.PRODUCT_CODE=fct.RSAPRODUCTCODE			
left join stage.dbo.STG_RSALBLabel lab on lab.PRODUCT_INVENTORY_ID = Inv.PRODUCT_INVENTORY_ID			
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code 			
and ClassifierGroup in ( 'LR RBC','NON LR RBC','NLRLOWVOL','LRLOWVOL')			
inner join #Transfer Trans on Trans.PRODUCT_INVENTORY_ID= Inv.PRODUCT_INVENTORY_ID 			
left join integration.dbo.INT_DIMInventoryCenter InvC on InvC.RSACenterID=In_Transit_source_center_id           			
where 			
ClassifierGroup in ( 'LR RBC','NON LR RBC','NLRLOWVOL','LRLOWVOL')			
and  RSAstoragelocationcode='IN' 			
			
			
--select * from #Temp where unitnumber='W036818263143'				
			
--declare @UnitNumber  varchar (20)			
--set @UnitNumber='W036818014939'			
			
			
			
			
			
IF OBJECT_ID('tempdb..#Discarded') IS NOT NULL			
    DROP TABLE #Discarded			
			
select  			
 --distinct			
 UnitNumber,CollectionDate,DriveID,AccountInternalName,cast(Discard_Date as Date) AS  [DiscardDate],cast('9999-01-01' as date) as [ShippedDate], cast(NULL as varchar) as [StorageLocation] ,cast(NULL as varchar) as CustomerName, ProductCode,Product,product_inventory_id,reference_product_inv_id,			
ISBT_PRODUCT_CODE as ISBTCode, 'Discarded' as Disposition			
 into #Discarded			
from			
(			
select			
mkt.registrationid,cast(dd.date as Date) AS  [CollectionDate],DriveID,AccountInternalName,mkt.unitnumber,dd1.date as [Discard_Date],			
inv.product_inventory_id as [Product_Inventory_ID],reference_product_inv_id			
,prod.productcode,prod.description as Product,prod.productstatus			
,NULL AS [ShippedDate],lbl.ISBT_PRODUCT_CODE			
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt inner join 			
STAGE.dbo.STG_RSARegistration reg on mkt.registrationid=reg.registration_id			
inner join INTEGRATION.dbo.DimDate dd on dd.date = cast(reg.REGISTRATION_DATE as date)			
left join stage.dbo.STG_RSACLProductInventory inv on inv.REGISTRATION_ID=reg.REGISTRATION_ID			
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id			
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code			
inner join  [INTEGRATION].[dbo].[INT_FCTProductDiscardsWithReason] dis on dis.unitnumber=mkt.unitnumber 			
and Prod.ProductCode=inv.product_code and dis.prodsk=prod.prodsk			
left join INTEGRATION.dbo.DimDate dd1 on dd1.Datekey = dis.discarddatesk 			
			
left join  #Temp temp on temp.unitnumber=mkt.unitnumber 			
and temp.product_inventory_id=inv.product_inventory_id 			
                                                                                                                                                                                                        			
--where mkt.unitnumber ='W036817980344'			
where mkt.collectiondatesk between 20171201 and 20180630			
			
			
)			
a 			
order by unitnumber			
			
			
select count(1) as Discarded from #Discarded			
--select * from #Discarded where unitnumber='W036817980344'			
			
			
			
IF OBJECT_ID('tempdb..#Manufactured') IS NOT NULL			
    DROP TABLE #Manufactured			
			
select  			
 UnitNumber,CollectionDate,DriveID,AccountInternalName,cast('9999-01-01' as date) AS  [DiscardDate],cast('9999-01-01' as date) as [ShippedDate], NULL as [StorageLocation] ,cast(NULL as varchar) as CustomerName, ProductCode,Product,			
 product_inventory_id,reference_product_inv_id,			
ISBT_PRODUCT_CODE as ISBTCode,'Manufactured' as Disposition			
 into #Manufactured			
from			
(			
select 			
mkt.registrationid,cast(dd.date as Date) AS  [CollectionDate],DriveID,AccountInternalName,mkt.unitnumber,			
NULL as [Discard_Date],			
inv.product_inventory_id as [Product_Inventory_ID],reference_product_inv_id			
,prod.productcode,prod.description as Product,prod.productstatus,lbl.ISBT_PRODUCT_CODE			
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt inner join 			
STAGE.dbo.STG_RSARegistration reg on mkt.registrationid=reg.registration_id			
inner join INTEGRATION.dbo.DimDate dd on dd.date = cast(reg.REGISTRATION_DATE as date)			
inner join stage.dbo.STG_RSACLProductInventory inv on inv.REGISTRATION_ID=reg.REGISTRATION_ID			
inner join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code 			
and ClassifierGroup in ( 'LR RBC','NON LR RBC','NLRLOWVOL','LRLOWVOL')			
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id			
left join  #Temp temp on temp.unitnumber=mkt.unitnumber 			
and temp.product_inventory_id=inv.product_inventory_id 			
                                                                                                                                                                                 			
--where mkt.unitnumber ='W036817736811'			
where mkt.collectiondatesk between 20171201 and 20180630			
			
and not exists			
(select 1			
 from stage.dbo.STG_RSACLProductInventory x			
 where x.reference_product_inv_id = inv.product_inventory_id			
 )                                                                                                                                                           			
and not exists 			
			
(select  1 from #Discarded			
Where unitnumber= mkt.unitnumber and productcode=inv.product_code			
)			
			
)			
			
a			
			
			
select  count (1) from #Manufactured 			
--where unitnumber='W036817736811'			
			
--select *  from #Manufactured where unitnumber='W036818453863'			
			
			
			
IF OBJECT_ID('tempdb..#Shipped1') IS NOT NULL			
    DROP TABLE #Shipped1			
			
select  			
 distinct			
 UnitNumber,CollectionDate,DriveID,AccountInternalName,cast('9999-01-01' as date) AS  [DiscardDate],ShippedDate, cast(NULL as varchar) as [StorageLocation] ,CustomerName, ProductCode,Product,			
 product_inventory_id,reference_product_inv_id,			
ISBT_PRODUCT_CODE as ISBTCode,'Shipped' as Disposition			
 into #Shipped1			
from			
(			
select			
mkt.registrationid,cast(dd.date as Date) AS  [CollectionDate],mkt.DriveID,mkt.AccountInternalName,mkt.unitnumber,			
NULL as [Discard_Date],			
cust.customername,			
inv.product_inventory_id as [Product_Inventory_ID],inv.reference_product_inv_id			
,prod.productcode,prod.description as Product,prod.productstatus			
,cast(rsainv.ship_validate_date as Date) AS[ShippedDate],lbl.ISBT_PRODUCT_CODE			
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt inner join 			
STAGE.dbo.STG_RSARegistration reg on mkt.registrationid=reg.registration_id			
inner join INTEGRATION.dbo.DimDate dd on dd.date = cast(reg.REGISTRATION_DATE as date)			
left join stage.dbo.STG_RSACLProductInventory inv on inv.REGISTRATION_ID=reg.REGISTRATION_ID			
left join stage.dbo.stg_rsashippedinventory rsainv on rsainv.product_inventory_id=inv.product_inventory_id			
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id			
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code			
and ClassifierGroup in ( 'LR RBC','NON LR RBC','NLRLOWVOL','LRLOWVOL')			
inner join #Manufactured manf on manf.unitnumber=mkt.unitnumber 			
left  join stage.dbo.STG_RSAOrderFormDetails odt on rsainv.ORDER_FORM_DETAILS_ID=odt.ORDER_FORM_DETAILS_ID			
left join stage.dbo.STG_RSAOrderForm odf on odf.ORDER_FORM_ID=odt.ORDER_FORM_ID 			
left join stage.dbo.STG_RSAOrderMain odm on odm.ORDER_ID=odf.ORDER_ID			
left join INTEGRATION.dbo.[INT_DIMCustomer] cust on odm.SHIP_TO_FACILITY=cust.CustomerID and cust.enddate is null			
			
left join  #Temp temp on temp.unitnumber=mkt.unitnumber 			
and temp.product_inventory_id=inv.product_inventory_id 			
                                                                                                                                                                                                          			
--where mkt.unitnumber ='W036817479785'			
			
where mkt.collectiondatesk between 20171201 and 20180630			
			
)			
a where ShippedDate is not null			
order by unitnumber			
			
			
IF OBJECT_ID('tempdb..#Shipped') IS NOT NULL			
    DROP TABLE #Shipped			
			
			
select  UnitNumber,CollectionDate,DriveID,AccountInternalName,DiscardDate,ShippedDate,StorageLocation,CustomerName,ProductCode,Product			
, product_inventory_id,reference_product_inv_id,ISBTCode, Disposition			
into #Shipped			
from			
(			
  select UnitNumber,CollectionDate,DriveID,AccountInternalName,DiscardDate,ShippedDate,StorageLocation,CustomerName,ProductCode,Product, product_inventory_id,reference_product_inv_id,ISBTCode,Disposition,			
    dense_rank() over(partition by UnitNumber,productcode order by ShippedDate desc) rn			
  from #Shipped1			
  ) src			
where rn =1			
			
select count(1) as Shipped from #Shipped			
			
--select *  from #Shipped where unitnumber='W036817479785'			
			
--select * from #Shipped			
			
			
			
IF OBJECT_ID('tempdb..#ShippedPlasma') IS NOT NULL			
    DROP TABLE #ShippedPlasma			
			
select  			
 distinct			
 UnitNumber,CollectionDate,DriveID,AccountInternalName,cast('9999-01-01' as date) AS  [DiscardDate],ShippedDate, cast(NULL as varchar) as [StorageLocation] ,CustomerName, ProductCode,Product, product_inventory_id,reference_product_inv_id,			
ISBT_PRODUCT_CODE as ISBTCode, 'Shipped' as Disposition			
 into #ShippedPlasma			
from			
(			
select			
mkt.registrationid,cast(dd.date as Date) AS  [CollectionDate],mkt.DriveID,mkt.AccountInternalName,mkt.unitnumber,			
NULL as [Discard_Date],			
cust.customername,			
inv.product_inventory_id as [Product_Inventory_ID], inv.reference_product_inv_id			
,prod.productcode,prod.description as Product,prod.productstatus			
,cast(plaship.ship_date as Date) AS [ShippedDate],lbl.ISBT_PRODUCT_CODE			
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt inner join 			
STAGE.dbo.STG_RSARegistration reg on mkt.registrationid=reg.registration_id			
inner join INTEGRATION.dbo.DimDate dd on dd.date = cast(reg.REGISTRATION_DATE as date)			
left join stage.dbo.STG_RSACLProductInventory inv on inv.REGISTRATION_ID=reg.REGISTRATION_ID			
left join stage.[dbo].[STG_RSACLRECPLASMAINVENTORY] plainv on plainv.product_inventory_id=inv.product_inventory_id			
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id			
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code			
and ClassifierGroup in ( 'LR RBC','NON LR RBC','NLRLOWVOL','LRLOWVOL')			
inner join #Manufactured manf on manf.unitnumber=mkt.unitnumber 			
left  join stage.[dbo].[STG_RSACLRECPLASMACARTON] placar on placar.CARTON_ID=plainv.CARTON_ID			
left join stage.[dbo].[STG_RSACLRECPLASMASHIPPING] plaship on plaship.SHIPMENT_ID=placar.SHIPMENT_ID 			
left join INTEGRATION.dbo.[INT_DIMCustomer] cust on plaship.CUSTOMER_ID=cust.CustomerID and cust.enddate is null			
 			
left join  #Temp temp on temp.unitnumber=mkt.unitnumber 			
and temp.product_inventory_id=inv.product_inventory_id 			
                                                                                                                                                                                                      			
--where mkt.unitnumber =@UnitNumber			
where mkt.collectiondatesk between 20171201 and 20180630			
)			
a where ShippedDate is not null			
order by unitnumber			
			
select count(1) as ShippedPlasma from #ShippedPlasma			
			
--select *  from #ShippedPlasma where unitnumber='W036818123940'			
			
			
			
IF OBJECT_ID('tempdb..#Inventory') IS NOT NULL			
    DROP TABLE #Inventory			
			
select  			
			
 UnitNumber,CollectionDate,DriveID,AccountInternalName,cast('9999-01-01' as date) AS  [DiscardDate],cast('9999-01-01' as date) as [ShippedDate], NULL as [StorageLocation] ,cast(NULL as varchar) as CustomerName, ProductCode,Product,			
 product_inventory_id,reference_product_inv_id,			
ISBT_PRODUCT_CODE as ISBTCode, 'In Inventory' as Disposition			
 into #Inventory			
from			
(			
select			
mkt.registrationid,cast(dd.date as Date) AS  [CollectionDate],mkt.DriveID,mkt.AccountInternalName,mkt.unitnumber,			
inv.product_inventory_id as [Product_Inventory_ID],inv.reference_product_inv_id			
,prod.productcode,prod.description as Product,prod.productstatus,lbl.ISBT_PRODUCT_CODE			
from [INTEGRATION].[dbo].INT_MKTCollectionDetails mkt inner join 			
STAGE.dbo.STG_RSARegistration reg on mkt.registrationid=reg.registration_id			
inner join INTEGRATION.dbo.DimDate dd on dd.date = cast(reg.REGISTRATION_DATE as date)			
left join stage.dbo.STG_RSACLProductInventory inv on inv.REGISTRATION_ID=reg.REGISTRATION_ID			
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id			
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code			
and ClassifierGroup in ( 'LR RBC','NON LR RBC','NLRLOWVOL','LRLOWVOL')			
inner join #Manufactured manf on manf.unitnumber=mkt.unitnumber and manf.productcode=prod.productcode			
			
left  join  #Temp temp on temp.unitnumber=mkt.unitnumber 			
and temp.product_inventory_id=inv.product_inventory_id 			
                                                                                                                                                                                    			
--where  mkt.unitnumber ='W036818123940'			
where mkt.collectiondatesk between 20171201 and 20180630			
    			
			
 and not exists (select  1 from #Shipped			
Where unitnumber= mkt.unitnumber and productcode=inv.product_code) 			
     			
 and not exists (select  1 from #ShippedPlasma			
Where unitnumber= mkt.unitnumber and productcode=inv.product_code) 	 		
	                                                                                                                                                                                    		
			
)			
a 			
order by unitnumber			
			
--select * from #shipped where unitnumber='W036817736811'			
--select * from #Inventory where unitnumber='W036818453863'			
			
			
--select count(1) as [Manufactured] from #Manufactured			
--select count(1) as [In Inventory] from #Inventory			
			
			
			
			
			
			
IF OBJECT_ID('tempdb..#Result') IS NOT NULL			
    DROP TABLE #Result			
			
select * into 			
#Result			
from  			
(			
select * from #Discarded 			
union all			
select * from #Shipped 			
union all			
select * from #ShippedPlasma 			
union all			
select * from #Inventory			
)			
a 			
			
			
			
IF OBJECT_ID('tempdb..#Final') IS NOT NULL			
    DROP TABLE #Final			
			
select distinct Temp.UnitNumber,Temp.ProductCode,Temp.product_inventory_id,Temp.ProductDescription,temp.OriginalHub,ReceivingHub,			
TransferDate,LabelDate,ExpiryDate,ABO,DaysToExpire,Disposition 			
into #Final			
from 			
#Temp temp left join #Result Res			
on temp.unitnumber=Res.unitnumber 			
and temp.product_inventory_id=Res.product_inventory_id 			
--where Temp.UnitNumber='W239817084088'			
			
			
			
--select * from #Discarded where unitnumber='W036817980344'			
			
			
                                                          			
--select * from #Result where unitnumber='W036818123940'			
--select  * from #Temp			
--select * into work.dbo.ABC from #Result			
			
			
		IF OBJECT_ID('tempdb..#hsi') IS NOT NULL	
		DROP TABLE #hsi	
		select PRODUCT_INVENTORY_ID,ORDER_FORM_DETAILS_ID,LABEL_ID,HS_LAB_LOCATION_ID,SHIP_VALIDATE_DATE	
		into #hsi	
		from	
		(	
		  select PRODUCT_INVENTORY_ID,ORDER_FORM_DETAILS_ID,LABEL_ID,HS_LAB_LOCATION_ID,SHIP_VALIDATE_DATE,	
			row_number() over(partition by PRODUCT_INVENTORY_ID,ORDER_FORM_DETAILS_ID,LABEL_ID,HS_LAB_LOCATION_ID order by SHIP_VALIDATE_DATE desc) rn
		  from stage.dbo.STG_RSAShippedInventory  where cast(SHIP_VALIDATE_DATE as date) >='2017-01-01'	
		and cast(SHIP_VALIDATE_DATE as date) < '2018-06-10'	
		  ) src	
		where rn =1	
			
			
			
			
			
			
IF OBJECT_ID('tempdb..#Converted') IS NOT NULL			
DROP TABLE #Converted			
			
select			
ret.unitnumber,cast(rsainv.ship_validate_date as Date) AS[ShippedDate],			
inv.product_inventory_id as [Product_Inventory_ID],inv.reference_product_inv_id			
,prod.ProductGroup,prod.productcode,prod.description as Product,prod.productstatus,			
			
case when cast(rsainv.ship_validate_date as Date) is not null then 'Shipped' end Disposition			
into #Converted			
from (select * from #Final where disposition is null) ret			
left join stage.dbo.STG_RSACLProductInventory inv on inv.reference_product_inv_id=ret.product_inventory_id			
left join #hsi rsainv on rsainv.product_inventory_id=inv.product_inventory_id			
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id			
left join [STAGE].[dbo].[STG_RSALBCodabarISBTMap] map on map.ISBT_code=lbl.ISBT_PRODUCT_CODE			
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code			
			
			
--where ret.unitnumber='W036817893483'			
			
			
			
update  final			
set final.Disposition = sh.Disposition,			
final.ProductDescription=sh.Product			
from			
#Final final 			
inner join #Converted sh on sh.UnitNumber=final.UnitNumber and 			
sh.REFERENCE_PRODUCT_INV_ID=final.product_inventory_id and final.Disposition is null			
--select * from  #Converted where unitnumber='W036818265142'			
--select * from  #Final where unitnumber='W036818265142'			
			
			
			
update  final			
set final.Disposition = 'Discarded',			
final.ProductDescription=sh.Product			
from			
#Final final 			
inner join #Converted sh on sh.UnitNumber=final.UnitNumber and 			
sh.REFERENCE_PRODUCT_INV_ID=final.product_inventory_id and final.Disposition is null			
and  sh.productstatus=99			
--select * from  #Converted where unitnumber='W036818265142'			
--select * from  #Final where unitnumber='W036818265142'			
			
--select * from  #Converted where disposition is null and ProductStatus=99			
			
			
update  final			
set final.Disposition = dis.Disposition			
			
from			
#Final final 			
inner join #Discarded dis on dis.UnitNumber=final.UnitNumber 			
and final.productcode +'D'=dis.productcode   and final.Disposition is null			
where dis.disposition='Discarded' 			
			
			
			
update  final			
set final.Disposition = sh.Disposition,			
final.ProductDescription=sh.Product			
from			
#Final final 			
inner join #Inventory sh on sh.UnitNumber=final.UnitNumber and 			
sh.REFERENCE_PRODUCT_INV_ID=final.product_inventory_id and final.Disposition is null			
--select * from  #Converted where unitnumber='W239817084088'			
			
			
update  final			
set final.Disposition = sh.Disposition,			
final.ProductDescription=sh.Product			
from			
#Final final 			
inner join #Shipped sh on sh.UnitNumber=final.UnitNumber and 			
sh.REFERENCE_PRODUCT_INV_ID=final.product_inventory_id and final.Disposition is null			
--select * from  #Converted where unitnumber='W239817084088'			
			
			
			
update  final			
set final.Disposition = dis.Disposition			
			
from			
#Final final 			
inner join #Discarded dis on dis.UnitNumber=final.UnitNumber 			
and final.productdescription=dis.product  and final.Disposition is null			
where dis.disposition='Discarded' 			
			
			
			
			
			
--set final.Disposition = 'Shipped'			
			
			
			
--#Final final 			
--inner join #Converted dis on dis.UnitNumber=final.UnitNumber 			
			
			
--and final.UnitNumber='W036817893483'			
			
drop table test.dbo.adhoc_191			
select * 			
into test.dbo.adhoc_191			
from #Final 			
			
			
			
			
			
--select * from #Final where unitnumber='W036818265142'			
--select * from #Shipped where unitnumber='W036818265142'			
--select * from #Converted where unitnumber='W036818265142'			
--select * from #Discarded  where unitnumber='W036818265142'			
--select * from #Inventory where unitnumber='W036818265142'			
			
--select * from #Temp where unitnumber='W036818265142'			
