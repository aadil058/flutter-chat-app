import 'package:chat_app/Datalayer/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_app/BLoC/bloc.dart';

class AuthenticationBloc implements Bloc {
  
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUserId;
  User currentUser;

  dynamic loginWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      AuthResult authResult = await _auth.signInWithCredential(credential);
      await Firestore.instance.collection('users')
        .document(authResult.user.uid)  
        .setData({
          'name': authResult.user.displayName,
          'email': authResult.user.email,
          'phone': null
        });

      currentUserId = authResult.user.uid;
      currentUser = User(id: currentUserId, name: authResult.user.displayName, email: authResult.user.email, phone: null);

      return 'Success';  
    } 
    catch(err) {
      print(err);
    }
  }

  dynamic logInWithEmail(String email, String password) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      currentUserId = authResult.user.uid;

      Firestore.instance.collection('users').document(currentUserId).get()
        .then((user) {
          currentUser = User(id: currentUserId, name: user.data['name'], email: user.data['email'], phone: user.data['phone']);
        });

      return 'Success';  
    }
    catch(err) {
      if(err.code == 'ERROR_USER_NOT_FOUND')
        return 'There is no user account corresponding to the given email address.';
      else if(err.code == 'ERROR_WRONG_PASSWORD')
        return 'Password is incorrect.';
      return err.message;
    }
  }

  dynamic signUpWithEmail(String name, String email, String password, String phone) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );

      await Firestore.instance.collection('users')
        .document(authResult.user.uid)  
        .setData({
          'name': name,
          'email': email,
          'phone': phone
        });

      currentUserId = authResult.user.uid;
      currentUser = User(id: currentUserId, name: name, email: email, phone: phone);

      return 'Success';  
    }
    catch(err) {
      return err.message;
    }
  }

  @override
  void dispose() {
  }
}
