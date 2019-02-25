import './session_page_view_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/session_model.dart';
import '../model/class_model.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';
class SessionPageView extends SessionPageViewModel {
  static String uid;
  GlobalKey globalKey = new GlobalKey();
  String dataString = "";
  var url="";
  static SessionModel session;
  static SessionPageView thisInstance;
  static DatabaseReference classesReference;
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  DateTime date;
  SessionPageView() {
    thisInstance = this;
    final StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child(ClassModel.selected).child(SessionModel.selected +'.jpg');
    firebaseStorageRef.getDownloadURL().then((val){
      setState(() {
        url = val;
      });
    });
  }
  Widget buildBody(BuildContext ctxt, int index) {
    Widget result = new Center(
      child: new Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: new GestureDetector(
          onTap: (){
            
          },
          child: new Container(
            decoration: BoxDecoration(color: Colors.blue),
            alignment: Alignment(0, 0),
            child: Text(
              litems[index].name,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white
              ),
            ),
          ),
        ),
      ),
    );
    return result;
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
    return new Scaffold(
      appBar: new AppBar(
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  onPressed: loadAttendences,
                  child: Text("show attendance"),
                ),
                RaisedButton(
                  onPressed: shareCSV,
                  child: Text("save to csv"),
                )
              ],
            ),
            Flexible(
              child: ListView.builder(
                itemCount: litems.length,
                itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index)
              ),
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