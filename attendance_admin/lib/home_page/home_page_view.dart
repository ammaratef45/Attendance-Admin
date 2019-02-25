import 'package:flutter/material.dart';
import './home_page_view_model.dart';
import 'package:firebase_database/firebase_database.dart';
import '../model/class_model.dart';

class HomePageView extends HomePageViewModel {
  static String uid;
  static HomePageView thisInstance;
  static DatabaseReference classesReference;
  static List<ClassModel> litems = [];
  HomePageView() {
    thisInstance = this;
    auth.currentUser().then((user){
      uid = user.uid;
      classesReference = FirebaseDatabase.instance.reference().child(uid).child("classes");
      classesReference.onChildAdded.listen((Event e) {
        thisInstance.setState((){
          litems.add(ClassModel(e.snapshot.key, e.snapshot.value));
        });
      });
    });
  }
  void _showDialog() {
    TextEditingController nameController = new TextEditingController();
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Add new class"),
          content: new Container(
            width: 60.0,
            height: 230.0,
            child: new Column(
              children: <Widget>[
                new TextField(
                  controller: nameController,
                  obscureText: false,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: 'Class name',
                    hintStyle: TextStyle(color: Colors.grey),
                  )
                )
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Okay"),
              onPressed: () {
                classesReference.push().set({
                  'name':nameController.text
                }).then((val){
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
  Widget buildBody(BuildContext ctxt, int index) {
    Widget result = new Center(
      child: new Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: new GestureDetector(
          onTap: (){
            ClassModel.selected = litems[index].key;
            Navigator.of(context).pushNamed('/class');
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Classes"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: <Widget>[
                  new Image.network(
                    mUser.photoUrl,
                    width: 100.0,
                    height: 100.0,
                  ),
                  new Text(mUser.displayName),
                  new Text(mUser.email),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                signOut();
              },
            ),
          ],
        ),
      ),
      body: new ListView.builder(
        itemCount: litems.length,
        itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index)
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        tooltip: 'Add Class',
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
    );
  }
}