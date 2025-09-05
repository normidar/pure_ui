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
          ..color = colors[i].withValues(alpha: 0.7)
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

      // Create mathematical pattern with improved color mapping
      // Use larger blocks for better visibility
      final blockSize = 4;
      for (int x = 0; x < 400; x += blockSize) {
        for (int y = 0; y < 400; y += blockSize) {
          // Map coordinates to a more interesting region of the complex plane
          final cx = (x - 200) / 150.0; // Slightly zoomed in
          final cy = (y - 200) / 150.0;

          // Simple iteration count for coloring
          int iterations = 0;
          double zx = 0, zy = 0;

          while (iterations < 50 && (zx * zx + zy * zy) < 4) {
            final temp = zx * zx - zy * zy + cx;
            zy = 2 * zx * zy + cy;
            zx = temp;
            iterations++;
          }

          // Improved color mapping with better contrast
          ui.Color color;
          if (iterations == 50) {
            color = const ui.Color(0xFF000000); // Black for points in the set
          } else if (iterations < 10) {
            // Very fast escape - bright colors
            color = ui.Color.fromARGB(255, 255, (iterations * 25) % 255, 0);
          } else if (iterations < 20) {
            // Medium escape - green tones
            color = ui.Color.fromARGB(255, 0, 255, (iterations * 12) % 255);
          } else {
            // Slow escape - blue tones
            color = ui.Color.fromARGB(255, (iterations * 5) % 255, 0, 255);
          }

          final paint = ui.Paint()
            ..color = color
            ..style = ui.PaintingStyle.fill;

          canvas.drawRect(
              ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), blockSize.toDouble(),
                  blockSize.toDouble()),
              paint);
        }
      }

      // Add frame - test the improved stroke implementation
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

    test('Debug - Simple color test', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 400, 400));

      // Draw simple colored rectangles to test basic functionality
      final colors = [
        const ui.Color(0xFFFF0000), // Red
        const ui.Color(0xFF00FF00), // Green
        const ui.Color(0xFF0000FF), // Blue
        const ui.Color(0xFFFFFF00), // Yellow
        const ui.Color(0xFFFF00FF), // Magenta
        const ui.Color(0xFF00FFFF), // Cyan
      ];

      for (int i = 0; i < colors.length; i++) {
        final paint = ui.Paint()
          ..color = colors[i]
          ..style = ui.PaintingStyle.fill;

        final x = (i % 3) * 133.0;
        final y = (i ~/ 3) * 200.0;
        canvas.drawRect(ui.Rect.fromLTWH(x, y, 133, 200), paint);
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 400);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/debug_color_test.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Debug color test saved: ${file.path}');
    });

    test('Debug - 1x1 pixel test', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      // Fill background with black
      final bgPaint = ui.Paint()
        ..color = const ui.Color(0xFF000000)
        ..style = ui.PaintingStyle.fill;
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 100, 100), bgPaint);

      // Draw individual 1x1 pixel dots in different colors
      final colors = [
        const ui.Color(0xFFFF0000), // Red
        const ui.Color(0xFF00FF00), // Green
        const ui.Color(0xFF0000FF), // Blue
        const ui.Color(0xFFFFFFFF), // White
      ];

      for (int i = 0; i < colors.length; i++) {
        final paint = ui.Paint()
          ..color = colors[i]
          ..style = ui.PaintingStyle.fill;

        // Draw 1x1 pixel rectangles
        for (int j = 0; j < 20; j++) {
          final x = 10 + (i * 20) + (j % 5) * 2.0;
          final y = 10 + (j ~/ 5) * 2.0;
          canvas.drawRect(ui.Rect.fromLTWH(x, y, 1, 1), paint);
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(100, 100);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/pixel_test.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('1x1 pixel test saved: ${file.path}');
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

  group('Canvas.drawPicture Tests', () {
    test('Basic drawPicture with simple shapes', () async {
      // Create a source picture with basic shapes
      final sourceRecorder = ui.PictureRecorder();
      final sourceCanvas =
          ui.Canvas(sourceRecorder, const ui.Rect.fromLTWH(0, 0, 200, 200));

      // Draw some shapes in the source picture
      final redPaint = ui.Paint()
        ..color = const ui.Color(0xFFFF0000)
        ..style = ui.PaintingStyle.fill;
      sourceCanvas.drawCircle(const ui.Offset(100, 100), 50, redPaint);

      final bluePaint = ui.Paint()
        ..color = const ui.Color(0xFF0000FF)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 5.0;
      sourceCanvas.drawRect(
          const ui.Rect.fromLTWH(50, 50, 100, 100), bluePaint);

      final sourcePicture = sourceRecorder.endRecording();

      // Now create the main canvas and draw the picture
      final mainRecorder = ui.PictureRecorder();
      final mainCanvas =
          ui.Canvas(mainRecorder, const ui.Rect.fromLTWH(0, 0, 400, 400));

      // Background
      final bgPaint = ui.Paint()
        ..color = const ui.Color(0xFF333333)
        ..style = ui.PaintingStyle.fill;
      mainCanvas.drawRect(const ui.Rect.fromLTWH(0, 0, 400, 400), bgPaint);

      // Draw the picture
      mainCanvas.drawPicture(sourcePicture);

      final mainPicture = mainRecorder.endRecording();
      final image = await mainPicture.toImage(400, 400);

      expect(image.width, 400);
      expect(image.height, 400);

      // Save for visual verification
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/drawpicture_basic.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Basic drawPicture test saved: ${file.path}');
    });

    test('Nested pictures - picture within picture', () async {
      // Create the innermost picture
      final innerRecorder = ui.PictureRecorder();
      final innerCanvas =
          ui.Canvas(innerRecorder, const ui.Rect.fromLTWH(0, 0, 50, 50));

      final yellowPaint = ui.Paint()
        ..color = const ui.Color(0xFFFFFF00)
        ..style = ui.PaintingStyle.fill;
      innerCanvas.drawOval(const ui.Rect.fromLTWH(10, 10, 30, 30), yellowPaint);

      final innerPicture = innerRecorder.endRecording();

      // Create middle picture that contains the inner picture
      final middleRecorder = ui.PictureRecorder();
      final middleCanvas =
          ui.Canvas(middleRecorder, const ui.Rect.fromLTWH(0, 0, 150, 150));

      final greenPaint = ui.Paint()
        ..color = const ui.Color(0xFF00FF00)
        ..style = ui.PaintingStyle.fill;
      middleCanvas.drawRect(const ui.Rect.fromLTWH(0, 0, 150, 150), greenPaint);

      // Draw inner picture multiple times in different positions
      middleCanvas.save();
      middleCanvas.translate(25, 25);
      middleCanvas.drawPicture(innerPicture);
      middleCanvas.restore();

      middleCanvas.save();
      middleCanvas.translate(75, 75);
      middleCanvas.drawPicture(innerPicture);
      middleCanvas.restore();

      final middlePicture = middleRecorder.endRecording();

      // Create main canvas
      final mainRecorder = ui.PictureRecorder();
      final mainCanvas =
          ui.Canvas(mainRecorder, const ui.Rect.fromLTWH(0, 0, 300, 300));

      final bgPaint = ui.Paint()
        ..color = const ui.Color(0xFF000088)
        ..style = ui.PaintingStyle.fill;
      mainCanvas.drawRect(const ui.Rect.fromLTWH(0, 0, 300, 300), bgPaint);

      // Draw middle picture in different positions
      mainCanvas.save();
      mainCanvas.translate(20, 20);
      mainCanvas.drawPicture(middlePicture);
      mainCanvas.restore();

      mainCanvas.save();
      mainCanvas.translate(130, 130);
      mainCanvas.drawPicture(middlePicture);
      mainCanvas.restore();

      final mainPicture = mainRecorder.endRecording();
      final image = await mainPicture.toImage(300, 300);

      expect(image.width, 300);
      expect(image.height, 300);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/drawpicture_nested.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Nested drawPicture test saved: ${file.path}');
    });

    test('drawPicture with transformations', () async {
      // Create source picture with a simple, visible shape
      final sourceRecorder = ui.PictureRecorder();
      final sourceCanvas =
          ui.Canvas(sourceRecorder, const ui.Rect.fromLTWH(0, 0, 60, 60));

      // Draw a simple arrow shape with bright colors
      final arrowPaint = ui.Paint()
        ..color = const ui.Color(0xFFFF6600)
        ..style = ui.PaintingStyle.fill;

      final arrowPath = ui.Path();
      arrowPath.moveTo(30, 5); // Top point
      arrowPath.lineTo(45, 20); // Right top
      arrowPath.lineTo(37, 20); // Inner right
      arrowPath.lineTo(37, 55); // Right bottom
      arrowPath.lineTo(23, 55); // Left bottom
      arrowPath.lineTo(23, 20); // Inner left
      arrowPath.lineTo(15, 20); // Left top
      arrowPath.close();

      sourceCanvas.drawPath(arrowPath, arrowPaint);

      // Add a border for visibility
      final borderPaint = ui.Paint()
        ..color = const ui.Color(0xFFFFFFFF)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2.0;
      sourceCanvas.drawPath(arrowPath, borderPaint);

      final sourcePicture = sourceRecorder.endRecording();

      // Main canvas with transformations
      final mainRecorder = ui.PictureRecorder();
      final mainCanvas =
          ui.Canvas(mainRecorder, const ui.Rect.fromLTWH(0, 0, 400, 400));

      // Light background for better visibility
      final bgPaint = ui.Paint()
        ..color = const ui.Color(0xFF333333)
        ..style = ui.PaintingStyle.fill;
      mainCanvas.drawRect(const ui.Rect.fromLTWH(0, 0, 400, 400), bgPaint);

      // Draw picture with various transformations - arrange in a circle
      for (int i = 0; i < 8; i++) {
        mainCanvas.save();

        // Position around a circle
        final angle = i * math.pi / 4;
        final x = 200 + math.cos(angle) * 120;
        final y = 200 + math.sin(angle) * 120;

        mainCanvas.translate(x, y);
        mainCanvas.rotate(angle + math.pi / 2); // Point outward from center
        mainCanvas.translate(-30, -30); // Center the 60x60 picture

        mainCanvas.drawPicture(sourcePicture);
        mainCanvas.restore();
      }

      // Draw a larger version in the center
      mainCanvas.save();
      mainCanvas.translate(200, 200);
      mainCanvas.scale(1.2, 1.2);
      mainCanvas.translate(-30, -30); // Center the picture
      mainCanvas.drawPicture(sourcePicture);
      mainCanvas.restore();

      // Add some corner markers for reference
      final markerPaint = ui.Paint()
        ..color = const ui.Color(0xFF00FF00)
        ..style = ui.PaintingStyle.fill;

      mainCanvas.drawCircle(const ui.Offset(50, 50), 5, markerPaint);
      mainCanvas.drawCircle(const ui.Offset(350, 50), 5, markerPaint);
      mainCanvas.drawCircle(const ui.Offset(50, 350), 5, markerPaint);
      mainCanvas.drawCircle(const ui.Offset(350, 350), 5, markerPaint);

      final mainPicture = mainRecorder.endRecording();
      final image = await mainPicture.toImage(400, 400);

      expect(image.width, 400);
      expect(image.height, 400);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/drawpicture_transformations.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Transformations drawPicture test saved: ${file.path}');
    });

    test('Multiple pictures composition', () async {
      // Create different themed pictures

      // Picture 1: Geometric pattern
      final geo1Recorder = ui.PictureRecorder();
      final geo1Canvas =
          ui.Canvas(geo1Recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      for (int i = 0; i < 5; i++) {
        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(255, 255 - i * 40, i * 50, 100 + i * 30)
          ..style = ui.PaintingStyle.fill;
        geo1Canvas.drawRect(
            ui.Rect.fromLTWH(i * 10.0, i * 10.0, 80 - i * 10.0, 80 - i * 10.0),
            paint);
      }
      final geoPicture1 = geo1Recorder.endRecording();

      // Picture 2: Circular pattern
      final circle1Recorder = ui.PictureRecorder();
      final circle1Canvas =
          ui.Canvas(circle1Recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      for (int i = 0; i < 4; i++) {
        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(180, i * 60, 255 - i * 60, 128)
          ..style = ui.PaintingStyle.fill;
        circle1Canvas.drawCircle(const ui.Offset(50, 50), 45 - i * 10.0, paint);
      }
      final circlePicture1 = circle1Recorder.endRecording();

      // Picture 3: Line pattern
      final line1Recorder = ui.PictureRecorder();
      final line1Canvas =
          ui.Canvas(line1Recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final linePaint = ui.Paint()
        ..color = const ui.Color(0xFFFFFFFF)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3.0;

      for (int i = 0; i < 10; i++) {
        final path = ui.Path();
        path.moveTo(0, i * 10.0);
        path.lineTo(100, 100 - i * 10.0);
        line1Canvas.drawPath(path, linePaint);
      }
      final linePicture1 = line1Recorder.endRecording();

      // Compose all pictures on main canvas
      final mainRecorder = ui.PictureRecorder();
      final mainCanvas =
          ui.Canvas(mainRecorder, const ui.Rect.fromLTWH(0, 0, 350, 350));

      final bgPaint = ui.Paint()
        ..color = const ui.Color(0xFF1a1a1a)
        ..style = ui.PaintingStyle.fill;
      mainCanvas.drawRect(const ui.Rect.fromLTWH(0, 0, 350, 350), bgPaint);

      // Create a 3x3 grid composition
      final pictures = [geoPicture1, circlePicture1, linePicture1];

      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          mainCanvas.save();
          mainCanvas.translate(25 + col * 110.0, 25 + row * 110.0);

          // Vary the pictures and add some rotation
          final pictureIndex = (row + col) % pictures.length;
          if ((row + col) % 2 == 1) {
            mainCanvas.rotate(math.pi / 4);
            mainCanvas.translate(-50, -50);
          }

          mainCanvas.drawPicture(pictures[pictureIndex]);
          mainCanvas.restore();
        }
      }

      final mainPicture = mainRecorder.endRecording();
      final image = await mainPicture.toImage(350, 350);

      expect(image.width, 350);
      expect(image.height, 350);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/drawpicture_composition.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Multiple pictures composition test saved: ${file.path}');
    });

    test('drawPicture with clipping', () async {
      // Create a large detailed picture
      final sourceRecorder = ui.PictureRecorder();
      final sourceCanvas =
          ui.Canvas(sourceRecorder, const ui.Rect.fromLTWH(0, 0, 200, 200));

      // Draw a complex pattern that extends beyond what we want to show
      for (int i = 0; i < 20; i++) {
        for (int j = 0; j < 20; j++) {
          final paint = ui.Paint()
            ..color = ui.Color.fromARGB(
                255, (i * 12) % 255, (j * 17) % 255, ((i + j) * 8) % 255)
            ..style = ui.PaintingStyle.fill;

          sourceCanvas.drawRect(
              ui.Rect.fromLTWH(i * 10.0, j * 10.0, 8, 8), paint);
        }
      }

      // Add some circles on top
      for (int i = 0; i < 5; i++) {
        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(200, 255, 255 - i * 40, i * 50)
          ..style = ui.PaintingStyle.fill;
        sourceCanvas.drawCircle(ui.Offset(40 + i * 30.0, 100), 25, paint);
      }

      final sourcePicture = sourceRecorder.endRecording();

      // Main canvas with clipping
      final mainRecorder = ui.PictureRecorder();
      final mainCanvas =
          ui.Canvas(mainRecorder, const ui.Rect.fromLTWH(0, 0, 400, 300));

      final bgPaint = ui.Paint()
        ..color = const ui.Color(0xFF444444)
        ..style = ui.PaintingStyle.fill;
      mainCanvas.drawRect(const ui.Rect.fromLTWH(0, 0, 400, 300), bgPaint);

      // Draw picture with rectangular clipping
      mainCanvas.save();
      mainCanvas.translate(50, 50);
      mainCanvas.clipRect(const ui.Rect.fromLTWH(0, 0, 100, 150));
      mainCanvas.drawPicture(sourcePicture);
      mainCanvas.restore();

      // Draw picture with circular clipping
      mainCanvas.save();
      mainCanvas.translate(200, 50);
      final clipPath = ui.Path();
      clipPath.addOval(const ui.Rect.fromLTWH(25, 25, 150, 150));
      mainCanvas.clipPath(clipPath);
      mainCanvas.drawPicture(sourcePicture);
      mainCanvas.restore();

      // Draw picture with complex clipping path
      mainCanvas.save();
      mainCanvas.translate(100, 175);
      final complexClipPath = ui.Path();
      complexClipPath.moveTo(50, 0);
      complexClipPath.lineTo(100, 50);
      complexClipPath.lineTo(75, 100);
      complexClipPath.lineTo(25, 100);
      complexClipPath.lineTo(0, 50);
      complexClipPath.close();
      mainCanvas.clipPath(complexClipPath);
      mainCanvas.drawPicture(sourcePicture);
      mainCanvas.restore();

      final mainPicture = mainRecorder.endRecording();
      final image = await mainPicture.toImage(400, 300);

      expect(image.width, 400);
      expect(image.height, 300);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/drawpicture_clipping.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Clipping drawPicture test saved: ${file.path}');
    });

    test('drawPicture performance test', () async {
      final stopwatch = Stopwatch()..start();

      // Create a moderately complex source picture
      final sourceRecorder = ui.PictureRecorder();
      final sourceCanvas =
          ui.Canvas(sourceRecorder, const ui.Rect.fromLTWH(0, 0, 50, 50));

      final colors = [
        const ui.Color(0xFFFF0000),
        const ui.Color(0xFF00FF00),
        const ui.Color(0xFF0000FF),
      ];

      for (int i = 0; i < colors.length; i++) {
        final paint = ui.Paint()
          ..color = colors[i].withValues(alpha: 0.7)
          ..style = ui.PaintingStyle.fill;
        sourceCanvas.drawCircle(ui.Offset(25 + (i - 1) * 8.0, 25), 20, paint);
      }

      final sourcePicture = sourceRecorder.endRecording();

      // Main canvas - draw the picture many times
      final mainRecorder = ui.PictureRecorder();
      final mainCanvas =
          ui.Canvas(mainRecorder, const ui.Rect.fromLTWH(0, 0, 500, 500));

      final bgPaint = ui.Paint()
        ..color = const ui.Color(0xFF2a2a2a)
        ..style = ui.PaintingStyle.fill;
      mainCanvas.drawRect(const ui.Rect.fromLTWH(0, 0, 500, 500), bgPaint);

      // Draw picture 400 times (20x20 grid)
      for (int row = 0; row < 20; row++) {
        for (int col = 0; col < 20; col++) {
          mainCanvas.save();
          mainCanvas.translate(col * 25.0, row * 25.0);

          // Add some variety with rotation
          if ((row + col) % 4 == 0) {
            mainCanvas.rotate(math.pi / 4);
            mainCanvas.translate(-25, -25);
          }

          mainCanvas.drawPicture(sourcePicture);
          mainCanvas.restore();
        }
      }

      final mainPicture = mainRecorder.endRecording();
      final image = await mainPicture.toImage(500, 500);

      stopwatch.stop();

      expect(image.width, 500);
      expect(image.height, 500);
      expect(stopwatch.elapsedMilliseconds,
          lessThan(3000)); // Should complete within 3 seconds

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/drawpicture_performance.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print(
          'drawPicture performance test completed in ${stopwatch.elapsedMilliseconds}ms');
      print('Performance test saved: ${file.path}');
    });
  });
}
