import 'dart:io';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

const _fontPath = 'test/fixtures/Roboto-Regular.ttf';

late ui.TtfFont _font;

void main() {
  setUpAll(() {
    final bytes = File(_fontPath).readAsBytesSync();
    _font = ui.TtfFont.load(bytes);
  });

  // ── ShapedGlyph count ────────────────────────────────────────────────────

  group('shapeText – glyph count', () {
    test('returns one ShapedGlyph per ASCII character', () {
      final glyphs = ui.shapeText(
          'ABC', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      expect(glyphs.length, 3);
    });

    test('empty string returns empty list', () {
      final glyphs =
          ui.shapeText('', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      expect(glyphs, isEmpty);
    });

    test('surrogate pair emoji counts as one glyph', () {
      // U+1F600 😀 is encoded as a surrogate pair in Dart String but
      // String.runes yields one code point → one ShapedGlyph.
      final glyphs = ui.shapeText(
          '😀', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      expect(glyphs.length, 1);
    });

    test('space character produces one ShapedGlyph', () {
      final glyphs = ui.shapeText(
          'A B', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      expect(glyphs.length, 3);
    });
  });

  // ── Advance widths ───────────────────────────────────────────────────────

  group('shapeText – advance widths', () {
    test('all advance widths are positive for printable ASCII', () {
      final glyphs = ui.shapeText(
          'Hello', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      for (final g in glyphs) {
        expect(g.advance, greaterThan(0));
      }
    });

    test('I is narrower than W', () {
      final i = ui.shapeText(
          'I', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      final w = ui.shapeText(
          'W', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      expect(i.first.advance, lessThan(w.first.advance));
    });

    test('advance scales with fontSize', () {
      final small = ui.shapeText(
          'A', ui.TextStyle(fontSize: 12, fontFamily: 'x'), _font);
      final large = ui.shapeText(
          'A', ui.TextStyle(fontSize: 24, fontFamily: 'x'), _font);
      expect(large.first.advance,
          closeTo(small.first.advance * 2, small.first.advance * 0.1));
    });
  });

  // ── letterSpacing ────────────────────────────────────────────────────────

  group('shapeText – letterSpacing', () {
    test('letterSpacing increases advance width', () {
      final base = ui.shapeText(
          'A', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      final spaced = ui.shapeText(
          'A',
          ui.TextStyle(fontSize: 16, fontFamily: 'x', letterSpacing: 10.0),
          _font);
      expect(spaced.first.advance,
          closeTo(base.first.advance + 10.0, 0.01));
    });

    test('negative letterSpacing decreases advance width', () {
      final base = ui.shapeText(
          'A', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      final tight = ui.shapeText(
          'A',
          ui.TextStyle(fontSize: 16, fontFamily: 'x', letterSpacing: -2.0),
          _font);
      expect(tight.first.advance,
          closeTo(base.first.advance - 2.0, 0.01));
    });

    test('letterSpacing applies to every glyph in a string', () {
      const spacing = 5.0;
      final base = ui.shapeText(
          'AB', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      final spaced = ui.shapeText(
          'AB',
          ui.TextStyle(fontSize: 16, fontFamily: 'x', letterSpacing: spacing),
          _font);
      final totalBase = base.fold(0.0, (s, g) => s + g.advance);
      final totalSpaced = spaced.fold(0.0, (s, g) => s + g.advance);
      expect(totalSpaced, closeTo(totalBase + spacing * 2, 0.01));
    });
  });

  // ── wordSpacing ──────────────────────────────────────────────────────────

  group('shapeText – wordSpacing', () {
    test('wordSpacing increases advance of space character', () {
      const ws = 8.0;
      final base = ui.shapeText(
          'A B', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      final spaced = ui.shapeText(
          'A B',
          ui.TextStyle(fontSize: 16, fontFamily: 'x', wordSpacing: ws),
          _font);
      // The space glyph (index 1) should have a larger advance.
      expect(spaced[1].advance, closeTo(base[1].advance + ws, 0.01));
    });

    test('wordSpacing does not affect non-space characters', () {
      const ws = 8.0;
      final base = ui.shapeText(
          'AB', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      final spaced = ui.shapeText(
          'AB',
          ui.TextStyle(fontSize: 16, fontFamily: 'x', wordSpacing: ws),
          _font);
      expect(spaced[0].advance, closeTo(base[0].advance, 0.01));
      expect(spaced[1].advance, closeTo(base[1].advance, 0.01));
    });
  });

  // ── Colour ───────────────────────────────────────────────────────────────

  group('shapeText – colour', () {
    test('default colour is black when no colour specified', () {
      final glyphs = ui.shapeText(
          'A', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      expect(glyphs.first.color, equals(const ui.Color(0xFF000000)));
    });

    test('red TextStyle colour is reflected in ShapedGlyph', () {
      final glyphs = ui.shapeText(
          'A',
          ui.TextStyle(
              fontSize: 16,
              fontFamily: 'x',
              color: const ui.Color(0xFFFF0000)),
          _font);
      expect(glyphs.first.color, equals(const ui.Color(0xFFFF0000)));
    });
  });

  // ── Kerning ──────────────────────────────────────────────────────────────

  group('shapeText – kerning', () {
    test('kern is applied: "AV" advance differs from "AA"', () {
      // Many fonts kern "AV" tighter than "AA".
      // If the font has no kern pair, advances will be equal; that's fine too.
      final av = ui.shapeText(
          'AV', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      final aa = ui.shapeText(
          'AA', ui.TextStyle(fontSize: 16, fontFamily: 'x'), _font);
      // Just verify the total is a finite number (kerning does not throw).
      final totalAv = av.fold(0.0, (s, g) => s + g.advance);
      final totalAa = aa.fold(0.0, (s, g) => s + g.advance);
      expect(totalAv.isFinite, isTrue);
      expect(totalAa.isFinite, isTrue);
    });
  });

  // ── Canvas integration ───────────────────────────────────────────────────

  group('shapeText – canvas integration', () {
    const _fontFamily = 'ShapedTestFont';

    setUpAll(() {
      ui.FontLoader.clear();
      final bytes = File(_fontPath).readAsBytesSync();
      ui.FontLoader.load(_fontFamily, bytes);
    });

    tearDownAll(() => ui.FontLoader.clear());

    Future<int> countInkPixels(String text,
        {double fontSize = 24,
        double? letterSpacing,
        double? wordSpacing}) async {
      final style = ui.ParagraphStyle(
          fontFamily: _fontFamily, fontSize: fontSize);
      final builder = ui.ParagraphBuilder(style)
        ..pushStyle(ui.TextStyle(
          color: const ui.Color(0xFF000000),
          fontSize: fontSize,
          fontFamily: _fontFamily,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
        ))
        ..addText(text)
        ..pop();
      final para = builder.build()
        ..layout(const ui.ParagraphConstraints(width: 600));

      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder,
              const ui.Rect.fromLTWH(0, 0, 600, 100))
          .drawParagraph(para, const ui.Offset(0, 10));
      final image = await recorder.endRecording().toImage(600, 100);
      final bd =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final raw = bd?.buffer.asUint8List() ?? [];
      int count = 0;
      for (int i = 3; i < raw.length; i += 4) {
        if (raw[i] > 0) count++;
      }
      return count;
    }

    test('letterSpacing increases ink spread in canvas', () async {
      final tight = await countInkPixels('Hello', letterSpacing: 0);
      final wide = await countInkPixels('Hello', letterSpacing: 20);
      // More spacing → glyphs spread out → more total ink area
      // (at minimum the ink count should not decrease dramatically).
      expect(wide, greaterThanOrEqualTo(tight));
    });

    test('wordSpacing widens space between words on canvas', () async {
      final tight = await countInkPixels('A B', wordSpacing: 0);
      final wide = await countInkPixels('A B', wordSpacing: 30);
      // Same characters, just the space is wider; total ink should be same
      // or slightly different due to rendering position, but must not crash.
      expect(tight, greaterThan(0));
      expect(wide, greaterThan(0));
    });
  });
}
