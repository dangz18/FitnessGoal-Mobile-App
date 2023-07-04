import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:flutter/cupertino.dart';
//To work with database
import 'package:http/http.dart' as http;
import 'dart:convert';
//To use Toast Notifications
import 'package:fluttertoast/fluttertoast.dart';
//To use water indicator
import 'package:waveprogressbar_flutter/waveprogressbar_flutter.dart';
//Pages to go to
import 'package:fitness_goal_android_app/pages/app_pages/profilePage.dart';
//Global variables
import 'package:fitness_goal_android_app/utilities/globalVariables.dart' as globals;

class HydrationPage extends StatefulWidget {
  final int userId;
  HydrationPage({
    required this.userId,
  });

  @override
  _HydrationPageState createState() => _HydrationPageState(
      userId: userId
  );

}


class _HydrationPageState extends State<HydrationPage> {
  final int userId;
  _HydrationPageState({required this.userId,}){
    DateTime now = new DateTime.now();
    todayDate = '${now.year}-${now.month}-${now.day}';
    _futureBuild = getUserInfo();
  }

  late Future _futureBuild;
  late String todayDate;
  late double userWaterPerDay;
  late double userCurrentConsumption;
  TextEditingController _quantityController = TextEditingController();
  late double waterHeight;

  WaterController waterController = WaterController();

  List userInfo = [];
  getUserInfo() async {
    //to get UserWaterPerDay
    var url_userInfo = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getUserInfo.php");
    var response_userInfo = await http.post(
        url_userInfo,
        body: {"userId": "${userId}"}
    );
    if(response_userInfo.statusCode == 200){
      userInfo = json.decode(response_userInfo.body);
    }
    userWaterPerDay = double.parse(userInfo[0]['user_waterPerDay']);

    //to get UserWaterConsumption
    var data;
    var url_userProgress = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getWaterHistory.php");
    var response_userProgress = await http.post(url_userProgress, body: {"userId": "${userId}", "todayDate": todayDate});

    if(response_userProgress.statusCode == 200)
      data = json.decode(response_userProgress.body);
    else
      print("Error conn db");

    if(data == 'Database error')
      return false;
    else
      userCurrentConsumption = double.parse(data[0]['water_consumed']);

    if(userCurrentConsumption <= userWaterPerDay)
      waterHeight = userCurrentConsumption / userWaterPerDay;
    else
      waterHeight = 1;

    return true;
  }

  Future updateWaterHistory() async {
    var url = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/updateWaterHistory.php");
    var response = await http.post(url, body:{
      "userId" : '${userId}',
      "waterConsumed" : '${userCurrentConsumption}',
      "todayDate" : todayDate
    });

    var data = json.decode(response.body);

    if(data == "Success"){
      Fluttertoast.showToast(
        msg: "Quantity added with success!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );

    }
    else if(data == "Failed"){
      Fluttertoast.showToast(
        msg: "Failed to add",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
    }
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FutureBuilder<dynamic>(
                        future: _futureBuild,
                        builder: (context, AsyncSnapshot<dynamic> snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return const Center(child: CircularProgressIndicator(color: Colors.black26));
                          }
                          else if(snapshot.hasData){
                            return Column(
                              children: <Widget>[
                                WaveProgressBar(
                                    flowSpeed: 2.0,
                                    waveDistance:45.0,
                                    size: Size (300,300),
                                    percentage: waterHeight,
                                    waterColor: Colors.blue,
                                    textStyle: TextStyle(
                                        color: Colors.black45,
                                        fontSize: 60.0,
                                        fontWeight: FontWeight.bold),
                                    heightController: waterController
                                ),
                                SizedBox(height: 20),
                                Text('${userCurrentConsumption} l / ${userWaterPerDay} l', style: TextStyle(fontFamily: 'calibri', fontSize: 40)),
                              ],
                            );
                          }
                          else{
                            return const Text('Nothing found');
                          }
                        },
                      ),
                      addQuantityBtn(),
                    ],
                  ),
                ),

              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container( //bottom red container
                  height: (MediaQuery.of(context).size.height) * 0.15,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFDF5658),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Text(
                      'Your body needs to be hydrated to function at its best. If there isn\'t enough liquid in your body, essential functions like circulation don\'t perform as smoothly and your organs won\'t get necessary nutrients, resulting in less efficient performance.',
                      style: TextStyle(fontSize: 18, fontFamily: 'calibri',),
                      textAlign: TextAlign.center
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addQuantityBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 200,
        child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))
                  ),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 70,
                            icon: Image.asset('assets/icons/100cupIcon.png', height: 300, width: 100),
                            onPressed: () {
                              userCurrentConsumption += 100/1000;
                              updateWaterHistory();
                              _quantityController.clear();
                              setState(() {
                                _futureBuild = getUserInfo();
                                waterController.changeWaterHeight(waterHeight);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            iconSize: 70,
                            icon: Image.asset('assets/icons/200cupIcon.png', height: 300, width: 100),
                            onPressed: () {
                              userCurrentConsumption += 200/1000;
                              updateWaterHistory();
                              _quantityController.clear();
                              setState(() {
                                _futureBuild = getUserInfo();
                                waterController.changeWaterHeight(waterHeight);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            iconSize: 70,
                            icon: Image.asset('assets/icons/400cupIcon.png', height: 300, width: 100),
                            onPressed: () {
                              userCurrentConsumption += 400/1000;
                              updateWaterHistory();
                              _quantityController.clear();
                              setState(() {
                                _futureBuild = getUserInfo();
                                waterController.changeWaterHeight(waterHeight);
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ]
                      ),
                      SizedBox(height: 20),
                      Text('Enter a custom quantity:', style: TextStyle(fontSize: 25, fontFamily: 'calibri'),),
                      Container(
                        padding: EdgeInsets.only(left:10),
                        alignment: Alignment.center,
                        height: (MediaQuery.of(context).size.height) / 15,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.pinkAccent,
                                  blurRadius: 15,
                                  offset: Offset(0,5)
                              )
                            ]
                        ),
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.black, fontSize: 30),
                          decoration: InputDecoration(
                            hintText: 'Quantity in ml',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(0),
                          ),
                        )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          addBtn(),
                          SizedBox(width: 20),
                          closeBtn(),
                        ],
                      )
                    ],
                  ),
                ),
              );
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
              'Add quantity',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: 'calibri'
              ),
            )
        )
    );
  }

  Widget addBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 100,
        child: ElevatedButton(
            onPressed: () {
              if(_quantityController.text.isEmpty){
                Fluttertoast.showToast(
                  msg: "Enter a quantity first",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else{
                userCurrentConsumption += double.parse(_quantityController.text)/1000;
                updateWaterHistory();
                _quantityController.clear();
                setState(() {
                  _futureBuild = getUserInfo();
                  waterController.changeWaterHeight(waterHeight);
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
              'Add',
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
              _quantityController.clear();
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
}
