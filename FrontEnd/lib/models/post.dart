class Post{
  final int postId;
  final int userId;
  final String userName;
  final String postText;
  final String postDate;
  List hashTags = [];

  Post(
      this.postId,
      this.userId,
      this.userName,
      this.postText,
      this.postDate,
      this.hashTags
  );
}