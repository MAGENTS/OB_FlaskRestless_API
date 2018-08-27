# Connect to db using dataset:
import dataset
import datafreeze
db = dataset.connect('mssql+pyodbc://ORLEBIDEVDB/INTEGRATION?driver=SQL+Server+Native+Client+11.0')

# print(db.tables)


# Grab the mktcollection table:
mktCollect_Table = db['INT_MKTCollectionDetails']
# print(mktCollect_Table.columns)

dimdate_Table = db['VW_INT_DIMDATE']

# print(dimdate_Table.columns
# list(mktCollect_Table.find(_limit=10))


# Querying:
mktJul2018Donors = db.query(
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
    group by MKT.personid
) mkt
JOIN [Integration].[dbo].[VW_INT_DIMDATE] dd
    ON dd.dateKey = mkt.MIN_REG_DATE
""")

# for row in mktJul2018Donors:
#   print(row['PERSON_ID'], row['total_platelet_donations'])


# Output to CSV:
#datafreeze.freeze(mktJul2018Donors, format='csv',
#                  filename='data/mktCollect_Jul18_platelet_dons.csv')
                            
# Output to JSON:
datafreeze.freeze(mktJul2018Donors, format='json', wrap=False, prefix='../',
                  filename='data/mktCollect_Jul18_plDons.json')