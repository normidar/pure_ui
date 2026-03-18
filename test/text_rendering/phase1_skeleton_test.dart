import 'dart:typed_data';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

void main() {
  group('ParagraphBuilder (Phase 1 – skeleton)', () {
    test('can be instantiated with default ParagraphStyle', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      expect(builder, isNotNull);
    });

    test('addText does not throw', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      expect(() => builder.addText('Hello'), returnsNormally);
    });

    test('pushStyle/pop does not throw', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.pushStyle(ui.TextStyle(fontSize: 16));
      expect(() => builder.pop(), returnsNormally);
    });

    test('pop on empty stack does not throw', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      expect(() => builder.pop(), returnsNormally);
    });

    test('build() returns a Paragraph', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.addText('Hello');
      final para = builder.build();
      expect(para, isA<ui.Paragraph>());
    });

    test('placeholderCount starts at 0', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      expect(builder.placeholderCount, 0);
    });

    test('addPlaceholder increments placeholderCount', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.addPlaceholder(
        30,
        50,
        ui.PlaceholderAlignment.bottom,
      );
      expect(builder.placeholderCount, 1);
    });

    test('placeholderScales records scale for each placeholder', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.addPlaceholder(30, 50, ui.PlaceholderAlignment.bottom,
          scale: 2.0);
      expect(builder.placeholderScales, [2.0]);
    });

    test('multiple addText calls accumulate spans', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.addText('Hello');
      builder.addText(' World');
      final para = builder.build();
      expect(para, isA<ui.Paragraph>());
    });

    test('nested pushStyle/pop works correctly', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.addText('normal ');
      builder.pushStyle(ui.TextStyle(fontSize: 24));
      builder.addText('big ');
      builder.pushStyle(ui.TextStyle(fontSize: 32));
      builder.addText('bigger');
      builder.pop();
      builder.addText(' back to big');
      builder.pop();
      builder.addText(' normal again');
      expect(() => builder.build(), returnsNormally);
    });
  });

  group('Paragraph (Phase 1 – skeleton)', () {
    ui.Paragraph buildParagraph(String text, {double width = 200}) {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.addText(text);
      final para = builder.build();
      para.layout(ui.ParagraphConstraints(width: width));
      return para;
    }

    test('layout() does not throw', () {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.addText('Hello');
      final para = builder.build();
      expect(
        () => para.layout(const ui.ParagraphConstraints(width: 200)),
        returnsNormally,
      );
    });

    test('width equals constraint after layout', () {
      final para = buildParagraph('Hello', width: 300);
      expect(para.width, 300.0);
    });

    test('height is non-negative', () {
      expect(buildParagraph('Hello').height, greaterThanOrEqualTo(0));
    });

    test('longestLine is non-negative', () {
      expect(buildParagraph('Hello').longestLine, greaterThanOrEqualTo(0));
    });

    test('minIntrinsicWidth is non-negative', () {
      expect(buildParagraph('Hello').minIntrinsicWidth,
          greaterThanOrEqualTo(0));
    });

    test('maxIntrinsicWidth is non-negative', () {
      expect(buildParagraph('Hello').maxIntrinsicWidth,
          greaterThanOrEqualTo(0));
    });

    test('alphabeticBaseline is non-negative', () {
      expect(
          buildParagraph('Hello').alphabeticBaseline, greaterThanOrEqualTo(0));
    });

    test('ideographicBaseline is non-negative', () {
      expect(buildParagraph('Hello').ideographicBaseline,
          greaterThanOrEqualTo(0));
    });

    test('didExceedMaxLines returns bool', () {
      expect(buildParagraph('Hello').didExceedMaxLines, isA<bool>());
    });

    test('numberOfLines is non-negative', () {
      expect(buildParagraph('Hello').numberOfLines, greaterThanOrEqualTo(0));
    });

    test('getBoxesForRange returns a list', () {
      final para = buildParagraph('Hello');
      expect(para.getBoxesForRange(0, 3), isA<List<ui.TextBox>>());
    });

    test('getBoxesForPlaceholders returns a list', () {
      expect(buildParagraph('').getBoxesForPlaceholders(),
          isA<List<ui.TextBox>>());
    });

    test('getPositionForOffset returns a TextPosition', () {
      final para = buildParagraph('Hello');
      expect(
        para.getPositionForOffset(const ui.Offset(10, 10)),
        isA<ui.TextPosition>(),
      );
    });

    test('getClosestGlyphInfoForOffset returns null or GlyphInfo', () {
      final para = buildParagraph('Hello');
      final result =
          para.getClosestGlyphInfoForOffset(const ui.Offset(10, 10));
      expect(result, anyOf(isNull, isA<ui.GlyphInfo>()));
    });

    test('getWordBoundary returns a TextRange', () {
      final para = buildParagraph('Hello world');
      expect(
        para.getWordBoundary(const ui.TextPosition(offset: 0)),
        isA<ui.TextRange>(),
      );
    });

    test('getLineBoundary returns a TextRange', () {
      final para = buildParagraph('Hello');
      expect(
        para.getLineBoundary(const ui.TextPosition(offset: 0)),
        isA<ui.TextRange>(),
      );
    });

    test('computeLineMetrics returns a list', () {
      expect(buildParagraph('Hello').computeLineMetrics(),
          isA<List<ui.LineMetrics>>());
    });

    test('getLineMetricsAt returns null or LineMetrics', () {
      final para = buildParagraph('Hello');
      expect(
        para.getLineMetricsAt(0),
        anyOf(isNull, isA<ui.LineMetrics>()),
      );
    });

    test('getLineNumberAt returns null or int', () {
      final para = buildParagraph('Hello');
      expect(para.getLineNumberAt(0), anyOf(isNull, isA<int>()));
    });

    test('debugDisposed is false before dispose', () {
      expect(buildParagraph('Hello').debugDisposed, isFalse);
    });

    test('dispose sets debugDisposed to true', () {
      final para = buildParagraph('Hello');
      para.dispose();
      expect(para.debugDisposed, isTrue);
    });
  });

  group('Canvas.drawParagraph (Phase 1 – no crash)', () {
    test('drawParagraph does not throw', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(
        recorder,
        const ui.Rect.fromLTWH(0, 0, 200, 60),
      );

      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.addText('Hello');
      final para = builder.build();
      para.layout(const ui.ParagraphConstraints(width: 200));

      expect(
        () => canvas.drawParagraph(para, ui.Offset.zero),
        returnsNormally,
      );
    });

    test('image size is correct after drawParagraph', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(
        recorder,
        const ui.Rect.fromLTWH(0, 0, 200, 60),
      );

      final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
      builder.addText('Hello');
      final para = builder.build();
      para.layout(const ui.ParagraphConstraints(width: 200));
      canvas.drawParagraph(para, ui.Offset.zero);

      final image = await recorder.endRecording().toImage(200, 60);
      expect(image.width, 200);
      expect(image.height, 60);
      image.dispose();
    });
  });

  group('FontLoader (Phase 1)', () {
    setUp(() => ui.FontLoader.clear());
    tearDown(() => ui.FontLoader.clear());

    test('load() registers font bytes', () {
      final dummyBytes = Uint8List.fromList([0x00, 0x01, 0x00, 0x00]);
      ui.FontLoader.load('TestFont', dummyBytes);
      expect(ui.FontLoader.getFont('TestFont'), isNotNull);
    });

    test('getFont() returns null for unregistered family', () {
      expect(ui.FontLoader.getFont('NoSuchFont'), isNull);
    });

    test('hasFamily() returns true after load', () {
      ui.FontLoader.load('MyFont', Uint8List(4));
      expect(ui.FontLoader.hasFamily('MyFont'), isTrue);
    });

    test('hasFamily() returns false for unknown family', () {
      expect(ui.FontLoader.hasFamily('Ghost'), isFalse);
    });

    test('families includes registered family', () {
      ui.FontLoader.load('Alpha', Uint8List(4));
      ui.FontLoader.load('Beta', Uint8List(4));
      expect(ui.FontLoader.families, containsAll(['Alpha', 'Beta']));
    });

    test('load() with weight registers separate variant', () {
      final regular = Uint8List.fromList([1, 2, 3, 4]);
      final bold = Uint8List.fromList([5, 6, 7, 8]);
      ui.FontLoader.load('MyFont', regular);
      ui.FontLoader.load('MyFont', bold, weight: ui.FontWeight.bold);

      final gotRegular =
          ui.FontLoader.getFont('MyFont', weight: ui.FontWeight.normal);
      final gotBold =
          ui.FontLoader.getFont('MyFont', weight: ui.FontWeight.bold);

      expect(gotRegular, regular);
      expect(gotBold, bold);
    });

    test('getFont() falls back to normal when exact variant not found', () {
      final normalBytes = Uint8List.fromList([1, 2, 3, 4]);
      ui.FontLoader.load('MyFont', normalBytes);

      // Request w900 (not registered) → should fall back to normal
      final got = ui.FontLoader.getFont('MyFont', weight: ui.FontWeight.w900);
      expect(got, normalBytes);
    });

    test('clear() removes all fonts', () {
      ui.FontLoader.load('A', Uint8List(4));
      ui.FontLoader.load('B', Uint8List(4));
      ui.FontLoader.clear();
      expect(ui.FontLoader.families, isEmpty);
    });

    test('load() overwrites previous bytes for same key', () {
      final v1 = Uint8List.fromList([1, 2]);
      final v2 = Uint8List.fromList([3, 4]);
      ui.FontLoader.load('X', v1);
      ui.FontLoader.load('X', v2);
      expect(ui.FontLoader.getFont('X'), v2);
    });
  });
}
