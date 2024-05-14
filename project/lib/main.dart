import 'package:flutter/material.dart';
import 'signup.dart';

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
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
