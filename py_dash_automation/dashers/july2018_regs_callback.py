import dash
from dash.dependencies import Input, Output, State
import dash_core_components as dcc
import dash_html_components as html
import pandas as pd
import dateutil

figureName = 'Platelet Donors by Month'

#startDate = datetime.datetime(2018, 7, 1) # datetime.now - 1 year
#endDate = datetime.now()


plDons_df = pd.read_csv('../extractors/data/mktCollect_Jul18_platelet_dons.csv')
# Convert date from string to date times
#plDons_df['FullDateUSA'] = plDons_df['FullDateUSA'].apply(dateutil.parser.parse, dayfirst=False)
plDons_df['FullDateUSA'] = pd.to_datetime(plDons_df['FullDateUSA'])


dataset = plDons_df.to_dict(orient='index')
#points = pickle.load(open("'../data/Jul18_pldons.pkl'", "rb"))

# Plotting group by:
#fig, ax = plt.subplots(figsize=(15,7))
#plDons_df.groupby(['FullDateUSA']).count()['person_id'].plot(ax=ax)


layout = dict(
    autosize=True,
    height=500,
    font=dict(color='#CCCCCC'),
    titlefont=dict(color='#CCCCCC', size='14'),
    margin=dict(
        l=35,
        r=35,
        b=35,
        t=45
    ),
    hovermode="closest",
    plot_bgcolor="#191A1A",
    paper_bgcolor="#020202",
    legend=dict(font=dict(size=10), orientation='h'),
    title='Satellite Overview',
    mapbox=dict(
        #accesstoken=mapbox_access_token,
        style="dark",
        center=dict(
            lon=-78.05,
            lat=42.54
        ),
        zoom=7,
    )
)

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
    html.H1(children='plDonorsbyMonth'),
    # generate_table(plDons_df),
	dcc.Graph(id='plDonors_MTD_Graph')
])



@app.callback(Output('plDonors_MTD_Graph', 'figure'))
def make_plDonorsbyMonth():

	layout_aggregate = copy.deepcopy(layout)
	
	aggregations = {
		'person_id': 'count'
		# 'date': lambda x: max(x) - 1
	}
	date_groups = plDons_df.groupby('FullDateUSA')
	grouped = date_groups.agg(aggregations)
	grouped.columns = ["num_persons"]
	
	data = [
		dict(
            type='line',
            labels=[grouped.index],
            values=grouped['num_persons'],
            name='Platelet Donors by Month',
            hoverinfo="label+text+value+percent",
            textinfo="label+percent+name",
			domain={"x": grouped.index, 'y':grouped['num_persons']},
		)
	]
	
	layout_aggregate['title'] = 'PL Donors by Month' # noqa: E501
	 
	figure = dict(data=data, layout=layout_aggregate)
	return figure

	


if __name__ == '__main__':
    app.run_server(debug=True)