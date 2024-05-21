import 'package:flutter/material.dart';
import 'package:project/signin.dart';
import 'product.dart';
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
      initialRoute: '/products',
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/products': (context) => ProductsPage(),
        '/signin': (context) => const SignInPage()
      },
    );
  }
}
