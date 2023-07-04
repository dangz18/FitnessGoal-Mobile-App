<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }

	$sql = "SELECT * FROM post ORDER BY post_id DESC";
	
	$postId = array();
	$userId = array();
	$userName = array();
	$postText = array();
	$postDate = array();
	
	
	$result = mysqli_query($db, $sql);
	$count = mysqli_num_rows($result);
	
	if($count>0){
		while($row = mysqli_fetch_array($result)){
			$postId[] = $row['post_id'];
			$userId[] = $row['user_id'];
			$postText[] = $row['post_text'];
			$postDate[] = $row['post_date'];
			
			$sql2 = "SELECT user_name FROM utilizator WHERE user_id = '".$row['user_id']."'";
			$result2 = mysqli_query($db, $sql2);
			$count2 = mysqli_num_rows($result2);
			if($count2>0){
				while($row2 = mysqli_fetch_array($result2)){
					$userName[] = $row2['user_name'];
				}
			}
		}
		$posts = array($postId, $userId, $userName, $postText, $postDate);
		echo json_encode($posts);
		
	}else{
		echo json_encode('Nothing found');
	}
	
?>