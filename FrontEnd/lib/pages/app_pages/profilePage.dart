import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:flutter/cupertino.dart';
//Pages to navigate to
import 'package:fitness_goal_android_app/pages/mainPage.dart';
//Global variables
import 'package:fitness_goal_android_app/utilities/globalVariables.dart' as globals;
//To work with database
import 'package:http/http.dart' as http;
import 'dart:convert';
//To use encrypt library
import 'package:encrypt/encrypt.dart' as encrypt;
//To use Toast Notifications
import 'package:fluttertoast/fluttertoast.dart';
//Pages to navigate to
import 'package:fitness_goal_android_app/pages/authentication_pages/loginPage.dart';
//To keep user logged/unlogged
import 'package:shared_preferences/shared_preferences.dart';
//To use graph
import 'package:fitness_goal_android_app/models/graphPoint.dart';
import 'package:fitness_goal_android_app/utilities/lineChart.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  ProfilePage({
    required this.userId,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState(
      userId: userId
  );

}


class _ProfilePageState extends State<ProfilePage> {
  final int userId;
  _ProfilePageState({required this.userId}){
    weightProgress = [];
    heightProgress = [];
    _futureBuild = getUserInfo();
  }

  //For the password encryption
  encryptPassword(TextEditingController pass) {
    final password = pass.text;

    //Generating the key
    String key = '';
    if (pass.text.isNotEmpty){
      key = pass.text;
      if(pass.text.length<32){
        int dif = 32 - pass.text.length;
        key = pass.text;
        for(int i=0; i<dif; i++){
          key += key[i];
        }
      }
    }
    final encryptedKey = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(encryptedKey));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  late String currentUserName;
  late String currentUserPassword;
  late String currentUserGenre;
  late String currentUserHeight;
  late String currentUserWeight;
  late int userFitnessLevel;
  late List<GraphPoint> weightProgress;
  late List<GraphPoint> heightProgress;

  List userInfo = [];
  //Get User Info, Weight History, Height History
  Future getUserInfo() async {
    weightProgress.clear();
    heightProgress.clear();
    var url = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getUserInfo.php");
    var response = await http.post(
        url,
        body: {"userId": "${userId}"}
    );
    if(response.statusCode == 200){

      userInfo = json.decode(response.body);
      currentUserName = userInfo[0]['user_name'];
      currentUserPassword = userInfo[0]['user_password'];
      currentUserGenre = userInfo[0]['user_genre'];
      currentUserHeight = userInfo[0]['user_height'];
      currentUserWeight = userInfo[0]['user_weight'];
      userFitnessLevel = int.parse(userInfo[0]['user_fitness_level']);

      _newUserGenreController = currentUserGenre;

      //Get info for the weight graph
      var url2 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getWeightHistory.php");
      var response2 = await http.post(
          url2,
          body: {"userId": "${userId}"}
      );
      List data2 = json.decode(response2.body);
      if(data2 == 'Nothing found'){
        print("Nothing found");
      }
      else{
        for(int i=0; i<data2[0].length; i++){
          weightProgress.add(GraphPoint(DateTime.parse(data2[1][i]), double.parse(data2[0][i])));
        }
      }

      //Get info for the height graph
      var url3 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/getHeightHistory.php");
      var response3 = await http.post(
          url3,
          body: {"userId": "${userId}"}
      );
      List data3 = json.decode(response3.body);
      if(data3 == 'Nothing found'){
        print("Nothing found");
      }
      else{
        for(int i=0; i<data3[0].length; i++){
          heightProgress.add(GraphPoint(DateTime.parse(data3[1][i]), double.parse(data3[0][i])));
        }
      }

      return true;
    }

    return false;
  }

