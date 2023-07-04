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
	
	$weight = array();
	$weightDate = array();

	$sql = "SELECT weight, weight_date FROM weight_history WHERE user_id = '".$userId."' ORDER BY weight_date";
	$result = mysqli_query($db, $sql);
	$count = mysqli_num_rows($result);
	
	if($count > 0){
		while($row = mysqli_fetch_array($result)){
			$weight[] = $row['weight'];
			$weightDate[] = $row['weight_date'];
		}
		$weightInfo = array($weight, $weightDate);
		echo json_encode($weightInfo);
	}
	else{
		echo json_encode('Nothing found');
	}
	
?>