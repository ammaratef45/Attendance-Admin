import 'package:flutter/material.dart';
import './login_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';


abstract class LoginPageViewModel extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  LoginPageViewModel() {
    auth.currentUser().then((user){
      if(user !=null) {
        handleUser(user);
      }
    });
  }

  Future<FirebaseUser> signInUser() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    FirebaseUser firebaseUser = await auth.signInWithGoogle(idToken: googleSignInAuthentication.idToken,
     accessToken: googleSignInAuthentication.accessToken);
     return firebaseUser;
  }
  void handleUser(FirebaseUser user) {
    if(user == null) {
      Fluttertoast.showToast(
          msg: "Failed to login",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void signIn() {
    signInUser().then((FirebaseUser user)=>handleUser(user));
  }
}