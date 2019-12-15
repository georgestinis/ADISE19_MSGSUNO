var me={};
var game_status={};

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
	$.ajax({type:"GET", url: "uno.php/players/", dataType:"json", success: fill_players });
	player_turn();
	//$.ajax({type:"GET", url: "uno.php/status/", dataType:"json", success: player_turn });
}

function fill_game_by_data(data){
	$('#player1_cards').html("Player1: ");
	$('#player2_cards').html("Player2: ");
	for(var i=0; i<data.length; i++){
		for(var j=0; j<data[i].length; j++){
			var obj = data[i][j];
			if(i==0){
				if(obj.player_name=='p1' && obj.player_name==me.player_name){
					$('#player1_cards').append(obj.card_code);
					$('#player1_cards').append("&nbsp;&nbsp;&nbsp;&nbsp;");
				}else if(obj.player_name=='p2' && obj.player_name==me.player_name){
					$('#player2_cards').append(obj.card_code);
					$('#player2_cards').append("&nbsp;&nbsp;&nbsp;&nbsp;");
				}else if(obj.player_name=='p1'){
					$('#player1_cards').append("[]");
					$('#player1_cards').append("&nbsp;&nbsp;&nbsp;&nbsp;");
				}else if(obj.player_name=='p2'){
					$('#player2_cards').append("[]");
					$('#player2_cards').append("&nbsp;&nbsp;&nbsp;&nbsp;");
				}
			}
			else{
				if(game_status.status=='started'){
					$('#table_card').html(obj.card_code);
				}else{
					$('#table_card').html("[]");
				}
			}
		}
	}
}

function pass(e){
	$.ajax({type:"PUT", url: "uno.php/game/pass", dataType:"json", success: player_turn });	
}

function draw(e){
	$.ajax({type:"PUT",url:"uno.php/game/draw", dataType:"json", success:fill_game_by_data});
}

function do_reset(e) {
	$.ajax({type: 'POST', url: "uno.php/game/", dataType: "json", 
			success: fill_game_by_data});
}

function game_status_update(){
	$.ajax({url:"uno.php/status/", success:update_status});
}

function update_status(data) {
	game_status=data[0];
	update_info();
	if(game_status.p_turn==me.player_name &&  me.player_name!=null) {
		//x=0;
		// do play
		$('#do_move').prop('disabled', false);
		$('#nextmove').prop('disabled', false);
		$('#pass').prop('disabled', false);
		$('#draw').prop('disabled', false);
		$('#say_uno').prop('disabled', false);
		setTimeout(function() { game_status_update();}, 4000);
	} else {
		// must wait for something
		$('#do_move').prop('disabled', true);
		$('#nextmove').prop('disabled', true);
		$('#pass').prop('disabled', true);
		$('#draw').prop('disabled', true);
		$('#say_uno').prop('disabled', true);
		setTimeout(function() { game_status_update();}, 4000);
	} 	
}

function update_info(){
	$('#game_info').html("I am Player: "+me.player_name+", my name is "+me.username +'<br>Token='+me.token+'<br>Game state: '+game_status.status);
	fill_game();	
}


