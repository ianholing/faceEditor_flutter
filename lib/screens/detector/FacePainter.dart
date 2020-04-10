import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Rect> faces;

  FacePainter(this.image, this.faces);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.yellow;

    //canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(faces[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}