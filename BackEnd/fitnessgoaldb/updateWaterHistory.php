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
	$waterConsumed = floatval($_POST['waterConsumed']);
	$todayDate = $_POST['todayDate'];
	
	$sql1 = "SELECT * FROM hydration_history WHERE user_id = '".$userId."' and hydration_date = '".$todayDate."' ";
	$result1 = mysqli_query($db, $sql1);
	$count1 = mysqli_num_rows($result1);
	
	if($count1!=0){ //user already logged today
		$sql2 = "UPDATE hydration_history SET water_consumed = '".$waterConsumed."' WHERE user_id = '".$userId."' and hydration_date = '".$todayDate."' ";
		$query2 = mysqli_query($db, $sql2);
		if($query2){
			echo json_encode("Success");
		}
		else{
			echo json_encode("Failed");
		}
	}
?>