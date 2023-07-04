import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:flutter/cupertino.dart';
//Global variables
import 'package:fitness_goal_android_app/utilities/globalVariables.dart' as globals;
//To use percentage indicator
import 'package:percent_indicator/circular_percent_indicator.dart';
//To work with database
import 'package:http/http.dart' as http;
import 'dart:convert';
//Pages to go to
import 'package:fitness_goal_android_app/pages/app_pages/profilePage.dart';

class HomePage extends StatefulWidget {
  final int userId;
  HomePage({
    required this.userId,
  });

  @override
  _HomePageState createState() => _HomePageState(
    userId: userId
  );

}

class _HomePageState extends State<HomePage> {
  final int userId;
  _HomePageState({
    required this.userId,
  });

  late String userName;
  late double userHeight;
  late double userWeight;
  late int userAge;
  late double progressPercentage;

  List userInfo = [];
  Future<dynamic> getUserInfo() async {
    var url = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getUserInfo.php");
    var response = await http.post(
        url,
        body: {"userId": "${userId}"}
    );
    if(response.statusCode == 200){

      userInfo = json.decode(response.body);
      userName = userInfo[0]['user_name'];
      userHeight = double.parse(userInfo[0]['user_height']);
      userWeight = double.parse(userInfo[0]['user_weight']);
      userAge = calculateAge("${userInfo[0]['user_birthdate']}");


      var url2 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getUserProgress.php");
      var response2 = await http.post(
          url2,
          body: {"userId": "${userId}"}
      );
      var data = await json.decode(response2.body);
      if(data == 'Failure'){
        return false;
      }
      else{
        progressPercentage = data;
        return true;
      }
    }
    else{
      return false;
    }
  }

  int calculateAge(String birthDate) {
    DateTime currentDate = DateTime.now();
    var age = currentDate.year - int.parse(birthDate.split("-")[0]);
    int month1 = currentDate.month;
    int month2 = int.parse(birthDate.split("-")[1]);
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = int.parse(birthDate.split("-")[2]);
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  @override
  void initState(){
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container( //red cont
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
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  //to be able to scroll
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      displayQuote(),
                      FutureBuilder<dynamic>(
                        future: getUserInfo(),
                        builder: (context, AsyncSnapshot<dynamic> snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return const Center(child: CircularProgressIndicator(color: Colors.black26));
                          }
                          else if(snapshot.hasData){
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('${userName}\'s personal information:', style: TextStyle(fontSize: 30, fontFamily: 'Alegreya')),
                                Text('Height:${userHeight} cm Weight:${userWeight} kg Age:${userAge} years', style: TextStyle(fontSize: 22, fontFamily: 'Alegreya')),
                                SizedBox(height: 10),
                                Center(
                                    child: CircularPercentIndicator(
                                      animation: true,
                                      animationDuration: 1000,
                                      radius: 150,
                                      lineWidth: 30,
                                      percent: (progressPercentage)/100,
                                      progressColor: Colors.lightBlue,
                                      circularStrokeCap: CircularStrokeCap.round,
                                      center: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('${progressPercentage}%', style: TextStyle(fontSize: 50)),
                                          refreshBtn(),
                                        ],
                                      ),
                                    )
                                ),
                              ],
                            );
                          }
                          else{
                            return const Text('Nothing found');
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Text('closer to achieving the goal', style: TextStyle(color: Colors.lightBlue, fontSize: 25, fontFamily: 'Alegreya')),
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

  Widget displayQuote(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      decoration: BoxDecoration(
        color: Color(0xFFDF5658),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0)
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'One part at a time, one day at a time, we can accomplish any goal we set for ourselves',
            style: TextStyle(fontSize: 20.0, fontFamily: 'calibri'),
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.only(left: (MediaQuery.of(context).size.height)/3), child: Image.asset('assets/icons/motivation.png', height: 50, width: 50)),
        ],
      ),
    );
  }

  Widget refreshBtn(){
    return IconButton(
      iconSize: 30,
      icon: Icon(Icons.refresh),
      onPressed: (){
        setState(() {
          getUserInfo();
        });
      },
    );
  }
}
