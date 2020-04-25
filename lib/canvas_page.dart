import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/services.dart';

class CanvasPage extends StatefulWidget {
  CanvasPage({@required this.canvasImage});

  final io.File canvasImage;

  @override
  _CanvasPageState createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  @override
  Widget build(BuildContext context) {
    print("${widget.canvasImage.lengthSync() / 1000} kB");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Canvas Page',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Image.file(
          widget.canvasImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
