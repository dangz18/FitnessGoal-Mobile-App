import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:flutter/cupertino.dart';
//Pages to go to
import 'package:fitness_goal_android_app/pages/app_pages/profilePage.dart';
//Global variables
import 'package:fitness_goal_android_app/utilities/globalVariables.dart' as globals;
//Post Class
import 'package:fitness_goal_android_app/models/post.dart';
//To work with database
import 'package:http/http.dart' as http;
import 'dart:convert';
//To use Toast Notifications
import 'package:fluttertoast/fluttertoast.dart';

class FeedPage extends StatefulWidget {
  final int userId;
  FeedPage({
    required this.userId,
  });

  @override
  _FeedPageState createState() => _FeedPageState(
      userId: userId
  );

}


class _FeedPageState extends State<FeedPage> {
  final int userId;
  _FeedPageState({required this.userId}){
    myHashTags = [];
    posts = [];

    _futureHashTags = getAllHashTags();
    _futurePosts = getAllPosts(myHashTags);
  }

  TextEditingController _myPostContentController = TextEditingController();
  TextEditingController _myHashTagController = TextEditingController();

  late List<String> myHashTags;
  late Future _futureHashTags;

  late List<Post> posts;
  late Future _futurePosts;


  Future getAllHashTags() async{
    await Future.delayed(Duration(seconds: 1));
    return myHashTags;
  }

