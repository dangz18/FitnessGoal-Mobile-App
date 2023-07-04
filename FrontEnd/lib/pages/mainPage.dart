import "package:flutter/material.dart";
//Pages to navigate to
import 'package:fitness_goal_android_app/pages/app_pages/homePage.dart';
import 'package:fitness_goal_android_app/pages/app_pages/workoutsPage.dart';
import 'package:fitness_goal_android_app/pages/app_pages/mealsPage.dart';
import 'package:fitness_goal_android_app/pages/app_pages/hydrationPage.dart';
import 'package:fitness_goal_android_app/pages/app_pages/feedPage.dart';
//Global variables
import 'package:fitness_goal_android_app/utilities/globalVariables.dart' as globals;
//To work with database
import 'package:http/http.dart' as http;
//To use Toast Notifications
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';


class MainPage extends StatefulWidget{
  final int userId;
  final int userFitnessLevel;
  MainPage({
    required this.userId,
    required this.userFitnessLevel,
  });
  @override
  _MainPageState createState() => _MainPageState(userId: userId, userFitnessLevel: userFitnessLevel);
}


class _MainPageState extends State<MainPage>{
  final int userId;
  final int userFitnessLevel;
  _MainPageState({required this.userId, required this.userFitnessLevel}){
    insertWaterHistory();
  }

  //To update User Water History
  Future insertWaterHistory() async {
    DateTime now = new DateTime.now();
    String todayDate = '${now.year}-${now.month}-${now.day}';
    var url = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/insertWaterHistory.php");
    var response = await http.post(url, body:{
      "userId" : '${userId}',
      "todayDate" : todayDate
    });

    var data = json.decode(response.body);

    if(data == "Success"){
      Fluttertoast.showToast(
        msg: "Water History updated with success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );

    }
    else if(data == "Failed"){
      Fluttertoast.showToast(
        msg: "Water History update failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
    }
    else if(data == "The row exists"){

    }
  }

  int pageIndex = 0;
  late List<Widget> pageContent = [
    HomePage(userId: userId),
    WorkoutsPage(userId: userId, userFitnessLevel: userFitnessLevel),
    MealsPage(userId: userId),
    HydrationPage(userId: userId),
    FeedPage(userId: userId),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFDF5658),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: 'calibri', fontSize: 18),
        selectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        currentIndex: pageIndex,
        items: [
          BottomNavigationBarItem(icon: Image.asset('assets/icons/home.png', height: 40, width: 35), label: 'Home'),
          BottomNavigationBarItem(icon: Image.asset('assets/icons/dumbell.png', height: 40, width: 40), label: 'Workouts'),
          BottomNavigationBarItem(icon: Image.asset('assets/icons/dish.png', height: 40, width: 40), label: 'Meals'),
          BottomNavigationBarItem(icon: Image.asset('assets/icons/water-bottle.png', height: 40, width: 40), label: 'Hydration'),
          BottomNavigationBarItem(icon: Image.asset('assets/icons/picture.png', height: 40, width: 40), label: 'Feed'),
        ],
      ),
      body: IndexedStack(
        children: pageContent,
        index: pageIndex
      ),
    );
  }
}