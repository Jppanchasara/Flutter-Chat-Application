import 'dart:convert';
import 'dart:developer';
import 'dart:io';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yourchat/helper/mydate_util.dart';
import 'package:yourchat/models/chat_user.dart';
import 'package:yourchat/screen/view_profile_screen.dart';

import '../ApI/apis.dart';
import '../main.dart';
import '../models/message.dart';
import '../widgets/chat_user_card.dart';
import '../widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ChatSCreen extends StatefulWidget {
  final ChatUser user;
  const ChatSCreen({super.key, required this.user});

  @override
  State<ChatSCreen> createState() => _ChatSCreenState();
}

class _ChatSCreenState extends State<ChatSCreen> {
  List<Message> list=[];
  
  final _textController=TextEditingController();
  //for storing value of showing or hiding emoji
  bool _showiEmoji=false;
  //for checking image is uploading or not?
  bool _upLoading=false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if emojis are shown $back button is pressed then hide emojis
        // or else simple close current screen on back button click
        onWillPop: (){
          if(_showiEmoji){
            setState(() {
              _showiEmoji=!_showiEmoji;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor:const  Color.fromARGB(255, 226, 243, 243),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appbar(),
            ),
            body:Column(
              
              children: [
                Expanded(
                  child: StreamBuilder(
                    
                  stream:APIs.getAllMessage(widget.user),
                  builder: (context ,snapshot){
                    
                    switch (snapshot.connectionState) {
                      //if data loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator(color: Colors.black,));
                      //if some all data is loaded then  show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        
                        final data=snapshot.data?.docs;
                        
                        
                        list=data?.map((e) => Message.fromJson(e.data())).toList()??[];
                        if(list.isNotEmpty){
                          
                          return ListView.builder(
                            reverse:true,
                            padding: EdgeInsets.only(top: mq.height*0.01),
                            physics: const BouncingScrollPhysics(),
                            itemCount:  list.length,
                            itemBuilder: (context,index){
                              //return ChatUserCard(user:  list[index]);
                              return MessageCard(message: list[index]);
                          
                          });
                        }else{
                          return const Center(child: Text('Say,Hii!👋',style: TextStyle(fontSize: 20,color: Colors.black),));
                        }
                          
                    }
                  },),
                ),
                //progress indicator for showing uploading image
                if(_upLoading)
                  const Align(
                    child: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 8,vertical: 20),
                      child: CircularProgressIndicator(strokeWidth: 2,color: Colors.black,),
                    ),
                  ),
                _chatInput(),
               
                if(_showiEmoji)
                  SizedBox(
                    height: mq.height*0.35,
                    child: EmojiPicker(           
                        textEditingController: _textController, 
                        config: Config(
                            columns: 8,
                            initCategory: Category.SMILEYS,
                            emojiSizeMax: 32 * ( Platform.isIOS? 1.30 : 1.0),     
                        ),
                    ),
                  )
                ],
            )
          ),
        ),
      ),
    );
  }
  Widget _appbar(){
    return InkWell(
      onTap: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context,snapshot){
        final data=snapshot.data?.docs;
        final list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];
        
              
    
        return  Row(
        children: [
          IconButton(onPressed: ()=>Navigator.pop(context), icon:const Icon(Icons.arrow_back,color: Colors.black,)),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height*0.03),
            child: CachedNetworkImage(
            width: mq.height*0.06,
            height: mq.height*0.06,
            fit: BoxFit.fill,
            imageUrl: list.isNotEmpty?list[0].image : widget.user.image,
            errorWidget: (context, url, error) =>const  CircleAvatar(child:  Icon(Icons.person,color: Colors.black,)),
            ),
          ),
          const SizedBox(height: 10,width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 5,),
              
              Text( list.isNotEmpty ? list[0].name : widget.user.name,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 16),),
              Text(
                list.isNotEmpty
              ?
               list[0].isOnline
                  ?'Online':
                   MyDateUtil.getLastActiveTime(context, list[0].lastActive):
             widget.user.lastActive
             //MyDateUtil.getLastActiveTime(context, widget.user.lastActive)
               ,style: TextStyle(color: Colors.black54,fontSize: 13),),
              
            ],
          )
        ],
      );
      
      }),
    );}
  Widget _chatInput(){
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: mq.height*0.01,horizontal: mq.width*0.025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(onPressed: (){
                    FocusScope.of(context).unfocus();
                    setState(() =>_showiEmoji= !_showiEmoji);
                  }, icon: const Icon(Icons.emoji_emotions,color:Colors.blueAccent,size: 25,)),
                   Expanded(child: TextField(
                    onTap:() {
                      if(_showiEmoji) setState(() =>_showiEmoji= !_showiEmoji);
                    },
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      
                      hintText: 'Type something...',
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none
                    ),
                  )),
                  IconButton(onPressed: ()  async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final List<XFile> image = await picker.pickMultiImage(imageQuality: 70);
                    for (var i in image){
                      log('image path:${i.path}');
                      setState(() {
                        _upLoading==true;
                      });
                      APIs.sendChatImage(widget.user, File(i.path));
                      setState(() {
                        _upLoading=false;
                      });

                    }
                    
                  }, icon: const Icon(Icons.image,color:Colors.blueAccent,size: 25,)),
                  IconButton(onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 70);
                    if(image !=null){
                      log('image path:${image.path}');
                      setState(() {
                        _upLoading=true;
                      });
                      APIs.sendChatImage(widget.user, File(image.path));
                      setState(() {
                        _upLoading=false;
                      });
                    
                    }

                  }, icon: const Icon(Icons.camera_alt_rounded,color:Colors.blueAccent,size: 25,)),
                  SizedBox(width: mq.width*0.02,)
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            padding: const EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10) ,
            onPressed: (){
              if(_textController.text.isNotEmpty){
                // if(list.isEmpty){
                //   //on first message (add user to my_user collection of chat user)
                //   APIs.sendFirstMessage(widget.user, _textController.text,Type.text);
                // }else{
                //   //simply send message
                  APIs.sendMessage(widget.user, _textController.text,Type.text);
                // }
                
                _textController.text='';
              }
            },
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send,color: Colors.white,) ,)
        ],
      ),
    );

  }

}