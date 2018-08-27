from pymongodb import MongoClient

DB_REGS_JUL18 = 'regsJul18'
COLL_PLDONSJUL18 = 'plDonsJul18'

client = MongoClient()
# Create Mongo database:
db = client[DB_REGS_JUL18]

# If collection exists this will retrieve otherwise the collection will be created:
coll = db.[COLL_PLDONSJUL18]