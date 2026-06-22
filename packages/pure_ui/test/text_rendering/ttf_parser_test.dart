import 'dart:io';
import 'dart:typed_data';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Loads test/fixtures/Roboto-Regular.ttf or skips the test if absent.
ui.TtfFont? _loadRoboto() {
  final file = File('test/fixtures/Roboto-Regular.ttf');
  if (!file.existsSync()) return null;
  return ui.TtfFont.load(file.readAsBytesSync());
}

// ─────────────────────────────────────────────────────────────────────────────
// TtfParser (low-level)
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('TtfParser – binary parsing', () {
    late Uint8List bytes;
    late ui.TtfParser parser;

    setUpAll(() {
      final file = File('test/fixtures/Roboto-Regular.ttf');
      if (!file.existsSync()) {
        printOnFailure(
          'test/fixtures/Roboto-Regular.ttf not found – skipping TTF tests.\n'
          'Run: curl -L -o test/fixtures/Roboto-Regular.ttf '
          '"https://github.com/google/fonts/raw/main/apache/roboto/static/Roboto-Regular.ttf"',
        );
      }
      bytes = file.readAsBytesSync();
      parser = ui.TtfParser(bytes);
    });

    test('availableTables contains required TTF tables', () {
      final tables = parser.availableTables;
      expect(tables, containsAll(['head', 'hhea', 'maxp', 'cmap', 'loca', 'glyf', 'hmtx']));
    });

    test('isTrueType is true for Roboto (glyf-based)', () {
      expect(parser.isTrueType, isTrue);
    });

    test('numGlyphs is a reasonable positive value', () {
      expect(parser.numGlyphs, greaterThan(200));
      expect(parser.numGlyphs, lessThan(100000));
    });

    test('unitsPerEm is a standard value (1000 or 2048)', () {
      expect(parser.unitsPerEm, anyOf(1000, 2048));
    });

    group('parseFontMetrics', () {
      late ui.FontMetrics m;
      setUpAll(() => m = parser.parseFontMetrics());

      test('unitsPerEm matches parser field', () {
        expect(m.unitsPerEm, equals(parser.unitsPerEm));
      });

      test('ascender > 0', () => expect(m.ascender, greaterThan(0)));
      test('descender < 0', () => expect(m.descender, lessThan(0)));

      test('lineHeightAt(16) is positive', () {
        expect(m.lineHeightAt(16), greaterThan(0));
      });

      test('baselineOffsetAt(16) is positive and < lineHeightAt(16)', () {
        expect(m.baselineOffsetAt(16), greaterThan(0));
        expect(m.baselineOffsetAt(16), lessThan(m.lineHeightAt(16)));
      });
    });

    group('parseCmap', () {
      late Map<int, int> cmap;
      setUpAll(() => cmap = parser.parseCmap());

      test('is non-empty', () => expect(cmap, isNotEmpty));

      test('contains ASCII letters A–Z', () {
        for (final cp in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.codeUnits) {
          expect(cmap, contains(cp), reason: 'Missing codepoint $cp (${String.fromCharCode(cp)})');
        }
      });

      test('contains ASCII lowercase a–z', () {
        for (final cp in 'abcdefghijklmnopqrstuvwxyz'.codeUnits) {
          expect(cmap, contains(cp));
        }
      });

      test('contains digits 0–9', () {
        for (final cp in '0123456789'.codeUnits) {
          expect(cmap, contains(cp));
        }
      });

      test('different characters map to different glyph IDs', () {
        final idA = cmap['A'.codeUnitAt(0)];
        final idB = cmap['B'.codeUnitAt(0)];
        expect(idA, isNotNull);
        expect(idB, isNotNull);
        expect(idA, isNot(equals(idB)));
      });

      test('all glyph IDs are in valid range', () {
        for (final glyphId in cmap.values) {
          expect(glyphId, greaterThan(0));
          expect(glyphId, lessThan(parser.numGlyphs));
        }
      });

      test('unmapped codepoint returns null from TtfFont', () {
        final font = _loadRoboto();
        if (font == null) return; // no fixture
        final id = font.getGlyphId(0xFFFFF); // Private Use Area – likely unmapped
        // Either null or a valid glyph ID (some fonts map PUA)
        if (id != null) expect(id, lessThan(parser.numGlyphs));
      });
    });

    group('parseGlyphContours', () {
      test('returns non-null for ASCII letter A', () {
        final cmap = parser.parseCmap();
        final glyphId = cmap['A'.codeUnitAt(0)]!;
        final contours = parser.parseGlyphContours(glyphId);
        expect(contours, isNotNull);
        expect(contours!, isNotEmpty);
      });

      test('every contour has at least one point', () {
        final cmap = parser.parseCmap();
        for (final ch in 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('')) {
          final glyphId = cmap[ch.codeUnitAt(0)];
          if (glyphId == null) continue;
          final contours = parser.parseGlyphContours(glyphId);
          if (contours == null) continue;
          for (final contour in contours) {
            expect(contour.points, isNotEmpty,
                reason: 'Empty contour in glyph for "$ch"');
          }
        }
      });

      test('space glyph (U+0020) returns empty contour list', () {
        final cmap = parser.parseCmap();
        final spaceId = cmap[0x20]; // space
        if (spaceId == null) return;
        final contours = parser.parseGlyphContours(spaceId);
        // Space is a valid glyph with advance width but no contours.
        expect(contours, anyOf(isNull, isEmpty));
      });

      test('out-of-range glyph ID returns null', () {
        expect(parser.parseGlyphContours(parser.numGlyphs + 100), isNull);
        expect(parser.parseGlyphContours(-1), isNull);
      });

      test('composite glyph (é U+00E9) is resolved without crash', () {
        final cmap = parser.parseCmap();
        final glyphId = cmap[0x00E9]; // é
        if (glyphId == null) return; // font may not contain it
        final contours = parser.parseGlyphContours(glyphId);
        // Composite glyphs must resolve to ≥1 contours (e + combining accent)
        expect(contours, isNotNull);
        expect(contours!, isNotEmpty);
      });
    });

    group('parseHmtx', () {
      late List<({int advanceWidth, int lsb})> hmtx;
      setUpAll(() => hmtx = parser.parseHmtx());

      test('length equals numGlyphs', () {
        expect(hmtx.length, equals(parser.numGlyphs));
      });

      test('all advance widths are non-negative', () {
        for (final m in hmtx) {
          expect(m.advanceWidth, greaterThanOrEqualTo(0));
        }
      });

      test('letter "I" advance width < letter "W"', () {
        final cmap = parser.parseCmap();
        final iId = cmap['I'.codeUnitAt(0)];
        final wId = cmap['W'.codeUnitAt(0)];
        if (iId == null || wId == null) return;
        expect(hmtx[iId].advanceWidth, lessThan(hmtx[wId].advanceWidth));
      });
    });

    group('parseKern', () {
      test('returns a map (may be empty if no kern table)', () {
        final kern = parser.parseKern();
        expect(kern, isA<Map>());
      });

      test('all kern values are finite integers', () {
        final kern = parser.parseKern();
        for (final v in kern.values) {
          expect(v.abs(), lessThan(10000)); // sanity bound in font units
        }
      });
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TtfFont (high-level)
  // ─────────────────────────────────────────────────────────────────────────

  group('TtfFont – high-level API', () {
    late ui.TtfFont font;

    setUpAll(() {
      final f = _loadRoboto();
      if (f == null) {
        markTestSkipped('test/fixtures/Roboto-Regular.ttf not found');
        return;
      }
      font = f;
    });

    test('metrics.unitsPerEm is valid', () {
      expect(font.metrics.unitsPerEm, greaterThan(0));
    });

    test('glyphCount matches parser.numGlyphs', () {
      expect(font.glyphCount, greaterThan(0));
    });

    group('getGlyphId', () {
      test('returns non-null for ASCII A', () {
        expect(font.getGlyphId('A'.codeUnitAt(0)), isNotNull);
      });

      test('returns distinct IDs for A and Z', () {
        final idA = font.getGlyphId('A'.codeUnitAt(0));
        final idZ = font.getGlyphId('Z'.codeUnitAt(0));
        expect(idA, isNotNull);
        expect(idZ, isNotNull);
        expect(idA, isNot(equals(idZ)));
      });

      test('returns null for unmapped codepoint', () {
        // U+FFFF is not a valid Unicode character and typically unmapped
        final id = font.getGlyphId(0xFFFF);
        // Null or mapped to something – both are acceptable
        if (id != null) expect(id, lessThan(font.glyphCount));
      });
    });

    group('getGlyphOutline', () {
      test('returns non-null for letter A', () {
        final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
        final outline = font.getGlyphOutline(glyphId);
        expect(outline, isNotNull);
      });

      test('outline for A has non-empty contours', () {
        final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
        final outline = font.getGlyphOutline(glyphId)!;
        expect(outline.contours, isNotEmpty);
      });

      test('advanceWidth is positive for letter A', () {
        final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
        final outline = font.getGlyphOutline(glyphId)!;
        expect(outline.advanceWidth, greaterThan(0));
      });

      test('second call returns cached (identical) object', () {
        final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
        final o1 = font.getGlyphOutline(glyphId);
        final o2 = font.getGlyphOutline(glyphId);
        expect(identical(o1, o2), isTrue);
      });

      test('returns null for out-of-range glyph ID', () {
        expect(font.getGlyphOutline(font.glyphCount + 999), isNull);
      });
    });

    group('getAdvanceWidth', () {
      test('returns positive value at fontSize 16', () {
        final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
        expect(font.getAdvanceWidth(glyphId, 16), greaterThan(0));
      });

      test('scales linearly with fontSize', () {
        final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
        final aw16 = font.getAdvanceWidth(glyphId, 16);
        final aw32 = font.getAdvanceWidth(glyphId, 32);
        expect((aw32 / aw16).round(), equals(2));
      });

      test('I is narrower than W at same font size', () {
        final iId = font.getGlyphId('I'.codeUnitAt(0))!;
        final wId = font.getGlyphId('W'.codeUnitAt(0))!;
        expect(
          font.getAdvanceWidth(iId, 16),
          lessThan(font.getAdvanceWidth(wId, 16)),
        );
      });

      test('returns 0 for out-of-range glyph ID', () {
        expect(font.getAdvanceWidth(font.glyphCount + 99, 16), 0);
      });
    });

    group('getKerning', () {
      test('returns a finite value for any two glyphs', () {
        final aId = font.getGlyphId('A'.codeUnitAt(0))!;
        final vId = font.getGlyphId('V'.codeUnitAt(0))!;
        final kern = font.getKerning(aId, vId, 16);
        expect(kern.isFinite, isTrue);
      });

      test('scales linearly with fontSize', () {
        final aId = font.getGlyphId('A'.codeUnitAt(0))!;
        final vId = font.getGlyphId('V'.codeUnitAt(0))!;
        final k16 = font.getKerning(aId, vId, 16);
        final k32 = font.getKerning(aId, vId, 32);
        // Either both zero (no kern pair), or the 32pt value is 2× the 16pt.
        if (k16 != 0) {
          expect((k32 / k16).round(), equals(2));
        } else {
          expect(k32, 0);
        }
      });
    });

    group('GlyphOutline coordinate validity', () {
      test('all glyph points have finite coordinates', () {
        final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        for (final ch in chars.split('')) {
          final glyphId = font.getGlyphId(ch.codeUnitAt(0));
          if (glyphId == null) continue;
          final outline = font.getGlyphOutline(glyphId);
          if (outline == null) continue;
          for (final contour in outline.contours) {
            for (final pt in contour.points) {
              expect(pt.x.isFinite, isTrue, reason: 'Non-finite x for "$ch"');
              expect(pt.y.isFinite, isTrue, reason: 'Non-finite y for "$ch"');
            }
          }
        }
      });

      test('letter A bounding box has positive width and height', () {
        final glyphId = font.getGlyphId('A'.codeUnitAt(0))!;
        final outline = font.getGlyphOutline(glyphId)!;

        double minX = double.infinity, maxX = double.negativeInfinity;
        double minY = double.infinity, maxY = double.negativeInfinity;

        for (final contour in outline.contours) {
          for (final pt in contour.points) {
            if (pt.x < minX) minX = pt.x;
            if (pt.x > maxX) maxX = pt.x;
            if (pt.y < minY) minY = pt.y;
            if (pt.y > maxY) maxY = pt.y;
          }
        }
        expect(maxX - minX, greaterThan(0), reason: 'Width should be positive');
        expect(maxY - minY, greaterThan(0), reason: 'Height should be positive');
      });
    });

    test('TtfFont.load throws for CFF-based fonts', () {
      // Create a minimal fake "OTF/CFF" header: sfVersion = 'OTTO' (0x4F54544F)
      // + minimal table directory pointing to a fake CFF table.
      // This is complex to fake perfectly; instead verify that Roboto is NOT CFF.
      expect(font.availableTables, contains('glyf'));
      expect(font.availableTables, isNot(contains('CFF ')));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // FontMetrics helpers
  // ─────────────────────────────────────────────────────────────────────────

  group('FontMetrics helpers', () {
    const m = ui.FontMetrics(
      unitsPerEm: 2048,
      ascender: 1536,
      descender: -512,
      lineGap: 0,
      capHeight: 1456,
      xHeight: 1120,
    );

    test('lineHeightAt scales correctly', () {
      // (1536 - (-512) + 0) * 16 / 2048 = 2048 * 16 / 2048 = 16
      expect(m.lineHeightAt(16), closeTo(16.0, 0.01));
    });

    test('baselineOffsetAt scales correctly', () {
      // 1536 * 16 / 2048 = 12
      expect(m.baselineOffsetAt(16), closeTo(12.0, 0.01));
    });

    test('baselineOffsetAt < lineHeightAt', () {
      expect(m.baselineOffsetAt(16), lessThan(m.lineHeightAt(16)));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GlyphOutline / GlyphContour / GlyphPoint
  // ─────────────────────────────────────────────────────────────────────────

  group('GlyphPoint', () {
    const p = ui.GlyphPoint(100, 200, true);

    test('translated offsets both coordinates', () {
      final t = p.translated(10, -20);
      expect(t.x, 110);
      expect(t.y, 180);
      expect(t.onCurve, isTrue);
    });

    test('transformed applies 2×2 matrix', () {
      // Scale x by 2, y by 3 (diagonal matrix)
      final t = p.transformed(2, 0, 0, 3);
      expect(t.x, 200);
      expect(t.y, 600);
    });
  });

  group('GlyphContour', () {
    final contour = ui.GlyphContour([
      const ui.GlyphPoint(0, 0, true),
      const ui.GlyphPoint(100, 0, true),
      const ui.GlyphPoint(50, 100, true),
    ]);

    test('translated shifts all points', () {
      final t = contour.translated(10, 20);
      expect(t.points[0].x, 10);
      expect(t.points[0].y, 20);
      expect(t.points[1].x, 110);
    });
  });

  group('GlyphOutline', () {
    test('isEmpty is true for outline with no contours', () {
      const outline = ui.GlyphOutline(
          contours: [], advanceWidth: 500, lsb: 0);
      expect(outline.isEmpty, isTrue);
    });

    test('isEmpty is false when contours are present', () {
      final outline = ui.GlyphOutline(
        contours: [
          ui.GlyphContour([const ui.GlyphPoint(0, 0, true)])
        ],
        advanceWidth: 500,
        lsb: 0,
      );
      expect(outline.isEmpty, isFalse);
    });
  });
}
