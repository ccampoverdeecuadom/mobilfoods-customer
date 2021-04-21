import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/src/elements/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/user_repository.dart' as userRepo;

class Chat extends StatelessWidget {
  final String peerId;

  Chat({Key key, @required this.peerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12 ,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Chat",
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: ChatScreen(
        peerId: peerId,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;

  ChatScreen({Key key, @required this.peerId}) : super(key: key);

  @override
  State createState() => ChatScreenState(peerId: peerId);
}

class ChatScreenState extends State<ChatScreen> {

  ChatScreenState({Key key, @required this.peerId});

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  String peerId; // driver id
  String id = userRepo.currentUser.value.id; // client id

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId;
  SharedPreferences prefs;

  bool isLoading;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();


  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {

    //focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    groupChatId = '';
    isLoading = false;

    readLocal();
    super.initState();
  }

  // void onFocusChange() {
  //   if (focusNode.hasFocus) {
  //     // Hide sticker when keyboard appear
  //     setState(() {
  //       isShowSticker = false;
  //     });
  //   }
  // }

  readLocal() async {
    print("INICIANDO....");
    //prefs = await SharedPreferences.getInstance();
    // print("actual id "+ prefs.getString('id'));
    // id = prefs.getString('id') ?? '';
    print("actual id "+ userRepo.currentUser.value.id);
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    fireStore.collection('users').doc(id).update({'chattingWith': peerId});

    setState(() {});
  }

  void onSendMessage(String content) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      print("gorup chat " + groupChatId);

      var documentReference = fireStore
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString());

      fireStore.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime
                .now()
                .millisecondsSinceEpoch
                .toString(),
            'content': content
          },
        );
      });
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data()['idFrom'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          // Text
          Container(
            child: Text(
              document.data()['content'],
              style: TextStyle(fontSize: 15),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 170.0,
            decoration: BoxDecoration(color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  child: Text(
                    document.data()['content'],
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 170.0,
                  decoration: BoxDecoration(color: Color(0xff203152), borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )
              ],
            ),
            // Time
            isLastMessageLeft(index) ? Container(
              child: Text(
                DateFormat('dd MMM kk:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document.data()['timestamp']))),
                style: TextStyle(color: Color(0xffaeaeae),
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
            )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage != null &&
        listMessage[index - 1].data()['idFrom'] == id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage != null &&
        listMessage[index - 1].data()['idFrom'] != id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    FirebaseFirestore.instance.collection('users').doc(id).update({'chattingWith': null});
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),
              // Input content
              buildInput(),
            ],
          ),
          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

Widget buildLoading() {
  return Positioned(
    child: isLoading ? const Loading() : Container(),
  );
}

  Widget buildInput() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
        height: 60,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            SizedBox(width: 15,),
            Expanded(
              child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                    hintText: "Write a message...",
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none
                ),
                focusNode: focusNode,
              ),
            ),
            SizedBox(width: 15,),
            FloatingActionButton(
              onPressed: () {
                onSendMessage(textEditingController.text);
              },
              child: Icon(Icons.send, color: Theme.of(context).primaryColor, size: 18,),
              backgroundColor: Theme.of(context).accentColor.withOpacity(0.9), elevation: 0,),
          ],

        ),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
                } else {
                  listMessage.addAll(snapshot.data.documents);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}
