
import 'package:bubble/bubble.dart';
import 'package:chat_app/BLoC/authentication_bloc.dart';
import 'package:chat_app/BLoC/bloc_provider.dart';
import 'package:chat_app/BLoC/database_bloc.dart';
import 'package:chat_app/Datalayer/Chat.dart';
import 'package:chat_app/Datalayer/Message.dart';
import 'package:chat_app/Datalayer/User.dart';
import 'package:chat_app/Screens/GroupSettings.dart';
import 'package:chat_app/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupChatId;
  GroupChatScreen(this.groupChatId);

  @override
  State<StatefulWidget> createState() {
    return _GroupChatScreenState();
  }
}

class _GroupChatScreenState extends State<GroupChatScreen> with TickerProviderStateMixin {

  final TextEditingController _textEditingController = TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Chat chat = BlocProvider.of<DatabaseBloc>(context).chats.firstWhere((c) => c.id == widget.groupChatId);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Text(chat.adminName + "'s Group", style: TextStyle(fontSize: 24.0),)
            ],
          ),
          actions: <Widget>[
            PopupMenuButton<String>(
                onSelected: choiceAction,
                itemBuilder: (BuildContext context){
                  return <String>['Add/Remove Users'].map((String choice){
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('chats')
                    .document(widget.groupChatId)
                    .snapshots(includeMetadataChanges: true),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Text('No Messages');

                  DocumentSnapshot docs = snapshot.data;
                  BlocProvider.of<DatabaseBloc>(context).addLocalMessage(docs);
                  List<Message> messages = BlocProvider.of<DatabaseBloc>(context).chatById(widget.groupChatId).messages;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      if(messages[index].sender == BlocProvider.of<AuthenticationBloc>(context).currentUserId) {
                        return Bubble(
                          margin: BubbleEdges.only(top: 10),
                          alignment: Alignment.topRight,
                          nip: BubbleNip.rightBottom,
                          color: Color.fromRGBO(225, 255, 199, 1.0),
                          child: Column(
                            children: <Widget>[
                              Text('Me', style: TextStyle(fontSize: 16.0)),
                              SizedBox(height: 8.0),
                              Text(messages[index].data, textAlign: TextAlign.right, style: TextStyle(fontSize: 24.0)),
                            ],
                          ) 
                        );
                      }
                      else {
                        return Bubble(
                          margin: BubbleEdges.only(top: 10),
                          alignment: Alignment.topLeft,
                          nip: BubbleNip.leftBottom,
                          child: Column(
                            children: <Widget>[
                              Text(senderName(messages[index].sender), style: TextStyle(fontSize: 16.0)),
                              SizedBox(height: 8.0),
                              Text(messages[index].data, style: TextStyle(fontSize: 24.0)),
                            ],
                          ) 
                        );
                      }
                    },
                  );
                },
              )
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

  void choiceAction(String choice){
    if(choice == 'Add/Remove Users') {
      Chat chat = BlocProvider.of<DatabaseBloc>(context).chats.firstWhere((c) => c.id == widget.groupChatId);
      if(chat.adminId != BlocProvider.of<AuthenticationBloc>(context).currentUserId) {
        FlushbarHelper.createError(
          message: 'You are not the admin of this group. Only an admin can add or remove users.',
          duration: Duration(seconds: 6),
          title: 'Error'
        )..show(context);
      }
      else {
        editGroupHandler(context);
      }
    }
  }

  String senderName(String senderId) {
    Chat chat = BlocProvider.of<DatabaseBloc>(context).chatById(widget.groupChatId);
    int index = chat.participants.indexOf(senderId);
    return chat.names[index];
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

    String myId = BlocProvider.of<AuthenticationBloc>(context).currentUserId;
    BlocProvider.of<DatabaseBloc>(context).addMessage(widget.groupChatId, myId, 'All', text)
      .then((_) {
        setState(() {
          Navigator.of(context).pop();
        });
      });
  }

  @override
  void dispose() {
    super.dispose();       
  }

  void editGroupHandler(BuildContext context) async {
    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: BlocProvider.of<DatabaseBloc>(context).searchUsers(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> users) {
            if(users.connectionState == ConnectionState.waiting || users.connectionState == ConnectionState.none) {
              return SpinKitDualRing(
                color: primaryColor,
                size: 48.0
              );
            }

            List<User> copy = List<User>.from(BlocProvider.of<DatabaseBloc>(context).users);
            copy.removeWhere((user) => user.id == BlocProvider.of<AuthenticationBloc>(context).currentUserId);

            Chat chat = BlocProvider.of<DatabaseBloc>(context).chats.firstWhere((c) => c.id == widget.groupChatId);
            Set<int> alreadySelected = Set<int>();
            for(int i = 0; i < chat.participants.length; ++i) {
              int index = copy.indexWhere((u) => u.id == chat.participants[i]);
              if(index != -1)
                alreadySelected.add(index);
            }

            List<MultiSelectDialogItem<int>> items = List<MultiSelectDialogItem<int>>();
            for(int i = 0; i < copy.length; ++i) {
              items.add(MultiSelectDialogItem(i, copy[i].name, copy[i].id));
            }

            return MultiSelectDialog(
              items: items,
              initialSelectedValues: alreadySelected,
            );
          },
        );
      },
    );

    if(selectedValues != null) {
      print(selectedValues);
      
      List<User> copy = List<User>.from(BlocProvider.of<DatabaseBloc>(context).users);
      copy.removeWhere((user) => user.id == BlocProvider.of<AuthenticationBloc>(context).currentUserId);

      List<String> participants = List<String>();
      List<String> names = List<String>();
      String adminId;
      String adminName;
      List<Message> messages = List<Message>();

      adminId = BlocProvider.of<AuthenticationBloc>(context).currentUserId;
      adminName = BlocProvider.of<AuthenticationBloc>(context).currentUser.name;
      participants.add(adminId);
      names.add(adminName);

      selectedValues.forEach((i) {
        participants.add(copy[i].id);
        names.add(copy[i].name);
      });

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

      BlocProvider.of<DatabaseBloc>(context).editGroup(widget.groupChatId, participants, names)
        .then((_) {
          setState(() {
            Navigator.of(context).pop();
          });
        });
    }
  }
}