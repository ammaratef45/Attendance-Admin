import 'dart:convert';
class SessionModel {
  String key;
  String date;
  static String selected = "null";
  SessionModel(key, value) {
    this.key = key;
    Map<String, dynamic> map = json.decode(value);
    this.date = map["date"];
  }
}