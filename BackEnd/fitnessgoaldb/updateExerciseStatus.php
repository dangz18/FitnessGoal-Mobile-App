<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }
	
	$workoutExerciseId = intval($_POST['workoutExerciseId']);
	
	$sql1 = "UPDATE workout_exercises SET is_done = 1 WHERE workout_exercise_id = '".$workoutExerciseId."' ";
	$query1 = mysqli_query($db, $sql1);
	if($query1){
		echo json_encode("Success");
	}
	else{
		echo json_encode("Failed");
	}
?>