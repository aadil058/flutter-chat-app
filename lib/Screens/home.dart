
import 'dart:io';
import 'dart:math';
import 'package:chat_app/BLoC/authentication_bloc.dart';
import 'package:chat_app/BLoC/bloc_provider.dart';
import 'package:chat_app/BLoC/database_bloc.dart';
import 'package:chat_app/Datalayer/Chat.dart';
import 'package:chat_app/Datalayer/Message.dart';
import 'package:chat_app/Datalayer/User.dart';
import 'package:chat_app/Helpers/search.dart';
import 'package:chat_app/Screens/GroupSettings.dart';
import 'package:chat_app/Screens/UsersDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:chat_app/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  
  DateTime currentBackPressTime;
  bool isFetchingChats = true;

  @override
  void initState() {
    super.initState();

    checkInternetAccess()
      .then((bool isInternetAvailable) {
        if(isInternetAvailable == false) {
          Future.delayed(
            Duration(milliseconds: 500),
            () {
              showDialog(
                context: context,builder: (_) => AssetGiffyDialog(
                  image: Image.asset('assets/images/nointernetresize.gif'),
                  title: Text('Not Connected to Internet', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
                  description: Text('It is highly recommended that you connect to the internet to access all services.', textAlign: TextAlign.center, style: TextStyle()),
                  entryAnimation: EntryAnimation.BOTTOM,
                  onOkButtonPressed: () => Navigator.of(context).pop(),
                  onlyOkButton: true,
                  buttonOkColor: primaryColor,
                ),
              );
            }
          );
        }
      });

      BlocProvider.of<DatabaseBloc>(context).getChats(BlocProvider.of<AuthenticationBloc>(context).currentUserId)
        .then((_) => setState(() {
          isFetchingChats = false;
        }));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if(isFetchingChats == false) {
      isFetchingChats = true;
      BlocProvider.of<DatabaseBloc>(context).getChats(BlocProvider.of<AuthenticationBloc>(context).currentUser.id)
          .then((_) => setState(() {
            isFetchingChats = false;
          }));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('Connected to Internet');
        return true;
      }
    } 
    on SocketException catch (_) {
      print('Not Connected to Internet');
      return false;
    }

    return false;
  }

  String getOtherUserName(List<String> names) {
    List<String> copy = List<String>.from(names);
    copy.remove(BlocProvider.of<AuthenticationBloc>(context).currentUser.name);
    return copy[0];
  }

  String getOtherUserId(List<String> ids) {
    List<String> copy = List<String>.from(ids);
    copy.remove(BlocProvider.of<AuthenticationBloc>(context).currentUserId);
    return copy[0];
  }

  @override
  Widget build(BuildContext context) {
    List<Chat> myChats = BlocProvider.of<DatabaseBloc>(context).chats.where((chat) => chat.participants.contains(BlocProvider.of<AuthenticationBloc>(context).currentUserId)).toList();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
          title: Text("ChatApp", style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w600)),
          actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: Search());
                  },
                ),
              ),
              PopupMenuButton<String>(
                onSelected: choiceAction,
                itemBuilder: (BuildContext context){
                  return <String>['Create Group', 'All Users', 'Sign Out'].map((String choice){
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              )
            ],
            backgroundColor: primaryColor,
          ),
          body: WillPopScope(
            onWillPop: onWillPop,
            child: isFetchingChats == true 
            ? Center(
              child: SpinKitDualRing(
                color: primaryColor,
                size: 48.0
              )
            )
            : ListView.separated(
            itemCount: myChats.length,
            separatorBuilder: (BuildContext context, int index) => buildDivider(),
            itemBuilder: (BuildContext context, int index) {
              var randomizer = Random(DateTime.now().millisecondsSinceEpoch);
              int random = randomizer.nextInt(3) + 1;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26.0,
                    backgroundImage: AssetImage('assets/man' + random.toString() + '.png'),
                  ),
                  title: Text(
                    myChats[index].adminName != null ? myChats[index].adminName + "'s Group"  : getOtherUserName(myChats[index].names),
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: myChats[index].messages.length == 0 ? Text('No messages yet.', style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    )) : Text(
                    myChats[index].messages.last.data.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    if(myChats[index].adminId == null)
                      Navigator.of(context).pushNamed('/Chat/' + getOtherUserId(myChats[index].participants) + '/' + getOtherUserName(myChats[index].names));
                    else
                      Navigator.of(context).pushNamed('/GroupChat/' + myChats[index].id);
                  },
                ),
              );
            },
          ),
          ),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Divider(
      height: 0.0,
      color: Colors.black38,
      indent: 10.0,
      endIndent: 10.0,
    );
  }

  void choiceAction(String choice){
    if(choice == 'Create Group')
      createGroupHandler(context);
    else if(choice == 'Sign Out') {
      FirebaseAuth.instance.signOut()
        .then((_) {
          Navigator.of(context).pushReplacementNamed('/authentication');
        });
    }
    else if(choice == 'All Users') {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return UsersDialog();
        }
      );
    }
  }

  void createGroupHandler(BuildContext context) async {
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

            List<MultiSelectDialogItem<int>> items = List<MultiSelectDialogItem<int>>();
            for(int i = 0; i < copy.length; ++i) {
              items.add(MultiSelectDialogItem(i, copy[i].name, copy[i].id));
            }

            return MultiSelectDialog(
              items: items,
            );
          },
        );
      },
    );

    if(selectedValues != null) {
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

      BlocProvider.of<DatabaseBloc>(context).createGroup(participants, names, adminId, adminName, messages)
        .then((chat) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/GroupChat/' + chat.id);
        });
    }
  }
 

  Future<bool> onWillPop() {
    // Double press backbutton within 2 seconds to exit the app.
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Press again to exit app.');
      return Future.value(false);
    }
    return Future.value(true);
  }
}
