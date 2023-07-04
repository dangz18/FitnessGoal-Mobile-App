import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:flutter/cupertino.dart';
//Pages to go to
import 'package:fitness_goal_android_app/pages/app_pages/profilePage.dart';
import 'package:fitness_goal_android_app/pages/app_pages/addExercisePage.dart';
//To work with database
import 'package:http/http.dart' as http;
import 'dart:convert';
//Exercise Class
import 'package:fitness_goal_android_app/models/workoutExercise.dart';
//Global variables
import 'package:fitness_goal_android_app/utilities/globalVariables.dart' as globals;
//To use Toast Notifications
import 'package:fluttertoast/fluttertoast.dart';
//To convert DateTime
import 'package:intl/intl.dart';

class WorkoutsPage extends StatefulWidget {
  final int userId;
  final int userFitnessLevel;
  WorkoutsPage({
    required this.userId,
    required this.userFitnessLevel
  });

  @override
  _WorkoutsPageState createState() => _WorkoutsPageState(
      userId: userId, userFitnessLevel : userFitnessLevel
  );

}


class _WorkoutsPageState extends State<WorkoutsPage> {
  final int userId;
  final int userFitnessLevel;
  _WorkoutsPageState({required this.userId, required this.userFitnessLevel}){
    workout = [];
    _futureWorkout = getWorkout();
  }

  late List<WorkoutExercise> workout;
  late Future _futureWorkout;

  DateTime now = new DateTime.now();
  String todayDate = '';
  int workoutDayId = 0;
  String day = '';
  List<String> restDays = [];

  Future getWorkout() async{
    if(now.month < 10 && !(now.day<10)){
      todayDate = '${now.year}-0${now.month}-${now.day}';
    }
    else if(!(now.month<10) && now.day<10){
      todayDate = '${now.year}-0${now.month}-0${now.day}';
    }
    else if(now.month < 10 && now.day<10){
      todayDate = '${now.year}-0${now.month}-0${now.day}';
    }
    else{
      todayDate = '${now.year}-${now.month}-${now.day}';
    }
    day = DateFormat('EEEE').format(now);
    restDays.clear();
    if(userFitnessLevel==1){
      restDays.add('Thursday');
      restDays.add('Sunday');
    }
    else{
      restDays.add('Thursday');
    }
    workout.clear();
    if(restDays.contains(day)){

    }
    else{
      var url1 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getWorkoutPlan.php");
      var response1 = await http.post(url1, body:{
        "userId" : "${userId}",
        "todayDate" : todayDate,
      }).timeout(Duration(seconds: 30));
      var data = await json.decode(response1.body);
      if(data == 'Nothing found'){
        print("Nothing found");
      }
      else{
        for(int i=0; i<data.length; i++){
          bool isDone;
          if(data[i][4] == '0'){
            isDone = false;
          }
          else{
            isDone = true;
          }
          workout.add(WorkoutExercise(data[i][0], data[i][1], base64Decode(data[i][2]), int.parse(data[i][3]), isDone, int.parse(data[i][5])));
        }
        workoutDayId = int.parse(data[0][6]);
      }
    }


    return true;
  }

  Future updateExerciseStatus(int index) async{
    var url1 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/updateExerciseStatus.php");
    var response1 = await http.post(url1, body:{
      "workoutExerciseId" : '${workout[index].workoutExerciseId}',
    }).timeout(Duration(seconds: 30));
    var data = await json.decode(response1.body);
    if(data == 'Failed'){
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
      return false;
    }
    else if(data == 'Success'){
      return true;
    }
  }

