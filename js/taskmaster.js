var num_ids = 0;

function mk_alert(elem, id, desc, domain) {
    $(elem).prepend('<div class="alert alert-warning alert-dismissable" id="' + id + '"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button><strong>' + desc + '</strong><br><small>' + domain + '</small></div>');
    $("#" + id).on( "click", function( event ) {
	    //event.preventDefault();
	    //console.log( $( this ).serialize() );
	    
	    $.ajax({
		    url: "delete_task",
			type: "get",
			data: 'id=' + id
			});
	});

    
};

$( document ).ready(function() {
	$('#inputNewTaskDescription').focus();	

	$( "form" ).on( "submit", function( event ) {
		event.preventDefault();
		console.log( $( this ).serialize() );
		
		var task_id = 'alert' + num_ids;
		num_ids = num_ids + 1;
	
		$.ajax({
			url: "new_task",
			    type: "get",
			    data: $(this).serialize() + '&id=' + task_id
			    });

		mk_alert('#tasks', task_id, $('#inputNewTaskDescription').val(), $('#inputNewTaskDomain').val());

		$('#inputNewTaskDescription').val('');
		$('#inputNewTaskDomain').val('');
		$('#inputNewTaskDescription').focus();
	    });

	
	// $('#newTaskButton').on('click', function (e) {
	// 	console.log($('#inputNewTaskDescription').serialize());
	// 	console.log($('#inputNewTaskDomain').val());

	// 	$.ajax({
	// 		url: "new_task",
	// 		    type: "post",
	// 		    data: values,
	// 		    success: function(){
	// 		    alert("success");
	// 		    $("#result").html('Submitted successfully');
	// 		},
	// 		    error:function(){
	// 		    alert("failure");
	// 		    $("#result").html('There is error while submit');
	// 		}
	// 	    });
		
	// 	$('#inputNewTaskDescription').val('');
	// 	$('#inputNewTaskDomain').val('');
		
	//     });
});