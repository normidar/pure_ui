import 'dart:io';
import 'dart:typed_data';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

/// Path to the test font (Geneva.ttf copied from macOS system fonts).
const _fontPath = 'test/fixtures/Roboto-Regular.ttf';
const _fontFamily = 'TestFont';

/// Loads the test font into [ui.FontLoader] and returns the parsed [ui.TtfFont].
ui.TtfFont _loadFont() {
  final bytes = File(_fontPath).readAsBytesSync();
  ui.FontLoader.load(_fontFamily, bytes);
  return ui.TtfFont.load(bytes);
}

/// Rasterises [paragraph] at [offset] in a [size]×[size] canvas and returns
/// the raw RGBA pixels as [Uint8List].
Future<Uint8List> _render(
  ui.Paragraph paragraph,
  ui.Offset offset, {
  int size = 200,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
      recorder, ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));
  canvas.drawParagraph(paragraph, offset);
  final image = await recorder.endRecording().toImage(size, size);
  final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return bd?.buffer.asUint8List() ?? Uint8List(0);
}

/// Returns true if the pixel buffer contains at least one non-transparent pixel.
bool _hasAnyInk(Uint8List rgba) {
  for (int i = 3; i < rgba.length; i += 4) {
    if (rgba[i] > 0) return true;
  }
  return false;
}

/// Returns the number of non-transparent pixels in the buffer.
int _countInkPixels(Uint8List rgba) {
  int count = 0;
  for (int i = 3; i < rgba.length; i += 4) {
    if (rgba[i] > 0) count++;
  }
  return count;
}

ui.Paragraph _buildParagraph(
  String text, {
  double fontSize = 24.0,
  ui.Color color = const ui.Color(0xFF000000),
  String fontFamily = _fontFamily,
}) {
  final style = ui.ParagraphStyle(fontFamily: fontFamily, fontSize: fontSize);
  final builder = ui.ParagraphBuilder(style)
    ..pushStyle(ui.TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
    ))
    ..addText(text)
    ..pop();
  final para = builder.build();
  para.layout(const ui.ParagraphConstraints(width: 500));
  return para;
}

