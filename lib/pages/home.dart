import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_chat/pages/chatpage.dart';
import 'package:firebase_app_chat/services/database.dart';
import 'package:firebase_app_chat/services/sharedpreference.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    ontheload();
    super.initState();
  }

  bool search = false;
  String? myName, myProfilepic, myuserName, myEmail;
  Stream? chatRoomsStream;

  gettheSharedPref() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilepic = await SharedPreferenceHelper().getuserpic();
    myuserName = await SharedPreferenceHelper().getuserName();
    myEmail = await SharedPreferenceHelper().getuserEmail();
    setState(() {});
  }

  ontheload() async {
    await gettheSharedPref();
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.doc.length;
                    return ChatRoomListTile(
                      chatRoomId: ds.id,
                      lastMessage: ds["lastMessage"],
                      myUserName: myuserName!,
                      time: ds["lastMessageSendTs"],
                    );
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\ $a";
    } else {
      return "$b \ $a ";
    }
  }

  var queryResultSet = [];
  var tempSearchStore = [];

  initialSearch(String value) async {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    setState(() {
      search = true;
    });

    var capitalizedvalue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.isEmpty && value.length == 1) {
      await DatabaseMethods().Search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; i++) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].startsWith(capitalizedvalue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.tealAccent,
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 40, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  search
                      ? Expanded(
                          child: TextField(
                          onChanged: (value) {
                            initialSearch(value.toUpperCase());
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search user",
                              hintStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black)),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ))
                      : Text(
                          "Lets-Talk",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                  GestureDetector(
                    onTap: () {
                      search = true;
                      setState(() {});
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blueGrey.shade700),
                        child: search
                            ? GestureDetector(
                                onTap: () {
                                  search = false;
                                  setState(() {});
                                },
                                child: Icon(Icons.close))
                            : Icon(Icons.search)),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(8),
                  // height:search?MediaQuery.of(context).size.height / 1.19: MediaQuery.of(context).size.height / 1.15,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: search
                      ? ListView(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          primary: false,
                          shrinkWrap: true,
                          children: tempSearchStore.map((element) {
                            return buildResultCard(element);
                          }).toList(),
                        )
                      : chatRoomList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        setState(() {});
        var chatRoomId = getChatRoomIdByUsername(myuserName!, data["username"]);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myuserName, data["username"]]
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: data["name"],
                    profileUrl: data["photo"],
                    username: data["username"])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      data["photo"],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    )),
                SizedBox(
                  width: 25,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["name"],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 02,
                    ),
                    Text(
                      data["username"],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUserName, time;

  const ChatRoomListTile(
      {super.key,
      required this.lastMessage,
      required this.chatRoomId,
      required this.myUserName,
      required this.time});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilPicUrl = "", name = "", username = "", id = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUserName, "");
    QuerySnapshot querysnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    name = "${querysnapshot.docs[0]["name"]}";
    profilPicUrl = "${querysnapshot.docs[0]["photo"]}";
    id = "${querysnapshot.docs[0]["id"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profilPicUrl == ""
              ? CircularProgressIndicator()
              : ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    profilPicUrl,
                    fit: BoxFit.cover,
                    height: 70,
                    width: 70,
                  )),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                child: Text(
                  widget.lastMessage,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            widget.time,
            style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
