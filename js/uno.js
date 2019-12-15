$(function () {
	fill_game();
	$('#do_move').click(do_move);
	$('#uno_game_reset').click(do_reset);
	$('#say_uno').click(say_uno);
	$('#draw').click(draw);
	$('#pass').click(pass);
	$('#uno_login').click(login_to_game);
    $('#do_move').prop('disabled', true);
    $('#nextmove').prop('disabled', true);
    $('#pass').prop('disabled', true);
    $('#draw').prop('disabled', true);
    $('#say_uno').prop('disabled', true);
    //$('#pass_div').hide();
    //$('#uno_card').hide();
    //$('#deck').hide();
    game_status_update();
});


function fill_game(){	
	$.ajax({type:"GET", url: "uno.php/game/", dataType:"json", success: fill_game_by_data });
}

function fill_game_by_data(data){
	$('#player1_cards').html("");
	$('#player2_cards').html("");
	for(var i=0; i<data.length; i++){
		for(var j=0; j<data[i].length; j++){
			console.log(j);
			var obj = data[i][j];
			if(i==0){
				if(obj.player_name=='p1'){
					$('#player1_cards').append(obj.card_code);
					$('#player1_cards').append("&nbsp;&nbsp;&nbsp;&nbsp;");
				}else if(obj.player_name=='p2'){
					$('#player2_cards').append(obj.card_code);
					$('#player2_cards').append("&nbsp;&nbsp;&nbsp;&nbsp;");
				}
			}
			else{
				$('#table_card').html(obj.card_code);
			}
		}
	}
}
function draw(e){
	$.ajax({type:"PUT",url:"uno.php/game/draw", dataType:"json", success:fill_game_by_data});
}

function do_reset(e) {
	$.ajax({type: 'POST', url: "uno.php/game/", dataType: "json", 
			success: fill_game_by_data,
			//error: alert("error")
			});
}

function game_status_update(){
	$.ajax({url:"uno.php/status/", success:update_status});
}



