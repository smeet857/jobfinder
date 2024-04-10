import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jobfinder/LoginPage/login_screen.dart';

import '../Services/global_variables.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});


  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
   Animation<double>? _animation;
  final TextEditingController _forgetPassTextController= TextEditingController(text: '');
  final FirebaseAuth _auth = FirebaseAuth.instance;



  @override
  void initState() {
      _controller = AnimationController(vsync: this,duration: const Duration(seconds: 20));
      _animation=CurvedAnimation(parent: _controller, curve: Curves.linear)
        ..addListener(() {
          setState(() {
          });
        })
        ..addStatusListener((animationStatus) {
          if(animationStatus==AnimationStatus.completed){
            _controller.reset();
            _controller.forward();
          }
        });
      _controller.forward();


    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _forgetPsdSubmit() async
  {
    try{
      await _auth.sendPasswordResetEmail(
          email:_forgetPassTextController.text,
      );
      Navigator.push(context, MaterialPageRoute(builder: (_)=> Login()));
    }catch (error){
      Fluttertoast.showToast(msg: error.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [


          CachedNetworkImage(
            imageUrl: forgetUrlImage,
            placeholder: (context,url) => Image.asset(
              'assets/images/wallpaper.jpg',
              fit: BoxFit.fill,
      ),
            errorWidget: (context,url,error)=> const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation!.value,0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                SizedBox(height: size.height*0.1,),
                const Text(
                  'Forget Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Signatra',
                    fontSize: 55,
                  ),
                ),
                const SizedBox(height: 10,),
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20,),
                TextField(
                  controller: _forgetPassTextController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white54,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                MaterialButton(
                  onPressed: (){
                    _forgetPsdSubmit();
                  },
                  color: Colors.cyan,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Reset Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ),
        ],
      ),
    );
  }
}
