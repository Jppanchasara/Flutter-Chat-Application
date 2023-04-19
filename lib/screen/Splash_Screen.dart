import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../ApI/apis.dart';
import '../main.dart';
import 'auth/login_screen.dart';
import 'home_Screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    
    super.initState();
    Future.delayed(const Duration(seconds: 7),(){
      //exit full-screen
      // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
       SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.white));
      if(APIs.auth.currentUser!=null){
        log('\nUser:${APIs.auth.currentUser}');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));

      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen()));

      }
      

    });
  }
  @override
  Widget build(BuildContext context) {
     mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          //Lottie.asset('icon/splash.json'),
          TextLiquidFill(
            text: 'We Chat',
            waveColor: Colors.blueAccent,
            boxBackgroundColor: Colors.blue.shade100,
            textStyle: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
            boxHeight: 100,
          ),
          const SizedBox(height: 50,),
          Lottie.asset('icon/splash.json'),
          const SizedBox(height: 50,),
          Text('MADE IN INDIA WITH ❤️',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black.withOpacity(0.5)),),
          
        ],
      ),
    );
  }
}