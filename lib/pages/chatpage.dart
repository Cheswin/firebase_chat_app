import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_chat/pages/home.dart';
import 'package:firebase_app_chat/services/database.dart';
import 'package:firebase_app_chat/services/sharedpreference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  String name, profileUrl, username;
  ChatPage(
      {required this.name, required this.profileUrl, required this.username});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ontheload();
  }

  TextEditingController messageController = TextEditingController();
  String? myUserName, myProfilePic, myname, myEmail, messageId, chatRoomId;
  Stream? messageStream;

  gettheSharedpref() async {
    myUserName = await SharedPreferenceHelper().getuserName();
    myProfilePic = await SharedPreferenceHelper().getuserpic();
    myEmail = await SharedPreferenceHelper().getuserEmail();
    myname = await SharedPreferenceHelper().getDisplayName();
    chatRoomId = getChatRoomIdByUsername(myUserName!, widget.username);
    setState(() {});
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\ $a";
    } else {
      return "$b \ $a ";
    }
  }

  ontheload() async {
    await gettheSharedpref();
    await getAndSetMessages();

    setState(() {});
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: sendByMe ? Colors.blueAccent : Colors.blueGrey,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  24,
                ),
                bottomRight:
                    sendByMe ? Radius.circular(0) : Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft:
                    sendByMe ? Radius.circular(24) : Radius.circular(0)),
          ),
          child: Text(
            message,
            style: TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ))
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
        stream: messageStream,
        builder: ((context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 90, top: 130),
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return chatMessageTile(
                        ds["message"], myUserName == ds["sendBy"]);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        }));
  }

  addMessage(bool sendClicked) {
    if (messageController.text != "") {
      String message = messageController.text;
      messageController.text = "";
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myProfilePic,
      };
      messageId ??= randomAlphaNumeric(10);
      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUserName
        };
        DatabaseMethods()
            .updatedLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
      });
    }
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Container(
        padding: EdgeInsets.only(top: 60),
        // margin: EdgeInsets.only(
        //   top: 60,
        // ),
        child: Stack(
          children: [
            Container(
                margin: EdgeInsets.only(top: 50),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.12,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: chatMessage()),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Home()));
                      },
                      child: Icon(Icons.arrow_back_ios_new)),
                  SizedBox(
                    width: 90,
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(
                        color: Color.fromARGB(255, 213, 228, 235),
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              alignment: Alignment.bottomCenter,
              child: Material(
                borderRadius: BorderRadius.circular(30),
                elevation: 5,
                child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          helperText: "type the message",
                          helperStyle: TextStyle(color: Colors.black),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                addMessage(true);
                              },
                              child: Icon(Icons.send_rounded))),
                    )),
              ),
            )

            
          ],
        ),
      ),
    );
  }
}