  Future deleteExercise(int index) async{
    var url1 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/deleteExercise.php");
    var response1 = await http.post(url1, body:{
      "workoutExerciseId" : '${workout[index].workoutExerciseId}',
    }).timeout(Duration(seconds: 30));
    var data = await json.decode(response1.body);
    if(data == 'Failed'){
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
      return false;
    }
    else if(data == 'Success'){
      return true;
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('My Workout Plan', style: TextStyle(fontSize: 35, fontFamily: 'Alegreya', color: Colors.black)),
                      Text('Today: ${todayDate}', style: TextStyle(fontFamily: 'calibri', fontSize: 30)),
                      restDays.contains(day) ? Container(
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
                        child: Column(children: [
                          Text('Rest Day', style: TextStyle(fontFamily: 'calibri', fontSize: 50)),
                          Center(child: Text('Take your rest.\n When you rest, your muscles start to heal and grow back stronger!', style: TextStyle(fontFamily: 'calibri', fontSize: 30), textAlign: TextAlign.center)),
                          Image.asset('assets/icons/rest.png', height: 100, width: 100)
                        ],),
                      ) : FutureBuilder<dynamic>(
                        future: _futureWorkout,
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
                                  height: (MediaQuery.of(context).size.height) * 0.666,
                                  width: double.maxFinite,
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: workout.length,
                                      itemBuilder: (context, index){
                                        if (index == workout.length - 1) {
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(3),
                                                child: exerciseBtn(index),
                                              ),
                                              SizedBox(height: 20),
                                              addExerciseBtn(),
                                              SizedBox(height: 20),
                                            ],
                                          );
                                        }
                                        else{
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(3),
                                                child: exerciseBtn(index),
                                                //child: Text('${index}'),
                                              ),
                                              SizedBox(height: 20),
                                            ],
                                          );
                                        }
                                      }),
                                ),

                              ],
                            );
                          }
                          else{
                            return const Text('No workout found', style: TextStyle(fontFamily: 'calibri', fontSize: 35, fontWeight: FontWeight.bold),);
                          }
                        },
                      ),
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

  Widget exerciseBtn(int index){
    return SizedBox(
      height: 70,
      width: 300,
      child: ElevatedButton(
        child: Text('${workout[index].exerciseName} x${workout[index].exerciseRepetitions}', style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: 'calibri')),
        onPressed: ()  {
          if(workout[index].exerciseIsDone == true){

          }
          else{
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
                          content:
                          SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                exerciseContainer(index),
                              ],
                            ),
                          ),
                        );
                      }
                  );
                }
            );
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          side: BorderSide(color: Colors.black12, width: 2),
          backgroundColor: workout[index].exerciseIsDone ? Color(0xFFF59292) : Colors.white,
          shadowColor: Colors.pinkAccent,
          elevation: 10,
        ),
      ),
    );
  }

  Widget exerciseContainer(int index){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${workout[index].exerciseName}', style: TextStyle(fontSize: 25, fontFamily: 'calibri')),
        Container(
          height: 300,
          width: 300,
          //padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          child: Image.memory(workout[index].exerciseImage),
        ),
        Text('Muscle category: ${workout[index].exerciseMuscleCategory}', style: TextStyle(fontSize: 20, fontFamily: 'calibri')),
        Text('Number of reps: ${workout[index].exerciseRepetitions}', style: TextStyle(fontSize: 20, fontFamily: 'calibri')),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            deleteBtn(index),
            SizedBox(width: 5),
            doneBtn(index),
            SizedBox(width: 5),
            closeBtn(),
          ],
        )
      ],
    );
  }

  Widget doneBtn(int index){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 100,
        child: ElevatedButton(
            onPressed: () async{
              await updateExerciseStatus(index);
              setState((){
                _futureWorkout = getWorkout();
              });
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
              'Done',
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 25,
                  fontFamily: 'calibri'
              ),
            )
        )
    );
  }

  Widget deleteBtn(int index){
    return Padding(
      padding: EdgeInsets.only(top:10),
      child: ElevatedButton(
          onPressed: () async{
            await deleteExercise(index);
            setState((){
              _futureWorkout = getWorkout();
            });
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Delete',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontFamily: 'calibri'
                ),
              ),
              Icon(Icons.delete, color: Colors.black87),
            ],
          )
      ),
    );
  }

  Widget closeBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 100,
        child: ElevatedButton(
            onPressed: () {
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

  Widget addExerciseBtn(){
    return Container(
      height: 60,
      width: 200,
      child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddExercisePage(workoutDayId: workoutDayId))).then((_){
              setState(() {
                _futureWorkout = getWorkout();
              });
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFDF5658),
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
                'Add Exercise',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'calibri'
                ),
              ),
              Icon(Icons.add, color: Colors.white,),
            ],
          )
      ),
    );
  }
}
