part of dart.ui;

/// Low-level binary parser for TrueType (`glyf`-based) font files.
///
/// Parses the TTF table structure and provides access to font metrics, the
/// character-to-glyph mapping (cmap), glyph outlines (glyf), horizontal
/// metrics (hmtx), and pair-kerning (kern).
///
/// **Usage** — prefer the higher-level [TtfFont] wrapper which adds caching
/// and a friendlier API:
///
/// ```dart
/// final parser = TtfParser(bytes); // parses table directory + head/hhea/maxp
/// final metrics = parser.parseFontMetrics();
/// final cmap = parser.parseCmap();
/// ```
///
/// **Supported tables:** `head`, `hhea`, `maxp`, `OS/2`, `cmap` (format 4 &
/// 12), `loca`, `glyf` (simple + composite), `hmtx`, `kern` (format 0).
///
/// **Not supported:** CFF/CFF2 (`CFF ` table), GPOS kerning, vertical metrics.
class TtfParser {
  final ByteData _data;

  // Table directory: tag → byte offset in file.
  final Map<String, int> _tableOffsets = {};

  // Internal state populated by [_parseInternalState].
  int _numGlyphs = 0;
  int _unitsPerEm = 1000;
  int _indexToLocFormat = 0; // 0 = short offsets, 1 = long offsets
  int _numberOfHMetrics = 0;

  TtfParser(Uint8List bytes) : _data = ByteData.sublistView(bytes) {
    _parseOffsetTable();
    _parseInternalState();
  }

  // ── Table directory ────────────────────────────────────────────────────────

  void _parseOffsetTable() {
    // Offset table: sfVersion(4) + numTables(2) + searchRange(2) +
    //               entrySelector(2) + rangeShift(2) = 12 bytes.
    final numTables = _data.getUint16(4);
    for (int i = 0; i < numTables; i++) {
      final base = 12 + i * 16;
      final tag = String.fromCharCodes([
        _data.getUint8(base),
        _data.getUint8(base + 1),
        _data.getUint8(base + 2),
        _data.getUint8(base + 3),
      ]);
      final offset = _data.getUint32(base + 8);
      _tableOffsets[tag] = offset;
    }
  }

  /// Reads `head`, `hhea`, and `maxp` tables to initialise internal state
  /// that other parse methods depend on.
  void _parseInternalState() {
    // head: unitsPerEm @ +18, indexToLocFormat @ +50
    final head = _tableOffsets['head'];
    if (head != null) {
      _unitsPerEm = _data.getUint16(head + 18);
      _indexToLocFormat = _data.getInt16(head + 50);
    }

    // hhea: numberOfHMetrics @ +34
    final hhea = _tableOffsets['hhea'];
    if (hhea != null) {
      _numberOfHMetrics = _data.getUint16(hhea + 34);
    }

    // maxp: numGlyphs @ +4
    final maxp = _tableOffsets['maxp'];
    if (maxp != null) {
      _numGlyphs = _data.getUint16(maxp + 4);
    }
  }

  int get numGlyphs => _numGlyphs;
  int get unitsPerEm => _unitsPerEm;

  // ── Font metrics ───────────────────────────────────────────────────────────

  /// Parses and returns the font-level typographic metrics.
  FontMetrics parseFontMetrics() {
    // hhea: ascender @ +4, descender @ +6, lineGap @ +8
    int ascender = 0, descender = 0, lineGap = 0;
    final hhea = _tableOffsets['hhea'];
    if (hhea != null) {
      ascender = _data.getInt16(hhea + 4);
      descender = _data.getInt16(hhea + 6);
      lineGap = _data.getInt16(hhea + 8);
    }

    // OS/2: capHeight @ +88, xHeight @ +86 (version ≥ 2 only)
    int capHeight = 0, xHeight = 0;
    final os2 = _tableOffsets['OS/2'];
    if (os2 != null) {
      final version = _data.getUint16(os2);
      if (version >= 2) {
        xHeight = _data.getInt16(os2 + 86);
        capHeight = _data.getInt16(os2 + 88);
      }
    }

    return FontMetrics(
      unitsPerEm: _unitsPerEm,
      ascender: ascender,
      descender: descender,
      lineGap: lineGap,
      capHeight: capHeight,
      xHeight: xHeight,
    );
  }

  // ── cmap: character code → glyph ID ───────────────────────────────────────

