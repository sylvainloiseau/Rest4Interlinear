//const levelSelectElement = $(document).getElementById('level');
//
//levelSelectElement.addEventListener('change', (event) => {
//  const levelSelectElement = $(document).getElementById('type');
//  levelSelectElement.disabled = true; //textContent = `You like ${event.target.value}`;
//});

//https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/change_event#select_element


//$(document).ready(function() {
//	$('#level').change(function() {
//		var select_type = $('#type');
//		var val = $(this).value;
//		if (val == "morph") {
//			select_type.html("<option value='x'>x<option>");
//		}
//		select_type.disabled = true;
//	});
//});

$(window).on('load', function() {
      $('form').jsonForm({
        schema: {
          sentence: {
            type: 'object',
            title: 'Sentence',
            required: true,
			properties: {
				fields: {
					"type": 'array',
					"items": {
						"type": "object",
						title: 'Field',
						properties: {
							key: {
								type: 'string',
								title: 'Key',
								"enum": ["gls", "ft", "lt", "note"]
							},
							lg: {
								type: 'string',
								title: 'Langue',
								"enum": ["tww", "tpi", "en"]
							},
							value: {
								type: 'string',
								title: 'value',
								required:true
							},
							match: {
								type: 'string',
								title: 'match',
								"enum": ["start", "end", "whole", "anywhere", "regexp"]
							}
						}
					}
				},
				words: {
					"type": "array",
					"items": {
						"type": "object",
						"title": "Word",
						"properties": {
				fields: {
					"type": 'array',
					"items": {
						"type": "object",
						title: 'Field',
						properties: {
							key: {
								type: 'string',
								title: 'Key',
								"enum": ["baseline", "cf", "pos", "gls"]
							},
							lg: {
								type: 'string',
								title: 'Langue',
								"enum": ["tww", "tpi", "en"]
							},
							value: {
								type: 'string',
								title: 'value',
								required:true
							},
							match: {
								type: 'string',
								title: 'match',
								"enum": ["start", "end", "whole", "anywhere", "regexp"]
							}
						}
					}
				},
							morphs: {
								"type": "array",
								"items": {
									"type": "object",
									"title": "Morph",
									"properties": {
				fields: {
					"type": 'array',
					"items": {
						"type": "object",
						title: 'Field',
						properties: {
							key: {
								type: 'string',
								title: 'Key',
								"enum": ["baseline", "cf", "msa", "gls", "hn"]
							},
							lg: {
								type: 'string',
								title: 'Langue',
								"enum": ["tww", "tpi", "en"]
							},
							value: {
								type: 'string',
								title: 'value',
								required:true
							},
							match: {
								type: 'string',
								title: 'match',
								"enum": ["start", "end", "whole", "anywhere", "regexp"]
							}
						}
					}
				},
									}
								}
							}
						}
					}
				}
			}
          }
        },
	//	"form":[
	//		"*",
	//		{
	//			"key": "sentence.gls.txt",
	//		    "htmlClass": "usermood",
	//		    "fieldHtmlClass": "input-small"
	//		}
	//	],
	    "params": {
		  "fieldHtmlClass": "input-small"
	    }
		,
		"onSubmitValid": function (values) {
			// "values" follows the schema, yeepee!
			var json = JSON.stringify(values);
			$.post("http://localhost:8984/TextSearch", {'query':json});
			console.log(values);
		  },
        "onSubmit": function (errors, values) {
          if (errors) {
            $('#res').html('<p>I beg your pardon?</p>');
          }
          else {
			var json = JSON.stringify(values);
			//$('#res').html(json)
			$.post("http://localhost:8984/TextSearch", {'query':json});
			//$.ajax({
			//	type: "POST",
			//	url: "/TextSearch",
			//	data: json,
			//	success: function(){},
			//	dataType: "json",
			//	contentType : "application/json"
			//});
            //$('#res').html('<p>Hello ' + values.name + '.' +
            //  (values.age ? '<br/>You are ' + values.age + '.' : '') +
            //  '</p>');
          }
        }
      });
});