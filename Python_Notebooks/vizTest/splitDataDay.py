# Break the json file of plattelet donors by July down into files by day:

import pandas as pd
import datetime
import json
import os

# Load json data to prevent Value Error using pd.read_json()
json_data = json.load(open('data/mktCollect_Jul18_plDons.json'))
pl_donors = pd.DataFrame(json_data["results"])

new_dir = 'data/plDonors_by_date'

try:
	os.mkdir(new_dir)
except IOError:
	print("Dir exists already")
	

for date, data_group in pl_donors.groupby('FullDateUSA'):
	format_date = date.replace("/", "")
	data_group.to_json('data/plDonors_by_date/pl_Dons_' + format_date + '.json', orient='records')