void main() {
  setUpAll(() {
    ui.FontLoader.clear();
    _loadFont();
  });

  tearDownAll(() {
    ui.FontLoader.clear();
  });

  // ── Basic ink tests ──────────────────────────────────────────────────────

  group('Glyph rasterizer – basic ink', () {
    test('drawParagraph produces non-transparent pixels for ASCII text',
        () async {
      final para = _buildParagraph('A');
      final raw = await _render(para, const ui.Offset(10, 40));
      expect(_hasAnyInk(raw), isTrue,
          reason: 'Expected ink pixels after rendering "A"');
    });

    test('drawParagraph with "Hello" produces more ink than single letter',
        () async {
      final paraA = _buildParagraph('A');
      final paraHello = _buildParagraph('Hello');
      final rawA = await _render(paraA, const ui.Offset(10, 40));
      final rawHello = await _render(paraHello, const ui.Offset(10, 40));
      expect(_countInkPixels(rawHello), greaterThan(_countInkPixels(rawA)),
          reason: '"Hello" should produce more ink than "A"');
    });

    test('blank canvas has no ink before drawing', () async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));
      final image = await recorder.endRecording().toImage(100, 100);
      final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final raw = bd?.buffer.asUint8List() ?? Uint8List(0);
      expect(_hasAnyInk(raw), isFalse,
          reason: 'Empty canvas should have no ink');
    });

    test('text at top-left offset has more ink in top-left region', () async {
      final para = _buildParagraph('I');

      Future<int> inkInRegion(ui.Offset off, ui.Rect region) async {
        final raw = await _render(para, off, size: 200);
        int count = 0;
        for (int y = region.top.toInt(); y < region.bottom.toInt(); y++) {
          for (int x = region.left.toInt(); x < region.right.toInt(); x++) {
            if (raw[(y * 200 + x) * 4 + 3] > 0) count++;
          }
        }
        return count;
      }

      final topLeftInk = await inkInRegion(
          const ui.Offset(10, 30), const ui.Rect.fromLTWH(0, 0, 100, 100));
      final bottomRightInk = await inkInRegion(
          const ui.Offset(10, 30), const ui.Rect.fromLTWH(100, 100, 100, 100));

      expect(topLeftInk, greaterThan(0),
          reason: 'Expected ink in top-left region');
      expect(topLeftInk, greaterThan(bottomRightInk),
          reason: 'Text at (10,30) should have more ink in top-left quadrant');
    });
  });

  // ── Color tests ──────────────────────────────────────────────────────────

  group('Glyph rasterizer – color', () {
    test('red text produces red pixels', () async {
      final para = _buildParagraph('A', color: const ui.Color(0xFFFF0000));
      final raw = await _render(para, const ui.Offset(10, 50));

      bool hasRedInk = false;
      for (int i = 0; i < raw.length; i += 4) {
        if (raw[i + 3] > 0 && raw[i] > 100 && raw[i + 1] < 50) {
          hasRedInk = true;
          break;
        }
      }
      expect(hasRedInk, isTrue, reason: 'Expected red ink pixels');
    });

    test('blue text produces blue pixels', () async {
      final para = _buildParagraph('A', color: const ui.Color(0xFF0000FF));
      final raw = await _render(para, const ui.Offset(10, 50));

      bool hasBlueInk = false;
      for (int i = 0; i < raw.length; i += 4) {
        if (raw[i + 3] > 0 && raw[i + 2] > 100 && raw[i] < 50) {
          hasBlueInk = true;
          break;
        }
      }
      expect(hasBlueInk, isTrue, reason: 'Expected blue ink pixels');
    });

    test('different colors produce different pixel patterns', () async {
      final paraRed = _buildParagraph('O', color: const ui.Color(0xFFFF0000));
      final paraBlue = _buildParagraph('O', color: const ui.Color(0xFF0000FF));
      final rawRed = await _render(paraRed, const ui.Offset(10, 50));
      final rawBlue = await _render(paraBlue, const ui.Offset(10, 50));

      bool differ = false;
      for (int i = 0; i < rawRed.length && !differ; i++) {
        if (rawRed[i] != rawBlue[i]) differ = true;
      }
      expect(differ, isTrue, reason: 'Red and blue text should differ');
    });
  });

  // ── Font size tests ──────────────────────────────────────────────────────

  group('Glyph rasterizer – font size', () {
    test('larger font size produces more ink', () async {
      final paraSmall = _buildParagraph('A', fontSize: 12.0);
      final paraLarge = _buildParagraph('A', fontSize: 48.0);
      final rawSmall = await _render(paraSmall, const ui.Offset(10, 60));
      final rawLarge = await _render(paraLarge, const ui.Offset(10, 60));
      expect(_countInkPixels(rawLarge), greaterThan(_countInkPixels(rawSmall)),
          reason: 'Larger font size should produce more ink pixels');
    });
  });

  // ── Glyph outline integrity tests ────────────────────────────────────────

  group('Glyph rasterizer – outline integrity', () {
    test('GlyphOutline for letter A is non-empty', () {
      final bytes = File(_fontPath).readAsBytesSync();
      final font = ui.TtfFont.load(bytes);

      final glyphId = font.getGlyphId('A'.runes.first);
      expect(glyphId, isNotNull);

      final outline = font.getGlyphOutline(glyphId!);
      expect(outline, isNotNull);
      expect(outline!.isEmpty, isFalse);
    });

    test('font metrics ascender is positive', () {
      final bytes = File(_fontPath).readAsBytesSync();
      final font = ui.TtfFont.load(bytes);
      expect(font.metrics.ascender, greaterThan(0));
    });

    test('font metrics unitsPerEm is positive', () {
      final bytes = File(_fontPath).readAsBytesSync();
      final font = ui.TtfFont.load(bytes);
      expect(font.metrics.unitsPerEm, greaterThan(0));
    });
  });

  // ── Multi-span tests ─────────────────────────────────────────────────────

  group('Glyph rasterizer – multi-span paragraph', () {
    test('two spans with different sizes produce ink', () async {
      final style = ui.ParagraphStyle(fontFamily: _fontFamily);
      final builder = ui.ParagraphBuilder(style)
        ..pushStyle(ui.TextStyle(
            fontSize: 20,
            color: const ui.Color(0xFF000000),
            fontFamily: _fontFamily))
        ..addText('Hi')
        ..pop()
        ..pushStyle(ui.TextStyle(
            fontSize: 30,
            color: const ui.Color(0xFFFF0000),
            fontFamily: _fontFamily))
        ..addText('!')
        ..pop();
      final para = builder.build()
        ..layout(const ui.ParagraphConstraints(width: 300));

      final raw = await _render(para, const ui.Offset(10, 50));
      expect(_hasAnyInk(raw), isTrue,
          reason: 'Multi-span paragraph should produce ink');
    });
  });

  // ── Unknown font family ──────────────────────────────────────────────────

  group('Glyph rasterizer – unknown font', () {
    test('unknown font family produces no ink', () async {
      final para = _buildParagraph('A', fontFamily: 'NoSuchFont');
      final raw = await _render(para, const ui.Offset(10, 50));
      expect(_hasAnyInk(raw), isFalse,
          reason: 'Unknown font family should produce no ink');
    });
  });
}
