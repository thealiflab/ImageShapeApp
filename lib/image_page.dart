import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';

//https://paste.ofcode.org/YgfMrTAQmVpHPatzhRtin7

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
  ui.Image _image;

  List<ui.Offset> _points = [
    ui.Offset(90, 120),
    ui.Offset(90, 370),
    ui.Offset(320, 370),
    ui.Offset(320, 120)
  ];
  bool _clear = false;
  int _currentlyDraggedIndex = -1;

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
      ),
    );

    ui.Image finalImg = await _load(croppedImage.path);
    setState(
      () {
        image = croppedImage;
        _image = finalImg;
        if (image != null) {
          print("${image.lengthSync() / 1000} kB");
        }
      },
    );
  }

  Future<ui.Image> _load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (image == null) ...[
              Center(
                  child: Text(
                'Insert an image',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                ),
              )),
            ],
            if (image != null) ...[
              GestureDetector(
                onPanStart: (DragStartDetails details) {
                  // get distance from points to check if is in circle
                  int indexMatch = -1;
                  for (int i = 0; i < _points.length; i++) {
                    double distance = sqrt(
                        pow(details.localPosition.dx - _points[i].dx, 2) +
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
                      _points[_currentlyDraggedIndex] = details.localPosition;
                    });
                  }
                },
                onPanEnd: (_) {
                  setState(() {
                    _currentlyDraggedIndex = -1;
                  });
                },
                child: CustomPaint(
//                  size: Size.fromHeight(MediaQuery.of(context).size.height - appBar.preferredSize.height),
                  painter: RectanglePainter(
                      points: _points, clear: _clear, image: _image),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (image == null) ...[
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
          ],
        ),
      ),
    );
  }
}

class RectanglePainter extends CustomPainter {
  List<Offset> points;
  bool clear;
  final ui.Image image;

  RectanglePainter(
      {@required this.points, @required this.clear, @required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final outputRect =
        Rect.fromPoints(ui.Offset.zero, ui.Offset(size.width, size.height));
    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes sizes =
        applyBoxFit(BoxFit.contain, imageSize, outputRect.size);
    final Rect inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final Rect outputSubrect =
        Alignment.center.inscribe(sizes.destination, outputRect);
    canvas.drawImageRect(image, inputSubrect, outputSubrect, paint);
    if (!clear) {
      final circlePaint = Paint()
        ..color = Colors.red
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.multiply
        ..strokeWidth = 2;

      for (int i = 0; i < points.length; i++) {
        if (i + 1 == points.length) {
          canvas.drawLine(points[i], points[0], paint);
        } else {
          canvas.drawLine(points[i], points[i + 1], paint);
        }
        canvas.drawCircle(points[i], 10, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(RectanglePainter oldPainter) =>
      oldPainter.points != points || clear;
}
