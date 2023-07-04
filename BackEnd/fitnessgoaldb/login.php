<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }

	$email = $_POST['email'];
	$password = $_POST['password'];
	
	$sql1 = "SELECT * FROM utilizator WHERE user_email= '".$email."' ";
	$result1 = mysqli_query($db, $sql1);
	$count1 = mysqli_num_rows($result1);
	
	if($count1 > 1){
		echo json_encode("[Error] More than one return");
	}
	else if($count1 == 1){ 
		$sql2 = "SELECT * FROM utilizator WHERE user_email = '".$email."' AND user_password = '".$password."' ";
		$result2 = mysqli_query($db, $sql2);
		$count2 = mysqli_num_rows($result2);
		if($count2 == 1){
			$userId = [];
			while($row = mysqli_fetch_array($result2)){
				$userId[]=$row;
			}
			echo json_encode($userId);
		}
		else{
			echo json_encode("[Error] Email or password incorrect");
		}
	}
	else{
		echo json_encode("[Error] Inexistent user");
	}
	

?>