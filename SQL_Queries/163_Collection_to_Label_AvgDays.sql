
IF OBJECT_ID('tempdb..#Manufactured') IS NOT NULL
    DROP TABLE #Manufactured

select  
 Region,UnitNumber,RegistrationID,DrawTime,DonationDescription,CREATE_DATE as ProductCreateDate, centername as [ManufactLocation] , Product_Code as ProductCode,Product,
 product_inventory_id,reference_product_inv_id,product_status,label_date,MotivationName,
round((datediff(hour, drawtime, label_date)/24.0),2) as DaysTaken


 into #Manufactured
from
(
select
case When isnull(loc.RegionID,loc.RegionID)=1 then 'Region1'
When isnull(loc.RegionID,loc.RegionID)=2 then 'Region2'
When isnull(loc.RegionID,loc.RegionID)=3 then 'Region3'
When isnull(loc.RegionID,loc.RegionID)=4 then 'Region4'
When isnull(loc.RegionID,loc.RegionID)=5 then 'Region5'
When isnull(loc.RegionID,loc.RegionID)=6 then 'Region6'
When isnull(loc.RegionID,loc.RegionID)=7 then 'Region7'
When isnull(loc.RegionID,loc.RegionID)=8 then 'Region8'
Else 'Other' End as Region,

mkt.registrationid,drawtime,DonationDescription,mkt.unitnumber,
inv.product_inventory_id as [Product_Inventory_ID],reference_product_inv_id
,prod.product_code,prod.description as Product,prod.product_status,
CENTER_ID,inv.CREATE_DATE,centername,label_date,m.MotivationName as MotivationName
from  integration.dbo.INT_MKTCollectionDetails  mkt 
left join STAGE.dbo.STG_RSARegistration reg on mkt.registrationid=reg.registration_id
left join INTEGRATION.dbo.DimDate dd on dd.date = cast(reg.REGISTRATION_DATE as date)
left join integration.dbo.Int_DimDonationType don on mkt.donationtypesk=don.donationtypesk
left join stage.dbo.STG_RSACLProductInventory inv on inv.REGISTRATION_ID=reg.REGISTRATION_ID
left join stage.dbo.STG_RSALBLabel lbl on lbl.product_inventory_id=inv.product_inventory_id
left join stage.dbo.STG_RSACLProducts prod on prod.product_code=inv.product_code       
left join integration.[dbo].[INT_DIMInventoryCenter] ctr on ctr.rsacenterid = inv.CENTER_ID    
left join integration.dbo.INT_DIMLocation loc on loc.LocationSK=mkt.LocationSK
left join INTEGRATION.dbo.INT_DIMMotivation m on m.MotivationSK = mkt.MotivationSK

where cast(reg.REGISTRATION_DATE as date) >= '2017-01-01' and  cast(reg.REGISTRATION_DATE as date) <='2017-12-31'
and (mkt.unitnumber like 'W0368%'  or mkt.unitnumber like 'W2398%' )
and  import=0 and CompletedFlag=12
and prod.product_status in (50)

and lbl.validation = 1 and lbl.active = 1

                                                                                                                                                 
 and not exists (select * from stage.dbo.STG_RSAHSIMPORTS i        
 where i.product_inventory_id = inv.product_inventory_id)

 ) a   

 
select Region,DonationDescription,ManufactLocation,ClassifierGroup, MotivationName,
round(avg (DaysTaken),2) as AvgDaysTaken
from #Manufactured man
left join ebiimport.[dbo].[RSA_ISBT_COMPONENT_MAP] map on man.productcode = map.product_code 
where man.Productcode in ('0185013','0500003','0500013','0500023','0500543','0047503','0482123','0482133','0482143','0482153','0482163','0001503','0001513','0001603','0001613','0033113','0033703','0038203','0040503','0040513','0040603','0040613','0042103','0042113','0042713','0042813','0043503','0043603','0047103','0047713','0047913','0101003','0120003','0127103','0127503','0127803','0182013','0184353','0192013','0197013','0482113','BUFFY','0120913','0127113','0199013','0033603','0182113','0181013','0042303','0047303','0120703','0042313','0040803','0043803','0001803','0040813','0120643','0198043','0001813','0101913','CP2DA','CP2DB','CP2DC','CP2DD','CP2DE','CP2DF','CP2DG','CP2DH','LCP2DA','LCP2DB','LCP2DC','LCP2DD','LCP2DE','LCP2DF','LCP2DG','LCP2DH','0900003','0900013','0900083','0900093','0198613','0042543','0047413','0047613','9996209','0042413','0042613','0042503','E7644AB','E7644AC','E7644BA','E7644BB','E7644BC','E7644CA','E7644CB','E7644CC','E7644AA','9998340','9998341','9998342','E0713A0','9990033','0203013','9993753','9993754','PF24BGA','PF24BGB','PF24BGC','PF24RTA','PF24RTB','PF24RTC','9993102','9993103','9993104','9994635','9990078','9995566','9995155','9995157','E0707A0','E0707B0','E0707C0','9995611','9992494','9996170','9995242','9995240','9910898','9920898','9930898','9995165','9990900','9995567','E0713B0','E0713C0','E0713D0','9990678','PF24RTD','9990122','99977A0','99977B0','99977C0','9993673','9994701','9994689','9994693','9994697','9993732','9991111','9991112','9991113','9992221','9992222','9992223','9993331','9993332','9993333','9995565','9995244','9992780','9998331','9998332','9998333','9998335')
group by
Region,DonationDescription,ManufactLocation,ClassifierGroup, MotivationName
 
