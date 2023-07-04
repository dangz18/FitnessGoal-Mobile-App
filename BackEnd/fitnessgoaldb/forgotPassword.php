<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }

	$userEmail = $_POST['userEmail'];
	$userNewPassword = $_POST['userNewPassword'];

	$sql1 = "SELECT * FROM utilizator WHERE user_email= '".$userEmail."' ";
	$result1 = mysqli_query($db, $sql1);
	$count1 = mysqli_num_rows($result1);
	
	if($count1 < 1){
		echo json_encode("You don't have an account yet");
	}else{
		$sql2 = "UPDATE utilizator SET user_password = '".$userNewPassword."' WHERE user_email = '".$userEmail."' ";
		
		$query2 = mysqli_query($db, $sql2);
		if($query2){
			echo json_encode("Success");
		}
		else{
			echo json_encode("Failure");
		}
	}
	
	
	
?>