  /// Returns a map from Unicode code point to glyph ID.
  ///
  /// Prefers format 12 (full Unicode) over format 4 (BMP only).
  Map<int, int> parseCmap() {
    final cmapBase = _tableOffsets['cmap'];
    if (cmapBase == null) return {};

    final numTables = _data.getUint16(cmapBase + 2);

    int? format4Off;
    int? format12Off;

    for (int i = 0; i < numTables; i++) {
      final rec = cmapBase + 4 + i * 8;
      final platformId = _data.getUint16(rec);
      final encodingId = _data.getUint16(rec + 2);
      final subtableOff = cmapBase + _data.getUint32(rec + 4);
      final format = _data.getUint16(subtableOff);

      // Encoding priority:
      //   Format 12 (full Unicode): Platform 3/enc10, Platform 0/any
      //   Format 4  (BMP Unicode):  Platform 3/enc1,  Platform 0/any
      // We take the last matching subtable; later records tend to be better.
      if (format == 12) {
        if ((platformId == 3 && encodingId == 10) || platformId == 0) {
          format12Off = subtableOff;
        }
      } else if (format == 4) {
        if ((platformId == 3 && encodingId == 1) || platformId == 0) {
          format4Off = subtableOff;
        }
      }
    }

    if (format12Off != null) return _parseCmapFormat12(format12Off);
    if (format4Off != null) return _parseCmapFormat4(format4Off);
    return {};
  }

  Map<int, int> _parseCmapFormat4(int off) {
    // Format 4 layout (offsets relative to `off`):
    //   0: format(2), 2: length(2), 4: language(2), 6: segCountX2(2),
    //   8: searchRange(2), 10: entrySelector(2), 12: rangeShift(2),
    //  14: endCount[segCount], +2: reservedPad,
    //       startCount[segCount], idDelta[segCount], idRangeOffset[segCount],
    //       glyphIdArray[]
    final segCount = _data.getUint16(off + 6) ~/ 2;

    final endCountBase = off + 14;
    final startCountBase = endCountBase + segCount * 2 + 2; // skip reservedPad
    final idDeltaBase = startCountBase + segCount * 2;
    final idRangeOffBase = idDeltaBase + segCount * 2;

    final result = <int, int>{};

    for (int i = 0; i < segCount; i++) {
      final endCount = _data.getUint16(endCountBase + i * 2);
      final startCount = _data.getUint16(startCountBase + i * 2);
      final idDelta = _data.getInt16(idDeltaBase + i * 2);
      final idRangeOffset = _data.getUint16(idRangeOffBase + i * 2);

      if (startCount == 0xFFFF) break; // sentinel segment

      for (int c = startCount; c <= endCount; c++) {
        int glyphId;
        if (idRangeOffset == 0) {
          glyphId = (c + idDelta) & 0xFFFF;
        } else {
          // The spec says: glyphId = *(idRangeOffset[i]/2
          //                         + (c - startCount[i])
          //                         + &idRangeOffset[i])
          // In file-offset terms: address of idRangeOffset[i] is
          //   idRangeOffBase + i*2
          // So the glyphIdArray entry is at:
          //   idRangeOffBase + i*2 + idRangeOffset + (c - startCount)*2
          final addr =
              idRangeOffBase + i * 2 + idRangeOffset + (c - startCount) * 2;
          if (addr + 2 > _data.lengthInBytes) continue;
          final raw = _data.getUint16(addr);
          glyphId = raw == 0 ? 0 : (raw + idDelta) & 0xFFFF;
        }
        if (glyphId != 0) result[c] = glyphId;
      }
    }

    return result;
  }

  Map<int, int> _parseCmapFormat12(int off) {
    // Format 12 layout:
    //  0: format(2), 2: reserved(2), 4: length(4), 8: language(4),
    // 12: nGroups(4), 16: groups[nGroups] (startChar, endChar, startGlyph: 4 each)
    final nGroups = _data.getUint32(off + 12);
    final result = <int, int>{};

    for (int i = 0; i < nGroups; i++) {
      final g = off + 16 + i * 12;
      final start = _data.getUint32(g);
      final end = _data.getUint32(g + 4);
      final startGlyph = _data.getUint32(g + 8);
      for (int c = start; c <= end; c++) {
        result[c] = startGlyph + (c - start);
      }
    }

    return result;
  }

  // ── loca: glyph offsets ────────────────────────────────────────────────────

  int _glyphOffset(int glyphId) {
    final loca = _tableOffsets['loca'];
    if (loca == null) return 0;
    if (_indexToLocFormat == 0) {
      return _data.getUint16(loca + glyphId * 2) * 2;
    } else {
      return _data.getUint32(loca + glyphId * 4);
    }
  }

  // ── glyf: glyph outlines ──────────────────────────────────────────────────

