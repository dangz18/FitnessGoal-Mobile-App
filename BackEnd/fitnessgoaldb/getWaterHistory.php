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
	$todayDate = $_POST['todayDate'];

	$sql = "SELECT water_consumed FROM hydration_history WHERE user_id = '".$userId."' and hydration_date = '".$todayDate."' ";
	$result = mysqli_query($db, $sql);
	$count = mysqli_num_rows($result);
	
	if($count == 1){
		$waterConsumed = [];
		while($row = mysqli_fetch_array($result)){
			$waterConsumed[]=$row;
		}
		echo json_encode($waterConsumed);
	}
	else{
		echo json_encode('Database error');
	}
	
?>