#server_dw.sql
# This code require Python 2.2.1 or later
from __future__ import generators    # needs to be at the top of your module
from flask import Flask, request, abort
import dataset
import datafreeze
import datetime
from json import dumps

def ResultIter(cursor, arraysize=1000):
    'An iterator that uses fetchmany to keep memory usage down'
    while True:
        results = cursor.fetchmany(arraysize)
        if not results:
            break
        for result in results:
            yield result
            
def datetime_handler(obj):
    if hasattr(obj, 'isoformat'):
        return obj.isoformat()
    else:
        raise TypeError(
            "Unserializable object {} of type {}".format(obj, type(obj))
        )

app = Flask(__name__)


db = dataset.connect('mssql+pyodbc://ORLEBIDEVDB/INTEGRATION?driver=SQL+Server+Native+Client+11.0')

plDonsQueryStr = """
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
"""

mktJul2018Donors = db.query(plDonsQueryStr)

@app.route('/api/plDonors')
def get_plMonthDonors():

    print('Request args: ' + str(dict(request.args)))
    query_dict = {}
    
    for key in ['CollectionDateSK','EthnicSK','DonationTypeSK']:
        # Request the field from database model
        arg = request.args.get(key)
        
        if arg:
            query_dict[key] = arg
            
            
    #print(query_dict) = {'CollectionDateSK' : ['20180604']}
    
    plDons = db['INT_MKTCollectionDetails'].find(**query_dict)
    
    #list(plDons.find(_limit=10))
    if plDons:
        return dumps([pl for pl in plDons], default=datetime_handler)
    abort(404)
    
if __name__ == '__main__':
    app.run(port=8000, debug=True)