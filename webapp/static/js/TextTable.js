$(document).ready(function () {
	var table = $('#table').DataTable({
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
		column_number: 1,
		filter_type: "text"
	}, {
		column_number: 2,
		filter_type: 'range_number'
	}
	]);

});
