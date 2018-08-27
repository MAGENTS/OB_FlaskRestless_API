import requests

response = requests.get('http://localhost:8000/api/plDonors',
						params={'FullDateUSA':'07/01/2018'})
						
print(response.json())