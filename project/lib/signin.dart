import 'dart:convert';
import 'package:flutter/material.dart';
import 'Models/userModel.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'signUp.dart'; // Import the SignUpPage

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
              if (userData.containsKey('role')) {
                print('Role type: ${userData['role'].runtimeType}');
                if (userData['role'] is String) {
                  User user = User(
                    username: userData['username'],
                    email: userData['email'],
                    role: userData['role'], // Assuming the role is stored in the database
                  );
                  print('User logged in successfully');
                  _showSnackBar('User logged in successfully');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsPage(user: user), // Pass the user object with role
                    ),
                  );
                } else {
                  throw Exception('Role is not a string');
                }
              } else {
                throw Exception('Role field does not exist in user data');
              }
            } else {
              print('Incorrect password');
              _showSnackBar('Incorrect password');
            }
            userFound = true;
          }
        });

        if (!userFound) {
          print('User not found');
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

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
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
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: _navigateToSignUp,
              child: Text(
                "Don't have an account? Sign up",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
