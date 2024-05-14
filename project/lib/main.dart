import 'package:flutter/material.dart';

import 'signup.dart'; // Import the SignUpScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/signup', // Set the initial route
      routes: {// Define the '/' route for SignInScreen
        '/signup': (context) => const SignUpPage(), // Define the '/signup' route for SignUpScreen
      },
    );
  }
}
