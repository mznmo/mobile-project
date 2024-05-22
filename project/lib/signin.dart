// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'dart:convert';
// import 'product.dart';
// import 

// class SignInPage extends StatefulWidget {
//   const SignInPage({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _SignInPageState();
// }

// class _SignInPageState extends State<SignInPage> {
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   UserRole _selectedRole = UserRole.shopper;
//   Future<String?>? _tokenFuture;

//   @override
//   void initState() {
//     super.initState();
//     setupFirebaseMessaging();
//     _tokenFuture = fetchFcmToken();
//   }

//   Future<void> setupFirebaseMessaging() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     print('User granted permission: ${settings.authorizationStatus}');

//     if (kIsWeb) {
//       // Subscribe to multiple topics
//       await messaging.subscribeToTopic('new_product');
//       await messaging.subscribeToTopic('discount_announcement');
//       await messaging.subscribeToTopic('comments');
//     }

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Received a message while in the foreground!');
//       print('Message data: ${message.data}');
//       if (message.notification != null) {
//         print('Message also contained a notification: ${message.notification}');
//         // Show notification in a dialog
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text(message.notification!.title ?? 'New Notification'),
//             content: Text(message.notification!.body ?? 'You have a new message.'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     });

//     // Handle background messages
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Message clicked!');
//       // Navigate to a specific screen if needed
//       Navigator.pushNamed(context, '/products');
//     });

//     // Handle messages that opened the app from terminated state
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       _handleMessage(initialMessage);
//     }
//   }

//   Future<String?> fetchFcmToken() async {
//     try {
//       String? token = await FirebaseMessaging.instance.getToken();
//       print('FCM Token: $token');
//       return token;
//     } catch (error) {
//       print('Failed to get FCM token: $error');
//       return null;
//     }
//   }

//   Future<void> _signIn() async {
//     String email = _emailController.text;
//     String password = _emailController.text;

//     final String databaseUrl =
//         'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/users.json';

//     try {
//       final response = await http.get(Uri.parse(databaseUrl));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as Map<String, dynamic>;

//         bool userFound = false;
//         data.forEach((userId, userData) {
//           if (userData['email'] == email) {
//             if (userData['password'] == password) {
//               print('User logged in successfully');
//               _showSnackBar('User logged in successfully');
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ProductsPage(userRole: _selectedRole),
//                 ),
//               );
//             } else {
//               _showSnackBar('Incorrect password');
//             }
//             userFound = true;
//           }
//         });

//         if (!userFound) {
//           _showSnackBar('User not found');
//         }
//       } else {
//         print('Failed to fetch user data - ${response.statusCode}');
//         throw Exception('Failed to fetch user data');
//       }
//     } catch (e) {
//       print('Error signing in: $e');
//       throw Exception('Error signing in');
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   void _handleMessage(RemoteMessage message) {
//     if (message.data['type'] == 'chat') {
//       Navigator.pushNamed(context, '/chat', arguments: ChatArguments(message));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sign In'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 labelText: 'Email',
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             SizedBox(height: 20.0),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(
//                 labelText: 'Password',
//               ),
//               obscureText: true,
//             ),
//             SizedBox(height: 20.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Are you a: '),
//                 DropdownButton<UserRole>(
//                   value: _selectedRole,
//                   onChanged: (UserRole? value) {
//                     setState(() {
//                       _selectedRole = value!;
//                     });
//                   },
//                   items: <UserRole>[
//                     UserRole.shopper,
//                     UserRole.vendor,
//                   ].map<DropdownMenuItem<UserRole>>((UserRole value) {
//                     return DropdownMenuItem<UserRole>(
//                       value: value,
//                       child: Text(value == UserRole.shopper ? 'Shopper' : 'Vendor'),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: _signIn,
//               child: Text('Sign In'),
//             ),
//             SizedBox(height: 20.0),
//             FutureBuilder<String?>(
//               future: _tokenFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else if (snapshot.hasData) {
//                   return Text('FCM Token: ${snapshot.data}');
//                 } else {
//                   return Text('Failed to get FCM token');
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'dart:convert';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.shopper;

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
          ],
        ),
      ),
    );
  }
}
