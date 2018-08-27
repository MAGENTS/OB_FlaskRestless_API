#server_dw.sql
from flask import Flask, request, abort
import sqlalchemy as sa
from sqlalchemy import create_engine
from sqlalchemy import (Table, Column, Integer, String, MetaData, ForeignKey, Numeric)
from sqlalchemy import inspect
from sqlalchemy.orm import sessionmaker
from bson.json_util import dumps, default
import pandas as pd
from pandas.io.common import EmptyDataError
from pymongo import MongoClient

def get_mongo_database(db_name, host='localhost', port=27017, username=None, password=None):
    
    """ Get named database from MongoDB with/out authentification """
    if username and password:
        mongo_uri = 'mongodb://%s:%s@%s/%s' % (username, password, host, db_name)
        conn = MongoClient(mongo_uri)
    else:
        conn = MongoClient(host, port)
        
    return conn[db_name]
	

def read_data(file):
    try:
        df = pd.read_csv(file)
    except EmptyDataError:
        df = pd.DataFrame()

    return df

app = Flask(__name__)

#engine = sa.create_engine('mssql+pyodbc://ORLEBIDEVDB/INTEGRATION?driver=SQL+Server+Native+Client+11.0')

#metadata = MetaData()

# persist the schema of the existing database
#metadata.create_all(engine)
#print(metadata.tables)

# reflect db schema to MetaData
#metadata.reflect(bind=engine)

#connection = engine.connect()

#mktDB = Table('INT_MKTCollectionDetails', metadata)

#plDons_df = pd.read_csv('/data/mktCollect_Jul18_platelet_dons.csv')
# plDons_columns = list(plDons_data.columns)

DB_REGS_JUL18 = 'regsJul18'
COLL_PLDONSJUL18 = 'plDonorsJul18'

db = get_mongo_database(DB_REGS_JUL18)

# plDons_df = read_data('/data/mktCollect_Jul18_platelet_dons.csv')
# plDons_columns = list(plDons_df.columns)


@app.route('/api/plDonors')
def get_pldonors_month():

    query_dict = {}
    
    for key in ['person_id', 'FullDateUSA', 'total_platelet_donations']:
        # Request the field from database model
        arg = request.args.get(key)
        print(arg)
        if arg:
            query_dict[key] = arg
            
    plDons = db[COLL_PLDONSJUL18].find(query_dict)
    
    if plDons:
        return dumps(plDons)
    abort(404)
    
if __name__ == '__main__':
    app.run(port=8000, debug=True)