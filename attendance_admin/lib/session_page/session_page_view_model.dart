import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import './session_page.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../model/user_attended_model.dart';
import '../model/session_model.dart';

abstract class SessionPageViewModel extends State<SessionPage> {
  List<UserAttendanceModel> litems = [];

  Future<void> loadAttendences() async {
    litems.clear();
    DataSnapshot atUsers = await FirebaseDatabase.instance.reference().child("attendances").once();
    Map<dynamic, dynamic> values=atUsers.value;
    for (MapEntry entry in values.entries) {
      if(entry.value["session"] == SessionModel.selected) {
        var nameSnap = await FirebaseDatabase.instance.reference().child(entry.value["user"]).once();
        var name = nameSnap.value["name"];
        setState(() {
          litems.add(UserAttendanceModel(entry.value["user"], name));
        });
      }
    }
  }

  void shareCSV() async {
    await loadAttendences();
    final tempDir = await getTemporaryDirectory();
    final file = await new File('${tempDir.path}/attendance.csv').create();
    file.writeAsString("#, Name, email, phone\n");
    var counter = 0;
    for(var item in litems) {
      counter++;
      debugPrint(item.key);
      DataSnapshot user = await FirebaseDatabase.instance.reference().child(item.key).once();
      file.writeAsString("$counter, ${user.value["name"]}, ${user.value["mail"]}, ${user.value["phone"]}\n",
        mode: FileMode.append);
    }
    final channel = const MethodChannel('channel:me.ammar.share/share');
    channel.invokeMethod('shareCSV', 'attendance.csv');
  }
 
}