import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yourchat/models/chat_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:yourchat/models/message.dart';

class APIs {
  //user auth
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing uploading file to storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //to storing self information
  static late ChatUser me;

  //to return current user
  static get user => auth.currentUser!;

  //for accessing firebase messaging (push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }

  //for checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection('User').doc(user.uid).get()).exists;
  }

  //for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('User')
        .where('email', isEqualTo: email)
        .get();
    log('data:${data.docs}');
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      log('user exits:${data.docs.first.data()}');
      //user data
      firestore
          .collection('User')
          .doc(user.uid)
          .collection('my_user')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      //user doesn't exists
      return false;
    }
  }

  //for get current user Info
  static Future<void> getSelfInfo() async {
    await firestore.collection('User').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //setting for user status to active
        APIs.updateActiveStatus(true);
        log('MyData:${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for checking a new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, iam using We chat",
      image: user.photoURL,
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firestore
        .collection('User')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

//for getting id's of known users from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyChatId() {
    return firestore
        .collection('User')
        .doc(user.uid)
        .collection('my_user')
        .snapshots();
  }

  //for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nuserIds:${userIds}');
    return firestore
        .collection('User')
        .where('id', whereIn: userIds)
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for updating user information
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('User')
        .doc(chatUser.id)
        .collection('my_user')
        .doc(user.uid)
        .set({}).then((value) =>
      sendMessage(chatUser, msg, type)
    );
  }

  //for updating user information
  static Future<void> updateuserInfo() async {
    await firestore.collection('User').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //update user profile picture
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extention
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child('Profile_picture/${user.uid}.$ext');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('/nData Transfer:${p0.bytesTransferred / 1000}kb/n');
    });
    //uploading image to firebase database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('User')
        .doc(user.uid)
        .update({'image': me.image});
  }

  //for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('User')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //update online for last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('User').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  ///****** chat screen APIs******
  //chats(Collection)-->Conversation_id(doc)-->message (collection)-->message(doc)
  //useful  for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all message of a specific conversation from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatUser user) {
    return firestore
        .collection('chat/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    //message to send
    final Message message = Message(
        msg: msg,
        read: '',
        told: chatUser.id,
        type: type,
        sent: time,
        fromId: user.uid);
    final ref = firestore
        .collection('chat/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chat/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chat/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send me
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extention
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().microsecondsSinceEpoch}.$ext');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('/nData Transfer:${p0.bytesTransferred / 1000}kb/n');
    });
    //uploading image to firebase database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> delateMessage(Message message) async {
    await firestore
        .collection('chat/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //Update message
  static Future<void> updateMessage(Message message, String updateMsg) async {
    await firestore
        .collection('chat/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .update({'msg': updateMsg});
  }
}
