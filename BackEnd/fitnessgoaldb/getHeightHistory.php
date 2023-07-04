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
	
	$height = array();
	$heightDate = array();

	$sql = "SELECT height, height_date FROM height_history WHERE user_id = '".$userId."' ORDER BY height_date ";
	$result = mysqli_query($db, $sql);
	$count = mysqli_num_rows($result);
	
	if($count > 0){
		while($row = mysqli_fetch_array($result)){
			$height[] = $row['height'];
			$heightDate[] = $row['height_date'];
		}
		$heightInfo = array($height, $heightDate);
		echo json_encode($heightInfo);
	}
	else{
		echo json_encode('Nothing found');
	}
	
?>