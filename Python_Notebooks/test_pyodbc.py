import pyodbc

cnxn = pyodbc.connect(r'DRIVER={SQL Server Native Client 11.0};SERVER=ORLEBIDEVDB;DATABASE=INTEGRATION;Trusted_Connection=yes;')
cursor = cnxn.cursor()

#Sample select query
cursor.execute("SELECT @@version;") 
row = cursor.fetchone() 
while row: 
    print(row[0]) 
    row = cursor.fetchone()