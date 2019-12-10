import 'package:chat_app/BLoC/authentication_bloc.dart';
import 'package:chat_app/BLoC/bloc_provider.dart';
import 'package:chat_app/BLoC/database_bloc.dart';
import 'package:chat_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math';

class Search extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () { query = ""; })];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: BlocProvider.of<DatabaseBloc>(context).filterUserAndChat(query, BlocProvider.of<AuthenticationBloc>(context).currentUserId),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitDualRing(color: primaryColor, size: 48.0);
        }
        else if(snapshot.connectionState == ConnectionState.done) 
        {
          return ListView.separated(
            itemCount: snapshot.data.length,
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
                    snapshot.data[index].name,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/Chat/' + snapshot.data[index].id + '/' + snapshot.data[index].name);
                  },
                ),
              );
            },
          );
        }

        return null;
      }, 
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