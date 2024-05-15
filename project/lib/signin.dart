import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
  String email = _emailController.text;
  String password = _passwordController.text;

  final String databaseUrl =
      'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/users.json';

  try {
    final response = await http.get(Uri.parse(databaseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;

      bool userFound = false;
      data.forEach((userId, userData) {
        if (userData['email'] == email) {
          if (userData['password'] == password) {
            print('User logged in successfully');
            _showSnackBar('User logged in successfully');
          } else {
            _showSnackBar('Incorrect password');
          }
          userFound = true;
        }
      });

      if (!userFound) {
        _showSnackBar('User not found');
      }
    } else {
      print('Failed to fetch user data - ${response.statusCode}');
      throw Exception('Failed to fetch user data');
    }
  } catch (e) {
    print('Error signing in: $e');
    throw Exception('Error signing in');
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
