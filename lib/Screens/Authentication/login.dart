import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:chat_app/BLoC/authentication_bloc.dart';
import 'package:chat_app/BLoC/bloc_provider.dart';
import 'package:chat_app/utils/colors.dart';

class LoginPage extends StatefulWidget {
  // final VoidCallback loginClickHandler;
  final VoidCallback createAccountClickHandler;

  // LoginPage({this.loginClickHandler, this.createAccountClickHandler});
  LoginPage({@required this.createAccountClickHandler});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String password;
  bool _autoValidate = false;

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

  @override
  Widget build(BuildContext context) {
    // Change Status Bar Color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: primaryColor));

    final pageTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.33,
          child: AutoSizeText("Log In.", maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 64.0)),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.407,
          child: AutoSizeText("We missed you!", maxLines: 1, style: TextStyle(color: Colors.white, fontSize: 36.0, fontWeight: FontWeight.w500)),
        )
      ],
    );

    final emailField = TextFormField(
      decoration: InputDecoration(
        labelText: 'Email Address',
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(LineIcons.envelope, color: Colors.white),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        errorStyle: TextStyle(color: Colors.white),
      ),
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      validator: (value) {
        if(value.isEmpty)
          return 'This field cannot be empty.';
        String pattern = r'''(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])''';
        RegExp regExp = new RegExp(pattern);
        if (!regExp.hasMatch(value))
          return 'Please enter valid email address.';
        email = value;
        return null;
      },
    );

    final passwordField = TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(LineIcons.lock, color: Colors.white),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        errorStyle: TextStyle(color: Colors.white),
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      obscureText: true,
      validator: (value) {
        if(value.isEmpty)
          return 'This field cannot be empty.';
        if(value.length < 8)
          return 'Password should be at least 8 characters long.';
        password = value;
        return null;        
      },
    );

    final loginForm = Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.105),
      child: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(
          children: <Widget>[
            emailField, 
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            passwordField
          ],
        ),
      ),
    );

    final loginBtn = Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.065),
      height: MediaQuery.of(context).size.height * 0.085,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          if(_formKey.currentState.validate()) {
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

            checkInternetAccess()
              .then((bool isInternetAvailable) {
                if(isInternetAvailable) {
                  BlocProvider.of<AuthenticationBloc>(context).logInWithEmail(email, password)
                    .then((dynamic message) {
                      if(message.toString() == 'Success') {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacementNamed('/home');
                        // FlushbarHelper.createSuccess(
                        //   message: "Account created successfully.",
                        //   duration: Duration(seconds: 6),
                        //   title: 'SIGN UP SUCCESS'
                        // )..show(context);
                      }
                      else {
                        Navigator.of(context).pop();
                        FlushbarHelper.createError(
                          message: message.toString(),
                          duration: Duration(seconds: 6),
                          title: 'LOG IN ERROR'
                        )..show(context);
                      }
                    });
                }
                else {
                  Navigator.of(context).pop();
                  FlushbarHelper.createError(
                    message: 'Please check your internet connection and try again.',
                    duration: Duration(seconds: 6),
                    title: 'INTERNET ERROR'
                  )..show(context);
                }
              });
          }
          else {
            setState(() {
              _autoValidate = true;
            });
          }
        }, // => Navigator.pushNamed(context, homeViewRoute),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(7.0)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.185,
          child: AutoSizeText('SIGN IN', maxLines: 1, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
        ),
      ),
    );

    final newUser = Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: InkWell(
        onTap: () => widget.createAccountClickHandler(), // => Navigator.pushNamed(context, registerViewRoute),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('New User?', style: TextStyle(color: Colors.white70, fontSize: 18.0, fontWeight: FontWeight.w600)),
            Text(' Create account', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.16, left: 30.0, right: 30.0),
          decoration: BoxDecoration(gradient: primaryGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              pageTitle,
              loginForm,
              loginBtn,
              newUser
            ],
          ),
        ),
      ),
    );
  }
}