  //Update User Info, Weight History, Height History
  Future updateUserInfo() async {
    var url = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/updateUserInfo.php");
    var response = await http.post(url, body:{
      "userId" : '${userId}',
      "userName" : _newUserNameController.text,
      "userPassword" : _newUserPasswordController.text,
      "userGenre" : _newUserGenreController,
      "userHeight" : _newUserHeightController.text,
      "userWeight" : _newUserWeightController.text
    });

    var data = json.decode(response.body);

    if(data == "Success"){
      //Update user weight history
      DateTime now = new DateTime.now();
      String todayDate = '${now.year}-${now.month}-${now.day}';
      var url2 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/updateWeightHistory.php");
      var response2 = await http.post(url2, body:{
        "userId" : '${userId}',
        "userNewWeight" : _newUserWeightController.text,
        "todayDate" : todayDate
      });
      var data2 = json.decode(response2.body);
      if(data2 == "Success"){
        //Update user height history
        var url3 = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/updateHeightHistory.php");
        var response3 = await http.post(url3, body:{
          "userId" : '${userId}',
          "userNewHeight" : _newUserHeightController.text,
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(userId: userId, userFitnessLevel: userFitnessLevel)));
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
    else if(data == "Failed"){
      Fluttertoast.showToast(
        msg: "Update failed!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
      Navigator.pop(context);
    }
  }

  late Future _futureBuild;

  TextEditingController _newUserNameController = TextEditingController();
  String _newUserGenreController = 'M';
  TextEditingController _newUserHeightController = TextEditingController();
  TextEditingController _newUserWeightController = TextEditingController();
  TextEditingController _newUserPasswordController = TextEditingController();
  TextEditingController _confirmNewUserPasswordController = TextEditingController();

  @override
  void initState(){
    super.initState();
    //_futureBuild = getUserInfo();
    _newUserNameController.clear();
    _newUserHeightController.clear();
    _newUserWeightController.clear();
    _newUserPasswordController.clear();
    _confirmNewUserPasswordController.clear();
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
                          Text('My Profile', style: TextStyle(color: Colors.black, fontFamily: 'Alegreya', fontSize: 32)),
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
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FutureBuilder<dynamic>(
                          future: _futureBuild,
                          builder: (context, AsyncSnapshot<dynamic> snapshot){
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return const Center(child: CircularProgressIndicator(color: Colors.black26));
                            }
                            else if(snapshot.hasData){
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  getNewName(),
                                  getNewGenre(),
                                  getNewHeight(),
                                  SizedBox(height: 10),
                                  getNewWeight(),
                                  SizedBox(height: 20),
                                  getNewPassword(),
                                  SizedBox(height: 20),
                                  getConfirmNewPassword(),
                                  SizedBox(height: 10),
                                  saveBtn(),
                                  SizedBox(height: 20),
                                  getWeightGraph(),
                                  SizedBox(height: 20),
                                  getHeightGraph()
                                ],
                              );
                            }
                            else{
                              return const Text('Nothing found');
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        logOutBtn(),
                        SizedBox(height: 5),
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

  Widget getNewName(){
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      decoration: BoxDecoration(
        color: Color(0xFFDF5658),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0),
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0)
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 80.0, width: 80.0, child: new Icon(CupertinoIcons.profile_circled, size: 80.0)),
          SizedBox(width: 5),
          Container(
            alignment: Alignment.center,
            height: (MediaQuery.of(context).size.height) / 15,
            width: (MediaQuery.of(context).size.width)-140,
            decoration: BoxDecoration(
                color: Colors.transparent,
            ),
            child: TextFormField(
              controller: _newUserNameController,
              keyboardType: TextInputType.text,
              style: TextStyle(color: Colors.black, fontSize: (MediaQuery.of(context).size.height) / 15),
              decoration: InputDecoration(
                hintText: '${currentUserName}',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getNewGenre(){
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 10),
          Text('Genre', style: TextStyle(fontSize: 40, fontFamily: 'calibri')),
          SizedBox(width: 30),
          DropdownButton<String>(
            value: _newUserGenreController,
            items: <String>['Male', 'Female', 'Other']
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
                _newUserGenreController = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget getNewHeight(){
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 10),
          Text('Height', style: TextStyle(fontSize: 40, fontFamily: 'calibri')),
          SizedBox(width: 20),
          Container(
              alignment: Alignment.center,
              height: (MediaQuery.of(context).size.height) / 15,
              width: 100,
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
                textAlign: TextAlign.center,
                controller: _newUserHeightController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black, fontSize: 35),
                decoration: InputDecoration(
                    hintText: '${currentUserHeight}',
                    border: InputBorder.none,
                  contentPadding: EdgeInsets.all(0),
                ),
              )
          ),
          SizedBox(width: 20),
          Text('cm', style: TextStyle(fontSize: 40, fontFamily: 'calibri')),
        ],
      ),
    );
  }

  Widget getNewWeight(){
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 10),
          Text('Weight', style: TextStyle(fontSize: 40, fontFamily: 'calibri')),
          SizedBox(width: 20),
          Container(
              alignment: Alignment.center,
              height: (MediaQuery.of(context).size.height) / 15,
              width: 100,
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
                textAlign: TextAlign.center,
                controller: _newUserWeightController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black, fontSize: 35),
                decoration: InputDecoration(
                  hintText: '${currentUserWeight}',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(0),
                ),
              )
          ),
          SizedBox(width: 20),
          Text('kg', style: TextStyle(fontSize: 40, fontFamily: 'calibri')),
        ],
      ),
    );
  }

  Widget getNewPassword(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('New Password', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
        ),
        SizedBox(height: 5),
        Container(
            alignment: Alignment.centerLeft,
            height: 60,
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
              controller: _newUserPasswordController,
              obscureText: true,
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                  hintText: 'Enter a new password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFFDF5658))),
            )
        )
      ],
    );
  }

  Widget getConfirmNewPassword(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Confirm New Password', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
        ),
        SizedBox(height: 5),
        Container(
            alignment: Alignment.centerLeft,
            height: 60,
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
              controller: _confirmNewUserPasswordController,
              obscureText: true,
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFFDF5658))),
            )
        )
      ],
    );
  }

  Widget getWeightGraph(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Weight Progress', style: TextStyle(fontSize: 40, fontFamily: 'calibri')),
        SizedBox(height: 5),
        LineChartGraph(weightProgress, "kg"),
      ],
    );
  }

  Widget getHeightGraph(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Height Progress', style: TextStyle(fontSize: 40, fontFamily: 'calibri')),
        SizedBox(height: 5),
        LineChartGraph(heightProgress, "cm"),
      ],
    );
  }

  Widget saveBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 120,
        child: ElevatedButton(
            onPressed: () {
              bool newName = false;
              bool newGenre = false;
              bool newHeight = false;
              bool newWeight = false;
              bool newPassword = false;
              RegExp passRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{8,}$');
              RegExp nameRegex = RegExp(r'^(?=.*[a-zA-Z]).{2,}$');

              //If the user changed nothing
              if (_newUserNameController.text.isEmpty && (currentUserGenre==_newUserGenreController) && _newUserHeightController.text.isEmpty && _newUserWeightController.text.isEmpty && _newUserPasswordController.text.isEmpty && _confirmNewUserPasswordController.text.isEmpty){
                Navigator.pop(context);
              }
              //If the user changed name
              if(!_newUserNameController.text.isEmpty){
                if(nameRegex.hasMatch(_newUserNameController.text) == false){
                  Fluttertoast.showToast(
                    msg: "Name did not change, it should have minimum length of 2 characters and contain at least one letter",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    fontSize: 20.0,
                  );
                  newName = false;
                }
                else{
                  newName = true;
                }

              }
              //If the user changed genre
              if(currentUserGenre!=_newUserGenreController){
                newGenre = true;
              }
              //If the user changed height
              if(!_newUserHeightController.text.isEmpty){
                newHeight = true;
              }
              //If the user changed weight
              if(!_newUserWeightController.text.isEmpty){
                newWeight = true;
              }
              //If the user changed password
              if(!_newUserPasswordController.text.isEmpty || !_confirmNewUserPasswordController.text.isEmpty){
                if(_newUserPasswordController.text == _confirmNewUserPasswordController.text){
                  if(passRegex.hasMatch(_newUserPasswordController.text) == false){
                    Fluttertoast.showToast(
                      msg: "Password should have minimum length of 8 characters and contain at least one digit and one letter",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      fontSize: 20.0,
                    );
                    newName = false;
                    newGenre = false;
                    newHeight = false;
                    newWeight = false;
                    newPassword = false;
                  }
                  else{
                    newPassword = true;
                  }
                }
                else{
                  Fluttertoast.showToast(
                    msg: "New Password and Confirm Password should be the same!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    fontSize: 20.0,
                  );
                  newName = false;
                  newGenre = false;
                  newHeight = false;
                  newWeight = false;
                  newPassword = false;
                }
              }

              //If the user changed at least one information about himself
              if(newName || newGenre || newHeight || newWeight || newPassword){
                //If the user put the same information
                if((currentUserName==_newUserNameController.text) && (currentUserGenre==_newUserGenreController) && (currentUserHeight==_newUserHeightController.text) && (currentUserWeight==_newUserWeightController.text) && (currentUserPassword==encryptPassword(_newUserPasswordController))){
                  Navigator.pop(context);
                }
                //Find what info he didn't changed
                if(newName == false)
                  _newUserNameController.text = currentUserName;
                if(newHeight == false)
                  _newUserHeightController.text = currentUserHeight;
                if(newWeight == false)
                  _newUserWeightController.text = currentUserWeight;
                if(newPassword == false)
                  _newUserPasswordController.text = currentUserPassword;
                else
                  _newUserPasswordController.text = encryptPassword(_newUserPasswordController);

                //Update database
                updateUserInfo();
              }
              else{
                Fluttertoast.showToast(
                  msg: "Nothing changed!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
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
              'Save',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontFamily: 'calibri'
              ),
            )
        )
    );
  }

  Widget logOutBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 120,
        child: ElevatedButton(
            onPressed: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.remove("userId");
              pref.remove("userFitnessLevel");

              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
              'Log Out',
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
