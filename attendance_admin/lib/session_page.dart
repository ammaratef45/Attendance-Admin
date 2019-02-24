import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './model/session_model.dart';
import './model/class_model.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_view/photo_view.dart';

class SessionPage extends StatefulWidget {
  SessionPage({Key key}) : super(key: key);

  @override
  SessionPageState createState() => new SessionPageState();
}

class SessionPageState extends State<SessionPage> {
  static String uid;
  GlobalKey globalKey = new GlobalKey();
  String dataString = "";
  var url="";
  static SessionModel session;
  static SessionPageState thisInstance;
  static DatabaseReference classesReference;
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  //final timeFormat = DateFormat("h:mm a");
  DateTime date;
  //TimeOfDay time;
  SessionPageState() {
    thisInstance = this;
    final StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child(ClassModel.selected).child(SessionModel.selected +'.jpg');
    firebaseStorageRef.getDownloadURL().then((val){
      setState(() {
        url = val;
      });
    });
  }
  Future<void> captureAndSharePng() async {
    try {
      
      var cacheManager =  await CacheManager.getInstance();
      final file =  await cacheManager.getFile(url);
      debugPrint(file.path);
      final channel = const MethodChannel('channel:me.ammar.share/share');
      channel.invokeMethod('shareFile', 'image.png');

    } catch(e) {
      print(e.toString());
    }
  }
  Future<FirebaseUser> auth = FirebaseAuth.instance.currentUser().then((user){
    uid = user.uid;
    classesReference = FirebaseDatabase.instance.reference().child(uid).child("classes").child(ClassModel.selected).
      child("sessions").child(SessionModel.selected);
    classesReference.onValue.listen((Event e) {
      thisInstance.setState((){
        thisInstance.dataString = e.snapshot.value["qrval"];
        session = SessionModel(e.snapshot.key, e.snapshot.value["qrval"]);
      });
    });
  });
  
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text("session"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("\nDate: " + session.date),
            Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            height: 300.0,
            child: PhotoView(
                imageProvider: NetworkImage(url),
                backgroundDecoration: BoxDecoration(color: Colors.white),
              )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: captureAndSharePng,
        tooltip: 'Share QR',
        child: Icon(Icons.share),
        elevation: 2.0,
      ),
    );
  }
}