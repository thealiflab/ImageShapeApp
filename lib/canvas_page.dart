import 'dart:io' as io;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'rectangle_painter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

//constants
const buttonTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w900,
);

class CanvasPage extends StatefulWidget {
  @override
  _CanvasPageState createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  ui.Image _image;
  Image _imageWidget;
  List<ui.Offset> _points = [
    ui.Offset(90, 120),
    ui.Offset(90, 370),
//    ui.Offset(320, 370),
    ui.Offset(320, 120)
  ];
  bool _clear = false;
  int _currentlyDraggedIndex = -1;

  double x, y;

  @override
  Widget build(BuildContext context) {
    final AppBar appBar = AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(
        'Canvas',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
//        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (_imageWidget == null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton.extended(
                  onPressed: () => _pickImage(ImageSource.camera),
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
                  onPressed: () => _pickImage(ImageSource.gallery),
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
          ],
          if (_imageWidget != null) ...[
            Expanded(
              child: Zoom(
                width: _image.width.toDouble(),
                height: _image.height.toDouble(),
                backgroundColor: Colors.white,
                colorScrollBars: Colors.cyan,
                opacityScrollBars: 0.9,
                scrollWeight: 10.0,
                centerOnScale: true,
                enableScroll: true,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: GestureDetector(
                    onPanStart: (DragStartDetails details) {
                      // get distance from points to check if is in circle
                      int indexMatch = -1;
                      for (int i = 0; i < _points.length; i++) {
                        double distance = sqrt(pow(
                                details.localPosition.dx - _points[i].dx, 2) +
                            pow(details.localPosition.dy - _points[i].dy, 2));
                        if (distance <= 30) {
                          indexMatch = i;
                          break;
                        }
                      }
                      if (indexMatch != -1) {
                        _currentlyDraggedIndex = indexMatch;
                      }
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      if (_currentlyDraggedIndex != -1) {
                        setState(() {
                          _points = List.from(_points);
                          _points[_currentlyDraggedIndex] =
                              details.localPosition;
                        });
                      }
                    },
                    onPanEnd: (_) {
                      setState(() {
                        _currentlyDraggedIndex = -1;
                      });
                    },
                    child: SizedBox(
                      width: _image.width.toDouble(),
                      height: _image.height.toDouble(),
                      child: CustomPaint(
                        painter: RectanglePainter(
                            points: _points, clear: _clear, image: _image),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Future _pickImage(ImageSource imageSource) async {
    try {
      io.File imageFile = await ImagePicker.pickImage(source: imageSource);
      print("Before Cropping");
      print(" Image Size is : ${imageFile.lengthSync() / 1000} kB");

      io.File croppedImage = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
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
        ),
      );

      Future<ui.Image> load(String asset) async {
        if (asset == null || asset == "") return null;
        ByteData data = await rootBundle.load(asset);
        ui.Codec codec =
            await ui.instantiateImageCodec(data.buffer.asUint8List());
        ui.FrameInfo fi = await codec.getNextFrame();
        return fi.image;
      }

      ui.Image finalImg = await load(croppedImage.path);
      setState(() {
        _imageWidget = Image.file(croppedImage);
        _image = finalImg;

        print("After");
        print(" Image Size is : ${imageFile.lengthSync() / 1000} kB");
        print("Image height: ${_image.height}");
        print("Image width: ${_image.width}");
      });
    } catch (e) {
      print(e);
    }
  }
}
