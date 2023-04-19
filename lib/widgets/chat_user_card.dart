import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yourchat/ApI/apis.dart';
import 'package:yourchat/models/message.dart';
import 'package:yourchat/screen/chat_Screen.dart';
import 'package:yourchat/widgets/dialog/profile_dialog.dart';

import '../helper/mydate_util.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
   
  @override
  Widget build(BuildContext context) {
     mq = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.height*0.02,vertical: 4),
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      
      child: InkWell(
        onTap: (){
          Navigator.push (context, MaterialPageRoute(builder: (context)=>ChatSCreen(user: widget.user,)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context,snapshot){
            
            final data=snapshot.data?.docs;
            final list=data?.map((e) => Message.fromJson(e.data())).toList()??[];
            if(list.isNotEmpty)_message=list[0];


             return ListTile(
              //leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (_)=>ProfileDialog(user: widget.user));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height*0.25),
                  child: CachedNetworkImage(
                    width: mq.height*0.06,
                    height: mq.height*0.06,
                    
                      imageUrl: widget.user.image,
                      //placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>const  CircleAvatar(child:  Icon(Icons.person,color: Colors.black,)),
                  ),
                ),
              ),
              title: Text(widget.user.name),
              subtitle: Text(_message!=null ? _message!.type==Type.image?'image':_message!.msg
                : widget.user.about,maxLines: 1,),
              //last message time
              trailing: _message== null
                    ?null//show nothing when no message is sent
                    : _message!.read.isEmpty&&_message!.fromId!=APIs.user.uid?
                    //show for unread message
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400,
                        borderRadius: BorderRadius.circular(7.5)
                      ),
                    )//message sent time
                    :Text(MyDateUtil.getLastMessageTime(context: context, time: _message!.sent) ,style: const TextStyle(color: Colors.black),)

          
        );

        })
      ),
    );
  }
}