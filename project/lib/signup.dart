import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUser(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // User registration successful, now store additional user data in Firebase Realtime Database
      final String userId = userCredential.user!.uid;
      final String userName = _nameController.text.trim();
      final String userEmail = _emailController.text.trim();

      // Example: Storing user data in Firebase Realtime Database via HTTP request
      final String url = 'https://mobile-470d7-default-rtdb.europe-west1.firebasedatabase.app//users/$userId.json';
      final response = await http.post(
        Uri.parse(url),
        body: {
          'name': userName,
          'email': userEmail,
          'password': _passwordController.text, // Store password in database (not recommended, for demonstration only)
        },
      );

      if (response.statusCode == 200) {
        // Data stored successfully
        Navigator.pushReplacementNamed(context, '/signin'); // Navigate to sign-in screen
      } else {
        // Error occurred while storing data
        throw Exception('Failed to store user data');
      }
    } catch (e) {
      // Handle sign-up errors
      print('Sign up error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _registerUser(context),
              child: Text('Sign Up'),
            ),
            SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signin');
              },
              child: Text("Have an account? Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}
