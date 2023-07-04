<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }
	
	function calculateAge($birthdate) {
		$today = new DateTime();
		$diff = $today->diff(new DateTime($birthdate));
		return $diff->y;
	}

	function calculateInitialRepetitions($userGoal, $userWeight, $userHeight, $userGenre, $userFitnessLevel, $userAge) {
		$repetitions = 0;

		switch ($userGoal) {
			case "Lose Weight":
				if($userGenre == "Female"){ //->more reps
					$repetitions = floor(3500/($userHeight+$userWeight)) * $userFitnessLevel;
				}
				else{ //male ->fewer reps
					$repetitions = floor(3000/($userHeight+$userWeight)) * $userFitnessLevel;
				}
				
				if($userAge > 30 && $userAge < 70){ //middle age
					$repetitions = floor($repetitions * 0.9); // reduce by 10%
				}
				else if($userAge > 70){ //olders
					$repetitions = floor($repetitions * 0.7); // reduce by 30%
				}
				break;
			case "Get Muscle":
				if($userGenre == "Female"){ //->less reps
					$repetitions = floor($userWeight / 4) * $userFitnessLevel;
					$repetitions = floor($repetitions * 0.9); // reduce by 10%
				}
				else{ //male ->more reps
					$repetitions = floor($userWeight / 4) * $userFitnessLevel;
				}
				
				if($userAge > 30 && $userAge < 70){ //middle age
					$repetitions = floor($repetitions * 0.8); // reduce by 20%
				}
				else if($userAge > 70){ //olders
					$repetitions = floor($repetitions * 0.5); // reduce by 50%
				}
				break;
			case "Be Active":
				$repetitions = floor(400 / $userAge) * $userFitnessLevel;
				break;
		}

		return $repetitions;
	}

	function chooseExercises($userGoal, $userFitnessLevel, $db){
		$exercises = array();
		$strenghExercisesNumber = 3 * $userFitnessLevel;
		$cardioExercisesNumber = 3 * $userFitnessLevel;
		
		switch ($userGoal) {
			case "Lose Weight":
				$strenghExercisesNumber = floor($strenghExercisesNumber / 2);
				$sqlLW = "select exercise_id from exercise where exercise_muscle_category='Cardio' and exercise_difficulty_level <= '".$userFitnessLevel."' order by rand() limit ?";
				
				$stmt = mysqli_prepare($db, $sqlLW);
				mysqli_stmt_bind_param($stmt, "i", $cardioExercisesNumber);
				mysqli_stmt_execute($stmt);
				
				$resultLW = mysqli_stmt_get_result($stmt);			
				while($row = mysqli_fetch_array($resultLW)){
					$exercises[]=intval($row['exercise_id']);
				}
				
				$sqlGM = "select exercise_id from exercise where exercise_muscle_category!='Cardio' and exercise_difficulty_level <= '".$userFitnessLevel."' order by rand() limit ? ";
				
				$stmt = mysqli_prepare($db, $sqlGM);
				mysqli_stmt_bind_param($stmt, "i", $strenghExercisesNumber);
				mysqli_stmt_execute($stmt);
				
				$resultGM = mysqli_stmt_get_result($stmt);
				while($row = mysqli_fetch_array($resultGM)){
					$exercises[]=intval($row['exercise_id']);
				}
				break;
				
			case "Get Muscle":
				$cardioExercisesNumber = floor($cardioExercisesNumber / 2);
				$sqlLW = "select exercise_id from exercise where exercise_muscle_category='Cardio' and exercise_difficulty_level <= '".$userFitnessLevel."' order by rand() limit ? ";
				
				$stmt = mysqli_prepare($db, $sqlLW);
				mysqli_stmt_bind_param($stmt, "i", $cardioExercisesNumber);
				mysqli_stmt_execute($stmt);
				
				$resultLW = mysqli_stmt_get_result($stmt);
				while($row = mysqli_fetch_array($resultLW)){
					$exercises[]=intval($row['exercise_id']);
				}
				
				$sqlGM = "select exercise_id from exercise where exercise_muscle_category!='Cardio' and exercise_difficulty_level <= '".$userFitnessLevel."' order by rand() limit ? ";
				
				$stmt = mysqli_prepare($db, $sqlGM);
				mysqli_stmt_bind_param($stmt, "i", $strenghExercisesNumber);
				mysqli_stmt_execute($stmt);
				
				$resultGM = mysqli_stmt_get_result($stmt);
				while($row = mysqli_fetch_array($resultGM)){
					$exercises[]=intval($row['exercise_id']);
				}
				break;
				
			case "Be Active":
				
				$sqlLW = "select exercise_id from exercise where exercise_muscle_category='Cardio' and exercise_difficulty_level = 1 order by rand() limit ? ";
				
				$stmt = mysqli_prepare($db, $sqlLW);
				mysqli_stmt_bind_param($stmt, "i", $cardioExercisesNumber);
				mysqli_stmt_execute($stmt);
				
				$resultLW = mysqli_stmt_get_result($stmt);
				while($row = mysqli_fetch_array($resultLW)){
					$exercises[]=intval($row['exercise_id']);
				}
				
				$sqlGM = "select exercise_id from exercise where exercise_muscle_category!='Cardio' and exercise_difficulty_level = 1 order by rand() limit ?";
				
				$stmt = mysqli_prepare($db, $sqlGM);
				mysqli_stmt_bind_param($stmt, "i", $strenghExercisesNumber);
				mysqli_stmt_execute($stmt);
				
				$resultGM = mysqli_stmt_get_result($stmt);
				while($row = mysqli_fetch_array($resultGM)){
					$exercises[]=intval($row['exercise_id']);
				}
				break;
		}
		shuffle($exercises);
		return $exercises;
	}

	function buildWorkoutPlan($userId, $userGenre, $userHeight, $userWeight, $userAge, $userFitnessLevel, $userGoal, $db){
		$workoutDuration = 30;
		$startDay = new DateTime();
		$repetitions = calculateInitialRepetitions($userGoal, $userWeight, $userHeight, $userGenre, $userFitnessLevel, $userAge);
		$progression = 10 / $workoutDuration;
		
		for($day=0; $day<$workoutDuration; $day++){
			$currentDate = $startDay->format('Y-m-d');
			$exercises = array();
			$exercises = chooseExercises($userGoal, $userFitnessLevel, $db);
			
			$sql1 = "INSERT INTO workout_day(user_id, workout_day) VALUES('".$userId."', '".$currentDate."')";
			if(mysqli_query($db, $sql1)){
				$insertedId = mysqli_insert_id($db);
				for($i=0; $i<count($exercises); $i++){
					$sql2 = "INSERT INTO workout_exercises(exercise_id, repetitions, is_done, workout_day_id) VALUES('".$exercises[$i]."', round('".$repetitions."'), 0, '".$insertedId."')";
					if(mysqli_query($db, $sql2)){
					}
					else{
						return "Failure";
					}
				}
				//Increase the number of repetitions over time
				$repetitions += $progression;
				
				//Increase the difficulty level of exercise over time
				if ($day % 10 == 0){
					$userFitnessLevel = min(3, $userFitnessLevel + 1);
				}
				
				$startDay->modify('+1 day');
			}
			else{
				return "Failure";
			}	
		}
		return "Success";
	}

	function chooseMeals($userGoal, $userVegetarian, $userWeight, $db){
		$meals = array();
		$userWeightPounds = $userWeight * 2.205;
		$meintenanceCal = $userWeightPounds * 15;
		$kcalLW = floor((($meintenanceCal - $userWeightPounds) - 700)/3);
		switch ($userGoal) {
			case "Lose Weight":
				if($userVegetarian == 1){
					$sqlBreakfast = "select meal_id from meal where vegetarian = '".$userVegetarian."' and meal_fat<=15 and meal_сarbs<=42 and meal_sugars<=8 and meal_kcal<='".$kcalLW."' and meal_category = 'Breakfast' order by rand() limit 1";
					$resultBreakfast = mysqli_query($db, $sqlBreakfast);
					while($row = mysqli_fetch_array($resultBreakfast)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlLunch = "select meal_id from meal where vegetarian = '".$userVegetarian."' and meal_fat<=15 and meal_сarbs<=42 and meal_sugars<=8 and meal_kcal<='".$kcalLW."' and meal_category = 'Lunch' order by rand() limit 1";
					$resultLunch = mysqli_query($db, $sqlLunch);
					while($row = mysqli_fetch_array($resultLunch)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlDinner = "select meal_id from meal where vegetarian = '".$userVegetarian."' and meal_fat<=15 and meal_сarbs<=42 and meal_sugars<=8 and meal_kcal<='".$kcalLW."' and meal_category = 'Dinner' order by rand() limit 1";
					$resultDinner = mysqli_query($db, $sqlDinner);
					while($row = mysqli_fetch_array($resultDinner)){
						$meals[] = intval($row['meal_id']);
					}
				}
				else{
					$sqlBreakfast = "select meal_id from meal where meal_fat<=15 and meal_сarbs<=42 and meal_sugars<=8 and meal_kcal<='".$kcalLW."' and meal_category = 'Breakfast' order by rand() limit 1";
					$resultBreakfast = mysqli_query($db, $sqlBreakfast);
					while($row = mysqli_fetch_array($resultBreakfast)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlLunch = "select meal_id from meal where meal_fat<=15 and meal_сarbs<=42 and meal_sugars<=8 and meal_kcal<='".$kcalLW."' and meal_category = 'Lunch' order by rand() limit 1";
					$resultLunch = mysqli_query($db, $sqlLunch);
					while($row = mysqli_fetch_array($resultLunch)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlDinner = "select meal_id from meal where meal_fat<=15 and meal_сarbs<=42 and meal_sugars<=8 and meal_kcal<='".$kcalLW."' and meal_category = 'Dinner' order by rand() limit 1";
					$resultDinner = mysqli_query($db, $sqlDinner);
					while($row = mysqli_fetch_array($resultDinner)){
						$meals[] = intval($row['meal_id']);
					}	
				}

				break;
				
			case "Get Muscle":
			
				if($userVegetarian == 1){
					$sqlBreakfast = "select meal_id from (select * from meal where vegetarian = '".$userVegetarian."' and meal_category = 'Breakfast' order by meal_protein desc limit 10) as subquery order by rand() limit 1";
					$resultBreakfast = mysqli_query($db, $sqlBreakfast);
					while($row = mysqli_fetch_array($resultBreakfast)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlLunch = "select meal_id from (select * from meal where vegetarian = '".$userVegetarian."' and meal_category = 'Lunch' order by meal_protein desc limit 10) as subquery order by rand() limit 1";
					$resultLunch = mysqli_query($db, $sqlLunch);
					while($row = mysqli_fetch_array($resultLunch)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlDinner = "select meal_id from (select * from meal where vegetarian = '".$userVegetarian."' and meal_category = 'Dinner' order by meal_protein desc limit 10) as subquery order by rand() limit 1";
					$resultDinner = mysqli_query($db, $sqlDinner);
					while($row = mysqli_fetch_array($resultDinner)){
						$meals[] = intval($row['meal_id']);
					}
				}
				else{
					$sqlBreakfast = "select meal_id from (select * from meal where meal_category = 'Breakfast' order by meal_protein desc limit 10) as subquery order by rand() limit 1";
					$resultBreakfast = mysqli_query($db, $sqlBreakfast);
					while($row = mysqli_fetch_array($resultBreakfast)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlLunch = "select meal_id from (select * from meal where meal_category = 'Lunch' order by meal_protein desc limit 10) as subquery order by rand() limit 1";
					$resultLunch = mysqli_query($db, $sqlLunch);
					while($row = mysqli_fetch_array($resultLunch)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlDinner = "select meal_id from (select * from meal where meal_category = 'Dinner' order by meal_protein desc limit 10) as subquery order by rand() limit 1";
					$resultDinner = mysqli_query($db, $sqlDinner);
					while($row = mysqli_fetch_array($resultDinner)){
						$meals[] = intval($row['meal_id']);
					}
				}
				break;
				
			case "Be Active":
				if($userVegetarian == 1){
					$sqlBreakfast = "select meal_id from meal where vegetarian = '".$userVegetarian."' and meal_category = 'Breakfast' order by rand() limit 1";
					$resultBreakfast = mysqli_query($db, $sqlBreakfast);
					while($row = mysqli_fetch_array($resultBreakfast)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlLunch = "select meal_id from meal where vegetarian = '".$userVegetarian."' and meal_category = 'Lunch' order by rand() limit 1";
					$resultLunch = mysqli_query($db, $sqlLunch);
					while($row = mysqli_fetch_array($resultLunch)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlDinner = "select meal_id from meal where vegetarian = '".$userVegetarian."' and meal_category = 'Dinner' order by rand() limit 1";
					$resultDinner = mysqli_query($db, $sqlDinner);
					while($row = mysqli_fetch_array($resultDinner)){
						$meals[] = intval($row['meal_id']);
					}
				}
				else{
					$sqlBreakfast = "select meal_id from meal where meal_category = 'Breakfast' order by rand() limit 1";
					$resultBreakfast = mysqli_query($db, $sqlBreakfast);
					while($row = mysqli_fetch_array($resultBreakfast)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlLunch = "select meal_id from meal where meal_category = 'Lunch' order by rand() limit 1";
					$resultLunch = mysqli_query($db, $sqlLunch);
					while($row = mysqli_fetch_array($resultLunch)){
						$meals[] = intval($row['meal_id']);
					}
					
					$sqlDinner = "select meal_id from meal where meal_category = 'Dinner' order by rand() limit 1";
					$resultDinner = mysqli_query($db, $sqlDinner);
					while($row = mysqli_fetch_array($resultDinner)){
						$meals[] = intval($row['meal_id']);
					}	
				}
				break;
		}

		return $meals;
	}

	function buildMealPlan($userId, $userWeight, $userVegetarian, $userGoal, $db){
		$mealDuration = 30;
		$startDay = new DateTime();
		
		for($day=0; $day<$mealDuration; $day++){
			$currentDate = $startDay->format('Y-m-d');
			$meals = array();
			$meals = chooseMeals($userGoal, $userVegetarian, $userWeight, $db);
			
			$sql1 = "INSERT INTO meal_plan_day(user_id, meal_day) VALUES('".$userId."', '".$currentDate."')";
			if(mysqli_query($db, $sql1)){
				$insertedId = mysqli_insert_id($db);
				for($i=0; $i<count($meals); $i++){
					$sql2 = "INSERT INTO meal_plan_meals(meal_id, meal_day_id) VALUES('".$meals[$i]."', '".$insertedId."')";
					if(mysqli_query($db, $sql2)){
					}
					else{
						return "Failure";
					}
				}
				
				$startDay->modify('+1 day');
			}
			else{
				return "Failure";
			}	
		}
		return "Success";
	}

	function getWaterPerDayIntake($userWeight, $userGoal){
		$userWeightPounds = $userWeight * 2.205;
		$waterIntake = ($userWeightPounds * 0.5) / 33.814;
		
		switch ($userGoal) {
			case 'Lose Weight':
				$waterIntake = $waterIntake + 0.25;
				break;
			case 'Get Muscle':
				$waterIntake = $waterIntake + 0.35;
				break;
		}
		$waterIntake = round($waterIntake, 1);

		return $waterIntake;
	}


	$userName = $_POST['userName'];
	$userEmail = $_POST['userEmail'];
	$userPassword = $_POST['userPassword'];
	$userGenre = $_POST['userGenre'];
	$userHeight = floatval($_POST['userHeight']);
	$userWeight = floatval($_POST['userWeight']);
	$userBirthdate = $_POST['userBirthdate'];
	$userVegetarian = intval($_POST['userVegetarian']);
	$userGoal = $_POST['userGoal'];
	$userFitnessLevel = intval($_POST['userFitnessLevel']);
	$userAge = calculateAge($userBirthdate);
	$userWaterPerDay = getWaterPerDayIntake($userWeight, $userGoal);
	
	$sql1 = "SELECT * FROM utilizator WHERE user_email= '".$userEmail."' ";
	$result1 = mysqli_query($db, $sql1);
	$count1 = mysqli_num_rows($result1);
	
	if($count1 > 0){
		echo json_encode("You already have an account");
	}
	else{
		$sql2 = "INSERT INTO utilizator(user_name, user_email, user_password, user_genre, user_height, user_weight, user_birthdate, user_waterPerDay, user_fitness_level) 
		VALUES ('".$userName."', '".$userEmail."', '".$userPassword."', '".$userGenre."', '".$userHeight."', '".$userWeight."', '".$userBirthdate."', '".$userWaterPerDay."', '".$userFitnessLevel."') ";
		
		if(mysqli_query($db, $sql2)){
			$userId = mysqli_insert_id($db);
			if(buildWorkoutPlan($userId, $userGenre, $userHeight, $userWeight, $userAge, $userFitnessLevel, $userGoal, $db) == "Success"){
				if(buildMealPlan($userId, $userWeight, $userVegetarian, $userGoal, $db) == "Success"){
					echo json_encode($userId);
				}
				else{
					echo json_encode("Failure");
				}
			}
			else{
				echo json_encode("Failure");
			}
		}
		else{
			echo json_encode("Failure");
		}
	}
	
?>