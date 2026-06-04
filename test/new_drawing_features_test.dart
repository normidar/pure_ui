import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

void main() {
  group('drawArc', () {
    test('filled pie slice has ink at center', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFFFF0000)
        ..style = ui.PaintingStyle.fill;

      // Full circle (360°) centered at (50,50) radius 30
      canvas.drawArc(
        const ui.Rect.fromLTWH(20, 20, 60, 60),
        0,
        3.14159 * 2,
        true,
        paint,
      );

      final image = await recorder.endRecording().toImage(100, 100);
      final pixel = image.getPixel(50, 50);
      expect(pixel.red, greaterThan(200), reason: 'center pixel should be red');
      expect(pixel.alpha, greaterThan(200));
      image.dispose();
    });

    test('filled arc (useCenter=false) has ink inside chord', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFF0000FF)
        ..style = ui.PaintingStyle.fill;

      // Bottom semicircle
      canvas.drawArc(
        const ui.Rect.fromLTWH(20, 20, 60, 60),
        0,
        3.14159,
        false,
        paint,
      );

      final image = await recorder.endRecording().toImage(100, 100);
      // Bottom half of the ellipse should have blue ink
      final bottomPixel = image.getPixel(50, 65);
      expect(bottomPixel.blue, greaterThan(200),
          reason: 'bottom of arc should be blue');
      // Top of the ellipse should be transparent
      final topPixel = image.getPixel(50, 25);
      expect(topPixel.alpha, lessThan(50),
          reason: 'top outside arc should be transparent');
      image.dispose();
    });

    test('stroked arc produces ink along edge', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFF00FF00)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawArc(
        const ui.Rect.fromLTWH(20, 20, 60, 60),
        0,
        3.14159 * 2,
        false,
        paint,
      );

      final image = await recorder.endRecording().toImage(100, 100);
      // Right edge of circle (center=50,50, radius=30)
      final edgePixel = image.getPixel(80, 50);
      expect(edgePixel.green, greaterThan(200),
          reason: 'arc edge should be green');
      image.dispose();
    });
  });

  group('drawRRect', () {
    test('filled RRect has ink at center', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFFFF8800)
        ..style = ui.PaintingStyle.fill;

      canvas.drawRRect(
        ui.RRect.fromRectXY(
            const ui.Rect.fromLTWH(10, 10, 80, 80), 10, 10),
        paint,
      );

      final image = await recorder.endRecording().toImage(100, 100);
      final center = image.getPixel(50, 50);
      expect(center.red, greaterThan(200), reason: 'center should be orange');
      expect(center.alpha, greaterThan(200));
      image.dispose();
    });

    test('filled RRect has no ink at sharp corners (rounded off)', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFFFF0000)
        ..style = ui.PaintingStyle.fill;

      // Large corner radius (20px) should round off the corners significantly
      canvas.drawRRect(
        ui.RRect.fromRectXY(
            const ui.Rect.fromLTWH(10, 10, 80, 80), 20, 20),
        paint,
      );

      final image = await recorder.endRecording().toImage(100, 100);
      // Corner (10,10) should be transparent (rounded off)
      final corner = image.getPixel(11, 11);
      expect(corner.alpha, lessThan(50),
          reason: 'corner pixel should be transparent (rounded off)');
      image.dispose();
    });

    test('stroked RRect has no fill', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFF0000FF)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawRRect(
        ui.RRect.fromRectXY(
            const ui.Rect.fromLTWH(20, 20, 60, 60), 8, 8),
        paint,
      );

      final image = await recorder.endRecording().toImage(100, 100);
      // Center should be transparent
      final center = image.getPixel(50, 50);
      expect(center.alpha, lessThan(50),
          reason: 'interior of stroked RRect should be transparent');
      image.dispose();
    });
  });

  group('drawDRRect', () {
    test('filled DRRect has ink in ring, not in hole', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFFFFFF00)
        ..style = ui.PaintingStyle.fill;

      final outer = ui.RRect.fromRectXY(
          const ui.Rect.fromLTWH(5, 5, 90, 90), 5, 5);
      final inner = ui.RRect.fromRectXY(
          const ui.Rect.fromLTWH(25, 25, 50, 50), 5, 5);

      canvas.drawDRRect(outer, inner, paint);

      final image = await recorder.endRecording().toImage(100, 100);

      // Ring area (between outer and inner) should have yellow ink
      final ringPixel = image.getPixel(10, 50);
      expect(ringPixel.red, greaterThan(200),
          reason: 'ring area should be yellow (red component)');
      expect(ringPixel.green, greaterThan(200),
          reason: 'ring area should be yellow (green component)');

      // Hole (inside inner rect) should be transparent
      final holePixel = image.getPixel(50, 50);
      expect(holePixel.alpha, lessThan(50),
          reason: 'hole (inner rect) should be transparent');

      image.dispose();
    });
  });

  group('drawImageNine', () {
    // Build a simple 3x3 source image (9 pixels) programmatically
    ui.Image _make3x3Image() {
      // 3x3 RGBA pixels: center pixel is green, border is red
      final pixels = List<int>.filled(3 * 3 * 4, 0);
      for (int i = 0; i < 9; i++) {
        final base = i * 4;
        if (i == 4) {
          // center pixel → green
          pixels[base] = 0;
          pixels[base + 1] = 255;
          pixels[base + 2] = 0;
          pixels[base + 3] = 255;
        } else {
          // border pixels → red
          pixels[base] = 255;
          pixels[base + 1] = 0;
          pixels[base + 2] = 0;
          pixels[base + 3] = 255;
        }
      }
      // Use drawImage via a recorder to get a _PureDartImage
      // Actually build via PictureRecorder
      final rec = ui.PictureRecorder();
      final c = ui.Canvas(rec, const ui.Rect.fromLTWH(0, 0, 3, 3));
      // Draw red background
      c.drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.srcOver);
      // Draw green center pixel
      c.drawRect(
          const ui.Rect.fromLTWH(1, 1, 1, 1),
          ui.Paint()
            ..color = const ui.Color(0xFF00FF00)
            ..style = ui.PaintingStyle.fill);
      // We can't get the image synchronously easily here, so return null
      return rec.endRecording().toImageSync(3, 3);
    }

    test('drawImageNine does not crash', () async {
      final src = _make3x3Image();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      canvas.drawImageNine(
        src,
        const ui.Rect.fromLTWH(1, 1, 1, 1), // center slice
        const ui.Rect.fromLTWH(0, 0, 100, 100), // destination
        ui.Paint()..color = const ui.Color(0xFFFFFFFF),
      );

      final image = await recorder.endRecording().toImage(100, 100);
      // Should have produced some ink (not all transparent)
      final pixel = image.getPixel(50, 50);
      expect(pixel.alpha, greaterThan(200),
          reason: '9-slice center should produce ink');
      image.dispose();
      src.dispose();
    });
  });

  group('Path addOval / addArc / addRRect', () {
    test('Path.addOval fills correctly', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFFAA00AA)
        ..style = ui.PaintingStyle.fill;

      final path = ui.Path()
        ..addOval(const ui.Rect.fromLTWH(20, 20, 60, 60));
      canvas.drawPath(path, paint);

      final image = await recorder.endRecording().toImage(100, 100);
      final center = image.getPixel(50, 50);
      expect(center.red, greaterThan(100),
          reason: 'center of oval should be filled');
      expect(center.alpha, greaterThan(200));
      image.dispose();
    });

    test('Path.addRRect fills correctly', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFF007700)
        ..style = ui.PaintingStyle.fill;

      final path = ui.Path()
        ..addRRect(ui.RRect.fromRectXY(
            const ui.Rect.fromLTWH(10, 10, 80, 80), 10, 10));
      canvas.drawPath(path, paint);

      final image = await recorder.endRecording().toImage(100, 100);
      final center = image.getPixel(50, 50);
      expect(center.green, greaterThan(100),
          reason: 'center of RRect path should be filled green');
      expect(center.alpha, greaterThan(200));
      image.dispose();
    });

    test('Path.addArc fills correctly', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()
        ..color = const ui.Color(0xFF0000CC)
        ..style = ui.PaintingStyle.fill;

      final path = ui.Path()
        ..addArc(const ui.Rect.fromLTWH(10, 10, 80, 80), 0, 3.14159 * 2);
      canvas.drawPath(path, paint);

      final image = await recorder.endRecording().toImage(100, 100);
      final center = image.getPixel(50, 50);
      expect(center.blue, greaterThan(150),
          reason: 'full arc should fill like a circle');
      expect(center.alpha, greaterThan(200));
      image.dispose();
    });
  });
}
