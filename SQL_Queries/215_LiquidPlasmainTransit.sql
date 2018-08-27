
IF OBJECT_ID('tempdb..#Transfer') IS NOT NULL
    DROP TABLE #Transfer

select  product_inventory_id,shelf_id, barcode_id,storage_id ,In_Transit_source_center_id,Create_date
into #Transfer
from
(
  select product_inventory_id,shelf_id, barcode_id,Pst.storage_id ,In_Transit_source_center_id,Create_date,
    dense_rank() over(partition by product_inventory_id order by cast(Create_date as date) desc) rn
   from  stage.[dbo].[STG_RSACLStorage] St left join stage.[dbo].[STG_RSACLProductStorage] 
PSt on  Pst.storage_id = St.storage_id and St.barcode_id = 'IN TRANSIT TO' 
where  cast(St.Create_Date as date) between '2018-01-01' and '2018-08-23' 
  ) src
where rn =1


select * from #Transfer


IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
    DROP TABLE #Temp

select fct.UnitNumber,fct.RSAProductCode as ProductCode,-- Inv.product_inventory_id,
fct.RSAProductDescription as ProductDescription
,CenterName as OriginalHub,Shelf_ID as ReceivingHub,Trans.Create_Date as TransferDate,ISBT_PRODUCT_CODE as ISBTCode,lab.LABEL_DATE LabelDate,lab.exp_date ExpiryDate,fct.ABO_RH as ABO,
datediff(day,Trans.Create_Date,lab.exp_date)as DaystoExpire
 into #Temp
 from (select distinct unitnumber,RSAProductCode,RSAProductDescription,ExpiryDate,LabelDate,ABO_RH,RSAStorageLocationCode from integration.[dbo].[INT_FCT_BIO_InventoryDetail]) fct 

inner join integration.dbo.INT_MKTCollectionDetails mkt on fct.unitnumber=mkt.unitnumber
left join stage.dbo.stg_rsaclproductinventory Inv on Inv.Registration_id=mkt.Registrationid and Inv.PRODUCT_CODE=fct.RSAPRODUCTCODE
left join stage.dbo.STG_RSALBLabel lab on lab.PRODUCT_INVENTORY_ID = Inv.PRODUCT_INVENTORY_ID
left join [INTEGRATION].[dbo].[INT_DIMProducts] prod on prod.productcode=inv.product_code 
and ClassifierGroup in ( 'LIQUID PLASMA')
inner join #Transfer Trans on Trans.PRODUCT_INVENTORY_ID= Inv.PRODUCT_INVENTORY_ID 
left join integration.dbo.INT_DIMInventoryCenter InvC on InvC.RSACenterID=In_Transit_source_center_id           
where 
ClassifierGroup in  ( 'LIQUID PLASMA')
and  RSAstoragelocationcode='IN' 


select *
from #temp