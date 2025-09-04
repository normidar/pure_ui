import 'dart:io';
import 'dart:math' as math;

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

void main() {
  group('Complex Canvas Tests', () {
    test('Complex geometric shapes composition', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 400, 400));

      // Background gradient effect (simulated with multiple rectangles)
      for (int i = 0; i < 400; i += 10) {
        final opacity = (255 - (i * 255 / 400)).round();
        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(opacity, 100, 150, 255)
          ..style = ui.PaintingStyle.fill;
        canvas.drawRect(ui.Rect.fromLTWH(i.toDouble(), 0, 10, 400), paint);
      }

      // Draw overlapping circles with different colors
      final colors = [
        const ui.Color(0xFFFF0000), // Red
        const ui.Color(0xFF00FF00), // Green
        const ui.Color(0xFF0000FF), // Blue
        const ui.Color(0xFFFFFF00), // Yellow
        const ui.Color(0xFFFF00FF), // Magenta
      ];

      for (int i = 0; i < colors.length; i++) {
        final paint = ui.Paint()
          ..color = colors[i].withOpacity(0.7)
          ..style = ui.PaintingStyle.fill;

        final centerX = 100 + (i * 50).toDouble();
        final centerY = 200.0;
        canvas.drawCircle(ui.Offset(centerX, centerY), 60, paint);
      }

      // Draw concentric rectangles with rotation
      canvas.save();
      canvas.translate(200, 200);
      for (int i = 0; i < 5; i++) {
        canvas.save();
        canvas.rotate(i * math.pi / 8);

        final paint = ui.Paint()
          ..color =
              ui.Color.fromARGB(255, 255 - (i * 40), i * 40, 100 + (i * 30))
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 3.0;

        final size = 80 - (i * 10).toDouble();
        canvas.drawRect(
            ui.Rect.fromCenter(
                center: ui.Offset.zero, width: size, height: size),
            paint);
        canvas.restore();
      }
      canvas.restore();

      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 400);

      expect(image.width, 400);
      expect(image.height, 400);

      // Save as PNG for visual verification
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/complex_geometric.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Complex geometric shapes saved: ${file.path}');
    });

    test('Artistic pattern with paths and transformations', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 300, 300));

      // Background
      final bgPaint = ui.Paint()
        ..color = const ui.Color(0xFF1a1a2e)
        ..style = ui.PaintingStyle.fill;
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 300, 300), bgPaint);

      // Create spiral pattern
      canvas.save();
      canvas.translate(150, 150);

      for (int i = 0; i < 36; i++) {
        canvas.save();
        canvas.rotate(i * math.pi / 18);

        // Create path for complex shape
        final path = ui.Path();
        path.moveTo(0, -50);
        path.quadraticBezierTo(20, -30, 0, -10);
        path.quadraticBezierTo(-20, -30, 0, -50);
        path.close();

        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(
              200,
              (255 * math.sin(i * math.pi / 18)).abs().round(),
              (255 * math.cos(i * math.pi / 12)).abs().round(),
              255 - (i * 5))
          ..style = ui.PaintingStyle.fill;

        canvas.drawPath(path, paint);
        canvas.restore();
      }
      canvas.restore();

      // Add decorative corner elements
      for (int corner = 0; corner < 4; corner++) {
        canvas.save();
        final x = corner % 2 == 0 ? 30.0 : 270.0;
        final y = corner < 2 ? 30.0 : 270.0;
        canvas.translate(x, y);

        if (corner >= 2) canvas.rotate(math.pi);
        if (corner == 1 || corner == 2) canvas.scale(-1, 1);

        // Draw decorative element
        for (int i = 0; i < 3; i++) {
          final paint = ui.Paint()
            ..color = ui.Color.fromARGB(255, 255, 215 - (i * 50), 0)
            ..style = ui.PaintingStyle.fill;

          canvas.drawOval(
              ui.Rect.fromCenter(
                  center: ui.Offset(i * 8.0, 0),
                  width: 15 - (i * 2).toDouble(),
                  height: 15 - (i * 2).toDouble()),
              paint);
        }
        canvas.restore();
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(300, 300);

      expect(image.width, 300);
      expect(image.height, 300);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/artistic_pattern.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Artistic pattern saved: ${file.path}');
    });

    test('Complex layered composition with clipping', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 350, 250));

      // Background gradient simulation
      for (int y = 0; y < 250; y++) {
        final gradient = y / 249.0;
        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(255, (50 + (gradient * 100)).round(),
              (100 + (gradient * 50)).round(), (200 - (gradient * 50)).round())
          ..style = ui.PaintingStyle.fill;
        canvas.drawRect(ui.Rect.fromLTWH(0, y.toDouble(), 350, 1), paint);
      }

      // Layer 1: Clipped circles
      canvas.save();
      canvas.clipRect(const ui.Rect.fromLTWH(50, 50, 250, 150));

      for (int i = 0; i < 8; i++) {
        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(
              150,
              (255 * math.sin(i * math.pi / 4)).abs().round(),
              (255 * math.cos(i * math.pi / 3)).abs().round(),
              255 - (i * 20))
          ..style = ui.PaintingStyle.fill;

        canvas.drawCircle(ui.Offset(100 + (i * 20).toDouble(), 125), 25, paint);
      }
      canvas.restore();

      // Layer 2: Overlapping rectangles with different blend modes simulation
      canvas.save();
      canvas.translate(175, 125);

      for (int i = 0; i < 6; i++) {
        canvas.save();
        canvas.rotate(i * math.pi / 6);

        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(
              100, i % 2 == 0 ? 255 : 0, (i * 42) % 255, 255 - (i * 42) % 255)
          ..style = ui.PaintingStyle.fill;

        canvas.drawRect(
            ui.Rect.fromCenter(center: ui.Offset.zero, width: 80, height: 20),
            paint);
        canvas.restore();
      }
      canvas.restore();

      // Layer 3: Border decoration
      final borderPaint = ui.Paint()
        ..color = const ui.Color(0xFF333333)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 5.0;
      canvas.drawRect(const ui.Rect.fromLTWH(10, 10, 330, 230), borderPaint);

      // Add corner embellishments
      final cornerPaint = ui.Paint()
        ..color = const ui.Color(0xFFFFD700)
        ..style = ui.PaintingStyle.fill;

      final corners = [
        const ui.Offset(10, 10),
        const ui.Offset(340, 10),
        const ui.Offset(10, 240),
        const ui.Offset(340, 240),
      ];

      for (final corner in corners) {
        canvas.drawCircle(corner, 8, cornerPaint);
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(350, 250);

      expect(image.width, 350);
      expect(image.height, 250);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/layered_composition.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Layered composition saved: ${file.path}');
    });

    test('Mathematical visualization - Mandelbrot-inspired pattern', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 400, 400));

      // Create mathematical pattern
      for (int x = 0; x < 400; x += 2) {
        for (int y = 0; y < 400; y += 2) {
          // Map coordinates to complex plane
          final cx = (x - 200) / 100.0;
          final cy = (y - 200) / 100.0;

          // Simple iteration count for coloring
          int iterations = 0;
          double zx = 0, zy = 0;

          while (iterations < 50 && (zx * zx + zy * zy) < 4) {
            final temp = zx * zx - zy * zy + cx;
            zy = 2 * zx * zy + cy;
            zx = temp;
            iterations++;
          }

          // Color based on iterations
          final color = iterations == 50
              ? const ui.Color(0xFF000000)
              : ui.Color.fromARGB(255, (iterations * 5) % 255,
                  (iterations * 7) % 255, (iterations * 11) % 255);

          final paint = ui.Paint()
            ..color = color
            ..style = ui.PaintingStyle.fill;

          canvas.drawRect(
              ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), 2, 2), paint);
        }
      }

      // Add frame
      final framePaint = ui.Paint()
        ..color = const ui.Color(0xFFFFFFFF)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawRect(const ui.Rect.fromLTWH(5, 5, 390, 390), framePaint);

      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 400);

      expect(image.width, 400);
      expect(image.height, 400);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/mandelbrot_pattern.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Mandelbrot pattern saved: ${file.path}');
    });

    test('Performance test - Many small elements', () async {
      final stopwatch = Stopwatch()..start();

      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 500, 500));

      // Background
      final bgPaint = ui.Paint()
        ..color = const ui.Color(0xFF2C3E50)
        ..style = ui.PaintingStyle.fill;
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 500, 500), bgPaint);

      // Draw 1000 small elements with various shapes
      for (int i = 0; i < 1000; i++) {
        final x = (i * 17) % 480 + 10.0;
        final y = (i * 23) % 480 + 10.0;
        final size = 3 + (i % 7).toDouble();

        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(
              255, (i * 37) % 255, (i * 67) % 255, (i * 97) % 255)
          ..style = ui.PaintingStyle.fill;

        if (i % 3 == 0) {
          // Circle
          canvas.drawCircle(ui.Offset(x, y), size, paint);
        } else if (i % 3 == 1) {
          // Rectangle
          canvas.drawRect(
              ui.Rect.fromCenter(
                  center: ui.Offset(x, y), width: size * 2, height: size * 2),
              paint);
        } else {
          // Oval
          canvas.drawOval(
              ui.Rect.fromCenter(
                  center: ui.Offset(x, y), width: size * 3, height: size),
              paint);
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(500, 500);

      stopwatch.stop();

      expect(image.width, 500);
      expect(image.height, 500);
      expect(stopwatch.elapsedMilliseconds,
          lessThan(5000)); // Should complete within 5 seconds

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/performance_test.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Performance test completed in ${stopwatch.elapsedMilliseconds}ms');
      print('Performance test saved: ${file.path}');
    });
  });
}
