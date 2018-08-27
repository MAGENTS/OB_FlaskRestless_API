var loadplDonorsbyDateJSON = function(date){
	d3.json('data/plDonors_by_date/pl_Dons_' + date + '.json',
	function(error, data) {
		if(error) { console.log(error); }
		d3.select('h2#data-title').text('All the Platelet Donors for Date ' + date);
		d3.select('div#data pre').html(JSON.stringify(data, null, 4));
	});
};

loadplDonorsbyDateJSON('07102018');