<?php
	require_once "lib/dbconnect.php";
	require_once "lib/test.php";
	require_once "lib/game.php";
	
	$method = $_SERVER['REQUEST_METHOD'];
	$request = explode('/', trim($_SERVER['PATH_INFO'],'/'));
	$input = json_decode(file_get_contents('php://input'),true);
	
	switch ($r=array_shift($request)){
		case 'game' :
			switch ($b=array_shift($request)){
				case '':
				case null: handle_game($method);
					break;
				case 'bla': echo("bla");
					break;
				default: header("HTTP/1.1 404 Not Found");
					break;
			}
			break;
		case 'status':
			if(sizeof($request)==0){
				show_status();
			}
			else{
				header("HTTP/1.1 404 Not Found");
			}
			break;
		case 'players': echo("bla");
			break;
		default: header("HTTP/1.1 404 Not Found");
			exit;
	}
	
	function handle_game($method){
		if($method=='GET'){
			show_game();
		}
		else if($method=='POST'){
			reset_game();
		}
	}
?>