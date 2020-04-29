import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
