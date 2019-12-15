<?php
	function show_users(){
		global $mysqli;
		$sql='select username, player_name from player';
		$st=$mysqli->prepare($sql);
		$st->execute();
		$res=$st->get_result();
		header('Content-type: application/json');
		print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
	}
	
	function handle_user($method, $b, $input){
		if($method=='GET'){
			show_user($b);
		}
		else if($method=='PUT'){
			set_user($b, $input);
		}
	}
	
	function show_user($b){
		global $mysqli;
		$sql='select username, player_name from player where player_name=?';
		$st=$mysqli->prepare($sql);
		$st->bind_param('s', $b);
		$st->execute();
		$res=$st->get_result();
		header('Content-type: application/json');
		print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
	}
	
	function set_user($b, $input){
		
	}
?>