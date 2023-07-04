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
	
	$exerciseInfo = array();
	$workoutInfo = array();
	
	$sql = "SELECT * FROM workout_exercises AS t2 INNER JOIN
		(SELECT workout_day_id FROM workout_day WHERE user_id = '".$userId."' and workout_day = '".$todayDate."') AS t1
		ON t2.workout_day_id = t1.workout_day_id";
		
	$result = mysqli_query($db, $sql);
	$count = mysqli_num_rows($result);
	
	if($count > 0){
		while($row = mysqli_fetch_array($result)){
			$sql2 = "SELECT * FROM exercise WHERE exercise_id = '".$row["exercise_id"]."' ";
			$result2 = mysqli_query($db, $sql2);
			while($row2 = mysqli_fetch_array($result2)){
				$exerciseInfo[] = $row2["exercise_name"];
				$exerciseInfo[] = $row2["exercise_muscle_category"];
				$exerciseInfo[] = base64_encode($row2["exercise_image"]);
			}
			$exerciseInfo[] = $row["repetitions"];
			$exerciseInfo[] = $row["is_done"];
			$exerciseInfo[] = $row["workout_exercise_id"]; //for easier changes
			$exerciseInfo[] = $row["workout_day_id"]; //for future adding exercises
			$workoutInfo[] = $exerciseInfo;
			$exerciseInfo = array();
		}
		
		echo json_encode($workoutInfo);
		
	}
	else{
		echo json_encode('Nothing found');
	}
	
	
?>