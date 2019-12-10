import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat_app/Screens/Authentication/landing.dart';
import 'package:chat_app/Screens/Authentication/login.dart';
import 'package:chat_app/Screens/Authentication/register.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => new _AuthenticationScreenState();
}


class _AuthenticationScreenState extends State<AuthenticationScreen> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  Widget homePage() {
    return LandingPage(
      loginClickHandler: gotoLogin,
      signUpClickHandler: gotoSignup,
    );
  }


  Widget loginPage() {
    return LoginPage(
      createAccountClickHandler: gotoSignup,
    );
  }

  Widget signupPage() {
    return RegisterPage(
      alreadyHaveAnAccountClickHandler: gotoLogin,
    );
  }

  gotoLogin() {
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  gotoSignup() {
    _controller.animateToPage(
      2,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  gotoHome() {
    _controller.animateToPage(
      1,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  PageController _controller = PageController(initialPage: 1, viewportFraction: 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: PageView(
            controller: _controller,
            physics: AlwaysScrollableScrollPhysics(),
            children: <Widget>[loginPage(), homePage(), signupPage()],
            scrollDirection: Axis.horizontal,
          ),
        ),
        onWillPop: onWillPop
      )  
    );
  }

  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    int currentPage = _controller.page.toInt();

    if(currentPage == 1) {
      // Double press backbutton within 2 seconds to exit the app.
      DateTime now = DateTime.now();
      if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        Fluttertoast.showToast(msg: 'Press again to exit app.');
        return Future.value(false);
      }
      return Future.value(true);
    }
    else if(currentPage == 0) {
      gotoHome();
      return Future.value(false);
    }
    else {
      gotoHome();
      return Future.value(false);
    }

  }
}