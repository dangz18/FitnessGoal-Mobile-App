<?php
	$host = 'localhost';
    $user = 'root';
    $password = '';
    $schema = 'fitnessgoaldb';
	
    $db = mysqli_connect($host, $user, $password, $schema);
    if(!$db){
        echo "Database connection failed";
    }
	
	
	$postId = intval($_POST['postId']);
	$sql = "SELECT post_hashtag FROM post_hashtags WHERE post_id = '".$postId."' ";
	
	$postHashTags = array();
	
	$result = mysqli_query($db, $sql);
	
	while($row = mysqli_fetch_array($result)){
		$postHashTags[] = $row['post_hashtag'];
	}
	
	echo json_encode($postHashTags);
	
?>