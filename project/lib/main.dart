import 'package:flutter/material.dart';
import 'package:project/signin.dart';
import 'product.dart';
import 'signup.dart';
// import 'signin.dart';

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
        '/products': (context) => ProductsPage(),
        '/signin': (context) => const SignInPage()
      },
    );
  }
}
