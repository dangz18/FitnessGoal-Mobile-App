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
	$userName = $_POST['userName'];
	$userPassword = $_POST['userPassword'];
	$userGenre = $_POST['userGenre'];
	$userHeight = floatval($_POST['userHeight']);
	$userWeight = floatval($_POST['userWeight']);

	
	$sql1 = "UPDATE utilizator SET user_name = '".$userName."', user_password = '".$userPassword."' , user_genre = '".$userGenre."' , user_height = '".$userHeight."', user_weight = '".$userWeight."' WHERE user_id = '".$userId."' ";
		
	$query1 = mysqli_query($db, $sql1);
	if($query1){
		echo json_encode("Success");
	}
	else{
		echo json_encode("Failed");
	}
?>