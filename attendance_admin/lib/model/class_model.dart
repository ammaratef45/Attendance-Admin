class ClassModel {
  String key;
  String name;
  static String selected = "null";
  ClassModel(key, value) {
    this.key = key;
    this.name = value["name"];
  }
}