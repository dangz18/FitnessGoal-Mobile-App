import "package:flutter/material.dart";
import "package:flutter/services.dart";
//Pages to navigate to
import 'package:fitness_goal_android_app/pages/authentication_pages/loginPage.dart';
//Global variables
import 'package:fitness_goal_android_app/utilities/globalVariables.dart' as globals;
//To use Toast Notifications
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
//To work with database
import 'package:http/http.dart' as http;

class SelectYourGoalPage extends StatefulWidget{
  final String userName;
  final String userEmail;
  final String userPassword;
  final String userHeight;
  final String userWeight;
  final String userGenre;
  final String userBirthdate;
  final String userVegetarian;

  SelectYourGoalPage({
    required this.userName,
    required this.userEmail,
    required this.userPassword,
    required this.userGenre,
    required this.userHeight,
    required this.userWeight,
    required this.userBirthdate,
    required this.userVegetarian,
  });

  @override
  _SelectYourGoalPageState createState() => _SelectYourGoalPageState(
    userName: userName,
    userEmail: userEmail,
    userPassword: userPassword,
    userGenre: userGenre,
    userHeight: userHeight,
    userWeight: userWeight,
    userBirthdate: userBirthdate,
    userVegetarian: userVegetarian
  );

}

class LimitRangeTextInputFormatter extends TextInputFormatter {
  LimitRangeTextInputFormatter(this.min, this.max) : assert(min < max);

  final int min;
  final int max;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var value = int.parse(newValue.text);
    if (value < min) {
      return TextEditingValue(text: min.toString());
    } else if (value > max) {
      return TextEditingValue(text: max.toString());
    }
    return newValue;
  }
}

class _SelectYourGoalPageState extends State<SelectYourGoalPage>{
  bool _isGainMusclePressed = false;
  bool _isLoseWeightPressed = false;
  bool _isBeActivePressed = false;
  Color gainMuscleColorPressed = Colors.white;
  Color loseWeightColorPressed = Colors.white;
  Color beActiveColorPressed = Colors.white;

  String dropdownFitnessLevel = 'Beginner';

  final String userName;
  final String userEmail;
  final String userPassword;
  final String userHeight;
  final String userWeight;
  final String userGenre;
  final String userBirthdate;
  final String userVegetarian;
  _SelectYourGoalPageState({
    required this.userName,
    required this.userEmail,
    required this.userPassword,
    required this.userGenre,
    required this.userHeight,
    required this.userWeight,
    required this.userBirthdate,
    required this.userVegetarian,
  });

