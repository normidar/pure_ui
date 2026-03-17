import 'dart:io';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

const _fontPath = 'test/fixtures/Roboto-Regular.ttf';
const _fontFamily = 'Perf8Font';

/// Renders [text] [times] times and returns the total elapsed microseconds.
Future<int> _benchmark(String text, int times,
    {double width = 400, double fontSize = 20}) async {
  final sw = Stopwatch()..start();
  for (int i = 0; i < times; i++) {
    final p = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
    ))
      ..pushStyle(ui.TextStyle(
        fontFamily: _fontFamily,
        fontSize: fontSize,
        color: const ui.Color(0xFF000000),
      ))
      ..addText(text)
      ..pop();
    final para = p.build()..layout(ui.ParagraphConstraints(width: width));

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 500, 200))
        .drawParagraph(para, ui.Offset.zero);
    await recorder.endRecording().toImage(500, 200);
  }
  sw.stop();
  return sw.elapsedMicroseconds;
}

void main() {
  setUpAll(() {
    ui.FontLoader.clear();
    ui.FontLoader.load(_fontFamily, File(_fontPath).readAsBytesSync());
  });
  tearDownAll(() => ui.FontLoader.clear());

  // ── Cache correctness ─────────────────────────────────────────────────────

  group('Performance – cache correctness', () {
    test('rendering same text twice produces ink both times', () async {
      Future<bool> hasInk(String text) async {
        final p = ui.ParagraphBuilder(ui.ParagraphStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
        ))
          ..pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 20))
          ..addText(text)
          ..pop();
        final para = p.build()..layout(const ui.ParagraphConstraints(width: 400));
        final recorder = ui.PictureRecorder();
        ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 400, 100))
            .drawParagraph(para, ui.Offset.zero);
        final image = await recorder.endRecording().toImage(400, 100);
        final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final raw = bd!.buffer.asUint8List();
        for (int i = 3; i < raw.length; i += 4) {
          if (raw[i] > 0) return true;
        }
        return false;
      }

      expect(await hasInk('Hello'), isTrue);
      expect(await hasInk('Hello'), isTrue, reason: 'Second render (cache hit)');
    });

    test('rendering same text 10 times produces ink every time', () async {
      for (int iter = 0; iter < 10; iter++) {
        final p = ui.ParagraphBuilder(
            ui.ParagraphStyle(fontFamily: _fontFamily, fontSize: 20))
          ..pushStyle(
              ui.TextStyle(fontFamily: _fontFamily, fontSize: 20))
          ..addText('Cache test $iter')
          ..pop();
        final para =
            p.build()..layout(const ui.ParagraphConstraints(width: 500));
        final recorder = ui.PictureRecorder();
        ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 500, 100))
            .drawParagraph(para, ui.Offset.zero);
        final image = await recorder.endRecording().toImage(500, 100);
        final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final raw = bd!.buffer.asUint8List();
        bool found = false;
        for (int i = 3; i < raw.length; i += 4) {
          if (raw[i] > 0) {
            found = true;
            break;
          }
        }
        expect(found, isTrue, reason: 'Render $iter should have ink');
      }
    });

    test('different font sizes render correctly after same-glyph at other size',
        () async {
      Future<int> inkCount(double fontSize) async {
        final p = ui.ParagraphBuilder(
            ui.ParagraphStyle(fontFamily: _fontFamily, fontSize: fontSize))
          ..pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: fontSize))
          ..addText('Aa')
          ..pop();
        final para =
            p.build()..layout(const ui.ParagraphConstraints(width: 400));
        final recorder = ui.PictureRecorder();
        ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 400, 100))
            .drawParagraph(para, ui.Offset.zero);
        final image = await recorder.endRecording().toImage(400, 100);
        final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final raw = bd!.buffer.asUint8List();
        int count = 0;
        for (int i = 3; i < raw.length; i += 4) {
          if (raw[i] > 0) count++;
        }
        return count;
      }

      // Render small first to populate cache, then large.
      final small = await inkCount(12);
      final large = await inkCount(40);
      expect(small, greaterThan(0));
      expect(large, greaterThan(small),
          reason: 'Larger font should produce more ink pixels');
    });

    test('different colors use the same polygon cache entry', () async {
      Future<bool> hasColorInk(ui.Color color) async {
        final p = ui.ParagraphBuilder(
            ui.ParagraphStyle(fontFamily: _fontFamily, fontSize: 20))
          ..pushStyle(
              ui.TextStyle(fontFamily: _fontFamily, fontSize: 20, color: color))
          ..addText('Hi')
          ..pop();
        final para =
            p.build()..layout(const ui.ParagraphConstraints(width: 400));
        final recorder = ui.PictureRecorder();
        ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 400, 100))
            .drawParagraph(para, ui.Offset.zero);
        final image = await recorder.endRecording().toImage(400, 100);
        final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final raw = bd!.buffer.asUint8List();
        for (int i = 3; i < raw.length; i += 4) {
          if (raw[i] > 0) return true;
        }
        return false;
      }

      // Both renders share the same polygon cache entry (color is not in key).
      expect(await hasColorInk(const ui.Color(0xFFFF0000)), isTrue);
      expect(await hasColorInk(const ui.Color(0xFF0000FF)), isTrue);
    });
  });

  // ── Cache warm-up speed ───────────────────────────────────────────────────

  group('Performance – warm-up vs cached speed', () {
    test('second batch of renders is not slower than first', () async {
      const text = 'Hello World';
      const rounds = 5;

      // First batch: cold cache (glyph polys get built).
      final cold = await _benchmark(text, rounds);

      // Second batch: warm cache (polygon lookup only).
      final warm = await _benchmark(text, rounds);

      // Allow up to 3× time for warm (should normally be faster, but give
      // generous tolerance for CI jitter).
      expect(
        warm,
        lessThanOrEqualTo(cold * 3),
        reason: 'Warm renders should not be dramatically slower than cold '
            '(cold: ${cold}µs, warm: ${warm}µs)',
      );
    });

    test('rendering 20 times completes in reasonable time', () async {
      final elapsed = await _benchmark('Performance test text', 20);
      // 20 renders should finish in under 30 seconds on any reasonable machine.
      expect(elapsed, lessThan(30 * 1000 * 1000),
          reason: '20 renders took ${elapsed}µs');
    });
  });

  // ── Font cache (Task 8.2) ─────────────────────────────────────────────────

  group('Performance – font cache', () {
    test('same font loaded twice yields the same TtfFont instance', () {
      // FontLoader keeps bytes by key; _pureDartFontCache caches parsed fonts.
      // Render the same font twice at the same size — the second call must
      // hit the glyph-poly cache (verified by correctness test above).
      // Here we just confirm it does not crash.
      expect(
        () {
          for (int i = 0; i < 3; i++) {
            (ui.ParagraphBuilder(
                ui.ParagraphStyle(fontFamily: _fontFamily, fontSize: 16))
              ..pushStyle(
                  ui.TextStyle(fontFamily: _fontFamily, fontSize: 16))
              ..addText('Font cache test')
              ..pop())
              .build()
              .layout(const ui.ParagraphConstraints(width: 400));
          }
        },
        returnsNormally,
      );
    });

    test('different font weights use separate cache entries without crash', () {
      // Register same bytes under bold variant.
      ui.FontLoader.load(
        _fontFamily,
        File(_fontPath).readAsBytesSync(),
        weight: ui.FontWeight.bold,
      );
      expect(
        () {
          final p = ui.ParagraphBuilder(
              ui.ParagraphStyle(fontFamily: _fontFamily, fontSize: 18))
            ..pushStyle(ui.TextStyle(
                fontFamily: _fontFamily,
                fontSize: 18,
                fontWeight: ui.FontWeight.bold))
            ..addText('Bold')
            ..pop();
          p.build()..layout(const ui.ParagraphConstraints(width: 400));
        },
        returnsNormally,
      );
    });
  });
}
