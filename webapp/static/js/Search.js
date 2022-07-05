const levelSelectElement = $(document).getElementById('level');

levelSelectElement.addEventListener('change', (event) => {
  const levelSelectElement = $(document).getElementById('type');
  levelSelectElement.disabled = true; //textContent = `You like ${event.target.value}`;
});

//https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/change_event#select_element


$(document).ready(function() {
	$('#level').change(function() {
		var select_type = $('#type');
		var val = $(this).value;
		if (val == "morph") {
			select_type.html("<option value='x'>x<option>");
		}
		select_type.disabled = true;
	});
});
