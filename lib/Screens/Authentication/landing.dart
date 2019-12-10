import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:chat_app/BLoC/authentication_bloc.dart';
import 'package:chat_app/BLoC/bloc_provider.dart';
import 'package:chat_app/utils/colors.dart';
import 'package:chat_app/utils/utils.dart';

class LandingPage extends StatelessWidget {

  final VoidCallback loginClickHandler;
  final VoidCallback signUpClickHandler;

  LandingPage({@required this.loginClickHandler, @required this.signUpClickHandler});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: primaryColor));

    final logo = Icon(
      Icons.chat_bubble,
      size: MediaQuery.of(context).size.width * 0.225,
      color: Colors.white,
    );

    final appName = Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.55,
          child: AutoSizeText(
            AppConfig.appName,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 48.0,
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.65,
          child: AutoSizeText(
            AppConfig.appTagline,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.0,
              fontWeight: FontWeight.w500
            ),
          ),
        )
      ],
    );

    final loginBtn = InkWell(
      onTap: () => loginClickHandler(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.085,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(color: Colors.white),
          color: Colors.transparent,
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.59 ,// * 0.15,
            child: AutoSizeText(
              'LOG IN WITH EMAIL',
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    final registerBtn = Container(
      height: MediaQuery.of(context).size.height * 0.085,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => signUpClickHandler(),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.59, // 0.185,
          child: AutoSizeText(
            'SIGN UP WITH EMAIL',
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    final googleSignInButton = Container(
      height: MediaQuery.of(context).size.height * 0.085,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: RaisedButton.icon(
        elevation: 5.0,
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(
                child: SpinKitDualRing(
                  color: Colors.white,
                  size: 48.0
                )
              );
            }
          );

          BlocProvider.of<AuthenticationBloc>(context).loginWithGoogle()
            .then((value) {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/home');
            });
        },
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        icon: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.085 * 0.25),
          child: Image.asset('assets/google.png')
        ),
        label: Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.59, 
            child: Center(child: AutoSizeText('LOG IN WITH GOOGLE', maxLines: 1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0)))
          )
        )
      )
    );

    final buttons = Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.10,
        left: 35.0,
        right: 35.0,
      ),
      child: Column(
        children: <Widget>[
          loginBtn, 
          SizedBox(height: 20.0), 
          registerBtn,
          SizedBox(height: 20.0),
          googleSignInButton
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.10),
            decoration: BoxDecoration(gradient: primaryGradient),
            child: Column(
              children: <Widget>[
                logo, 
                SizedBox(height: 12.0),
                appName, 
                buttons,
              ],
            ),        
          ),
        ],
      )
    );
  }
}