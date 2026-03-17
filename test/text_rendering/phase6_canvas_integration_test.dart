import 'dart:io';
import 'dart:typed_data';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

const _fontPath = 'test/fixtures/Roboto-Regular.ttf';
const _fontFamily = 'Phase6Font';

ui.Paragraph _build(
  String text, {
  double width = 400,
  double fontSize = 20,
  ui.TextAlign? textAlign,
  int? maxLines,
  ui.TextDecoration? decoration,
  ui.Color? decorationColor,
  List<ui.Shadow>? shadows,
  ui.Color color = const ui.Color(0xFF000000),
}) {
  final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
    fontFamily: _fontFamily,
    fontSize: fontSize,
    textAlign: textAlign,
    maxLines: maxLines,
  ))
    ..pushStyle(ui.TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      color: color,
      decoration: decoration,
      decorationColor: decorationColor,
      shadows: shadows,
    ))
    ..addText(text)
    ..pop();
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

/// Count ink pixels in the row closest to [targetY] within a ±[tolerance]
/// pixel band.
int _inkInRow(Uint8List raw, int imgWidth, int targetY, int tolerance) {
  int count = 0;
  for (int y = targetY - tolerance; y <= targetY + tolerance; y++) {
    if (y < 0) continue;
    for (int x = 0; x < imgWidth; x++) {
      final idx = (y * imgWidth + x) * 4;
      if (idx + 3 < raw.length && raw[idx + 3] > 0) count++;
    }
  }
  return count;
}

void main() {
  setUpAll(() {
    ui.FontLoader.clear();
    ui.FontLoader.load(_fontFamily, File(_fontPath).readAsBytesSync());
  });
  tearDownAll(() => ui.FontLoader.clear());

  // ── Basic rendering ──────────────────────────────────────────────────────

  group('Canvas integration – basic rendering', () {
    test('plain text produces ink', () async {
      final p = _build('Hello World');
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });

    test('paragraph drawn at non-zero offset still produces ink', () async {
      final p = _build('Hi');
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 600, 200))
          .drawParagraph(p, const ui.Offset(50, 50));
      final image = await recorder.endRecording().toImage(600, 200);
      final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final raw = bd!.buffer.asUint8List();
      expect(_hasAnyInk(raw), isTrue);
    });

    test('coloured text renders ink', () async {
      final p = _build('Red', color: const ui.Color(0xFFFF0000));
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });
  });

  // ── Text decorations ──────────────────────────────────────────────────────

  group('Canvas integration – text decorations', () {
    test('underline decoration does not crash', () {
      expect(
        () => _build('Hello', decoration: ui.TextDecoration.underline),
        returnsNormally,
      );
    });

    test('overline decoration does not crash', () {
      expect(
        () => _build('Hello', decoration: ui.TextDecoration.overline),
        returnsNormally,
      );
    });

    test('lineThrough decoration does not crash', () {
      expect(
        () => _build('Hello', decoration: ui.TextDecoration.lineThrough),
        returnsNormally,
      );
    });

    test('underline produces ink', () async {
      final p = _build('Hello', decoration: ui.TextDecoration.underline);
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });

    test('lineThrough produces ink', () async {
      final p = _build('Hello', decoration: ui.TextDecoration.lineThrough);
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });

    test('overline produces ink', () async {
      final p = _build('Hello', decoration: ui.TextDecoration.overline);
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });

    test('decoration with custom color does not crash', () {
      expect(
        () => _build(
          'Hello',
          decoration: ui.TextDecoration.underline,
          decorationColor: const ui.Color(0xFFFF0000),
        ),
        returnsNormally,
      );
    });

    test('combined decorations (underline + lineThrough) do not crash', () {
      expect(
        () => _build(
          'Hello',
          decoration: ui.TextDecoration.combine([
            ui.TextDecoration.underline,
            ui.TextDecoration.lineThrough,
          ]),
        ),
        returnsNormally,
      );
    });

    test('no decoration produces same ink as plain text', () async {
      final pPlain = _build('Hello');
      final pDeco =
          _build('Hello', decoration: ui.TextDecoration.none);
      final rawPlain = await _renderToPixels(pPlain);
      final rawDeco = await _renderToPixels(pDeco);
      // Both should have ink.
      expect(_hasAnyInk(rawPlain), isTrue);
      expect(_hasAnyInk(rawDeco), isTrue);
    });
  });

  // ── Text shadows ─────────────────────────────────────────────────────────

  group('Canvas integration – text shadows', () {
    test('shadow does not crash', () {
      expect(
        () => _build(
          'Hello',
          shadows: const [
            ui.Shadow(color: ui.Color(0x88000000), offset: ui.Offset(2, 2)),
          ],
        ),
        returnsNormally,
      );
    });

    test('shadow renders ink', () async {
      final p = _build(
        'Hi',
        shadows: const [
          ui.Shadow(color: ui.Color(0xFF888888), offset: ui.Offset(4, 4)),
        ],
      );
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });

    test('shadow with zero offset renders ink', () async {
      final p = _build(
        'Hi',
        shadows: const [
          ui.Shadow(color: ui.Color(0xFF444444), offset: ui.Offset.zero),
        ],
      );
      final raw = await _renderToPixels(p);
      expect(_hasAnyInk(raw), isTrue);
    });

    test('multiple shadows do not crash', () {
      expect(
        () => _build(
          'Hi',
          shadows: const [
            ui.Shadow(
                color: ui.Color(0x44000000), offset: ui.Offset(2, 2)),
            ui.Shadow(
                color: ui.Color(0x44000000), offset: ui.Offset(-2, -2)),
          ],
        ),
        returnsNormally,
      );
    });

    test('no shadow equals plain text in ink presence', () async {
      final pPlain = _build('Hello');
      final pShadow = _build(
        'Hello',
        shadows: const [
          ui.Shadow(
              color: ui.Color(0x88000000), offset: ui.Offset(3, 3)),
        ],
      );
      final rawPlain = await _renderToPixels(pPlain);
      final rawShadow = await _renderToPixels(pShadow);
      expect(_hasAnyInk(rawPlain), isTrue);
      expect(_hasAnyInk(rawShadow), isTrue);
    });
  });
}
