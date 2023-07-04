<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }
	
	$mealId = intval($_POST['mealId']);
	
	
	$sql = "SELECT * FROM meal WHERE meal_id = '".$mealId."' ";
		
	$result = mysqli_query($db, $sql);
	$count = mysqli_num_rows($result);
	
	if($count > 0){
		while($row = mysqli_fetch_array($result)){
			echo json_encode(base64_encode($row['meal_image']));
		}
		
	}
	else{
		echo json_encode('Nothing found');
	}
	
	
?>