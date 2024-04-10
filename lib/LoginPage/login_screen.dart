import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jobfinder/ForgetPassword/forget_password_screen.dart';
import 'package:jobfinder/Services/global_method.dart';
import 'package:jobfinder/Services/global_variables.dart';
import 'package:jobfinder/SignupPage/signup_screen.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _loginformkey =GlobalKey<FormState>();
  final FocusNode _passFocusNode =FocusNode();
  late bool _obscureText = true;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final TextEditingController _emailTextController= TextEditingController(text: '');
  final TextEditingController _psdTextController= TextEditingController(text: '');

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
  void _submitFormOnLogin() async{
    final isValid =_loginformkey.currentState!.validate();
    if(isValid){
      setState(() {
      });
      try{
        await _auth.signInWithEmailAndPassword(email: _emailTextController.text.trim().toLowerCase(),
            password: _psdTextController.text.trim());
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      }catch(error){
        setState(() {
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
    setState(() {
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack (
        children: [
          CachedNetworkImage(
            imageUrl: loginUrlImage,
            placeholder: (context,url)=>
                Image.asset(
              'assets/images/wallpaper.jpg',
               fit: BoxFit.fill,
            ),
            errorWidget: (context,url,error)=> const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value,0),
          ),
          Container(
           color: Colors.black54,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 80),
              child: ListView(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 80,right: 80),
                    child: Image.asset('assets/images/login.png'),
                  ),
                  const SizedBox(height: 15,),
                  Form(
                    key: _loginformkey,
                    child: Column(
                      children: [
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(_passFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller:_emailTextController,
                          validator: (value) {
                          if (value!.isEmpty||!value.contains('@'))
                          {
                            return 'Please enter a username';
                          }
                          else{
                            return null;
                          }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: _passFocusNode,
                          //onEditingComplete: ()=>FocusScope.of(context).requestFocus(_passFocusNode),
                          keyboardType: TextInputType.visiblePassword,
                          controller:_psdTextController,
                          obscureText: !_obscureText,
                          validator: (value) {
                            if (value!.isEmpty||value.length<7)
                            {
                              return 'Please enter a valid Password';
                            }
                            else{
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration:InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _obscureText= !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                            ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.white),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: ()
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> const ForgetPassword()));
                            },
                            child: const Text(
                              'Forget Password?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        MaterialButton(
                            onPressed: _submitFormOnLogin,
                            color:Colors.cyan,
                            elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40,),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Do Not have an Account?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const TextSpan( text: '       '),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                      ..onTap=()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUp())),
                                  text: 'SignUp',
                                  style: const TextStyle(
                                    color: Colors.cyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            ),
          )
        ],
      ),
    );
  }
}
