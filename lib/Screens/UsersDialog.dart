import 'dart:math';

import 'package:chat_app/BLoC/authentication_bloc.dart';
import 'package:chat_app/BLoC/bloc_provider.dart';
import 'package:chat_app/BLoC/database_bloc.dart';
import 'package:chat_app/Datalayer/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UsersDialog extends StatefulWidget {

  @override
  _UsersDialogState createState() => _UsersDialogState();
}

class _UsersDialogState extends State<UsersDialog> {
 
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: 12.0),
      title: Text('All Users'),
      content: Container(
        width: width * 0.95,
        height: height * 0.60,
        child: FutureBuilder(
          future: BlocProvider.of<DatabaseBloc>(context).searchUsers(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> users) {
            if(users.connectionState == ConnectionState.waiting || users.connectionState == ConnectionState.none) {
              return SpinKitDualRing(
                color: Colors.white,
                size: 48.0
              );
            }

            return ListView.separated(
              itemCount: BlocProvider.of<DatabaseBloc>(context).users.length - 1,
              separatorBuilder: (BuildContext context, int index) => buildDivider(),
              itemBuilder: (BuildContext context, int index) {
                List<User> copy = List<User>.from(BlocProvider.of<DatabaseBloc>(context).users);
                copy.removeWhere((user) => user.id == BlocProvider.of<AuthenticationBloc>(context).currentUserId);

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
                      copy[index].name,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/Chat/' + copy[index].id + '/' + copy[index].name);
                    },
                  ),
                );
              },
            );
          },
        )
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
}