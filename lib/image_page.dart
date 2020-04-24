import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

//constants
const buttonTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w900,
);

class ImagePage extends StatefulWidget {
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  io.File image;
  io.File croppedImage;

  getImageFile(ImageSource source) async {
    var getImage = await ImagePicker.pickImage(source: source);
    croppedImage = await ImageCropper.cropImage(
        sourcePath: getImage.path,
        aspectRatioPresets: io.Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Image Edit',
            toolbarColor: Colors.cyan,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Edit',
        ));

    setState(() {
      image = croppedImage;
      if (image != null) {
        print("${image.lengthSync() / 1000} kB");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ImageShape App',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            image != null
                ? Padding(
                    padding: const EdgeInsets.only(
                      bottom: 25.0,
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () {},
                      label: Text(
                        'Insert Shapes to the Image',
                        style: buttonTextStyle,
                      ),
                      icon: Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white,
                      ),
                      heroTag: UniqueKey(),
                    ),
                  )
                : SizedBox(),
            Center(
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
                      fit: BoxFit.cover,
                    ),
            ),
          ],
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
              onPressed: () {
                getImageFile(ImageSource.camera);
              },
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
              onPressed: () {
                getImageFile(ImageSource.gallery);
              },
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
