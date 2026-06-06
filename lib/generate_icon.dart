import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = Size(1024, 1024);

  // Background
  final bgPaint = Paint()..color = const Color(0xFFD52B1E);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(200),
    ),
    bgPaint,
  );

  // Text
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'G1',
      style: TextStyle(
        color: Colors.white,
        fontSize: 480,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2 - 80,
    ),
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(1024, 1024);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  
  File('assets/images/app_icon.png').writeAsBytesSync(
    data!.buffer.asUint8List(),
  );
}