  /// Parses the contours for [glyphId].
  ///
  /// Returns `null` if the glyph ID is out of range or the glyph data is
  /// missing. Returns an empty list for whitespace glyphs (e.g. space).
  List<GlyphContour>? parseGlyphContours(int glyphId) {
    if (glyphId < 0 || glyphId >= _numGlyphs) return null;
    final glyf = _tableOffsets['glyf'];
    if (glyf == null) return null;

    final offset = _glyphOffset(glyphId);
    final nextOffset = _glyphOffset(glyphId + 1);
    if (offset == nextOffset) return []; // empty glyph (e.g. space)

    final base = glyf + offset;
    if (base + 10 > _data.lengthInBytes) return null;

    final numberOfContours = _data.getInt16(base);
    try {
      if (numberOfContours >= 0) {
        return _parseSimpleGlyph(base, numberOfContours);
      } else {
        return _parseCompositeGlyph(base);
      }
    } catch (_) {
      return null; // malformed glyph data – skip gracefully
    }
  }

  List<GlyphContour> _parseSimpleGlyph(int base, int numberOfContours) {
    if (numberOfContours == 0) return [];

    // endPtsOfContours[numberOfContours] @ base+10
    final endPts = List<int>.generate(
      numberOfContours,
      (i) => _data.getUint16(base + 10 + i * 2),
    );

    final instructionLength =
        _data.getUint16(base + 10 + numberOfContours * 2);
    int pos = base + 10 + numberOfContours * 2 + 2 + instructionLength;

    final numPoints = endPts.last + 1;

    // ── Flags ──
    final flags = <int>[];
    while (flags.length < numPoints) {
      final flag = _data.getUint8(pos++);
      flags.add(flag);
      if (flag & 0x08 != 0) {
        // REPEAT_FLAG
        final repeatCount = _data.getUint8(pos++);
        for (int j = 0; j < repeatCount; j++) {
          flags.add(flag);
        }
      }
    }

    // ── X coordinates ──
    final xs = List<double>.filled(numPoints, 0);
    int x = 0;
    for (int i = 0; i < numPoints; i++) {
      final flag = flags[i];
      if (flag & 0x02 != 0) {
        // X_SHORT_VECTOR: 1-byte magnitude
        final dx = _data.getUint8(pos++);
        x += (flag & 0x10 != 0) ? dx : -dx;
      } else if (flag & 0x10 == 0) {
        // X_IS_SAME_OR_POSITIVE: if clear, 2-byte signed delta
        x += _data.getInt16(pos);
        pos += 2;
        // if set, same as previous (no change)
      }
      xs[i] = x.toDouble();
    }

    // ── Y coordinates ──
    final ys = List<double>.filled(numPoints, 0);
    int y = 0;
    for (int i = 0; i < numPoints; i++) {
      final flag = flags[i];
      if (flag & 0x04 != 0) {
        // Y_SHORT_VECTOR: 1-byte magnitude
        final dy = _data.getUint8(pos++);
        y += (flag & 0x20 != 0) ? dy : -dy;
      } else if (flag & 0x20 == 0) {
        // Y_IS_SAME_OR_POSITIVE: if clear, 2-byte signed delta
        y += _data.getInt16(pos);
        pos += 2;
      }
      ys[i] = y.toDouble();
    }

    // ── Build contours ──
    final contours = <GlyphContour>[];
    int start = 0;
    for (int c = 0; c < numberOfContours; c++) {
      final end = endPts[c];
      final points = <GlyphPoint>[];
      for (int i = start; i <= end; i++) {
        points.add(GlyphPoint(xs[i], ys[i], flags[i] & 0x01 != 0));
      }
      contours.add(GlyphContour(points));
      start = end + 1;
    }

    return contours;
  }

