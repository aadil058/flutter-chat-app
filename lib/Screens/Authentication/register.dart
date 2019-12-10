import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:chat_app/BLoC/authentication_bloc.dart';
import 'package:chat_app/BLoC/bloc_provider.dart';
import 'package:chat_app/utils/colors.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback alreadyHaveAnAccountClickHandler;

  RegisterPage({@required this.alreadyHaveAnAccountClickHandler});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String name;
  String email;
  String phone;
  String password;

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

    final pageTitle = Container(
      width: MediaQuery.of(context).size.width * 0.74,
      child: AutoSizeText("Tell us about you.", maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 40.0)),
    );

    final formFieldSpacing = SizedBox(height: MediaQuery.of(context).size.height * 0.020);

    final registerForm = Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04),
      child: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(
          children: <Widget>[
            _buildFormField('Name', LineIcons.user),
            formFieldSpacing,
            _buildFormField('Email Address', LineIcons.envelope),
            formFieldSpacing,
            _buildFormField('Phone Number', LineIcons.mobile_phone),
            formFieldSpacing,
            _buildFormField('Password', LineIcons.lock),
            formFieldSpacing,
          ],
        ),
      ),
    );

    final submitBtn = Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.025),
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.white),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(7.0),
        color: primaryColor,
        elevation: 10.0,
        shadowColor: Colors.white70,
        child: MaterialButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
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
                    BlocProvider.of<AuthenticationBloc>(context).signUpWithEmail(name, email, password, phone)
                      .then((dynamic message) {
                        if(message.toString() == 'Success') {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                        else {
                          Navigator.of(context).pop();
                          FlushbarHelper.createError(
                            message: message.toString(),
                            duration: Duration(seconds: 6),
                            title: 'SIGN UP ERROR'
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
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.44,
            child: AutoSizeText('CREATE ACCOUNT', maxLines: 1, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, color: Colors.white)),
          ),
        ),
      ),
    );
 
    final existingUser = Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.80,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04),
        child: InkWell(
          onTap: () => widget.alreadyHaveAnAccountClickHandler(), // => Navigator.pushNamed(context, registerViewRoute),
          child: AutoSizeText.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(text: 'Already have an account?', style: TextStyle(color: Colors.black54, fontSize: 18.0, fontWeight: FontWeight.w600)),
                TextSpan(text: ' Log in', style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w600)),
              ]
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.10, left: 30.0, right: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              pageTitle,
              registerForm,
              submitBtn,
              existingUser
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, IconData icon) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(
          icon,
          color: Colors.black38,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black38),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
      keyboardType: getKeyboardType(icon),
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      obscureText: (icon == LineIcons.lock),
      validator: (value) => validator(icon, value),
    );
  }

  TextInputType getKeyboardType(IconData icon) {
    if(icon == LineIcons.lock || icon == LineIcons.user)
      return TextInputType.text;
    else if(icon == LineIcons.envelope)
      return TextInputType.emailAddress;
    else if(icon == LineIcons.mobile_phone)
      return TextInputType.phone;
    return TextInputType.text;
  }

  String validator(IconData icon, String value) {
    if(value.isEmpty)
      return 'This field cannot be empty.';

    if(icon == LineIcons.lock) {
      if(value.length < 8)
        return 'Password should be at least 8 characters long.';
      password = value;
    }
    else if(icon == LineIcons.user) {
      if(value.length < 3)
        return 'Name should be at least 3 characters long.';
      name = value;
    }
    else if(icon == LineIcons.envelope) {
      String pattern = r'''(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])''';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value))
        return 'Please enter valid email address.';
      email = value;
    }
    else if(icon == LineIcons.mobile_phone) {
      String pattern = r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value))
        return 'Please enter valid mobile number.';
      phone = value;
    }

    return null;
  }
}