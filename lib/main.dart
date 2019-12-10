import 'package:chat_app/BLoC/database_bloc.dart';
import 'package:chat_app/Datalayer/User.dart';
import 'package:chat_app/Screens/ChatScreen.dart';
import 'package:chat_app/Screens/GroupChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:chat_app/BLoC/authentication_bloc.dart';
import 'package:chat_app/BLoC/bloc_provider.dart';
import 'package:chat_app/Screens/Authentication/authentication_main.dart';
import 'package:chat_app/Screens/home.dart';
import 'package:chat_app/utils/colors.dart';
import 'package:chat_app/utils/utils.dart';

void main(List<String> args) {
  // debugPaintSizeEnabled = true;
  runApp(Main());
}

class Main extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainState();
  }
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {

    final baseTheme = ThemeData(fontFamily: AvailableFonts.primaryFont);

    final theme = baseTheme.copyWith(
      primaryColor: primaryColor,
      primaryColorDark: primaryDark,
      primaryColorLight: primaryLight,
      accentColor: secondaryColor,
    );

    return BlocProvider(
      bloc: AuthenticationBloc(),
      child: BlocProvider(
        bloc: DatabaseBloc(),
        child: MaterialApp(
          theme: theme,
          debugShowCheckedModeBanner: false,
          title: 'Chat App',
          home: FutureBuilder(
            future: FirebaseAuth.instance.currentUser().then((data) => Firestore.instance.collection('users').document(data.uid).get()),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return SpinKitDualRing(
                  color: Colors.white,
                  size: 48.0
                );
              }
              else {
                if(snapshot.data != null) {
                  BlocProvider.of<AuthenticationBloc>(context).currentUserId = snapshot.data.documentID;
                  BlocProvider.of<AuthenticationBloc>(context).currentUser = User(id: snapshot.data.documentID.toString(), name: snapshot.data['name'].toString(), email: snapshot.data['email'].toString(), phone: snapshot.data['phone'].toString());
                  return HomeScreen();
                }
                else
                  return AuthenticationScreen();
              }
            },
          ),
          
          onGenerateRoute: (RouteSettings settings) {
            final List<String> pathElements = settings.name.split('/'); 
            if(pathElements[1] == 'home')
              return MaterialPageRoute<bool>(builder: (BuildContext context) => HomeScreen());
            else if(pathElements[1] == 'authentication')
              return MaterialPageRoute<bool>(builder: (BuildContext context) => AuthenticationScreen());
            else if(pathElements[1] == 'Chat')
              return MaterialPageRoute<bool>(builder: (BuildContext context) => ChatScreen(pathElements[2], pathElements[3]));
            else if(pathElements[1] == 'GroupChat')
              return MaterialPageRoute<bool>(builder: (BuildContext context) => GroupChatScreen(pathElements[2]));
            return null;
          }
        ),
      ),
    );
  }
}