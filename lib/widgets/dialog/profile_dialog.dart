import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:yourchat/screen/view_profile_screen.dart';

import '../../main.dart';
import '../../models/chat_user.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * 0.6,
        height: mq.height * .35,
        child: Stack(
          children: [
            
            //server image
            Positioned(
              top: mq.height*0.075,
              left: mq.width*0.15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.25),
                child: CachedNetworkImage(
                  width: mq.width * 0.5,
                  
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(
                    Icons.person,
                    color: Colors.black,
                  )),
                ),
              ),
            ),
            //user name
            Positioned(
              left: mq.width*0.04,
              top: mq.height*0.02,
              width: mq.width*0.55,
              child: Text(user.name,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600),)),
            //info button
            Positioned(
              right: 8,
              top: 6,
              child: Align(
                alignment: Alignment.topRight,
                child: MaterialButton(
                  minWidth: 0,
                  padding: const EdgeInsets.all(8),
                  shape: const CircleBorder(),
                  child: const Icon(Icons.info_outline_rounded,color: Colors.black,size:30),
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: user)));
            
                  }
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
