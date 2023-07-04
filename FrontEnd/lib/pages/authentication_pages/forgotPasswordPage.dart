import "package:flutter/material.dart";
import "package:flutter/services.dart";
//Pages to navigate to
import 'package:fitness_goal_android_app/pages/authentication_pages/loginPage.dart';
//Global variables
import 'package:fitness_goal_android_app/utilities/globalVariables.dart' as globals;
//For email OTP verification
import 'package:email_otp/email_otp.dart';
//To use Toast Notifications
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
//To validate email
import 'package:email_validator/email_validator.dart';
//To use encrypt library
import 'package:encrypt/encrypt.dart' as encrypt;
//To work with database
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget{
  final EmailOTP emailAuth = EmailOTP();
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();

}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>{
  Color sentOTPColor = Colors.black12;
  Color verifiedOTPColor = Colors.black12;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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

  Future updatePassword() async {
    var url = Uri.parse("http://${globals.ipAddress}/fitnessgoaldb/forgotPassword.php");
    var response = await http.post(url, body:{
      "userEmail" : _emailController.text,
      "userNewPassword" : encryptPassword(_newPasswordController)
    });

    var data = json.decode(response.body);
    if(data == "Success"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
    else if(data == "You don't have an account yet"){
      Fluttertoast.showToast(
        msg: "You don't have an account yet with this email!",
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
                          Text('Forgot Password', style: TextStyle(color: Colors.black, fontFamily: 'Alegreya', fontSize: 32)),
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
                        //getEmail and send Verification OTP
                        getEmail(),
                        SizedBox(height:30),
                        //getOTP and verificate OTP
                        getOTP(),
                        SizedBox(height:30),
                        getNewPassword(),
                        SizedBox(height: 30),
                        getConfirmPassword(),
                        SizedBox(height: 30),
                        submitBtn(),
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

  Widget getEmail(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Email', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
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
            onChanged: (_emailController) {
              sentOTPColor = Colors.black12;
              verifiedOTPColor = Colors.black12;
            },
            decoration: InputDecoration(
                hintText: 'Enter email',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.email, color: Color(0xFFDF5658)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: sentOTPColor),
                  onPressed: () async{
                    final bool isEmailValid = EmailValidator.validate(_emailController.text);
                    if(!isEmailValid){
                      Fluttertoast.showToast(
                        msg: "Please enter a valid email",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        fontSize: 20.0,
                      );
                    }
                    else {
                      widget.emailAuth.setConfig(
                          appEmail: "fitnessgoal@gmail.com",
                          appName: "Fitness Goal",
                          userEmail: _emailController.text,
                          otpLength: 6,
                          otpType: OTPType.digitsOnly
                      );
                      if (await widget.emailAuth.sendOTP() == true)
                        setState(() => sentOTPColor = Colors.green);
                      else
                        setState(() => sentOTPColor = Colors.red);
                    }
                  },
                )
            ),
          ),
        )
      ],
    );
  }

  Widget getOTP(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Email verification code', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
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
              controller: _otpController,
              keyboardType: TextInputType.number,
              onChanged: (_otpController) {
                verifiedOTPColor = Colors.black12;
              },
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                hintText: 'Enter code received on email mentioned above',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.numbers, color: Color(0xFFDF5658)),
                suffixIcon: IconButton(
                    icon: Icon(Icons.verified, color: verifiedOTPColor),
                    onPressed: () async {
                      if (await widget.emailAuth.verifyOTP(otp: _otpController.text)){
                        setState(() => verifiedOTPColor = Colors.green);
                      }
                      else
                        setState(() => verifiedOTPColor = Colors.red);
                    }
                ),
              ),
            )
        )
      ],
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
              controller: _newPasswordController,
              obscureText: true,
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                  hintText: 'Enter new password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFFDF5658))),
            )
        )
      ],
    );
  }

  Widget getConfirmPassword(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Confirm Password', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
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
              controller: _confirmPasswordController,
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

  Widget submitBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 120,
        child: ElevatedButton(
            onPressed: () {
              RegExp passRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{8,}$');
              if (_emailController.text.isEmpty || _otpController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty ){
                Fluttertoast.showToast(
                  msg: "Complete all fields!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else if(sentOTPColor != Colors.green){
                Fluttertoast.showToast(
                  msg: "Please verificate your email!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else if(verifiedOTPColor == Colors.black12){
                Fluttertoast.showToast(
                  msg: "Please check entered OTP!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else if(verifiedOTPColor == Colors.red){
                Fluttertoast.showToast(
                  msg: "You have entered an invalid OTP!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else if(_newPasswordController.text != _confirmPasswordController.text){
                Fluttertoast.showToast(
                  msg: "New Password and Confirm Password should be the same!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else if(passRegex.hasMatch(_newPasswordController.text) == false){
                Fluttertoast.showToast(
                  msg: "Password should have minimum length of 8 characters and contain at least one digit and one letter",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else{
                updatePassword();
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