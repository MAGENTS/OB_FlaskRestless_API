
// Consuming entire set of data
/*
d3.json('data/mktCollect_Jul18_plDons.json', function(error, data){
	if (error){
		console.log(error);
	}
	
	d3.select('h2#data-title').text('Platelet Donors for July');
	d3.select('div#data pre')
		.html(JSON.stringify(data, null, 4));
});
*/


// 	Consuming partitioned dataset by date:
var loadplDonorsbyDateJSON = function(date){
	d3.json('data/plDonors_by_date/pl_Dons_' + date + '.json',
	function(error, data) {
		if(error) { console.log(error); }
		d3.select('h2#data-title').text('All the Platelet Donors for Date ' + date);
		d3.select('div#data pre').html(JSON.stringify(data, null, 4));
	});
};

loadplDonorsbyDateJSON('07032018');