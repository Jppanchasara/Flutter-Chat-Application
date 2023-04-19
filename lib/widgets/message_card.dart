import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:yourchat/ApI/apis.dart';
import 'package:yourchat/helper/dialog.dart';
import 'package:yourchat/helper/mydate_util.dart';
import 'package:yourchat/models/message.dart';

import '../main.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  //sender or user message
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log('message read updated');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.msg == Type.image
                ? mq.width * 0.01
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue, width: 3),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  )
                : //show images
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  //our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * 0.02,
            ),
            //double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              Container(
                height: mq.height * 0.06,
                width: mq.width * 0.08,
                child: IconButton(
                    onPressed: () {
                      dialog.showSnackbar(
                          context,
                          MyDateUtil.getFormattedTime(
                              context: context, time: widget.message.read));
                    },
                    icon: const Icon(
                      Icons.done_all_rounded,
                      color: Colors.blue,
                      size: 20,
                    )),
              ),
            // SizedBox(width: mq.width*0.02,),
            //sent time

            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.02
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen, width: 3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  )
                : //show images
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  //bottom sheet for modifying message  details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .01, bottom: mq.height * 0.05),
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.015, horizontal: mq.width * 0.4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon:const Icon(
                        Icons.copy_all_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Copy Text',
                      onTap: ()async {
                        await Clipboard.setData(ClipboardData(text:widget.message.msg)).then((value) {
                          Navigator.pop(context);
                          dialog.showSnackbar(context, 'Text Copied!');
                        });
                      })
                  : _OptionItem(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Save Image',
                      onTap: () async{
                        try{
                          log('Image Url:${widget.message.msg}');
                          await GallerySaver.saveImage(widget.message.msg,albumName: 'We Chat').then((success) {
                            Navigator.pop(context);
                            if(success != null && success){
                              dialog.showSnackbar(context, 'Image Successfully Saved!');
                            }
      
                          });
                          
                        }catch(e){
                          log('ErrorWhileSavinging :${e}');

                        }

                      }),
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * 0.04,
                  indent: mq.width * 0.04,
                ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Edit Message',
                    onTap: () {
                      //hiding for dialog
                      Navigator.pop(context);
                      _showMessageUpdateDialog();
                    }),
              if (isMe)
                _OptionItem(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 26,
                    ),
                    name: 'Delete Message ',
                    onTap: () async {
                      await APIs.delateMessage(widget.message).then((value) {
                        Navigator.pop(context);
                      });
                    }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * 0.04,
                indent: mq.width * 0.04,
              ),
              _OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                    size: 26,
                  ),
                  name: 'Sent At :${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),
              _OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                    size: 26,
                  ),
                  name: widget.message.read.isEmpty?'Read At :Not Seen Yet '
                  :'Read At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }
  //dialog for updating message content
  void _showMessageUpdateDialog(){
    String updatedMsg =widget.message.msg;
    showDialog(context: context, builder: (_)=>AlertDialog(
      contentPadding:const EdgeInsets.only(top: 20,bottom: 10,left: 24,right: 24),
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      title: Row(
        children: const [
          Icon(Icons.message,color: Colors.blue,size: 28,),
          SizedBox(width: 10,),
          Text('Update Message')
        ],
      ),
      content: TextFormField(
        initialValue: updatedMsg,
        maxLines: null,
        onChanged: (value)=>updatedMsg=value,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          //hiding for alertBox
          Navigator.pop(context);

        },child: Text('Cancel',style: TextStyle(color: Colors.blue,fontSize: 16),),),
        MaterialButton(onPressed: (){
          //hiding for alertBox
          Navigator.pop(context);
          APIs.updateMessage(widget.message, updatedMsg).then((value) {
            dialog.showSnackbar(context, 'Successfully Update Message');
            log('$updatedMsg');


          });


        },child: Text('Update',style: TextStyle(color: Colors.blue,fontSize: 16),),)

      ],

    ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * 0.05,
            top: mq.height * 0.015,
            bottom: mq.height * 0.015),
        child: Row(
          children: [icon, Flexible(child: Text('    $name'))],
        ),
      ),
    );
  }
}
