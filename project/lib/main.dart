import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'signin.dart';
import 'product.dart';
import 'signup.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

// Firebase configuration options for web
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyAM_K2axMH_vb2JJdadwJGr5JWQXTifwOA",
  authDomain: "mobile2-b7914.firebaseapp.com",
  databaseURL: "https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "mobile2-b7914",
  storageBucket: "mobile2-b7914.appspot.com",
  messagingSenderId: "820320428284",
  appId: "1:820320428284:web:86ff19f46e8f1c8f79f779",
  measurementId: "G-P5RVSDGQJT"
);

// Function to handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: firebaseConfig);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseConfig);
    if (html.window.navigator.serviceWorker != null) {
      html.window.navigator.serviceWorker!.register('/firebaseMessaging.js');
    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } else {
    await Firebase.initializeApp();
  }

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
        '/products': (context) => ProductsPage(userRole: UserRole.shopper),
        '/signin': (context) => const SignInPage(),
        '/home': (context) => MyHomePage(),  // Add the route for MyHomePage
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String?>? _tokenFuture;

  @override
  void initState() {
    super.initState();
    setupFirebaseMessaging();
    _tokenFuture = fetchFcmToken();
  }

  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (kIsWeb) {
      // Subscribe to multiple topics
      await messaging.subscribeToTopic('new_product');
      await messaging.subscribeToTopic('discount_announcement');
      await messaging.subscribeToTopic('comments');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Show notification in a dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message.notification!.title ?? 'New Notification'),
            content: Text(message.notification!.body ?? 'You have a new message.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Navigate to a specific screen if needed
      Navigator.pushNamed(context, '/products');
    });

    // Handle messages that opened the app from terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  Future<String?> fetchFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      return token;
    } catch (error) {
      print('Failed to get FCM token: $error');
      return null;
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      Navigator.pushNamed(context, '/chat', arguments: ChatArguments(message));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Push Notifications'),
      ),
      body: Center(
        child: FutureBuilder<String?>(
          future: _tokenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Text('FCM Token: ${snapshot.data}');
            } else {
              return Text('Failed to get FCM token');
            }
          },
        ),
      ),
    );
  }
}

class ChatArguments {
  final RemoteMessage message;
  ChatArguments(this.message);
}
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'signin.dart';
// import 'product.dart';
// import 'signup.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:html' as html;

// // Firebase configuration options for web
// const firebaseConfig = FirebaseOptions(
//   apiKey: "AIzaSyAM_K2axMH_vb2JJdadwJGr5JWQXTifwOA",
//   authDomain: "mobile2-b7914.firebaseapp.com",
//   databaseURL: "https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app",
//   projectId: "mobile2-b7914",
//   storageBucket: "mobile2-b7914.appspot.com",
//   messagingSenderId: "820320428284",
//   appId: "1:820320428284:web:86ff19f46e8f1c8f79f779",
//   measurementId: "G-P5RVSDGQJT"
// );

// // Function to handle background messages
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: firebaseConfig);
//   print('Handling a background message: ${message.messageId}');
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (kIsWeb) {
//     await Firebase.initializeApp(options: firebaseConfig);
//     if (html.window.navigator.serviceWorker != null) {
//       html.window.navigator.serviceWorker!.register('/firebaseMessaging.js');
//     }
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   } else {
//     await Firebase.initializeApp();
//   }

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Authentication App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/signup',
//       routes: {
//         '/signup': (context) => const SignUpPage(),
//         '/products': (context) => ProductsPage(userRole: UserRole.shopper),
//         '/signin': (context) => const SignInPage(),
//       },
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     super.initState();
//     setupFirebaseMessaging();
//   }

//   Future<void> setupFirebaseMessaging() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     print('User granted permission: ${settings.authorizationStatus}');

//     // Get the token each time the application loads and print it
//     messaging.getToken().then((token) {
//       print('FCM Token: $token');
//     }).catchError((error) {
//       print('Failed to get FCM token: $error');
//     });

//     if (kIsWeb) {
//       // Subscribe to the topic
//       await messaging.subscribeToTopic('new_product');
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

//   void _handleMessage(RemoteMessage message) {
//     if (message.data['type'] == 'chat') {
//       Navigator.pushNamed(context, '/chat', arguments: ChatArguments(message));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Push Notifications'),
//       ),
//       body: Center(
//         child: Text('Push Notifications Example'),
//       ),
//     );
//   }
// }

// class ChatArguments {
//   final RemoteMessage message;
//   ChatArguments(this.message);
// }
