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
	$userNewHeight = floatval($_POST['userNewHeight']);
	$todayDate = $_POST['todayDate'];
	
	$sql1 = "SELECT * FROM height_history WHERE user_id = '".$userId."' and height_date = '".$todayDate."'";
	$result1 = mysqli_query($db, $sql1);
	$count1 = mysqli_num_rows($result1);
	
	if($count1 == 0){ // we insert a new height for this user at this date
		$sql2 = "INSERT INTO height_history(user_id, height, height_date) VALUES('".$userId."', '".$userNewHeight."', '".$todayDate."')";
		$query2 = mysqli_query($db, $sql2);
		if($query2){
			echo json_encode("Success");
		}
		else{
			echo json_encode("Failure");
		}
	}
	else if($count1 == 1){ // we update the height for this user and date
		$sql3 = "UPDATE height_history SET height = '".$userNewHeight."' WHERE user_id = '".$userId."' and height_date = '".$todayDate."' ";
		$query3 = mysqli_query($db, $sql3);
		if($query3){
			echo json_encode("Success");
		}
		else{
			echo json_encode("Failure");
		}
	}
	
?>