#server_flask_restless

import flask
import sqlalchemy as sa
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from sqlalchemy import (Table, Column, Integer, String, MetaData, ForeignKey, Numeric)
from sqlalchemy.ext.automap import automap_base
# import flask.ext.sqlalchemy
from flask_sqlalchemy import SQLAlchemy
# import flask.ext.restless
import flask_restless
import re
import inflect

def camelize_classname(base, tablename, table):
    "Produce a 'camelized' class name, e.g. "
    "'words_and_underscores' -> 'WordsAndUnderscores'"

    return str(tablename[0].upper() + \
            re.sub(r'_([a-z])', lambda m: m.group(1).upper(), tablename[1:]))

_pluralizer = inflect.engine()
def pluralize_collection(base, local_cls, referred_cls, constraint):
    "Produce an 'uncamelized', 'pluralized' class name, e.g. "
    "'SomeTerm' -> 'some_terms'"

    referred_name = referred_cls.__name__
    uncamelized = re.sub(r'[A-Z]',
                         lambda m: "_%s" % m.group(0).lower(),
                         referred_name)[1:]
    pluralized = _pluralizer.plural(uncamelized)
    return pluralized

# Create the Flask application and the Flask-sqlalchemy object:
app = flask.Flask(__name__)
app.config['DEBUG'] = True

app.config['SQLALCHEMY_DATABASE_URI'] = 'mssql+pyodbc://ORLEBIDEVDB/INTEGRATION?driver=SQL+Server+Native+Client+11.0'

engine = sa.create_engine('mssql+pyodbc://ORLEBIDEVDB/INTEGRATION?driver=SQL+Server+Native+Client+11.0')
metadata = MetaData()
# metadata.reflect(bind=engine)

# we can reflect it ourselves from a database, using options
# such as 'only' to limit what tables we look at...
metadata.reflect(engine, only=['INT_MKTCollectionDetails'])

#mktCollects = Table('INT_MKTCollectionDetails', metadata, autoload=True, autoload_with=engine)
#print(type(mktCollects))

# we can then produce a set of mappings from this MetaData.
Base = automap_base(metadata=metadata)

# calling prepare() just sets up mapped classes and relationships.
Base.prepare(engine, reflect=True, 
			classname_for_table=camelize_classname,
            name_for_collection_relationship=pluralize_collection)

# mapped classes are now created with names by default
# matching that of the table name.
mktCollects = Base.classes.INT_MKTCollectionDetails

session = Session(engine)

db = SQLAlchemy(app)

print(type(db))

# Create the Flask-Restless API Manager:
manager = flask_restless.APIManager(app, flask_sqlalchemy_db=db)

# Create API endpoints, which will be available at
# localhost:####/api/<tablename> by default
# Allowed HTTP methods can be specified as well:
manager.create_api(mktCollects, 
					methods=['GET'], # other ops POST, DELETE, etc..
					max_results_per_page=1000)
    
app.run()