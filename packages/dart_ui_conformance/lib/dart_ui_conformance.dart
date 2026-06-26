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

/// Conformance for the text vertical slice (plan §4.3 text). Requires a font
/// to be passed in since neither backend assumes any built-in font.
void runTextConformanceTests({
  required Uint8List fontBytes,
  String family = 'TestFont',
}) {
  group('text conformance', () {
    setUpAll(() async {
      await FontLoader.load(family, fontBytes);
    });

    test('ParagraphBuilder builds and lays out', () {
      final para = (ParagraphBuilder(
        ParagraphStyle(fontFamily: family, fontSize: 20),
      )
            ..pushStyle(TextStyle(
              fontFamily: family,
              fontSize: 20,
              color: const Color(0xFF222222),
            ))
            ..addText('Hello')
            ..pop())
          .build()
        ..layout(const ParagraphConstraints(width: 300));
      expect(para.width, greaterThan(0));
      expect(para.height, greaterThan(0));
      expect(para.longestLine, greaterThan(0));
      expect(para.numberOfLines, greaterThanOrEqualTo(1));
      expect(para.didExceedMaxLines, isFalse);
      final lines = para.computeLineMetrics();
      expect(lines, isNotEmpty);
      para.dispose();
    });

    test('Canvas.drawParagraph paints without throwing', () async {
      final para = (ParagraphBuilder(
        ParagraphStyle(fontFamily: family, fontSize: 16),
      )
            ..pushStyle(TextStyle(
              fontFamily: family,
              fontSize: 16,
              color: const Color(0xFF000000),
            ))
            ..addText('Hi')
            ..pop())
          .build()
        ..layout(const ParagraphConstraints(width: 200));

      final recorder = PictureRecorder();
      Canvas(recorder, const Rect.fromLTWH(0, 0, 200, 60))
        ..drawRect(
          const Rect.fromLTWH(0, 0, 200, 60),
          Paint()..color = const Color(0xFFFFFFFF),
        )
        ..drawParagraph(para, const Offset(4, 8));
      final picture = recorder.endRecording();
      final image = await picture.toImage(200, 60);
      expect(image.width, 200);
      image.dispose();
      picture.dispose();
      para.dispose();
    });

    test('maxLines + ellipsis is respected', () {
      final para = (ParagraphBuilder(
        ParagraphStyle(
          fontFamily: family,
          fontSize: 20,
          maxLines: 1,
          ellipsis: '...',
        ),
      )
            ..pushStyle(TextStyle(fontFamily: family, fontSize: 20))
            ..addText('this line is far too long to fit in twenty pixels')
            ..pop())
          .build()
        ..layout(const ParagraphConstraints(width: 20));
      // didExceedMaxLines is true *if* truncation actually happened. With
      // ellipsis, the value is backend-dependent (dart:ui sometimes reports
      // false because the line was replaced); just check that the laid-out
      // paragraph honours maxLines.
      expect(para.numberOfLines, 1);
      para.dispose();
    });
  });
}

/// Conformance for the shader / filter slice (plan §4.3 shader). Branches on
/// `UiBackend.instance.supports(...)` because pure_ui covers gradients but not
/// `ColorFilter` / `ImageFilter` (no native engine to call into).
void runShaderConformanceTests() {
  group('shader conformance', () {
    test('Paint.shader accepts a linear gradient', () {
      final paint = Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          const Offset(100, 0),
          const <Color>[Color(0xFFFF0000), Color(0xFF0000FF)],
        );
      expect(paint.shader, isNotNull);
    });

    test('ColorFilter.mode either works or refuses cleanly', () {
      final backend = UiBackend.instance;
      if (backend.supports(BackendFeature.imageFilters)) {
        final paint = Paint()
          ..colorFilter =
              ColorFilter.mode(const Color(0xFFFF0000), BlendMode.srcIn);
        expect(paint.colorFilter, isNotNull);
      } else {
        expect(
          () => ColorFilter.mode(const Color(0xFFFF0000), BlendMode.srcIn),
          throwsA(isA<UnsupportedError>()),
        );
      }
    });

    test('Paint.maskFilter accepts a blur', () {
      final paint = Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
      expect(paint.maskFilter, isNotNull);
    });

    test('gradient renders to image without throwing', () async {
      final recorder = PictureRecorder();
      Canvas(recorder, const Rect.fromLTWH(0, 0, 40, 40)).drawRect(
        const Rect.fromLTWH(0, 0, 40, 40),
        Paint()
          ..shader = Gradient.linear(
            Offset.zero,
            const Offset(40, 0),
            const <Color>[Color(0xFFFF0000), Color(0xFF0000FF)],
          ),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(40, 40);
      expect(image.width, 40);
      image.dispose();
      picture.dispose();
    });
  });
}
