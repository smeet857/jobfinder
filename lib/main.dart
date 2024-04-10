import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jobfinder/splash_screen.dart';
import 'package:jobfinder/user_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner:false,
      title: 'iJob Finder App',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          primarySwatch: Colors.cyan
      ),
      home: UserState(),
    );
  }
}
