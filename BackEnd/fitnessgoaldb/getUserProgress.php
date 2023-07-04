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

	$doneExercises = 0;
	$totalExercises = 0;
	
	$sql = "SELECT * FROM workout_day WHERE user_id = '".$userId."' ";
		
	$result = mysqli_query($db, $sql);
	$count = mysqli_num_rows($result);
	
	if($count > 0){
		while($row = mysqli_fetch_array($result)){
			$sql2 = "SELECT * FROM workout_exercises WHERE workout_day_id = '".$row['workout_day_id']."' ";
			$result2 = mysqli_query($db, $sql2);
			while($row2 = mysqli_fetch_array($result2)){
				$totalExercises = $totalExercises + 1;
				if($row2['is_done'] == 1){
					$doneExercises = $doneExercises + 1;
				}
			}
			
		}
		$percentage = ($doneExercises / $totalExercises) * 100;
		
		$percentage = sprintf("%.1f",$percentage);
		
		echo $percentage;
		
	}
	else{
		echo json_encode('Failed');
	}
	
	
?>