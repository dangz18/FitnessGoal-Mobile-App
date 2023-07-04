<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }
	
	$exerciseId = intval($_POST['exerciseId']);
	$repetitions = intval($_POST['repetitions']);
	$workoutDayId = intval($_POST['workoutDayId']);
	
	$sql = "INSERT INTO workout_exercises(exercise_id, repetitions, workout_day_id) VALUES('".$exerciseId."', '".$repetitions."', '".$workoutDayId."')";
	$query = mysqli_query($db, $sql);
	if($query){
			echo json_encode("Success");
	}
	else{
		echo json_encode("Failure");
	}
	
?>