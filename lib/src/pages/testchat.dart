import 'package:customer/src/models/chatMessageModel.dart';
import 'package:customer/src/models/route_argument.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ChatWidget extends StatefulWidget {

final RouteArgument routeArgument;

  ChatWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}


class _ChatWidgetState extends StateMVC<ChatWidget>{

  _ChatWidgetState() : super() {
  }

  List<ChatMessage> messages = [
    ChatMessage(messageContent: "Hello, Test", messageType: "receiver"),
    ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
    ChatMessage(messageContent: "Hey Test, I am doing fine dude. wbu?", messageType: "sender"),
    ChatMessage(messageContent: "doing OK.", messageType: "receiver"),
    ChatMessage(messageContent: "Ok good", messageType: "sender"),
  ];

 TextEditingController _textcontroller = new TextEditingController();
 String _mensaje;

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
      body: Stack(
        children: <Widget>[
          CustomScrollView(slivers: [
            SliverList(
              //shrinkWrap: true,
              //padding: EdgeInsets.only(top: 10,bottom: 10),
              //physics: NeverScrollableScrollPhysics(),
              delegate: SliverChildBuilderDelegate(( BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                  child: Align(
                    alignment: (messages[index].messageType == "receiver"?Alignment.topLeft:Alignment.topRight),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (messages[index].messageType  == "receiver"?Colors.grey.shade200:Colors.amber),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(messages[index].messageContent, style: TextStyle(fontSize: 15),),
                    ),
                  ),
                );
              }, childCount: messages.length,
            ),
            )
          ],
    ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      controller: _textcontroller,
                      decoration: InputDecoration(
                          hintText: "Write a message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none
                      ),
                      onChanged: (value){
                        setState(() {
                          _mensaje = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: (){
                      print(_mensaje);
                      print(messages);
                      setState(() {
                        messages.add(ChatMessage(messageContent: _mensaje, messageType: "sender"),);
                        _textcontroller.text = "";
                      });
                    },
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    //backgroundColor: Colors.blue,
                    backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                    elevation: 0,
                  ),
                ],

              ),
            ),
          ),
        ],
      ),
    );
  }

}