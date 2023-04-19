// ignore: implementation_imports


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourchat/helper/mydate_util.dart';

import '../main.dart';
import '../models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final _fromkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Joined on:',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500, fontSize: 15)),
            Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,showYear: true),style: const TextStyle(color: Colors.black54, fontSize: 15))
          ],
        ),
        body: Padding(
          padding:  EdgeInsets.symmetric(horizontal: mq.height*0.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(width: mq.width,height: mq.height*0.03,),
                //server image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.1),
                    child: CachedNetworkImage(
                      width: mq.height * 0.2,
                      height: mq.height * 0.2,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(
                        Icons.person,
                        color: Colors.black,
                      )),
                    ),
                  ),
                ),
                SizedBox(width: mq.width,height: mq.height*0.03,),
                Text(widget.user.email,style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87,fontSize: 15),),
                SizedBox(width: mq.width,height: mq.height*0.01,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('About:',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500, fontSize: 15),),
                    Text(widget.user.about,style: const TextStyle(color: Colors.black54,fontSize: 15),)
                  ],
                ),
                
              ],
            ),
          ),
        ));
  }
}
