import 'dart:convert';
import 'package:http/http.dart' as http;  // Import the http package
import 'package:flutter/material.dart';


class SignUpPage extends StatefulWidget{
  const SignUpPage({super.key});
  
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
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/users.json'; // Replace with your Firebase Database URL

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
        // Data stored successfully
        print('User data stored successfully');
        // Clear text fields after successful sign-up
        _userNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        // Navigate to the next screen upon successful sign-up
        // Example:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        // Handle error
        print('Failed to store user data - ${response.statusCode}');
        throw Exception('Failed to store user data');
      }
    } catch (e) {
      print('Error storing user data: $e');
      throw Exception('Failed to store user data');
    }
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
          ],
        ),
      ),
    );
  }
}


