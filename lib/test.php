<?php

function start_game(){
	global $mysqli;
	$sqlp1 = 'call draw_card("p1")';
	$sqlp2 = 'call draw_card("p2")';
	for ($i = 0; $i <=6; $i++){
		$mysqli->query($sqlp1);
		$mysqli->query($sqlp2);
	}
	$sql = 'select h.player_name, card_code from hand h inner join deck d on h.card_id=d.card_id';
	$st = $mysqli->query($sql);
	header('Content-type: application/json');
	print json_encode($st->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

//function show_game(){
	//syndesh sth bash
	//erothma gia na doyme ta fylla toy kathe paikth
	//erothma gia to fylo toy trapezioy
	//emfanish apotelesmatos
//}

function reset_game(){
	global $mysqli;
	$sql = 'call clean_deck()';
	$mysqli->query($sql);
	start_game();
}
?>