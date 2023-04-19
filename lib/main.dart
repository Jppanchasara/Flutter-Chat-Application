

 import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yourchat/screen/Splash_Screen.dart';

import 'firebase_options.dart';

late Size mq;


void main() {
    WidgetsFlutterBinding.ensureInitialized();

    // //enter full-screen
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // //for setting orientation to portrait only
    
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown])
    .then((value) {
       _initializeFirebase();
      runApp(const MyApp());
        
    });
    
}

void _initializeFirebase() async{
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
     
     debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        appBarTheme:const AppBarTheme(
            centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(
            color: Colors.black
          ),
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black,fontSize: 19,fontWeight: FontWeight.normal),
        ),
        
        
      ),
      home: const SplashScreen(),
    );
  }
 
}


