import 'package:firebase_app_chat/pages/forgotpassword.dart';
import 'package:firebase_app_chat/pages/home.dart';
import 'package:firebase_app_chat/pages/signin.dart';
import 'package:firebase_app_chat/pages/signup.dart';
import 'package:firebase_app_chat/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home:
            FutureBuilder(
              future: Authmethods().getCurrentUser(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Home();
          } else {
            return SignUp();
          }
        }));
  }
}
