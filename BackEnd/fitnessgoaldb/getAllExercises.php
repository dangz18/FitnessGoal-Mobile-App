<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }

	$exerciseInfo = array();
	$allExercises = array();
	
	$sql = "SELECT * FROM exercise";
		
	$result = mysqli_query($db, $sql);
	$count = mysqli_num_rows($result);
	
	if($count > 0){
		while($row = mysqli_fetch_array($result)){
			
			$exerciseInfo[] = $row["exercise_id"];
			$exerciseInfo[] = $row["exercise_name"];
			$exerciseInfo[] = $row["exercise_muscle_category"];
			
			$allExercises[] = $exerciseInfo;
			$exerciseInfo = array();
		}
		
		echo json_encode($allExercises);
		
	}
	else{
		echo json_encode('Nothing found');
	}
	
	
?>