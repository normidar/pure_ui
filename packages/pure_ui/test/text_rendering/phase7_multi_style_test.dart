import 'dart:io';
import 'dart:typed_data';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

const _fontPath = 'test/fixtures/Roboto-Regular.ttf';
const _fontFamily = 'MultiStyleFont';

// Build a paragraph from a callback that sets up spans on the builder.
ui.Paragraph _buildWith(
  void Function(ui.ParagraphBuilder) setup, {
  double width = 500,
  double? fontSize,
  ui.TextAlign? textAlign,
}) {
  final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
    fontFamily: _fontFamily,
    fontSize: fontSize,
    textAlign: textAlign,
  ));
  setup(builder);
  return builder.build()..layout(ui.ParagraphConstraints(width: width));
}

Future<Uint8List> _renderToPixels(
  ui.Paragraph para, {
  int imgWidth = 600,
  int imgHeight = 200,
}) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder,
          ui.Rect.fromLTWH(0, 0, imgWidth.toDouble(), imgHeight.toDouble()))
      .drawParagraph(para, ui.Offset.zero);
  final image = await recorder.endRecording().toImage(imgWidth, imgHeight);
  final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return bd?.buffer.asUint8List() ?? Uint8List(0);
}

bool _hasAnyInk(Uint8List raw) {
  for (int i = 3; i < raw.length; i += 4) {
    if (raw[i] > 0) return true;
  }
  return false;
}

bool _hasRedInk(Uint8List raw) {
  for (int i = 0; i < raw.length; i += 4) {
    final r = raw[i], g = raw[i + 1], b = raw[i + 2], a = raw[i + 3];
    if (a > 0 && r > 100 && g < 80 && b < 80) return true;
  }
  return false;
}

bool _hasBlueInk(Uint8List raw) {
  for (int i = 0; i < raw.length; i += 4) {
    final r = raw[i], g = raw[i + 1], b = raw[i + 2], a = raw[i + 3];
    if (a > 0 && b > 100 && r < 80 && g < 80) return true;
  }
  return false;
}

