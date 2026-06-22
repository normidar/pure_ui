import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

void main() {
  group('drawPath color bug tests', () {
    test('drawPath should respect Paint color (current bug reproduction)',
        () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      // Test 1: drawRect works correctly (EXPECTED BEHAVIOR)
      final rectPaint = ui.Paint()..color = const ui.Color(0xFF888888); // Gray
      canvas.drawRect(const ui.Rect.fromLTWH(10, 10, 30, 30), rectPaint);

      // Test 2: drawPath fails to use Paint color (BUG)
      final pathPaint = ui.Paint()..color = const ui.Color(0xFF888888); // Gray
      final path = ui.Path();
      path.addRect(const ui.Rect.fromLTWH(50, 10, 30, 30));
      canvas.drawPath(path, pathPaint);

      // Convert to image and check pixel colors
      final image = await recorder.endRecording().toImage(100, 100);

      // Check rect pixel (should be gray)
      final rectPixel = image.getPixel(25, 25);
      print(
          'Rect pixel (25,25): r=${rectPixel.red.toStringAsFixed(3)}, g=${rectPixel.green.toStringAsFixed(3)}, b=${rectPixel.blue.toStringAsFixed(3)}, a=${rectPixel.alpha.toStringAsFixed(3)}');

      // Check path pixel (should be gray but is currently black due to bug)
      final pathPixel = image.getPixel(65, 25);
      print(
          'Path pixel (65,25): r=${pathPixel.red.toStringAsFixed(3)}, g=${pathPixel.green.toStringAsFixed(3)}, b=${pathPixel.blue.toStringAsFixed(3)}, a=${pathPixel.alpha.toStringAsFixed(3)}');

      // Expected: Both should be gray (136, 136, 136, 255)
      // Actual: Rectangle is gray, but path is black (0, 0, 0, 0) due to bug

      // Currently this test will fail, demonstrating the bug
      // After fix, both pixels should have the same gray color
      expect(rectPixel.red, 136, reason: 'Rectangle should be gray');
      expect(rectPixel.green, 136, reason: 'Rectangle should be gray');
      expect(rectPixel.blue, 136, reason: 'Rectangle should be gray');
      expect(rectPixel.alpha, 255, reason: 'Rectangle should be opaque');

      // This will currently fail due to the bug - path should also be gray
      expect(pathPixel.red, 136,
          reason: 'Path should be gray (currently fails due to bug)');
      expect(pathPixel.green, 136,
          reason: 'Path should be gray (currently fails due to bug)');
      expect(pathPixel.blue, 136,
          reason: 'Path should be gray (currently fails due to bug)');
      expect(pathPixel.alpha, 255,
          reason: 'Path should be opaque (currently fails due to bug)');
    });

    test('drawPath should work with different colors', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      // Red path
      final redPaint = ui.Paint()..color = const ui.Color(0xFFFF0000);
      final redPath = ui.Path()
        ..addRect(const ui.Rect.fromLTWH(10, 10, 20, 20));
      canvas.drawPath(redPath, redPaint);

      // Blue path
      final bluePaint = ui.Paint()..color = const ui.Color(0xFF0000FF);
      final bluePath = ui.Path()
        ..addRect(const ui.Rect.fromLTWH(40, 10, 20, 20));
      canvas.drawPath(bluePath, bluePaint);

      final image = await recorder.endRecording().toImage(100, 100);

      final redPixel = image.getPixel(20, 20);
      expect(redPixel.red, 255, reason: 'Red path should be red');
      expect(redPixel.green, 0, reason: 'Red path should be red');
      expect(redPixel.blue, 0, reason: 'Red path should be red');

      final bluePixel = image.getPixel(50, 20);
      expect(bluePixel.red, 0, reason: 'Blue path should be blue');
      expect(bluePixel.green, 0, reason: 'Blue path should be blue');
      expect(bluePixel.blue, 255, reason: 'Blue path should be blue');
    });

    test('drawPath should work with complex paths', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final paint = ui.Paint()..color = const ui.Color(0xFF00FF00); // Green
      final path = ui.Path()
        ..moveTo(50, 10)
        ..lineTo(70, 40)
        ..lineTo(30, 40)
        ..close();

      canvas.drawPath(path, paint);
      final image = await recorder.endRecording().toImage(100, 100);

      final pixel = image.getPixel(50, 30);
      expect(pixel.green, 255, reason: 'Triangle path should be green');
      expect(pixel.red, 0, reason: 'Triangle path should be green');
      expect(pixel.blue, 0, reason: 'Triangle path should be green');
    });

    test('drawPath should respect PaintingStyle', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      final strokePaint = ui.Paint()
        ..color = const ui.Color(0xFFFF0000)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final path = ui.Path()..addRect(const ui.Rect.fromLTWH(20, 20, 40, 40));
      canvas.drawPath(path, strokePaint);

      final image = await recorder.endRecording().toImage(100, 100);

      // Check stroke pixel (should be red)
      final strokePixel = image.getPixel(20, 20);
      expect(strokePixel.red, 255, reason: 'Stroke should be red');

      // Check interior pixel (should be transparent/background)
      final interiorPixel = image.getPixel(40, 40);
      expect(interiorPixel.alpha, 0,
          reason: 'Interior should be transparent for stroke style');
    });
  });
}
