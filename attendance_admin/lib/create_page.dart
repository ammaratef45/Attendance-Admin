import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './model/session_model.dart';
import './model/class_model.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_places_picker/google_places_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreatePage extends StatefulWidget {
  CreatePage({Key key}) : super(key: key);

  @override
  CreatePageState createState() => new CreatePageState();
}

class CreatePageState extends State<CreatePage> {
  static String uid;
  GlobalKey globalKey = new GlobalKey();
  Map<String, dynamic> dataMap = {};
  String dataString="";
  Map<String, dynamic> qrMap = {};
  String qrString = "";
  Place place;
  static CreatePageState thisInstance;
  static DatabaseReference classesReference;
  List<SessionModel> litems = [];
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  //final timeFormat = DateFormat("h:mm a");
  DateTime date;
  //TimeOfDay time;
  CreatePageState() {
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
    thisInstance.qrMap["admin"] = uid;
    classesReference = FirebaseDatabase.instance.reference().child(uid).child("classes").child(ClassModel.selected).child("sessions");
    classesReference.onChildAdded.listen((Event e) {
      thisInstance.setState((){
        thisInstance.litems.add(SessionModel(e.snapshot.key, e.snapshot.value));
      });
    });
  });
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("new session"),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new DateTimePickerFormField(
              format: dateFormat,
              decoration: InputDecoration(labelText: 'Date'),
              onChanged: (dt) {
                setState(() {
                  date = dt;
                  dataMap["classkey"] = ClassModel.selected;
                  dataMap["date"] = dateFormat.format(date);
                  qrMap["classkey"] = ClassModel.selected;
                  qrString = json.encode(qrMap);
                  dataString  = json.encode(dataMap);
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(place==null?"Place?":place.name),
                RaisedButton(
                  child: new Text("Location"),
                  onPressed: (){
                    PluginGooglePlacePicker.showPlacePicker().then((p){
                      setState(() {
                        place = p;
                      });
                    });
                  },
                  color: Colors.green,
                ),
              ],
            ),
            Expanded(
              child:  Center(
                child: RepaintBoundary(
                  key: globalKey,
                  child: QrImage(
                    version: 6,
                    data: qrString,
                    onError: (ex) {
                      debugPrint("[QR] ERROR - $ex");
                    },
                  ),
                ),
              ),
            ),
            RaisedButton(
              child: new Text("Submit"),
              onPressed: (){
                if(place==null || dataString=="") {
                  Fluttertoast.showToast(
                    msg: "Set location and time",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white
                  );
                  return;
                }
                DatabaseReference rs = classesReference.push();
                setState(() {
                  dataMap["myKey"] = rs.key;
                  qrMap["myKey"] = rs.key;
                  dataMap["address"] = place.address;
                  dataMap["placeName"] = place.name;
                  dataMap["lat"] = place.latitude;
                  dataMap["long"] = place.longitude;
                  dataString  = json.encode(dataMap);
                  qrString = json.encode(qrMap);
                });
                rs.set({"qrval":dataString}).then((_){
                  captureAndSharePng(dataMap["myKey"]).then((_){
                    Navigator.of(context).pop();
                  });
                });
              },
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}