  Future insertPost() async {
    DateTime now = new DateTime.now();
    String todayDate = '${now.year}-${now.month}-${now.day}';
    var url = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/insertPost.php");
    var response = await http.post(url, body:{
      "userId" : '${userId}',
      "postText" : _myPostContentController.text,
      "postDate" : todayDate,
      "postHashTags" : myHashTags.join(',')
    });
    var data = await json.decode(json.encode(response.body));

    if(data == "Success"){
      Fluttertoast.showToast(
        msg: "Post added with success!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
    }
    else if(data == "Something went wrong"){
      Fluttertoast.showToast(
        msg: "Failed to post",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
    }
  }

  Future getAllPosts(List filterHashtags) async {
    await Future.delayed(Duration(seconds: 2));
    posts.clear();
    var url1 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getAllPosts.php");
    var response1 = await http.post(url1, body:{});
    List data = await json.decode(response1.body);
    if(data == 'Nothing found'){
      print("Nothing found");
    }
    else{
      for(int i=0; i<data[0].length; i++){
        //get post hashtags
        var url2 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getPostHashTags.php");
        var response2 = await http.post(url2, body:{"postId" : data[0][i]});
        var data2 = await json.decode(response2.body);
        //Make the posts
        if(filterHashtags.isEmpty){//if we didn't filter
          posts.add(Post(int.parse(data[0][i]), int.parse(data[1][i]), data[2][i], data[3][i], data[4][i], data2));
        }
        else if(data2.any((element) => filterHashtags.contains(element))){//if at least one element from post's hashtags exists in filter hashtags
          posts.add(Post(int.parse(data[0][i]), int.parse(data[1][i]), data[2][i], data[3][i], data[4][i], data2));
        }
        else{
          //We don't show the post
        }
      }
    }
    myHashTags.clear();
    return true;
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container( //upper red cont
                height: double.infinity,
                width: double.infinity,
                color: Color(0xFFDF5658),
                child: Stack(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                            'assets/images/fitness-goal-logo.png', height: 50,
                            width: 50),
                        Text('FitnessGoal', style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Alegreya',
                            fontSize: 32)),
                        SizedBox(
                            height: 45.0,
                            width: 45.0,
                            child: new IconButton(
                              padding: new EdgeInsets.only(right: 5.0),
                              icon: new Icon(CupertinoIcons.profile_circled,
                                  size: 45.0),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)));
                              },
                            )
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container( //white cont
                height: (MediaQuery.of(context).size.height) - 50,
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FutureBuilder<dynamic>(
                        future: _futurePosts,
                        builder: (context, AsyncSnapshot<dynamic> snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  CircularProgressIndicator(color: Colors.black26)
                                ],
                              ),
                            );
                          }
                          else if(snapshot.hasData){
                            return Column(
                              children: [
                                Container(
                                  height: (MediaQuery.of(context).size.height) * 0.68,
                                  width: double.maxFinite,
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: posts.length,
                                      itemBuilder: (context, index){
                                        return Padding(
                                          padding: EdgeInsets.all(3),
                                          child: postContainer(index),
                                        );
                                      }),
                                ),
                              ],
                            );
                          }
                          else{
                            return const Text('No posts yet', style: TextStyle(fontFamily: 'calibri', fontSize: 35, fontWeight: FontWeight.bold),);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container( //bottom red container
                  height: (MediaQuery.of(context).size.height) * 0.1,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFDF5658),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget> [
                      //Refresh btn
                      IconButton(
                        iconSize: 30,
                        icon: Icon(Icons.refresh),
                        onPressed: (){
                          setState(() {
                            myHashTags.clear();
                            _futurePosts = getAllPosts(myHashTags);
                          });
                        },
                      ),
                      //Make a post btn
                      makePostBtn(),
                      //Filter btn
                      filterPostsBtn(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makePostBtn(){
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  insetPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))
                  ),
                  content: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //Post content
                        Container(
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            height: (MediaQuery.of(context).size.height) * 0.3,
                            width: (MediaQuery.of(context).size.width),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.pinkAccent,
                                      blurRadius: 10,
                                      offset: Offset(0,5)
                                  )
                                ]
                            ),
                            child: SizedBox(
                              height: (MediaQuery.of(context).size.height) * 0.3,
                              child: TextFormField(
                                maxLines: 10,
                                minLines: 1,
                                textAlign: TextAlign.start,
                                controller: _myPostContentController,
                                keyboardType: TextInputType.text,
                                style: TextStyle(color: Colors.black, fontSize: 20),
                                decoration: InputDecoration(
                                  hintText: 'Enter your words here',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0),
                                ),
                              ),
                            ),
                        ),
                        SizedBox(height: 15),
                        //HashTags List
                        FutureBuilder<dynamic>(
                          future: _futureHashTags,
                          builder: (context, AsyncSnapshot<dynamic> snapshot){
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return const Center(child: CircularProgressIndicator(color: Colors.black26));
                            }
                            else if(snapshot.hasData){
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: myHashTags.length,
                                        itemBuilder: (context, index){
                                          return Padding(
                                            padding: EdgeInsets.all(3),
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                alignment: Alignment.center,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFDF5658),
                                                  borderRadius: BorderRadius.circular(30.0),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(myHashTags[index], style: TextStyle(fontSize: 20, fontFamily: 'calibri')),
                                                    IconButton(
                                                      iconSize: 20,
                                                      icon: const Icon(Icons.delete),
                                                      onPressed: () {
                                                        removeHashtag(index);
                                                        setState(() {
                                                          _futureHashTags = getAllHashTags();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                )
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              );
                            }
                            else{
                              return const Text('Nothing found');
                            }
                          },
                        ),
                        SizedBox(height: 15),
                        enterHashtag(),
                        //Bottom buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            postBtn(),
                            SizedBox(width: 20),
                            closeBtn(),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }
            );
          }
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 10, // Elevation
        shadowColor: Colors.pinkAccent, // Shadow Color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Make a post',
            style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontFamily: 'calibri'
            ),
          ),
          Icon(Icons.add, color: Colors.black,),
        ],
      )
    );
  }

  Widget filterPostsBtn(){
    return IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        insetPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        content: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //UseLess Container but important
                              Container(
                                alignment: Alignment.topCenter,
                                height: 1,
                                width: (MediaQuery.of(context).size.width),
                                child: SizedBox(
                                  height: (MediaQuery.of(context).size.height) * 0.3,
                                  child: Text(''),
                                ),
                              ),
                              enterHashtag(),
                              SizedBox(height: 15),
                              //HashTags List
                              FutureBuilder<dynamic>(
                                future: _futureHashTags,
                                builder: (context, AsyncSnapshot<dynamic> snapshot){
                                  if(snapshot.connectionState == ConnectionState.waiting){
                                    return const Center(child: CircularProgressIndicator(color: Colors.black26));
                                  }
                                  else if(snapshot.hasData){
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          width: double.maxFinite,
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: myHashTags.length,
                                              itemBuilder: (context, index){
                                                return Padding(
                                                  padding: EdgeInsets.all(3),
                                                  child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                      alignment: Alignment.center,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFDF5658),
                                                        borderRadius: BorderRadius.circular(30.0),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Text(myHashTags[index], style: TextStyle(fontSize: 20, fontFamily: 'calibri')),
                                                          IconButton(
                                                            iconSize: 20,
                                                            icon: const Icon(Icons.delete),
                                                            onPressed: () {
                                                              removeHashtag(index);
                                                              setState(() {
                                                                _futureHashTags = getAllHashTags();
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    );
                                  }
                                  else{
                                    return const Text('Nothing found');
                                  }
                                },
                              ),
                              SizedBox(height: 15),
                              //Bottom buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  filterBtn(),
                                  SizedBox(width: 20),
                                  closeBtn(),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                );
              }
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 10, // Elevation
          shadowColor: Colors.pinkAccent, // Shadow Color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: Icon(Icons.sort),
        iconSize: 30,
    );
  }

  void addHashtag(String hashtag){
    myHashTags.add(hashtag);
  }

  void removeHashtag(int index){
    myHashTags.removeAt(index);
  }

  Widget enterHashtag(){
    return Container(
        alignment: Alignment.center,
        height: 50,
        width: 150,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.pinkAccent,
                  blurRadius: 10,
                  offset: Offset(0,5)
              )
            ]
        ),
        child: TextFormField(
          textAlign: TextAlign.center,
          controller: _myHashTagController,
          keyboardType: TextInputType.name,
          style: TextStyle(color: Colors.black38),
          decoration: InputDecoration(
            hintText: 'Enter hashtag',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (text){
            if(_myHashTagController.text[0] != '#' || _myHashTagController.text.length<3){
              Fluttertoast.showToast(
                msg: "Your hashtag should start with '#' and have a minimum length of 2!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                fontSize: 20.0,
              );
            }
            else if(_myHashTagController.text.contains(RegExp(r"\s"))){
              Fluttertoast.showToast(
                msg: "Hashtag can't contain whitespaces!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                fontSize: 20.0,
              );
            }
            else if(myHashTags.contains(_myHashTagController.text)){
              Fluttertoast.showToast(
                msg: "Hashtag already exists!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                fontSize: 20.0,
              );
            }
            else{
              addHashtag(_myHashTagController.text);
              setState(() {
                _futureHashTags = getAllHashTags();
                _myHashTagController.clear();
              });
            }
            _myHashTagController.clear();
          },
        )
    );
  }

  Widget postBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 100,
        child: ElevatedButton(
            onPressed: () {
              if(_myPostContentController.text.isEmpty){
                Fluttertoast.showToast(
                  msg: "You can't make an empty post!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else{
                insertPost();
                for(int i=0; i< 10; i++);
                _myPostContentController.clear();
                _myHashTagController.clear();
                myHashTags.clear();
                setState(() {
                  posts.clear();
                  _futurePosts = getAllPosts(myHashTags);
                });
                Navigator.pop(context);
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return Color(0xFFDF5658);
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )
              ),
            ),
            child:const Text(
              'Post',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'calibri'
              ),
            )
        )
    );
  }

  Widget closeBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 100,
        child: ElevatedButton(
            onPressed: () {
              _myPostContentController.clear();
              _myHashTagController.clear();
              myHashTags.clear();
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return Color(0xFFDF5658);
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )
              ),
            ),
            child:const Text(
              'Close',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'calibri'
              ),
            )
        )
    );
  }

  Widget postContainer(int index){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFFDF5658),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(posts[index].userName, style: TextStyle(fontSize: 25, fontFamily: 'calibri')),
                  Text(posts[index].postDate, style: TextStyle(fontSize: 20, fontFamily: 'calibri')),
                ],
              ),
              Text(posts[index].postText, style: TextStyle(fontSize: 20, fontFamily: 'calibri')),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget filterBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 100,
        child: ElevatedButton(
            onPressed: () {
              if(myHashTags.isEmpty){
                Fluttertoast.showToast(
                  msg: "Enter a hashtag to filter by!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else{
                _myHashTagController.clear();
                setState(() {
                  posts.clear();
                  _futurePosts = getAllPosts(myHashTags);
                  //myHashTags.clear();
                });
                Navigator.pop(context);
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return Color(0xFFDF5658);
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )
              ),
            ),
            child:const Text(
              'Filter',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'calibri'
              ),
            )
        )
    );
  }

}
