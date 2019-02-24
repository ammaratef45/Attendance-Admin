import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './model/session_model.dart';
import './model/class_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ClassPage extends StatefulWidget {
  ClassPage({Key key}) : super(key: key);

  @override
  ClassPageState createState() => new ClassPageState();
}

class ClassPageState extends State<ClassPage> {
  static String uid;
  GlobalKey globalKey = new GlobalKey();
  Map<String, dynamic> dataMap = {};
  String dataString="";
  String qrString = "";
  static ClassPageState thisInstance;
  static DatabaseReference classesReference;
  List<SessionModel> litems = [];
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  //final timeFormat = DateFormat("h:mm a");
  DateTime date;
  //TimeOfDay time;
  ClassPageState() {
    thisInstance = this;
  }
  Future<void> captureAndSharePng(String val) async {
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);
      final StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child(ClassModel.selected).child(val +'.jpg');
      firebaseStorageRef.putFile(file);

    } catch(e) {
      print(e.toString());
    }
  }
  Future<FirebaseUser> auth = FirebaseAuth.instance.currentUser().then((user){
    uid = user.uid;
    classesReference = FirebaseDatabase.instance.reference().child(uid).child("classes").child(ClassModel.selected).child("sessions");
    classesReference.onChildAdded.listen((Event e) {
      thisInstance.setState((){
        thisInstance.litems.add(SessionModel(e.snapshot.key, e.snapshot.value["qrval"]));
      });
    });
  });
  
  Widget buildBody(BuildContext ctxt, int index) {
    Widget result = new Center(
      child: new Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: new GestureDetector(
          onTap: (){
            SessionModel.selected = litems[index].key;
            Navigator.of(context).pushNamed('/session');
          },
          child: new Container(
            decoration: BoxDecoration(color: Colors.blue),
            alignment: Alignment(0, 0),
            child: Text(
              litems[index].date,
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Sessions"),
      ),
      body: new ListView.builder(
        itemCount: litems.length,
        itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index)
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/sessionadd');
        }
          /*_showDialog*/,
        tooltip: 'Add Session',
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
    );
  }
}