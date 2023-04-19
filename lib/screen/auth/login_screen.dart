


import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:yourchat/helper/dialog.dart';

import '../../ApI/apis.dart';

import '../../main.dart';
import '../home_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  get dialog => null;

  _handleGoogleBtnCLick(){
    
    
    signInWithGoogle().then((user) async {
      if(user != null){
          log('\nUser:${user.user}');
          log('\nuserAdditionalInfo:${user.additionalUserInfo}');
          if((await APIs.userExists())){
              
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));
      
          }else{
            await APIs.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));

            });
      
          }
         
      }
    });

  }

  Future<UserCredential?> signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);

    }catch(e){
      log('\n_signWithGoogle:$e');
      dialog.showSnackbar(context, 'Something went wrong (check internet!)');
      
      
      return null;
     

    }
    

  
}
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(

        title: const Text('Welcome to We Chat'),
      ),
      body: Stack(
        children: [

          const SizedBox(height: 30,),
          Lottie.asset('icon/splash.json'),
          const SizedBox(height: 3000,),
          Positioned(
            bottom: mq.height*0.15,
            left: mq.width*0.05,
            width: mq.width*0.9,
            height: mq.height*0.07,
            child:ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade100,
                shape: const StadiumBorder(),
                elevation: 5
              ),
              onPressed: (){
                _handleGoogleBtnCLick();

              }, 
            icon: Image.asset('icon/google.png',height: mq.height*0.05,), 
            label: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black,fontSize: 16),
                children: [
                  TextSpan(text: 'Sign In With '),
                  TextSpan(text: 'Google',style: TextStyle(fontWeight: FontWeight.w800,))
                ]
              ))))
        ],
      ),
      
    
    );
  }
}

 