plDonsbyMonth =
"""
select
    mkt.person_id,
    dd.FullDateUSA,
    mkt.min_reg_id,
    mkt.total_platelet_donations
from
(
    select MKT.personid PERSON_ID, MIN(mkt.COLLECTIONDATESK) MIN_REG_DATE,MIN(registrationid) MIN_REG_ID,COUNT(1) total_platelet_donations
    from [Integration].[dbo].[INT_MKTCollectionDetails] mkt
    where mkt.DonationTypeSK in (2,5,7,26)		
     and mkt.CompletedFlag >= 8		
     and upper(mkt.GENDER) in ('M','F')		
     and (MKT.collectiondatesk >= '20180701' and MKT.collectiondatesk < '20180801')
    --and reg.person_id = 2237761
    group by MKT.personid
) mkt
JOIN [Integration].[dbo].[VW_INT_DIMDATE] dd
    ON dd.dateKey = mkt.MIN_REG_DATE
"""
