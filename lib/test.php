<?php

require_once 'dbconnect.php';

function start_game(){
	global $mysqli;
	$sqlp1 = 'call draw_card(1)';
	$sqlp2 = 'call draw_card(2)';
	
	for ($i = 0; $i <=6; $i++){
		$mysqli->query($sqlp1);
		$mysqli->query($sqlp2);
	}
	
	$sqlf = 'select d.card_code from hand h inner join deck d on h.card_id=d.card_id where h.player_id="1"';
	$st1 = $mysqli->prepare($sqlf);
	$sqls = 'select d.card_code from hand h inner join deck d on h.card_id=d.card_id where h.player_id="2"';
	$st2 = $mysqli->prepare($sqls);
	
	$st1->execute();
	$st2->execute();	
	
	$res1 = $st1->get_result();
	$res2 = $st2->get_result();
	
	header('Content-type: application/json');
	print json_encode($res1->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
	print json_encode($res2->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

function show_game(){
	//syndesh sth bash
	//erothma gia na doyme ta fylla toy kathe paikth
	//erothma gia to fylo toy trapezioy
	//emfanish apotelesmatos
}

function reset_game(){
	global $mysqli;
	$sql = 'call clean_deck()';
	$mysqli->query($sql);
	
	start_game();
}
?>