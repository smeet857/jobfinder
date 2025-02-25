import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobfinder/Services/global_method.dart';
import 'package:jobfinder/Services/global_variables.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});


  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>with SingleTickerProviderStateMixin  {

  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _fullNameController = TextEditingController(text: '');
  final TextEditingController _emailTextController= TextEditingController(text: '');
  final TextEditingController _psdTextController= TextEditingController(text: '');
  final TextEditingController _phonenumTextController= TextEditingController(text: '');
  final TextEditingController _addressTextController= TextEditingController(text: '');
  late bool _obscureText = true;
  final FocusNode _emailFocusNode= FocusNode();
  final FocusNode _passFocusNode =FocusNode();
  final FocusNode _phoneNumFocusNode =FocusNode();
  final FocusNode _positionFocusNode =FocusNode();
  final _signUpFormKey = GlobalKey<FormState>();
  File? imageFile;
  final FirebaseAuth _auth= FirebaseAuth.instance;
  bool _isLoading= false;
  String? imageUrl;

  @override
  void dispose() {
    _controller.dispose();
    _fullNameController.dispose();
    _emailTextController.dispose();
    _psdTextController.dispose();
    _phonenumTextController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _positionFocusNode.dispose();
    _phoneNumFocusNode.dispose();
    super.dispose();
  }

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
  void _showDialog()
  {
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text('Please choose an Option ',),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
           InkWell(
              onTap: (){
                _getFromCamera();
               },
             child: const Row(
               children: [
                 Padding(
                   padding: EdgeInsets.all(4.0),
                   child: Icon(
                     Icons.camera,
                     color: Colors.purple,
                   ),
                 ),
                 Text(
                   'Camera',
                   style: TextStyle(
                     color: Colors.purple,
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ],
             ),
          ),
              InkWell(
                onTap: (){
                  _getFromGallery();
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.image,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'Gallery',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        );
  }
    );
  }

  void _getFromCamera() async
  {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    //Navigator.pop(context);
  }

  void _getFromGallery() async
  {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    //Navigator.pop(context);
  }
  void _cropImage(filePath) async
  {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: filePath ,maxHeight: 1080,maxWidth: 1080
    );
    if(croppedImage != null){
      setState(() {
          imageFile=File(croppedImage.path);
      });
    }
  }

  void _submitFormOnSignup() async
  {
    final isValid= _signUpFormKey.currentState!.validate();
    if(isValid){
      if(imageFile==null){
        GlobalMethod.showErrorDialog(error: 'Please Pick an Image ', ctx: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _psdTextController.text.trim()
        );
        final User? user = _auth.currentUser;
        final uid= user!.uid;
        final ref=FirebaseStorage.instance.ref().child('userImages').child('$uid.jpg');
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(uid).set({
          'id': uid,
          'name': _fullNameController.text,
          'email': _emailTextController.text,
          'userImage': imageUrl,
          'phoneNumber': _phonenumTextController.text,
          'location': _addressTextController.text,
          'createdAt': Timestamp.now(),
        });
        // ignore: use_build_context_synchronously
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      }catch(error){
        setState(() {
          _isLoading=false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
    setState(() {
      _isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size= MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: signupUrlImage,
            placeholder: (context,url)=> Image.asset(
              'assets/images/wallpaper.jpg',
              fit: BoxFit.fill,
            ),
            errorWidget: (context,url,error)=> const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover ,
            alignment: FractionalOffset(_animation.value,0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 80),
              child: ListView(
                children: [
                  Form(
                    key: _signUpFormKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            _showDialog();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: size.width * 0.24,
                              height: size.width * 0.24,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: Colors.cyanAccent),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: imageFile==null
                                ? const Icon (Icons.camera_enhance_sharp, color: Colors.cyan, size: 30,)
                                :Image. file(imageFile!, fit: BoxFit.fill)
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(_emailFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller:_fullNameController,
                          validator: (value) {
                            if (value!.isEmpty)
                            {
                              return 'This Field Is Missing';
                            }
                            else{
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText:'Full Name',
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
                        const SizedBox(height: 20,),
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
                        const SizedBox(height: 20,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(_phoneNumFocusNode),
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
                        const SizedBox(height: 20,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(_positionFocusNode),
                          keyboardType: TextInputType.phone,
                          controller:_phonenumTextController,
                          validator: (value) {
                            if (value!.isEmpty)
                            {
                              return 'This Field is Empty';
                            }
                            else{
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Phone Number',
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
                        const SizedBox(height: 20,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: ()=>FocusScope.of(context).requestFocus(),
                          keyboardType: TextInputType.text,
                          controller:_addressTextController,
                          validator: (value) {
                            if (value!.isEmpty)
                            {
                              return 'This Field is Empty';
                            }
                            else{
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Company Address',
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
                        const SizedBox(height: 25,),
                        _isLoading
                        ?
                            const Center(
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(),
                              ),
                            )
                            :
                            MaterialButton(
                                onPressed: (){
                                  _submitFormOnSignup();
                                },
                              color: Colors.cyan,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("SignUp",
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
                        const SizedBox(height: 20,),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Already have an account?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                                const TextSpan(
                                  text: '      '
                                ),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                      ..onTap =() =>Navigator.canPop(context)
                                      ? Navigator.pop(context)
                                          : null,
                                  text: 'Login ',
                                  style: const TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )
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
          ),
        ],
      ),
    );
        
  }
}
