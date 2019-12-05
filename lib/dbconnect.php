<?php
$host='localhost';
$db='uno';
require_once "local_config.php";

$user=USERNAME;
$pass=DB_PWD;

$mysqli= new mysqli($host, $user, $pass, $db);

if ($mysqli->connect_errno) {
    echo "Failed to connect to MySQL: (" . 
    $mysqli->connect_errno . ") " . $mysqli->connect_error;
}

?>