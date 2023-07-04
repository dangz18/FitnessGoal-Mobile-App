<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }

	$userId = intval($_POST['userId']);

	$sql = "SELECT user_name, user_password, user_genre, user_height, user_weight, user_birthdate, user_waterPerDay, user_fitness_level FROM utilizator WHERE user_id = '".$userId."' ";
	$result = mysqli_query($db, $sql);
	
	$info = [];
	
	while($row = mysqli_fetch_array($result)){
		$info[]=$row;
	}
	
	echo json_encode($info);
?>