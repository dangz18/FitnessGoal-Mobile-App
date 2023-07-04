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
	
	$mealInfo = array();
	$allMealInfo = array();
	
	
	$sql = "SELECT * FROM meal AS t1 INNER JOIN 
		(SELECT meal_id 
		FROM meal_plan_meals AS t2 
		INNER JOIN (SELECT meal_day_id FROM meal_plan_day WHERE user_id = '".$userId."' and meal_day>='".$todayDate."' ORDER BY meal_day LIMIT 3) 
		AS t3
		ON t2.meal_day_id = t3.meal_day_id) 
	AS t4
	ON t1.meal_id = t4.meal_id";

	$result = mysqli_query($db, $sql);
	$count = mysqli_num_rows($result);
	
	if($count > 0){
		while($row = mysqli_fetch_array($result)){
			$mealInfo[] = $row["meal_name"];
			$mealInfo[] = $row["meal_ingredients"];
			$mealInfo[] = $row["meal_instructions"];
			$mealInfo[] = $row["meal_category"];
			$mealInfo[] = $row["vegetarian"];
			$mealInfo[] = $row["meal_kcal"];
			$mealInfo[] = $row["meal_fat"];
			$mealInfo[] = $row["meal_saturates"];
			$mealInfo[] = $row["meal_сarbs"];
			$mealInfo[] = $row["meal_sugars"];
			$mealInfo[] = $row["meal_fibre"];
			$mealInfo[] = $row["meal_protein"];
			$mealInfo[] = $row["meal_salt"];
			$mealInfo[] = $row["meal_id"];
			$allMealInfo[] = $mealInfo;
			$mealInfo = array();
		}
		echo json_encode($allMealInfo);
	}
	else{
		echo json_encode('Nothing found');
	}
	
?>