import 'dart:io';

import 'package:pure_ui/pure_ui.dart';

void main() {
  // Create a new image
  final image = Image(400, 300);

  // Create a canvas
  final canvas = Canvas.forImage(image);

  // Fill the background
  final bgPaint = Paint()
    ..color = const Color.fromRGB(240, 240, 255)
    ..style = PaintingStyle.fill;
  canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 300), bgPaint);

  // Draw a circle
  final circlePaint = Paint()
    ..color = const Color.fromRGB(255, 0, 0)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(const Offset(200, 150), 80, circlePaint);

  // Draw a rectangle
  final rectPaint = Paint()
    ..color = const Color.fromRGB(0, 0, 255)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  canvas.drawRect(const Rect.fromLTRB(50, 50, 350, 250), rectPaint);

  // Draw a path
  final pathPaint = Paint()
    ..color = const Color.fromRGB(0, 180, 0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  final path = Path()
    ..moveTo(50, 150)
    ..lineTo(150, 250)
    ..lineTo(250, 50)
    ..lineTo(350, 150);

  canvas.drawPath(path, pathPaint);

  // Save the image as PNG
  final pngData = image.toPng();
  File('output.png').writeAsBytesSync(pngData);
}
