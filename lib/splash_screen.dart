import 'package:flutter/material.dart';
import 'package:jobfinder/LoginPage/login_screen.dart';
import 'package:jobfinder/user_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(const Duration(seconds: 3),(){
      Navigator.push(context, MaterialPageRoute(builder: (_)=>Login()));
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.cyan,
      child: Center(child: Text("Welcome to my Application")),
    );
  }
}
