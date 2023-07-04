import "package:flutter/material.dart";
import "package:flutter/services.dart";
//Pages to navigate to
import 'package:fitness_goal_android_app/pages/authentication_pages/loginPage.dart';
import 'package:fitness_goal_android_app/pages/authentication_pages/selectYourGoalPage.dart';
//For email OTP verification
import 'package:email_otp/email_otp.dart';
//To use Toast Notifications
import 'package:fluttertoast/fluttertoast.dart';
//To validate email
import 'package:email_validator/email_validator.dart';
//To use encrypt library
import 'package:encrypt/encrypt.dart' as encrypt;

class CreateAccountPage extends StatefulWidget{
  final EmailOTP emailAuth = EmailOTP();
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();

}

class _CreateAccountPageState extends State<CreateAccountPage>{
  String dropdownGenreValue = 'Male';
  String dropdownVegetarianValue = 'No';
  DateTime birthdayDate = DateTime.now();
  Color sentOTPColor = Colors.black12;
  Color verifiedOTPColor = Colors.black12;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

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
                            Text('Create Account', style: TextStyle(color: Colors.black, fontFamily: 'Alegreya', fontSize: 32)),
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
                        getName(),
                        SizedBox(height:30),
                        //getEmail and send Verification OTP
                        getEmail(),
                        SizedBox(height:30),
                        //getOTP and verificate OTP
                        getOTP(),
                        SizedBox(height:30),
                        getPassword(),
                        Divider(height: 100, thickness: 3, color: Color(0xFFDF5658)),
                        Container(
                          alignment: Alignment.center,
                          child: Text('Select your genre', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
                        ),
                        //select genre
                        DropdownButton<String>(
                          value: dropdownGenreValue,
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
                              dropdownGenreValue = newValue!;
                            });
                          },
                        ),
                        SizedBox(height:30),
                        getHeight(),
                        SizedBox(height:30),
                        getWeight(),
                        SizedBox(height:30),
                        Container(
                          alignment: Alignment.center,
                          child: Text('Select your birthdate', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
                        ),
                        //select birhtday
                        ElevatedButton.icon(
                          label: Text('${birthdayDate.day}/${birthdayDate.month}/${birthdayDate.year}', style: TextStyle(fontSize: 20)),
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async{
                            DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: birthdayDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));
                            //if the Cancel button is pressed
                            if (newDate==null) return;
                            //if the Ok button is pressed
                            setState(() => birthdayDate = newDate);
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
                        ),
                        SizedBox(height:30),
                        Container(
                          alignment: Alignment.center,
                          child: Text('Are you vegetarian?', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
                        ),
                        //select vegetarian
                        DropdownButton<String>(
                          value: dropdownVegetarianValue,
                          items: <String>['No', 'Yes']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri'),
                                )
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownVegetarianValue = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        nextBtn(),
                        SizedBox(height: 5),
                        logInBtn(),
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

  Widget getName(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Name', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
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
              controller: _nameController,
              keyboardType: TextInputType.name,
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                  hintText: 'Enter name',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.person, color: Color(0xFFDF5658))),
            )
        )
      ],
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

  Widget getPassword(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Create password', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
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

  Widget getHeight(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Height', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
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
              controller: _heightController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                  hintText: 'Enter height in cm',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.height, color: Color(0xFFDF5658))),
            )
        )
      ],
    );
  }

  Widget getWeight(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text('Weight', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'calibri')),
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
              controller: _weightController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black38),
              decoration: InputDecoration(
                  hintText: 'Enter weight in kg',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.monitor_weight, color: Color(0xFFDF5658))),
            )
        )
      ],
    );
  }

  Widget nextBtn(){
    return Container(
        padding: EdgeInsets.only(top:10),
        width: 100,
        child: ElevatedButton(
            onPressed: () {
              RegExp passRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{8,}$');
              RegExp nameRegex = RegExp(r'^(?=.*[a-zA-Z]).{2,}$');
              if (_nameController.text.isEmpty || _emailController.text.isEmpty || _otpController.text.isEmpty || _passwordController.text.isEmpty || _heightController.text.isEmpty || _weightController.text.isEmpty){
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
              else if(nameRegex.hasMatch(_nameController.text) == false){
                Fluttertoast.showToast(
                  msg: "Name should have minimum length of 2 characters and contain at least one letter",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else if(passRegex.hasMatch(_passwordController.text) == false){
                Fluttertoast.showToast(
                  msg: "Password should have minimum length of 8 characters and contain at least one digit and one letter",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 20.0,
                );
              }
              else{
                Navigator.push(context, MaterialPageRoute(builder: (context) => SelectYourGoalPage(
                  userName: _nameController.text,
                  userEmail: _emailController.text,
                  userPassword: encryptPassword(_passwordController),
                  userGenre: dropdownGenreValue,
                  userHeight: _heightController.text,
                  userWeight: _weightController.text,
                  userBirthdate: "${birthdayDate.year}-" + "${birthdayDate.month}-" + "${birthdayDate.day}",
                  userVegetarian: dropdownVegetarianValue,
                ))).then((value){
                  sentOTPColor = Colors.black12;
                  verifiedOTPColor = Colors.black12;
                });
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
              'Next',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontFamily: 'calibri'
              ),
            )
        )
    );
  }

  Widget logInBtn(){
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
        child: Text(
          'Already have an account',
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