  List<GlyphContour> _parseCompositeGlyph(int base) {
    final allContours = <GlyphContour>[];
    int pos = base + 10;

    bool more = true;
    while (more) {
      if (pos + 4 > _data.lengthInBytes) break;
      final flags = _data.getUint16(pos);
      final componentGlyphId = _data.getUint16(pos + 2);
      pos += 4;

      // Read placement arguments
      double dx = 0, dy = 0;
      final argsAreWords = flags & 0x0001 != 0;
      final argsAreXY = flags & 0x0002 != 0;

      if (argsAreWords) {
        if (argsAreXY) {
          dx = _data.getInt16(pos).toDouble();
          dy = _data.getInt16(pos + 2).toDouble();
        }
        pos += 4;
      } else {
        if (argsAreXY) {
          dx = _data.getInt8(pos).toDouble();
          dy = _data.getInt8(pos + 1).toDouble();
        }
        pos += 2;
      }

      // Parse optional transform
      double a = 1, b = 0, c2 = 0, d = 1;
      if (flags & 0x0008 != 0) {
        // WE_HAVE_A_SCALE
        final s = _readF2Dot14(pos);
        pos += 2;
        a = s;
        d = s;
      } else if (flags & 0x0040 != 0) {
        // WE_HAVE_AN_X_AND_Y_SCALE
        a = _readF2Dot14(pos);
        d = _readF2Dot14(pos + 2);
        pos += 4;
      } else if (flags & 0x0080 != 0) {
        // WE_HAVE_A_TWO_BY_TWO
        a = _readF2Dot14(pos);
        b = _readF2Dot14(pos + 2);
        c2 = _readF2Dot14(pos + 4);
        d = _readF2Dot14(pos + 6);
        pos += 8;
      }

      // Parse and transform the component glyph
      final componentContours = parseGlyphContours(componentGlyphId);
      if (componentContours != null) {
        for (final contour in componentContours) {
          final transformed = (a == 1 && b == 0 && c2 == 0 && d == 1)
              ? contour.translated(dx, dy)
              : GlyphContour(
                  contour.points
                      .map((p) => GlyphPoint(
                            p.x * a + p.y * c2 + dx,
                            p.x * b + p.y * d + dy,
                            p.onCurve,
                          ))
                      .toList(growable: false),
                );
          allContours.add(transformed);
        }
      }

      more = flags & 0x0020 != 0; // MORE_COMPONENTS
    }

    return allContours;
  }

  double _readF2Dot14(int offset) {
    // F2Dot14: 2-bit signed integer + 14-bit fraction
    return _data.getInt16(offset) / 16384.0;
  }

  // ── hmtx: horizontal metrics ───────────────────────────────────────────────

  /// Returns `(advanceWidth, lsb)` pairs in font units for each glyph.
  ///
  /// The list length equals [numGlyphs]. Glyphs beyond [_numberOfHMetrics]
  /// share the last advance width (per the TTF spec).
  List<({int advanceWidth, int lsb})> parseHmtx() {
    final hmtx = _tableOffsets['hmtx'];
    if (hmtx == null) return [];

    final result = <({int advanceWidth, int lsb})>[];
    int lastAw = 0;

    for (int i = 0; i < _numberOfHMetrics; i++) {
      final off = hmtx + i * 4;
      final aw = _data.getUint16(off);
      final lsb = _data.getInt16(off + 2);
      result.add((advanceWidth: aw, lsb: lsb));
      lastAw = aw;
    }

    // Remaining glyphs reuse lastAw with individual lsb values.
    final extraBase = hmtx + _numberOfHMetrics * 4;
    for (int i = _numberOfHMetrics; i < _numGlyphs; i++) {
      final lsb = _data.getInt16(extraBase + (i - _numberOfHMetrics) * 2);
      result.add((advanceWidth: lastAw, lsb: lsb));
    }

    return result;
  }

  // ── kern: pair kerning ─────────────────────────────────────────────────────

  /// Returns pair-kerning values in font units.
  ///
  /// Only handles the classic `kern` table format 0 (horizontal pairs).
  /// Returns an empty map if the table is absent or has no format-0 subtables.
  Map<(int, int), int> parseKern() {
    final kern = _tableOffsets['kern'];
    if (kern == null) return {};

    final result = <(int, int), int>{};
    final nTables = _data.getUint16(kern + 2);
    int pos = kern + 4;

    for (int t = 0; t < nTables; t++) {
      if (pos + 6 > _data.lengthInBytes) break;
      final subtableLength = _data.getUint16(pos + 2);
      final coverage = _data.getUint16(pos + 4);
      final format = (coverage >> 8) & 0xFF;
      final isHorizontal = coverage & 0x01 != 0;

      if (format == 0 && isHorizontal) {
        final nPairs = _data.getUint16(pos + 6);
        for (int p = 0; p < nPairs; p++) {
          final pairOff = pos + 14 + p * 6;
          if (pairOff + 6 > _data.lengthInBytes) break;
          final left = _data.getUint16(pairOff);
          final right = _data.getUint16(pairOff + 2);
          final value = _data.getInt16(pairOff + 4);
          result[(left, right)] = value;
        }
      }

      pos += subtableLength;
    }

    return result;
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  /// Whether the font uses a `glyf` table (TrueType) vs `CFF ` (OpenType/CFF).
  bool get isTrueType => _tableOffsets.containsKey('glyf');

  /// The set of table tags present in this font.
  Set<String> get availableTables => _tableOffsets.keys.toSet();
}
