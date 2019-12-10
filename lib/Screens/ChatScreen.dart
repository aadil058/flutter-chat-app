import 'dart:math';

import 'package:bubble/bubble.dart';
import 'package:chat_app/BLoC/authentication_bloc.dart';
import 'package:chat_app/BLoC/bloc_provider.dart';
import 'package:chat_app/BLoC/database_bloc.dart';
import 'package:chat_app/Datalayer/Message.dart';
import 'package:chat_app/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  ChatScreen(this.otherUserId, this.otherUserName);

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  // User otherUser;
  String myId;

  final TextEditingController _textEditingController = TextEditingController();
  bool _isComposing = false;

  int random;
  String chatId;

  @override
  void initState() {
    super.initState();
    // otherUser = BlocProvider.of<DatabaseBloc>(context).userWhereIdEqualTo(widget.otherUserId);
    myId = BlocProvider.of<AuthenticationBloc>(context).currentUserId;

    var randomizer = Random(DateTime.now().millisecondsSinceEpoch);
    random = randomizer.nextInt(3) + 1;

    try {
      if(BlocProvider.of<DatabaseBloc>(context).chats != null) {
        chatId = BlocProvider.of<DatabaseBloc>(context).chats.firstWhere((chat) => chat.participants.contains(widget.otherUserId) && chat.participants.contains(myId) && chat.adminId == null).id;  
      }
    }
    catch(err) {
      chatId = null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/man' + random.toString() + '.png'),
              ),
              SizedBox(width: 12.0),
              Text(widget.otherUserName, style: TextStyle(fontSize: 24.0),)
            ],
          )
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: chatId == null 
                ? Center(child: Text('No messages', style: TextStyle(fontSize: 24.0))) 
                : StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('chats')
                    .document(chatId)
                    .snapshots(includeMetadataChanges: true),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Text('No Messages');

                  DocumentSnapshot docs = snapshot.data;
                  BlocProvider.of<DatabaseBloc>(context).addLocalMessage(docs);
                  List<Message> messages = BlocProvider.of<DatabaseBloc>(context).chatById(chatId).messages;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      if(messages[index].sender == myId) {
                        return Bubble(
                          margin: BubbleEdges.only(top: 10),
                          alignment: Alignment.topRight,
                          nip: BubbleNip.rightBottom,
                          color: Color.fromRGBO(225, 255, 199, 1.0),
                          child: Text(messages[index].data, textAlign: TextAlign.right, style: TextStyle(fontSize: 24.0)),
                        );
                      }
                      else {
                        return Bubble(
                          margin: BubbleEdges.only(top: 10),
                          alignment: Alignment.topLeft,
                          nip: BubbleNip.leftBottom,
                          child: Text(messages[index].data, style: TextStyle(fontSize: 24.0)),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
          ],
        )
      )
    );
  }

    // Prefixing an identifier with an _ (underscore) makes it private to its class.
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              // This tells the Row to automatically size the text field to use the remaining space that isn't used by the button.
              Flexible(
                child: TextField(
                  controller: _textEditingController,
                  onSubmitted: _handleSubmitted,
                  onChanged: (String text) {
                    setState(() {
                      _isComposing = text.length > 0;
                    });
                  },
                  // The TextField and InputDecorator classes use InputDecoration objects to describe their decoration. The border, labels, icons, and styles used to decorate a Material Design text field.
                  decoration:
                      InputDecoration.collapsed(hintText: 'Send a message'),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(Icons.send, color: primaryColor, size: 36.0,),
                  onPressed: _isComposing ? () => _handleSubmitted(_textEditingController.text) : null,
                ),
              )
            ],
          )),
    );
  }

  void _handleSubmitted(String text) {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SpinKitDualRing(
            color: primaryColor,
            size: 48.0
          )
        );
      }
    );

    _textEditingController.clear();
    FocusScope.of(context).requestFocus(FocusNode());

    if(chatId == null) { 
      BlocProvider.of<DatabaseBloc>(context)
        .createChat(
          <String>[widget.otherUserId, myId],
          <String>[widget.otherUserName, BlocProvider.of<AuthenticationBloc>(context).currentUser.name],
          <Message>[Message(sender: myId, receiver: widget.otherUserId, timestamp: DateTime.now().millisecondsSinceEpoch.toString(), data: text)]
        )
        .then((data) {
          setState(() {
            Navigator.of(context).pop();
            chatId = data.id;
          });
        });
    }
    else {
      BlocProvider.of<DatabaseBloc>(context).addMessage(chatId, myId, widget.otherUserId, text)
        .then((data) {
          setState(() {
            Navigator.of(context).pop();
          });
        });
    }
  }

  @override
  void dispose() {
    super.dispose();       
  }
}