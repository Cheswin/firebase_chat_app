import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_chat/services/sharedpreference.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  Future AddUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .doc(id)
        .set(userInfoMap);
  }

  Future<QuerySnapshot> getUserbyEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .where("email", isEqualTo: email)
        .get();
  }

  Future<QuerySnapshot> Search(String username) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .where("searchKey", isEqualTo: username.substring(0, 1).toUpperCase())
        .get();
  }

  createChatRoom(
      String ChatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(ChatRoomId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(ChatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updatedLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastmesssageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastmesssageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String userName) async {
    return FirebaseFirestore.instance
        .collection("user")
        .where("username", isEqualTo: userName)
        .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myusername = await SharedPreferenceHelper().getuserName();

    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("time", descending: true)
        .where("users", arrayContains: myusername!)
        .snapshots();
  }

}
