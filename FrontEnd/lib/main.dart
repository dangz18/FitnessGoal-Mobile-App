// @dart=2.9
import 'package:flutter/material.dart';
import 'pages/authentication_pages/loginPage.dart';
import 'pages/mainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs =await SharedPreferences.getInstance();
  var userId = prefs.getString("userId");
  var userFitnessLevel = prefs.getString("userFitnessLevel");
  runApp(MaterialApp(
    title: 'Fitness Goal',
    debugShowCheckedModeBanner: false,
    home: userId == null ? LoginPage() : MainPage(userId: int.parse(userId), userFitnessLevel: int.parse(userFitnessLevel)),
  ));
}
