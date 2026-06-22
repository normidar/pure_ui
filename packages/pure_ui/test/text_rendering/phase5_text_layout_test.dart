import 'dart:io';
import 'dart:typed_data';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

const _fontPath = 'test/fixtures/Roboto-Regular.ttf';
const _fontFamily = 'LayoutTestFont';

ui.Paragraph _build(
  String text, {
  double width = 500,
  double? fontSize,
  ui.TextAlign? textAlign,
  int? maxLines,
  String? ellipsis,
  ui.Color color = const ui.Color(0xFF000000),
}) {
  final para = ui.ParagraphBuilder(ui.ParagraphStyle(
    fontFamily: _fontFamily,
    fontSize: fontSize,
    textAlign: textAlign,
    maxLines: maxLines,
    ellipsis: ellipsis,
  ))
    ..pushStyle(ui.TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize ?? 20,
      color: color,
    ))
    ..addText(text)
    ..pop();
  return para.build()..layout(ui.ParagraphConstraints(width: width));
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

void main() {
  setUpAll(() {
    ui.FontLoader.clear();
    ui.FontLoader.load(_fontFamily, File(_fontPath).readAsBytesSync());
  });
  tearDownAll(() => ui.FontLoader.clear());

  // ── Single-line metrics ──────────────────────────────────────────────────

  group('Layout – single line', () {
    test('height is positive after layout', () {
      final p = _build('Hello');
      expect(p.height, greaterThan(0));
    });

    test('longestLine is positive for non-empty text', () {
      final p = _build('Hello');
      expect(p.longestLine, greaterThan(0));
    });

    test('alphabeticBaseline is positive and less than height', () {
      final p = _build('Hello');
      expect(p.alphabeticBaseline, greaterThan(0));
      expect(p.alphabeticBaseline, lessThanOrEqualTo(p.height));
    });

    test('computeLineMetrics returns one entry for single-line text', () {
      final p = _build('Hello', width: 500);
      expect(p.computeLineMetrics().length, 1);
    });

    test('LineMetrics ascent + descent equals height', () {
      final p = _build('Hello');
      final m = p.computeLineMetrics().first;
      expect(m.ascent + m.descent, closeTo(m.height, 0.01));
    });

    test('LineMetrics lineNumber is 0 for first line', () {
      final p = _build('Hello');
      expect(p.computeLineMetrics().first.lineNumber, 0);
    });

    test('numberOfLines is 1 for short single-line text', () {
      final p = _build('Hi', width: 500);
      expect(p.numberOfLines, 1);
    });

    test('width property equals constraint width', () {
      final p = _build('Hello', width: 300);
      expect(p.width, closeTo(300, 0.01));
    });

    test('didExceedMaxLines is false when text fits', () {
      final p = _build('Hi', maxLines: 5);
      expect(p.didExceedMaxLines, isFalse);
    });
  });

  // ── Multi-line wrapping ──────────────────────────────────────────────────

  group('Layout – line wrapping', () {
    test('long text wraps to multiple lines at narrow width', () {
      final p = _build(
          'This is a long sentence that should wrap across multiple lines.',
          width: 120,
          fontSize: 16);
      expect(p.computeLineMetrics().length, greaterThan(1));
    });

    test('height grows with number of lines', () {
      final narrow = _build('Hello world foo bar baz', width: 80, fontSize: 16);
      final wide = _build('Hello world foo bar baz', width: 500, fontSize: 16);
      expect(narrow.height, greaterThanOrEqualTo(wide.height));
    });

    test('newline character forces a line break', () {
      final p = _build('Line1\nLine2', width: 500);
      expect(p.computeLineMetrics().length, greaterThanOrEqualTo(2));
    });

    test('two newlines produce at least two lines', () {
      final p = _build('A\nB\nC', width: 500);
      expect(p.numberOfLines, greaterThanOrEqualTo(3));
    });

    test('longestLine does not exceed constraint width', () {
      final p = _build('A fairly long piece of text to force wrapping.',
          width: 100, fontSize: 16);
      // Allow a small rounding tolerance.
      expect(p.longestLine, lessThanOrEqualTo(100 + 5));
    });

    test('wrapping text has sequential lineNumber values', () {
      final p = _build('a b c d e f g h i j k', width: 60, fontSize: 20);
      final metrics = p.computeLineMetrics();
      for (int i = 0; i < metrics.length; i++) {
        expect(metrics[i].lineNumber, i);
      }
    });
  });

  // ── maxLines ────────────────────────────────────────────────────────────

  group('Layout – maxLines', () {
    test('maxLines=1 limits output to one line', () {
      final p = _build('Hello world foo bar baz qux',
          width: 80, fontSize: 16, maxLines: 1);
      expect(p.numberOfLines, 1);
    });

    test('maxLines=2 limits output to two lines', () {
      final p = _build('a b c d e f g h i j k l m',
          width: 60, fontSize: 20, maxLines: 2);
      expect(p.numberOfLines, lessThanOrEqualTo(2));
    });

    test('didExceedMaxLines is true when text is truncated', () {
      final p = _build('One two three four five six seven eight',
          width: 80, fontSize: 16, maxLines: 1);
      expect(p.didExceedMaxLines, isTrue);
    });

    test('didExceedMaxLines is false when maxLines >= actual lines', () {
      final p = _build('Hi', width: 500, maxLines: 10);
      expect(p.didExceedMaxLines, isFalse);
    });
  });

  // ── ellipsis ────────────────────────────────────────────────────────────

  group('Layout – ellipsis', () {
    test('ellipsis does not crash', () {
      expect(
        () => _build('Hello world foo bar baz',
            width: 80, fontSize: 16, maxLines: 1, ellipsis: '...'),
        returnsNormally,
      );
    });

    test('paragraph with ellipsis still has numberOfLines 1', () {
      final p = _build('Hello world foo bar baz',
          width: 80, fontSize: 16, maxLines: 1, ellipsis: '...');
      expect(p.numberOfLines, 1);
    });
  });

  // ── TextAlign ────────────────────────────────────────────────────────────

  group('Layout – TextAlign', () {
    test('left-aligned line has left=0', () {
      final p =
          _build('Hi', width: 400, textAlign: ui.TextAlign.left, fontSize: 20);
      expect(p.computeLineMetrics().first.left, closeTo(0.0, 0.5));
    });

    test('right-aligned line has left > 0 for short text in wide paragraph',
        () {
      final p =
          _build('Hi', width: 400, textAlign: ui.TextAlign.right, fontSize: 20);
      expect(p.computeLineMetrics().first.left, greaterThan(0));
    });

    test('center-aligned line has left > 0 for short text in wide paragraph',
        () {
      final p = _build('Hi',
          width: 400, textAlign: ui.TextAlign.center, fontSize: 20);
      expect(p.computeLineMetrics().first.left, greaterThan(0));
    });

    test('center left is roughly half of (width - lineWidth)', () {
      final p = _build('Hi',
          width: 400, textAlign: ui.TextAlign.center, fontSize: 20);
      final m = p.computeLineMetrics().first;
      final expected = (400 - m.width) / 2;
      expect(m.left, closeTo(expected, 2.0));
    });
  });

  // ── getLineMetricsAt ────────────────────────────────────────────────────

  group('Layout – getLineMetricsAt', () {
    test('returns non-null for valid line index', () {
      final p = _build('Hello\nWorld');
      expect(p.getLineMetricsAt(0), isNotNull);
      expect(p.getLineMetricsAt(1), isNotNull);
    });

    test('returns null for out-of-range index', () {
      final p = _build('Hello');
      expect(p.getLineMetricsAt(99), isNull);
      expect(p.getLineMetricsAt(-1), isNull);
    });
  });

  // ── intrinsic widths ────────────────────────────────────────────────────

  group('Layout – intrinsic widths', () {
    test('maxIntrinsicWidth is positive for non-empty text', () {
      final p = _build('Hello World');
      expect(p.maxIntrinsicWidth, greaterThan(0));
    });

    test('maxIntrinsicWidth >= longestLine', () {
      final p = _build('Hello World foo', width: 200, fontSize: 16);
      expect(p.maxIntrinsicWidth, greaterThanOrEqualTo(p.longestLine - 1));
    });
  });

  // ── Canvas rendering ────────────────────────────────────────────────────

  group('Layout – canvas rendering', () {
    test('multi-line text produces ink', () async {
      final p = _build('Hello\nWorld', width: 300);
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });

    test('text aligned right renders ink on the right side', () async {
      final p =
          _build('Hi', width: 400, textAlign: ui.TextAlign.right, fontSize: 30);
      final raw = await _renderToPixels(p, imgWidth: 400, imgHeight: 100);

      // Count ink in left half vs right half
      int leftInk = 0, rightInk = 0;
      for (int y = 0; y < 100; y++) {
        for (int x = 0; x < 400; x++) {
          if (raw[(y * 400 + x) * 4 + 3] > 0) {
            if (x < 200)
              leftInk++;
            else
              rightInk++;
          }
        }
      }
      expect(rightInk, greaterThan(leftInk),
          reason: 'Right-aligned text should have more ink on the right');
    });

    test('wrapped text fills more vertical space than single-line', () async {
      final narrow = _build('Hello World', width: 60, fontSize: 20);
      final wide = _build('Hello World', width: 500, fontSize: 20);

      final rawNarrow = await _renderToPixels(narrow, imgHeight: 300);
      final rawWide = await _renderToPixels(wide, imgHeight: 300);

      // Narrow should put ink lower (higher Y) than wide
      int maxInkY(Uint8List raw, int w, int h) {
        for (int y = h - 1; y >= 0; y--) {
          for (int x = 0; x < w; x++) {
            if (raw[(y * w + x) * 4 + 3] > 0) return y;
          }
        }
        return 0;
      }

      expect(maxInkY(rawNarrow, 600, 300),
          greaterThanOrEqualTo(maxInkY(rawWide, 600, 300)));
    });
  });
}