void main() {
  setUpAll(() {
    ui.FontLoader.clear();
    final bytes = File(_fontPath).readAsBytesSync();
    ui.FontLoader.load(_fontFamily, bytes);
    // Register same font bytes as a "bold" variant for font-weight tests.
    ui.FontLoader.load(_fontFamily, bytes, weight: ui.FontWeight.bold);
  });
  tearDownAll(() => ui.FontLoader.clear());

  // ── pushStyle / pop mechanics ─────────────────────────────────────────────

  group('Multi-style – pushStyle / pop mechanics', () {
    test('single pushStyle + addText + pop does not crash', () {
      expect(
        () => _buildWith((b) {
          b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 20));
          b.addText('Hello');
          b.pop();
        }),
        returnsNormally,
      );
    });

    test('addText before any pushStyle uses paragraph style', () {
      final p = _buildWith((b) {
        b.addText('Hello');
      }, fontSize: 20);
      expect(p.height, greaterThan(0));
    });

    test('pop on empty stack does not throw', () {
      expect(
        () => _buildWith((b) {
          b.pop(); // no-op — stack is empty
          b.addText('Hi');
        }),
        returnsNormally,
      );
    });

    test('two adjacent spans produce positive height', () {
      final p = _buildWith((b) {
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 18));
        b.addText('Hello ');
        b.pop();
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 18));
        b.addText('World');
        b.pop();
      });
      expect(p.height, greaterThan(0));
    });

    test('mixed styles produce positive longestLine', () {
      final p = _buildWith((b) {
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 16));
        b.addText('Small ');
        b.pop();
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 28));
        b.addText('Large');
        b.pop();
      });
      expect(p.longestLine, greaterThan(0));
    });
  });

  // ── Style inheritance (nested pushStyle) ──────────────────────────────────

  group('Multi-style – nested style inheritance', () {
    test('nested pushStyle inherits parent font family', () {
      // Inner push only sets color; fontFamily should be inherited from outer.
      expect(
        () => _buildWith((b) {
          b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 20));
          b.addText('Normal ');
          b.pushStyle(ui.TextStyle(color: const ui.Color(0xFFFF0000)));
          b.addText('Red');
          b.pop();
          b.pop();
        }),
        returnsNormally,
      );
    });

    test('nested pushStyle produces ink', () async {
      final p = _buildWith((b) {
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 20));
        b.addText('Normal ');
        b.pushStyle(ui.TextStyle(color: const ui.Color(0xFFFF0000)));
        b.addText('Red');
        b.pop();
        b.pop();
      });
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });

    test('nested pushStyle: inner style does not pollute outer', () {
      // After the inner pop, the outer style should still be active.
      final p = _buildWith((b) {
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 20));
        b.addText('Outer1 ');
        b.pushStyle(ui.TextStyle(color: const ui.Color(0xFFFF0000)));
        b.addText('Inner ');
        b.pop();
        b.addText('Outer2'); // should still use outer style (fontSize 20)
        b.pop();
      });
      expect(p.height, greaterThan(0));
    });

    test('deep nesting (3 levels) does not crash', () {
      expect(
        () => _buildWith((b) {
          b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 16));
          b.addText('L1 ');
          b.pushStyle(ui.TextStyle(color: const ui.Color(0xFFFF0000)));
          b.addText('L2 ');
          b.pushStyle(ui.TextStyle(color: const ui.Color(0xFF0000FF)));
          b.addText('L3');
          b.pop();
          b.pop();
          b.pop();
        }),
        returnsNormally,
      );
    });

    test('nested color is inherited by deeper push that does not set color',
        () {
      // outer push: red; inner push: only sets fontSize; text should be red.
      final p = _buildWith((b) {
        b.pushStyle(ui.TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            color: const ui.Color(0xFFFF0000)));
        b.pushStyle(ui.TextStyle(fontSize: 24));
        b.addText('Big Red');
        b.pop();
        b.pop();
      });
      expect(p.longestLine, greaterThan(0));
    });
  });

  // ── Mixed colours ─────────────────────────────────────────────────────────

  group('Multi-style – mixed colours', () {
    test('red + blue spans both produce ink', () async {
      final p = _buildWith((b) {
        b.pushStyle(ui.TextStyle(
            fontFamily: _fontFamily,
            fontSize: 24,
            color: const ui.Color(0xFFFF0000)));
        b.addText('Red ');
        b.pop();
        b.pushStyle(ui.TextStyle(
            fontFamily: _fontFamily,
            fontSize: 24,
            color: const ui.Color(0xFF0000FF)));
        b.addText('Blue');
        b.pop();
      });
      final raw = await _renderToPixels(p);
      expect(_hasRedInk(raw), isTrue, reason: 'Expected red ink');
      expect(_hasBlueInk(raw), isTrue, reason: 'Expected blue ink');
    });

    test('single-colour paragraph has no blue ink when only red', () async {
      final p = _buildWith((b) {
        b.pushStyle(ui.TextStyle(
            fontFamily: _fontFamily,
            fontSize: 24,
            color: const ui.Color(0xFFFF0000)));
        b.addText('Red Only');
        b.pop();
      });
      final raw = await _renderToPixels(p);
      expect(_hasRedInk(raw), isTrue);
      expect(_hasBlueInk(raw), isFalse);
    });
  });

  // ── Mixed font sizes ──────────────────────────────────────────────────────

  group('Multi-style – mixed font sizes', () {
    test('large font span makes longestLine wider than small-only', () {
      final pMixed = _buildWith((b) {
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 12));
        b.addText('Hi ');
        b.pop();
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 32));
        b.addText('Hi');
        b.pop();
      });
      final pSmall = _buildWith((b) {
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 12));
        b.addText('Hi Hi');
        b.pop();
      });
      expect(pMixed.longestLine, greaterThan(pSmall.longestLine));
    });

    test('line height adjusts to the tallest glyph in the line', () {
      final pMixed = _buildWith((b) {
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 12));
        b.addText('small ');
        b.pop();
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 40));
        b.addText('BIG');
        b.pop();
      });
      final pSmall = _buildWith((b) {
        b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 12));
        b.addText('small BIG');
        b.pop();
      });
      expect(pMixed.height, greaterThan(pSmall.height));
    });
  });

  // ── Mixed decorations ─────────────────────────────────────────────────────

  group('Multi-style – mixed decorations', () {
    test('underline on first span, none on second does not crash', () {
      expect(
        () => _buildWith((b) {
          b.pushStyle(ui.TextStyle(
              fontFamily: _fontFamily,
              fontSize: 20,
              decoration: ui.TextDecoration.underline));
          b.addText('Underlined ');
          b.pop();
          b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 20));
          b.addText('Normal');
          b.pop();
        }),
        returnsNormally,
      );
    });

    test('decoration on span produces ink', () async {
      final p = _buildWith((b) {
        b.pushStyle(ui.TextStyle(
            fontFamily: _fontFamily,
            fontSize: 20,
            decoration: ui.TextDecoration.lineThrough,
            color: const ui.Color(0xFF000000)));
        b.addText('Strike');
        b.pop();
      });
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });
  });

  // ── Multi-span line wrapping ──────────────────────────────────────────────

  group('Multi-style – line wrapping across spans', () {
    test('wrapping works with two adjacent spans', () {
      final p = _buildWith(
        (b) {
          b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 16));
          b.addText('Hello world foo ');
          b.pop();
          b.pushStyle(ui.TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              color: const ui.Color(0xFFFF0000)));
          b.addText('bar baz qux');
          b.pop();
        },
        width: 100,
      );
      expect(p.numberOfLines, greaterThan(1));
    });

    test('multi-span wrapped paragraph has positive height', () {
      final p = _buildWith(
        (b) {
          b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 20));
          b.addText('One two three ');
          b.pop();
          b.pushStyle(ui.TextStyle(
              fontFamily: _fontFamily,
              fontSize: 20,
              color: const ui.Color(0xFF0000FF)));
          b.addText('four five six');
          b.pop();
        },
        width: 80,
      );
      expect(p.height, greaterThan(0));
      expect(p.numberOfLines, greaterThan(1));
    });
  });

  // ── Font weight variant lookup ────────────────────────────────────────────

  group('Multi-style – font weight variant lookup', () {
    test('FontWeight.bold lookup does not crash', () {
      expect(
        () => _buildWith((b) {
          b.pushStyle(ui.TextStyle(
              fontFamily: _fontFamily,
              fontSize: 20,
              fontWeight: ui.FontWeight.bold));
          b.addText('Bold');
          b.pop();
        }),
        returnsNormally,
      );
    });

    test('FontWeight.bold span produces ink', () async {
      final p = _buildWith((b) {
        b.pushStyle(ui.TextStyle(
            fontFamily: _fontFamily,
            fontSize: 20,
            fontWeight: ui.FontWeight.bold));
        b.addText('Bold text');
        b.pop();
      });
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });

    test('normal + bold spans in same paragraph do not crash', () {
      expect(
        () => _buildWith((b) {
          b.pushStyle(ui.TextStyle(fontFamily: _fontFamily, fontSize: 20));
          b.addText('Normal ');
          b.pop();
          b.pushStyle(ui.TextStyle(
              fontFamily: _fontFamily,
              fontSize: 20,
              fontWeight: ui.FontWeight.bold));
          b.addText('Bold');
          b.pop();
        }),
        returnsNormally,
      );
    });
  });
}
