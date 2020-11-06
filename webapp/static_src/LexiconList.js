$(document).ready( function () {	
	var table = $('#table').DataTable( {
		/*"dom" : '&lt;lf&lt;t>ip>',*/
		"pagingType": "full_numbers",
		"lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
		/*"scrollY": "400px",*/
		/*"paging": false,*/	
	
	})
	yadcf.init(table, [{
		column_number: 0,
		filter_type: "text"
	}, {
		column_number: 1
		
	}, {
		column_number: 2,
		filter_type: "text"
	}, {
		column_number: 3,
		filter_type: "text"
	}, {
		column_number: 4
		
	}, {
		column_number: 5,
		column_data_type: "html",
		html_data_type: "text",
		filter_default_label: "Select tag"
	}
	/*, {
		column_number: 6,
		
	}, {
		column_number: 7
		
	}, {
		column_number: 8
		
	}, {
		column_number: 9,
		filter_type: 'range_number'
	}*/
		]);
	
} );
