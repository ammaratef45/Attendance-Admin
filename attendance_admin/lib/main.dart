import 'package:flutter/material.dart';
import './login_page/login_page.dart';
import './home_page/home_page.dart';
import './class_page.dart';
import './session_page.dart';
import './create_page.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final Widget myHome = LoginPage();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Attendance Admin',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: myHome,
      routes: <String, WidgetBuilder>{
        // Set routes for using the Navigator.
        '/class': (BuildContext context) => new ClassPage(),
        '/home': (BuildContext context) => new HomePage(),
        '/session': (BuildContext context) => new SessionPage(),
        '/login': (BuildContext context) => new LoginPage(),
        '/sessionadd': (BuildContext context) => new CreatePage(),
        
      },
    );
  }
}
