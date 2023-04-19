import 'package:flutter/material.dart';

// ignore: camel_case_types
class dialog{
  static void  showSnackbar(BuildContext context,String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.black.withOpacity(0.5),
      behavior: SnackBarBehavior.floating,
      
      ));
  }
  static void showProgressBar(BuildContext context){
    showDialog(context: context, builder: (_)=>const Center(child: CircularProgressIndicator(color: Colors.black,)));
  }
}