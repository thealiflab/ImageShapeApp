import 'package:flutter/material.dart';
import 'dart:io' as io;

//constants
const buttonTextStyle = TextStyle(
  color: Colors.white,
);

class ImagePage extends StatefulWidget {
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  io.File image;

  getImageFile() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insert',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: image == null
            ? Text(
                'Insert an image',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                ),
              )
            : Image.file(
                image,
                width: 300,
                height: 300,
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 25,
            ),
            FloatingActionButton.extended(
              onPressed: () {},
              label: Text(
                'Open Camera',
                style: buttonTextStyle,
              ),
              icon: Icon(
                Icons.camera,
                color: Colors.white,
              ),
              heroTag: UniqueKey(),
            ),
            SizedBox(
              width: 15,
            ),
            FloatingActionButton.extended(
              onPressed: () {},
              label: Text(
                'Open Gallery',
                style: buttonTextStyle,
              ),
              icon: Icon(
                Icons.photo_library,
                color: Colors.white,
              ),
              heroTag: UniqueKey(),
            ),
          ],
        ),
      ),
    );
  }
}
