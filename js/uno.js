$(function () {
	fill_game();
	$('#do_move').click(do_move);
	$('#uno_game_reset').click(do_reset);
	$('#say_uno').click(say_uno);
	$('#draw').click(draw);
	$('#pass').click(pass);
	
});


function fill_game(){
	
	$.ajax({type:"GET", url: "uno.php/game/", dataType:"json", success: fill_game_by_data });
}

function fill_game_by_data(data){
	$('#player1_cards').html("");
	$('#player2_cards').html("");
	for(var i=0; i<data.length; i++){
		console.log(i);
		var obj = data[i];
		if(obj.player_name=='p1'){
			$('#player1_cards').append(obj.card_code);
			$('#player1_cards').append("&nbsp;&nbsp;&nbsp;&nbsp;");
		}else if(obj.player_name=='p2'){
			$('#player2_cards').append(obj.card_code);
			$('#player2_cards').append("&nbsp;&nbsp;&nbsp;&nbsp;");
			
		}
	}
}
function draw(){
	
}
function do_reset(e) {
	$.ajax({type: 'POST', url: "uno.php/game", dataType: "json", 
			success: fill_game_by_data,
			//error: alert("error")
			});
}


