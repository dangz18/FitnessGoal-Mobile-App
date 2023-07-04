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
	$postText = $_POST['postText'];
	$postDate = $_POST['postDate'];
	$postHashTags = $_POST['postHashTags'];
	
	$postHashTags_list = explode (",", $postHashTags);
	
	//Insert the values into post table
	$sql1 = "INSERT INTO post(user_id, post_text, post_date) VALUES('".$userId."', '".$postText."', '".$postDate."')";
	$query1 = mysqli_query($db, $sql1);
	
	
	//Insert all hashtags for the post inserted
	for($i = 0; $i < count($postHashTags_list); $i++){
		$sql3 = "INSERT INTO post_hashtags(post_id, post_hashtag) VALUES(LAST_INSERT_ID(), '".$postHashTags_list[$i]."')";
		$query3 = mysqli_query($db, $sql3);
	}
	
	echo json_encode("Success");
	
?>