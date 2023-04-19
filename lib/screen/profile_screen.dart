
// ignore: implementation_imports

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yourchat/helper/dialog.dart';
import 'package:yourchat/screen/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';

import '../ApI/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import 'Splash_Screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fromkey=GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
     mq = MediaQuery.of(context).size;
    return Scaffold(
      
       
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          onPressed: ()async{
            dialog.showProgressBar(context);
            APIs.updateActiveStatus(false);
            await APIs.auth.signOut().then((value) async{
              await GoogleSignIn().signOut().then((value) {
                //for hiding progress dialogs
                Navigator.pop(context);
                APIs.auth=FirebaseAuth.instance;
                //for moving to home screen

                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen()));
              });
            });
            
          },
          icon :const Icon(Icons.logout),
          label:const  Text("LogOut"),
          ),
      ),
      body: Form(
        key: _fromkey,
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: mq.width*0.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                
                Stack(
                  children: [
                    _image !=null ? 
                    //local image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height*0.1),
                      child: Image.file(File(_image!),
                        width: mq.height*0.2,
                        height: mq.height*0.2,
                        fit: BoxFit.cover,
                        ),
                    )
                    :
                    //server image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height*0.1),
                      child: CachedNetworkImage(
                        width: mq.height*0.2,
                        height: mq.height*0.2,
                        fit: BoxFit.fill,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) =>const  CircleAvatar(child:  Icon(Icons.person,color: Colors.black,)),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: MaterialButton(
                        elevation: 1,
                        shape: const CircleBorder(),
                        onPressed: (){
                          _showBottomSheet();
                          
                        },
                        color: Colors.white,
                        child: const Icon(Icons.edit),
                      ),
                    )
                  ],
                ),
                SizedBox(width: mq.width,height: mq.height*0.015,),
                Text(widget.user.email,style: TextStyle(fontSize: 15,color: Colors.black.withOpacity(0.5)),),
                SizedBox(width: mq.width,height: mq.height*0.05,),
                TextFormField(
                  onSaved: (val)=>APIs.me.name=val ?? '',
                  validator: (val)=>val!= null && val.isNotEmpty?null:'Required Filed',
                  initialValue: widget.user.name,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person,color: Colors.blue,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    hintText: "eg.Jayesh panchasara",
                    label: const Text('Name',style: TextStyle(fontSize: 20,color: Colors.black),),
              
                  ),
                ),
                SizedBox(width: mq.width,height: mq.height*0.03,),
                TextFormField(
                  onSaved: (val)=>APIs.me.about=val ?? '',
                  validator: (val)=>val!= null && val.isNotEmpty?null:'Required Filed',
                  initialValue: widget.user.about,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person,color: Colors.blue,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    hintText: "eg.Jay shree krishna",
                    label: const Text('About',style: TextStyle(fontSize: 20,color: Colors.black),),
                    
              
                  ),
                ),
                SizedBox(width: mq.width,height: mq.height*0.03,),
                ElevatedButton.icon(
                  
                  style: ElevatedButton.styleFrom(shape:const StadiumBorder(),minimumSize: Size(mq.width*.5, mq.height*.06)),
                  onPressed: (){
                    if(_fromkey.currentState!.validate()){
                      _fromkey.currentState!.save();
                      APIs.updateuserInfo().then((value) {
                        dialog.showSnackbar(context, 'Profile Update Successfully!');
                      });

                    }
                  }, 
                  icon: const Icon(Icons.edit,size: 28,),
                  label: const Text('Update',style: TextStyle(fontSize: 16),),
                  ),
                  // Image.asset('icon/picture.png')
              ],
            ),
          ),
        ),
      ),
      
    );
  }
  void _showBottomSheet(){
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20))
      ),
       builder: (_){
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: mq.height*.03,bottom: mq.height*0.05),
          children:  [
            const Text('Pick Profile Picture',textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
            
            SizedBox(height: mq.height*.02,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width*0.3, mq.height*0.15)
                  ),
                  onPressed: ()async{
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);
                    if(image !=null){
                      setState(() {
                        _image=image.path;
                        APIs.updateProfilePicture(File(_image!));
                      });
                      

                      //for hiding bottomSheet
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      // ignore: use_build_context_synchronously
                      dialog.showSnackbar(context,'Update Profile Picture Successfully!');
                    
                    }
                    
                  }, 
                  child: Image.asset('icon/picture.png')
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width*0.3, mq.height*0.15)
                  ),
                  onPressed: ()async{
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if(image !=null){
                      setState(() {
                        _image=image.path;
                        APIs.updateProfilePicture(File(_image!));
                      });
                      
                      //for hiding bottomSheet
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      

                      dialog.showSnackbar(context,'Update Profile Picture Successfully!');
                    
                    }

                  }, 
                  child: Image.asset('icon/camera.png')
                ),
              ],
            )
          ],
        );
       });
   
  }
  
  
}
