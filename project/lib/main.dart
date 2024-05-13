import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'signin.dart'; // Import your sign-in screen
import 'signup.dart'; // Import your sign-up screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter bindings are initialized

  // Initialize Firebase
  await Firebase.initializeApp(); // Initialize Firebase app

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}
