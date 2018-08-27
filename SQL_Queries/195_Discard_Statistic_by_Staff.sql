Select                      			
               DR.UnitNumber,      			
               --DR.RegistrationID,      			
               P.Description as [Product Description],      			
              -- PP.PRODUCT_INVENTORY_ID, 			
               --DR.ProductInventoryID, 			
               --RS.Product_Inventory_ID, 			
               P.ProductGroup,      			
               isnull(DDR.DiscardRSADesc,DDR.DiscardDesc) Discard_Code,      			
               cast(dw.date as date) as [Draw Date],      			
               cast(Dt.[Date] as Date) as [Discard Date],      			
               (CASE      			
                    When DR.BloodTypeSK =1  then 'O+' 			
                       When DR.BloodTypeSK =2  then 'O-' 			
                       When DR.BloodTypeSK =3  then 'A+' 			
                       When DR.BloodTypeSK =4  then 'A-' 			
                       when DR.BloodTypeSK =5  then 'B+' 			
                       When DR.BloodTypeSK =6  then 'B-' 			
                       When DR.BloodTypeSK =7  then 'AB+' 			
                       When DR.BloodTypeSK =8  then 'AB-' 			
                       ELSE 'UNK' END) as [Blood Type], 			
               DR.Released,      			
               cast(RR.Create_Date as date) [DS Review Date],      			
               BC.centername [Inventory Location],      			
               Substring(CONVERT(varchar, dt.Date, 120),1,7) [Discard Month],      			
               --RST.Description,      			
               E.[EmpFullName] as Staff,      			
               upper(PP.Value) as Comment,			
			   --RS.Process_ID,      
               Count(*) as [Count]      			
               --RS.FRAC_STEP_COMMENTS as Comment"      			
from     Integration.[dbo].[INT_FCTProductDiscardsWithReason] DR  			
			Left join stage.[dbo].[STG_RSACLProductInventory] RPI on RPI.PRODUCT_INVENTORY_ID =  DR.ProductInventoryID
          left join stage.[dbo].STG_RSACLFRACSTEPS RS on RS.Product_Inventory_ID =   RPI.REFERENCE_PRODUCT_INV_ID                  			
          left join VW_INT_DIMDiscardReason DDR ON (isnull(DR.NewDiscardSK,DR.DiscardSK)=DDR.DiscardSk)           			
           left join [STAGE].[dbo].[STG_RSACLProductProperties] PP on PP.PRODUCT_INVENTORY_ID = DR.ProductInventoryID             			
           Left Join stage.[dbo].STG_RSADSReview RR on RR.Registration_ID = DR.RegistrationID           			
          left join  [dbo].[INT_DIMProducts] P ON DR.ProdSK=P.ProdSK           			
          left join Integration.[dbo].VW_INT_BIODIMInventoryCenter  BC  on DR.InventoryCenterSK=BC.inventorycentersk           			
          Inner join Integration.[dbo].[DimDate] dt on dt.datekey = DR.DiscardDateSK           			
          Inner join Integration.[dbo].[DimDate] dw on dw.datekey = DR.DrawdateSK           			
          left join Integration.[dbo].[INT_DIMEmployee] E on e.EmpRSAID = RS.Employee_ID           			
          --left join stage.[dbo].STG_RSACLFRACSTEPTYPES RST on RST.FRAC_STEP_TYPE_ID =RS.FRAC_STEP_TYPE_ID           			
where      			
DR.DiscardDateSK >= 20180301 and DR.DiscardDateSK < 20180601           			
          and PP.[KEY] = 'comments'           			
          and E.EndDate is null           			
          --and DR.UnitNumber in ('W036818125466','W036817245385') 			
		  and RS.Process_ID = 99          	
Group By DR.UnitNumber,                     			
          P.[Description], 			
          --PP.PRODUCT_INVENTORY_ID, 			
          --     DR.ProductInventoryID,      			
          --     RS.Product_Inventory_ID,      			
               P.ProductGroup,      			
               isnull(DDR.DiscardRSADesc,DDR.DiscardDesc),      			
               dw.date,      			
               Dt.[Date],      			
               DR.BloodTypeSK,      			
               DR.Released,      			
               RR.Create_Date,      			
               BC.centername,      			
              E.[EmpFullName],           			
               PP.Value			
