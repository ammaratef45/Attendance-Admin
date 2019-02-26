import 'package:flutter/material.dart';
import './home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class HomePageViewModel extends State<HomePage> {
  final auth = FirebaseAuth.instance;
  FirebaseUser mUser;
  String mail = "";
  String imageUrl = "";
  String name = "";
  HomePageViewModel() {
    auth.currentUser().then((user) {
      mUser = user;
      setState(() {
        if(mUser.email!=null) mail = mUser.email;
        if(mUser.displayName!=null) name = mUser.displayName;
        if(mUser.photoUrl!=null) imageUrl = mUser.photoUrl;
      });
    });
  }
  void signOut() {
    auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

}
