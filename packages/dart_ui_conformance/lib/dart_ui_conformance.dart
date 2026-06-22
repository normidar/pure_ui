/// Backend-agnostic conformance test suite.
///
/// Call [runDrawingConformanceTests] from a `test/` entrypoint inside an
/// `UiBackend.runWith(...)` scope, so the same assertions run against any
/// backend (plan §7.1).
library dart_ui_conformance;

import 'dart:typed_data';

import 'package:dart_ui_interface/dart_ui_interface.dart';
import 'package:test/test.dart';

/// Runs the drawing-pipeline parity tests against whatever [UiBackend] is
/// currently selected.
void runDrawingConformanceTests() {
  group('drawing conformance', () {
    test('Paint round-trips its properties', () {
      final paint = Paint()
        ..color = const Color(0xFF112233)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.bevel
        ..isAntiAlias = false;
      // Compare the 32-bit ARGB value: backends (including dart:ui) store paint
      // color as float32, so the underlying doubles are not bit-stable.
      expect(paint.color.value, const Color(0xFF112233).value);
      expect(paint.style, PaintingStyle.stroke);
      expect(paint.strokeWidth, 4.0);
      expect(paint.strokeCap, StrokeCap.round);
      expect(paint.strokeJoin, StrokeJoin.bevel);
      expect(paint.isAntiAlias, isFalse);
    });

    test('Path bounds reflect added geometry', () {
      final path = Path()..addRect(const Rect.fromLTWH(10, 20, 30, 40));
      final bounds = path.getBounds();
      expect(bounds.left, closeTo(10, 0.001));
      expect(bounds.top, closeTo(20, 0.001));
      expect(bounds.width, closeTo(30, 0.001));
      expect(bounds.height, closeTo(40, 0.001));
    });

    test('Path.contains', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 100, 100));
      expect(path.contains(const Offset(50, 50)), isTrue);
      expect(path.contains(const Offset(150, 50)), isFalse);
    });

    test('PictureRecorder lifecycle', () {
      final recorder = PictureRecorder();
      expect(recorder.isRecording, isTrue);
      Canvas(recorder, const Rect.fromLTWH(0, 0, 50, 50))
          .drawRect(const Rect.fromLTWH(0, 0, 50, 50), Paint());
      final picture = recorder.endRecording();
      expect(recorder.isRecording, isFalse);
      picture.dispose();
    });

    test('render a rectangle to an image and read pixels back', () async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 20, 20));
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 20, 20),
        Paint()..color = const Color(0xFFFF0000),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(20, 20);
      expect(image.width, 20);
      expect(image.height, 20);

      final bytes = await image.toByteData();
      expect(bytes, isNotNull);
      final data = bytes!.buffer.asUint8List();
      // Top-left pixel should be opaque red.
      expect(data[0], 255, reason: 'red channel');
      expect(data[1], 0, reason: 'green channel');
      expect(data[2], 0, reason: 'blue channel');
      expect(data[3], 255, reason: 'alpha channel');

      image.dispose();
      picture.dispose();
    });

    test('save/restore balances the save count', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 10, 10));
      final start = canvas.getSaveCount();
      canvas.save();
      canvas.translate(5, 5);
      expect(canvas.getSaveCount(), start + 1);
      canvas.restore();
      expect(canvas.getSaveCount(), start);
      recorder.endRecording().dispose();
    });

    test('decodeImageFromPixels produces a usable image', () async {
      final pixels = Uint8List(4 * 4 * 4); // 4x4 RGBA
      for (var i = 0; i < pixels.length; i += 4) {
        pixels[i] = 0; // r
        pixels[i + 1] = 255; // g
        pixels[i + 2] = 0; // b
        pixels[i + 3] = 255; // a
      }
      final image = await UiBackend.instance
          .decodeImageFromPixels(pixels, 4, 4, PixelFormat.rgba8888);
      expect(image.width, 4);
      expect(image.height, 4);
      image.dispose();
    });
  });
}
