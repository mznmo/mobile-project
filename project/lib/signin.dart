import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'dart:convert';
import 'signup.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.shopper;

  void _navigateToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsPage(userRole: _selectedRole),
                ),
              );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Are you a: '),
                DropdownButton<UserRole>(
                  value: _selectedRole,
                  onChanged: (UserRole? value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  items: <UserRole>[
                    UserRole.shopper,
                    UserRole.vendor,
                  ].map<DropdownMenuItem<UserRole>>((UserRole value) {
                    return DropdownMenuItem<UserRole>(
                      value: value,
                      child: Text(value == UserRole.shopper ? 'Shopper' : 'Vendor'),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: _navigateToSignUpPage,
              child: Text('Do not have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
