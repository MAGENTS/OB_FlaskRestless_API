import dash
import dash_core_components as dcc
import dash_html_components as html
import pandas as pd
import dateutil
from datetime import datetime as dt
from dateutil.relativedelta import relativedelta as rd
import sqlalchemy as sa
from sqlalchemy import create_engine
from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey
from sqlalchemy import inspect
from sqlalchemy.sql import text

def GetUpdates(start_date, end_date):
    return QueryData(GetDateInt(start_date), GetDateInt(end_date))

def GetDateInt(date):
    # Convert String format to DateTime (input format): dt.strptime(date_str, '%Y-%m-%d')
    # Convert DateTime back to String: dateTime.strftime('%Y%m%d')
    date_dt = dt.strptime(date, '%Y-%m-%d')
    date_str = date_dt.strftime('%Y%m%d')
    return int(date_str)

def QueryData(start_date, end_date):

    plDonsbyMonthQuery = """
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
         and (MKT.collectiondatesk >= '{0}' and MKT.collectiondatesk < '{1}')
        --and reg.person_id = 2237761
        group by MKT.personid
    ) mkt
    JOIN [Integration].[dbo].[VW_INT_DIMDATE] dd
        ON dd.dateKey = mkt.MIN_REG_DATE
    """.format(start_date, end_date)


    # mkt_text = text(plDonsbyMonthQuery)
    # mkt_res = conn.execute(mkt_text, minDate=20180701, maxDate=20180801).fetchall()
    df = pd.read_sql(plDonsbyMonthQuery, engine)

    # Convert date from string to date times
    df['FullDateUSA'] = df['FullDateUSA'].apply(dateutil.parser.parse, dayfirst=False)
    
    return df

# Connect to MS SQL Server via Windows Authentification:
engine = sa.create_engine('mssql+pyodbc://ORLEBIDEVDB/INTEGRATION?driver=SQL+Server+Native+Client+11.0')
conn = engine.connect()

figureName = 'Platelet Donors by Month'

#startDate = datetime.datetime(2018, 7, 1) # datetime.now - 1 year
#endDate = datetime.now()
# datetime
today_date = dt.today()
# str:
c_date_month = today_date.strftime('%Y-%m-%d')
p_date_month = (dt.today() - rd(months=1)).strftime('%Y-%m-%d')
#curCollectDateSK = int(c_date_month)
#prCollectDateSK = int(p_date_month)

date_prior_2year = (today_date - rd(years=2)).strftime('%Y-%m-%d')

# Read in csv data:
# plDons_df = pd.read_csv('../extractors/data/mktCollect_Jul18_platelet_dons.csv')

plDons_df = GetUpdates(p_date_month, c_date_month)

aggregations = {
    'person_id': 'count'
    # 'date': lambda x: max(x) - 1
}
date_groups = plDons_df.groupby('FullDateUSA')
grouped = date_groups.agg(aggregations)
grouped.columns = ["num_persons"]

#fig, ax = plt.subplots(figsize=(15,7))
#plDons_df.groupby(['FullDateUSA']).count()['person_id'].plot(ax=ax)


def generate_table(dataframe, max_rows=10):

    return html.Table(
        # Header
        [html.Tr([html.Th(col) for col in dataframe.columns])] +

        # Body
        [html.Tr([
            html.Td(dataframe.iloc[i][col]) 
            for col in dataframe.columns
        ]) 
        for i in range(min(len(dataframe), max_rows))]
    )


app = dash.Dash()

app.css.append_css({"external_url": "https://codepen.io/chriddyp/pen/bWLwgP.css"})

app.layout = html.Div(children=[
    html.H3(children='Donor Marketing'),
    dcc.DatePickerRange(
        id='date-picker-range',
        #month_format='YYMD',
        min_date_allowed=date_prior_2year,
        max_date_allowed=c_date_month,
        initial_visible_month=(dt.today() - rd(months=1)).strftime('%Y%m%d'),
        start_date=(dt.today() - rd(months=1)).strftime('%Y%m%d'),
        end_date=dt.today().strftime('%Y%m%d')
    ),
    html.Div(id='output-container-date-picker-range'),
    generate_table(plDons_df),
    dcc.Graph(id='plDonors_MTD_Graph')
])


@app.callback(
    dash.dependencies.Output('output-container-date-picker-range', 'children'),
    [dash.dependencies.Input('date-picker-range', 'start_date'),
    dash.dependencies.Input('date-picker-range', 'end_date')])
def update_output(start_date, end_date):
    string_prefix = 'You have selected: '
    if start_date is not None:
        #start_date = dt.strptime(start_date, '%Y%m%d')
        #start_date_string = start_date.strftime('%B %d, %Y')
        string_prefix = string_prefix + 'Start Date: ' + start_date + ' | '
    if end_date is not None:
        #end_date = dt.strptime(end_date, '%Y%m%d')
        #end_date_string = end_date.strftime('%B %d, %Y')
        string_prefix = string_prefix + 'End Date: ' + end_date
    if len(string_prefix) == len('You have selected: '):
        return 'Select a date to see it displayed here'
    else:
        return string_prefix
    
@app.callback(
    dash.dependencies.Output('plDonors_MTD_Graph', 'figure'),
    [dash.dependencies.Input('date-picker-range', 'start_date'),
    dash.dependencies.Input('date-picker-range', 'end_date')])
def update_figure(start, end):

    filtered_df = GetUpdates(start, end)
    
    aggregations={'person_id':'count'}
    date_groups = filtered_df.groupby('FullDateUSA')
    grouped = date_groups.agg(aggregations)
    grouped.columns = ["num_persons"]
    
    return {
        'data':[{'x': grouped.index, 'y': grouped.num_persons, 'type': 'line', 'name': figureName}],
        'layout': {'title': figureName}
    }



if __name__ == '__main__':
    app.run_server(debug=True)