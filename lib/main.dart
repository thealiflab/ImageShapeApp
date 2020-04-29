import 'package:flutter/material.dart';
import 'canvas_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Shape App',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: CanvasPage(),
    );
  }
}
