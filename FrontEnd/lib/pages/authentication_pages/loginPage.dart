import "package:flutter/material.dart";
import "package:flutter/services.dart";
//Pages to navigate to
import 'package:fitness_goal_android_app/pages/authentication_pages/createAccountPage.dart';
import 'package:fitness_goal_android_app/pages/authentication_pages/forgotPasswordPage.dart';
import 'package:fitness_goal_android_app/pages/mainPage.dart';
//Global variables
import 'package:fitness_goal_android_app/utilities/globalVariables.dart' as globals;
//To use encrypt library
import 'package:encrypt/encrypt.dart' as encrypt;
//To work with database
import 'package:http/http.dart' as http;
//To use Toast Notifications
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
//To validate email
import 'package:email_validator/email_validator.dart';
//To keep user logged/unlogged
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget{
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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

  //Conecting to database
  Future loginIntoAccount() async{
    var url = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/login.php");
    var response = await http.post(url, body:{
      "email" : _emailController.text,
      "password" : encryptPassword(_passwordController)
    });

    var data = json.decode(response.body);

    if(data == "[Error] Inexistent user"){
      Fluttertoast.showToast(
        msg: "You don't have an account yet",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
    }
    else if(data == "[Error] Email or password incorrect"){
      Fluttertoast.showToast(
        msg: "Email or password incorrect",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20.0,
      );
    }
    else if(data=="[Error] More than one return"){
      Fluttertoast.showToast(
          msg: "Database Error!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 20.0,
      );
    }
    else{
      SharedPreferences pref =await SharedPreferences.getInstance();
      pref.setString("userId", data[0]['user_id']);
      pref.setString("userFitnessLevel", data[0]['user_fitness_level']);

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(userId: int.parse(data[0]['user_id']), userFitnessLevel: int.parse(data[0]['user_fitness_level']))));
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
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Log In',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontFamily: 'Alegreya'
                          ),
                        )
                    )
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
                        Text('Hello! Please enter your information above to log in your account', style: TextStyle(color: Colors.black, fontSize: 24, fontFamily: 'calibri')),
                        SizedBox(height:20),
                        getEmail(),
                        SizedBox(height:30),
                        getPassword(),
                        forgotPassBtn(),
                        logInBtn(),
                        registerBtn(),
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

  Widget getEmail(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Email', style: TextStyle(color: Colors.black, fontSize: 24, fontFamily: 'calibri')),
        ),
        SizedBox(height: 10),
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                  hintText: 'Enter email',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.email, color: Color(0xFFDF5658))),
            )
        )
      ],
    );
  }

  Widget getPassword(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Password', style: TextStyle(color: Colors.black, fontSize: 24, fontFamily: 'calibri')),
        ),
        SizedBox(height: 10),
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
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                  hintText: 'Enter password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFFDF5658))),
            )
        )
      ],
    );
  }

  Widget forgotPassBtn(){
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 15),
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage())).then((value){
            _emailController.clear();
            _passwordController.clear();
          });
        },
        child: Text(
          'Forgot Password',
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.black,
            fontFamily: 'calibri',
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget logInBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 100,
        child: ElevatedButton(
            onPressed: () async {
              final bool isEmailValid = EmailValidator.validate(_emailController.text);
              if (_emailController.text.isEmpty || _passwordController.text.isEmpty){
                Fluttertoast.showToast(
                  msg: "Complete the Email and Password Fields!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else if(!isEmailValid){
                Fluttertoast.showToast(
                  msg: "Please enter a valid email",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else{
                loginIntoAccount();
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
              'Log In',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontFamily: 'calibri'
              ),
            )
        )
    );
  }

  Widget registerBtn(){
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage())).then((value){
            _emailController.clear();
            _passwordController.clear();
          });
        },
        child: Text(
          'Register',
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.black,
            fontFamily: 'calibri',
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}