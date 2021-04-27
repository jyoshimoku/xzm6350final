import 'package:flutter/material.dart';

// import different Screens
import 'package:xzm6350final/login_screen.dart';
import 'package:xzm6350final/registration_screen.dart';
import 'package:xzm6350final/BrowsePostsActivity.dart';
import 'package:xzm6350final/NewPostActivity.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.blueAccent,
        ),

        ///add required screen path
        initialRoute: LoginScreen.id,
        routes: {
          LoginScreen.id: (context) => LoginScreen(),
          BrowsePostsActivity.id: (context) => BrowsePostsActivity(),
          NewPostActivity.id: (context) => NewPostActivity(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
        });
  }
}