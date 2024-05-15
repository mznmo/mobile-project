import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'signin.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    String userName = _userNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    final String databaseUrl =
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/users.json';

    try {
      final response = await http.post(
        Uri.parse(databaseUrl),
        body: json.encode({
          'userName': userName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        print('User data stored successfully');
        _userNameController.clear();
        _emailController.clear();
        _passwordController.clear();
      } else {
        print('Failed to store user data - ${response.statusCode}');
        throw Exception('Failed to store user data');
      }
    } catch (e) {
      print('Error storing user data: $e');
      throw Exception('Failed to store user data');
    }
  }

  void _navigateToSignInPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 20.0),
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
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: _navigateToSignInPage,
              child: Text('Already have an account? Log in'),
            ),
          ],
        ),
      ),
    );
  }
}
