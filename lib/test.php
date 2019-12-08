<?php

function start_game(){
	global $mysqli;
	$sqlp1 = 'call draw_card("p1")';
	$sqlp2 = 'call draw_card("p2")';
	$sqlp3 = 'call start_game()'; 
	for ($i = 0; $i <=6; $i++){
		$mysqli->query($sqlp1);
		$mysqli->query($sqlp2);
	}
	$mysqli->query($sqlp3);
	$sql = 'select h.player_name, d.card_code from hand h inner join deck d on h.card_id=d.card_id';
	$st = $mysqli->query($sql);
	$sql1 = 'select * from table_deck order by table_id desc limit 1';
	$st1 = $mysqli->query($sql1);
	$res1 = $st->fetch_all(MYSQLI_ASSOC);
	$res2 = $st1->fetch_all(MYSQLI_ASSOC);
	header('Content-type: application/json');
	print json_encode(array($res1,$res2), JSON_PRETTY_PRINT);
}

function show_game(){
	global $mysqli;
	$sql = 'select h.player_name, d.card_code from hand h inner join deck d on h.card_id=d.card_id';
	$sql1 = 'select * from table_deck order by table_id desc limit 1';
	$st = $mysqli->query($sql);
	$st1 = $mysqli->query($sql1);
	$res1 = $st->fetch_all(MYSQLI_ASSOC);
	$res2 = $st1->fetch_all(MYSQLI_ASSOC);
	header('Content-type: application/json');
	print json_encode(array($res1,$res2), JSON_PRETTY_PRINT);
}

function reset_game(){
	global $mysqli;
	$sql = 'call clean_deck()';
	$mysqli->query($sql);
	start_game();
}
?>