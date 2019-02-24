import 'package:flutter/material.dart';
import './home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class HomePageViewModel extends State<HomePage> {
  final auth = FirebaseAuth.instance;
  void signOut() {
    auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

}
