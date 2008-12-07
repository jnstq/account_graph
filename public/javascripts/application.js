$(document).ready(function() {
	var addClickHandlers = function() {
		$('td.tag span').click(function() {
		
			id = $(this).parent().attr('id').match(/transaction_(\d+)/)[1]
		
			$(this).parent().load("/tags", {'id': id}, function() {
			
				$('select.tags').change(function(e) {
					action = $(this).parent('form').attr('action')
					
					if($(this).val() == "add_tag")
						$(this).children("option[value='add_tag']").attr('value', prompt("Please enter the new tag",""))
					
					$.post(action, $(this).parent('form').serialize(), function(result) {
						$('select.tags').parent('form').parent('td').html("<span>" + result + "</span>")
						addClickHandlers();
						if($("#date"))
							$('#date').change();												
					});
					
				})
			
			});
		
		});
	};
	addClickHandlers();
	
	
	$('#date').change(function() {
		$("#graph_date").text($(this).val())
		$.getJSON('/graph.json', {date: $(this).val()}, function(data) {
			
			
		  var options = {
		    bars: { 
		  				show: true,
		  				barWidth: 1
		  			},
		  			xaxis: { 
							ticks: data.ticks,
		  			},
		  			grid: {
		  		    clickable: true,
		  		    hoverable: true,
		  		    autoHighlight: true
		  		  }
		  };

	    $.plot($("#placeholder"), [{data: data.data}], options);			
			
		});
		
	});
	
  $("#placeholder").bind("plotclick", function (event, pos, item) {
      $.post("/tag_from_pos", {x: pos.x, y: pos.y, date: $('#date').val()}, function(tag) {
				$('#graph_tag').text(tag)
				$('#transactions').load('/transactions', {tag: tag, date: $('#date').val()}, function() {
					addClickHandlers();
				});
			});
  });	
	
});

