import 'dart:io';

import 'package:pure_ui/pure_ui.dart';
import 'package:test/test.dart';

void main() {
  group('Gradient Tests', () {
    test('Linear Gradient Test', () async {
      final size = const Size(800, 600);
      await exportImage(
        canvasFunction: (canvas) {
          final rect = Rect.fromLTWH(0, 0, size.width, size.height);

          // Create shader
          final gradient = Gradient.linear(
            Offset(0, 0), // Start point
            Offset(size.width, size.height), // End point
            [Color(0xFF42A5F5), Color(0xFFAB47BC)], // Color list
            [0.0, 1.0], // Color positions (optional)
          );

          final paint = Paint()..shader = gradient;

          // Fill the rectangle
          canvas.drawRect(rect, paint);
        },
        size: size,
        exportFile: File('test_output/linear_gradient.png'),
      );
    });

    test('Radial Gradient Test', () async {
      final size = const Size(400, 300);
      await exportImage(
        canvasFunction: (canvas) {
          final gradient = Gradient.radial(
            Offset(size.width / 2, size.height / 2), // Center point
            size.width / 2, // Radius
            [Color(0xFFFF5722), Color(0xFF4CAF50)],
          );

          final paint = Paint()..shader = gradient;

          canvas.drawCircle(
            Offset(size.width / 2, size.height / 2),
            size.width / 2,
            paint,
          );
        },
        size: size,
        exportFile: File('test_output/radial_gradient.png'),
      );
    });
  });
}