  Future registerAccount() async{
    String userGoal = '';
    if(_isGainMusclePressed)
      userGoal = 'Get Muscle';
    else if(_isLoseWeightPressed)
      userGoal = 'Lose Weight';
    else if(_isBeActivePressed)
      userGoal = 'Be Active';

    int fitnessLevel = 0;
    if(dropdownFitnessLevel=='Beginner')
      fitnessLevel = 1;
    else if(dropdownFitnessLevel=='Intermediate')
      fitnessLevel = 2;
    else if(dropdownFitnessLevel=='Advanced')
      fitnessLevel = 3;

    int isVegetarian = 0;
    if(userVegetarian=='No')
      isVegetarian = 0;
    else if(userVegetarian=='Yes')
      isVegetarian = 1;

    var url = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/register.php");
    var response = await http.post(url, body:{
      "userName" : userName,
      "userEmail" : userEmail,
      "userPassword" : userPassword,
      "userGenre" : userGenre,
      "userHeight" : userHeight,
      "userWeight" : userWeight,
      "userBirthdate" : userBirthdate,
      "userVegetarian" : '${isVegetarian}',
      "userGoal" : userGoal,
      "userFitnessLevel" : '${fitnessLevel}',
    });
    var data = json.decode(response.body);
    if(data != "You already have an account" && data != "Failure"){
      Fluttertoast.showToast(
        msg: "Registered with success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
      //Update user weight history
      DateTime now = new DateTime.now();
      String todayDate = '${now.year}-${now.month}-${now.day}';
      var url2 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/updateWeightHistory.php");
      var response2 = await http.post(url2, body:{
        "userId" : '${data}',
        "userNewWeight" : userWeight,
        "todayDate" : todayDate
      });
      var data2 = json.decode(response2.body);
      if(data2 == "Success"){
        //Update user height history
        var url3 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/updateHeightHistory.php");
        var response3 = await http.post(url3, body:{
          "userId" : '${data}',
          "userNewHeight" : userHeight,
          "todayDate" : todayDate
        });
        var data3 = json.decode(response3.body);
        if(data3 == "Success"){
          Fluttertoast.showToast(
            msg: "Updated with success!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 20.0,
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
        else if(data3 == "Failed"){
          Fluttertoast.showToast(
            msg: "Update failed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 20.0,
          );
          Navigator.pop(context);
        }
      }
      else if(data2 == "Failed"){
        Fluttertoast.showToast(
          msg: "Update failed!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 20.0,
        );
        Navigator.pop(context);
      }
    }
    else if(data == "You already have an account"){
      Fluttertoast.showToast(
        msg: "You already have an account",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
    }
    else if(data == "Failure"){
      Fluttertoast.showToast(
        msg: "Database error when creating account",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value:SystemUiOverlayStyle.light,
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
                          BackButton(),
                          Text('Select Your GOAL', style: TextStyle(color: Colors.black, fontFamily: 'Alegreya', fontSize: 32)),
                          SizedBox(width: 30),
                        ],
                      ),
                    ],
                  ),
                ),
                Container( //white cont
                  height: (MediaQuery.of(context).size.height)-50,
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft:Radius.circular(20.0), topRight: Radius.circular(20.0)),
                  ),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(), //to be able to scroll
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Select your main GOAL:', style: TextStyle(color: Colors.black, fontSize: 28, fontFamily: 'calibri')),
                        //Get Muscle Button
                        ElevatedButton.icon(
                          label: Text('Get Muscle', style: TextStyle(color: Colors.black, fontSize: 28, fontFamily: 'calibri')),
                          icon: Icon(Icons.fitness_center, color: Colors.black),
                          onPressed: () {
                            //if is pressed change to !pressed and viceversa
                            setState(() {
                              if (_isGainMusclePressed==false){
                                _isGainMusclePressed = true;
                                _isLoseWeightPressed = false;
                                _isBeActivePressed = false;
                              }
                              else
                                _isGainMusclePressed = false;

                              if (_isGainMusclePressed==true)
                                gainMuscleColorPressed=Color(0xFFDF5658);
                              else
                                gainMuscleColorPressed=Colors.white;

                              if (_isLoseWeightPressed==true)
                                loseWeightColorPressed=Color(0xFFDF5658);
                              else
                                loseWeightColorPressed=Colors.white;

                              if (_isBeActivePressed==true)
                                beActiveColorPressed=Color(0xFFDF5658);
                              else
                                beActiveColorPressed=Colors.white;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            side: BorderSide(color: Colors.black12, width: 2),
                            backgroundColor: gainMuscleColorPressed,
                            shadowColor: Colors.pinkAccent,
                            elevation: 20,
                          ),
                        ),
                        SizedBox(height: 30),
                        //Lose Weight Button
                        ElevatedButton.icon(
                          label: Text('Lose Weight', style: TextStyle(color: Colors.black, fontSize: 28, fontFamily: 'calibri')),
                          icon: Icon(Icons.scale, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              //if is pressed change to !pressed and viceversa
                              if (_isLoseWeightPressed==false){
                                  _isLoseWeightPressed = true;
                                  _isBeActivePressed = false;
                                  _isGainMusclePressed = false;
                              }
                              else
                                _isLoseWeightPressed = false;

                              if (_isGainMusclePressed==true)
                                gainMuscleColorPressed=Color(0xFFDF5658);
                              else
                                gainMuscleColorPressed=Colors.white;

                              if (_isLoseWeightPressed==true)
                                loseWeightColorPressed=Color(0xFFDF5658);
                              else
                                loseWeightColorPressed=Colors.white;

                              if (_isBeActivePressed==true)
                                beActiveColorPressed=Color(0xFFDF5658);
                              else
                                beActiveColorPressed=Colors.white;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            side: BorderSide(color: Colors.black12, width: 2),
                            backgroundColor: loseWeightColorPressed,
                            shadowColor: Colors.pinkAccent,
                            elevation: 20,
                          ),
                        ),
                        SizedBox(height: 30),
                        //Be Active Button
                        ElevatedButton.icon(
                          label: Text('Be Active', style: TextStyle(color: Colors.black, fontSize: 28, fontFamily: 'calibri')),
                          icon: Icon(Icons.run_circle, color: Colors.black),
                          onPressed: () {
                            //if is pressed change to !pressed and viceversa
                            setState(() {
                              if (_isBeActivePressed==false){
                                _isBeActivePressed = true;
                                _isGainMusclePressed = false;
                                _isLoseWeightPressed = false;
                              }
                              else
                                _isBeActivePressed = false;

                              if (_isGainMusclePressed==true)
                                gainMuscleColorPressed=Color(0xFFDF5658);
                              else
                                gainMuscleColorPressed=Colors.white;

                              if (_isLoseWeightPressed==true)
                                loseWeightColorPressed=Color(0xFFDF5658);
                              else
                                loseWeightColorPressed=Colors.white;

                              if (_isBeActivePressed==true)
                                beActiveColorPressed=Color(0xFFDF5658);
                              else
                                beActiveColorPressed=Colors.white;
                            });

                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            side: BorderSide(color: Colors.black12, width: 2),
                            backgroundColor: beActiveColorPressed,
                            shadowColor: Colors.pinkAccent,
                            elevation: 20,
                          ),
                        ),
                        SizedBox(height: 30),
                        Text('Select your fitness level based on your skills', style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'calibri')),
                        //Select FitnessLevel
                        DropdownButton<String>(
                          value: dropdownFitnessLevel,
                          items: <String>['Beginner', 'Intermediate', 'Advanced']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri'),
                                )
                            );
                          }).toList(),
                          // Step 5.
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownFitnessLevel = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: 30),
                        submitBtn(),
                        Image.asset('assets/images/fitness-goal-logo.png', height: 150, width: 150),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget submitBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 110,
        child: ElevatedButton(
            onPressed: () {
              if(!_isGainMusclePressed && !_isLoseWeightPressed && !_isBeActivePressed){
                Fluttertoast.showToast(
                  msg: "Select one goal",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else{
                registerAccount();
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
              'Submit',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontFamily: 'calibri'
              ),
            )
        )
    );
  }
}