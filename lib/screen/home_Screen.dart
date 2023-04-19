// ignore: implementation_imports

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yourchat/helper/dialog.dart';
import 'package:yourchat/screen/profile_screen.dart';

import '../ApI/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //for storing all user
  List<ChatUser> list = [];
  //for storing serch item
  final List<ChatUser> _serchList = [];
  //for storing serch status
  bool _isSerching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    //for updating user active status according to lifecycle events
    //resume--active or online
    //pause--inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message:$message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSerching) {
            setState(() {
              _isSerching = !_isSerching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              leading: const Icon(CupertinoIcons.home),
              title: _isSerching
                  ? Container(
                      height: 40,
                      width: double.infinity,
                      child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              hintText: 'Serch name or email'),
                          autofocus: true,
                          style: const TextStyle(fontSize: 13),
                          //when search text changes than upload search list
                          onChanged: (val) {
                            //serch logic
                            _serchList.clear();
                            for (var i in list) {
                              if (i.name
                                      .toLowerCase()
                                      .contains(val.toLowerCase()) ||
                                  i.email
                                      .toLowerCase()
                                      .contains(val.toLowerCase())) {
                                _serchList.add(i);
                              }
                              setState(() {
                                _serchList;
                              });
                            }
                          }),
                    )
                  : const Text('We Chat'),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSerching = !_isSerching;
                      });
                    },
                    icon: Icon(_isSerching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                    user: APIs.me,
                                  )));
                    },
                    icon: const Icon(Icons.more_vert)),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () {
                  _addChatUserDialog();
                },
                child: const Icon(Icons.message),
              ),
            ),
            body: StreamBuilder(
                stream: APIs.getMyChatId(),
                //get id of only know user

                builder: (context, snapshot) {
                  
                    if(snapshot.hasData){
                        StreamBuilder(
                          stream: APIs.getAllUsers(
                            snapshot.data?.docs.map((e) => e.id).toList() ??[]
                              ),
                          //get only those user,who's id are provided
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              //if data loading
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.black,
                                ));
                              //if some all data is loaded then  show it
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                list = data
                                        ?.map(
                                            (e) => ChatUser.fromJson(e.data()))
                                        .toList() ??
                                    [];
                                if (list.isNotEmpty) {
                                  return ListView.builder(
                                      padding: EdgeInsets.only(
                                          top: mq.height * 0.01),
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _isSerching
                                          ? _serchList.length
                                          : list.length,
                                      itemBuilder: (context, index) {
                                        return ChatUserCard(
                                            user: _isSerching
                                                ? _serchList[index]
                                                : list[index]);
                                        //return Text('name:${list[index]}');
                                      });
                                } else {
                                  return const Center(
                                      child: Text(
                                    'No Connection Found!',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ));
                                  // handle empty array case
                                }
                            }
                          },
                        );
                    }else{
                      return const Center(
                                      child:CircularProgressIndicator(strokeWidth: 2,) ,
                                  );

                    }
                       
                      
                  
                })),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  top: 20, bottom: 10, left: 24, right: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('  Add User')
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'jayesh@gmail.com',
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
                    label: const Text(
                      'Email Id',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    //hiding for alertBox
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    //hiding for alertBox
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          dialog.showSnackbar(context, 'User does not Exists!');
                        }
                      });
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}
