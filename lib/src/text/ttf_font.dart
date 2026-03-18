part of dart.ui;

/// High-level interface for a loaded TrueType font.
///
/// Wraps [TtfParser] with caching, metrics, and pixel-scale APIs.
///
/// **Load a font:**
/// ```dart
/// final bytes = File('/path/to/Roboto-Regular.ttf').readAsBytesSync();
/// final font = TtfFont.load(bytes);
/// ```
///
/// **Render text** (with [FontLoader] + [ParagraphBuilder] — see Phase 4+):
/// ```dart
/// final glyphId = font.getGlyphId('A'.codeUnitAt(0));
/// if (glyphId != null) {
///   final outline = font.getGlyphOutline(glyphId);
///   final advance = font.getAdvanceWidth(glyphId, 16.0);
/// }
/// ```
class TtfFont {
  final TtfParser _parser;

  /// Typographic metrics for this font.
  final FontMetrics metrics;

  // codePoint → glyphId mapping (loaded once, kept for the font lifetime).
  final Map<int, int> _cmap;

  // Per-glyph horizontal metrics: advanceWidth and lsb in font units.
  final List<({int advanceWidth, int lsb})> _hmtx;

  // Pair kerning: (leftGlyphId, rightGlyphId) → kern value in font units.
  final Map<(int, int), int> _kern;

  // Lazily built glyph outline cache. Keys are glyph IDs; value is the
  // complete GlyphOutline (including advance / lsb), or null if the glyph
  // cannot be parsed.
  final Map<int, GlyphOutline?> _outlineCache = {};

  TtfFont._({
    required TtfParser parser,
    required this.metrics,
    required Map<int, int> cmap,
    required List<({int advanceWidth, int lsb})> hmtx,
    required Map<(int, int), int> kern,
  })  : _parser = parser,
        _cmap = cmap,
        _hmtx = hmtx,
        _kern = kern;

  // ── Factory ────────────────────────────────────────────────────────────────

  /// Loads a TTF/OTF font from raw bytes.
  ///
  /// All tables are parsed eagerly (cmap, hmtx, kern) so that subsequent
  /// calls to [getGlyphId] and [getAdvanceWidth] are synchronous and O(1).
  /// Glyph outlines are parsed lazily on first access.
  ///
  /// Throws [StateError] if required tables (`head`, `hhea`, `maxp`, `cmap`,
  /// `hmtx`) are missing.
  /// Throws [ArgumentError] if the font is CFF-based (`.otf` with `CFF `
  /// table), which is not yet supported.
  static TtfFont load(Uint8List bytes) {
    final parser = TtfParser(bytes);

    if (!parser.isTrueType) {
      throw ArgumentError(
        'CFF/PostScript-based fonts are not yet supported. '
        'Use a TrueType-based font (with a "glyf" table).',
      );
    }

    final metrics = parser.parseFontMetrics();
    final cmap = parser.parseCmap();
    final hmtx = parser.parseHmtx();
    final kern = parser.parseKern();

    return TtfFont._(
      parser: parser,
      metrics: metrics,
      cmap: cmap,
      hmtx: hmtx,
      kern: kern,
    );
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns the glyph ID for [codePoint], or `null` if the character is not
  /// mapped in this font.
  int? getGlyphId(int codePoint) => _cmap[codePoint];

  /// Returns the glyph outline for [glyphId], or `null` if the glyph data
  /// cannot be parsed (e.g. the glyph ID is out of range).
  ///
  /// Results are cached: the glyph is only parsed once per font instance.
  GlyphOutline? getGlyphOutline(int glyphId) {
    return _outlineCache.putIfAbsent(glyphId, () => _buildOutline(glyphId));
  }

  GlyphOutline? _buildOutline(int glyphId) {
    final contours = _parser.parseGlyphContours(glyphId);
    if (contours == null) return null;

    final aw = glyphId < _hmtx.length ? _hmtx[glyphId].advanceWidth : 0;
    final lsb = glyphId < _hmtx.length ? _hmtx[glyphId].lsb : 0;

    return GlyphOutline(
      contours: contours,
      advanceWidth: aw.toDouble(),
      lsb: lsb.toDouble(),
    );
  }

  /// Advance width for [glyphId] scaled to [fontSize] in pixels.
  ///
  /// Returns 0 if [glyphId] is out of range.
  double getAdvanceWidth(int glyphId, double fontSize) {
    if (glyphId < 0 || glyphId >= _hmtx.length) return 0;
    return _hmtx[glyphId].advanceWidth * fontSize / metrics.unitsPerEm;
  }

  /// Left side bearing for [glyphId] in font units (unscaled).
  int getLsb(int glyphId) {
    if (glyphId < 0 || glyphId >= _hmtx.length) return 0;
    return _hmtx[glyphId].lsb;
  }

  /// Pair-kerning adjustment between two consecutive glyphs, in pixels.
  ///
  /// Returns 0 if no kern pair is defined for the combination.
  double getKerning(int glyphId1, int glyphId2, double fontSize) {
    final value = _kern[(glyphId1, glyphId2)] ?? 0;
    return value * fontSize / metrics.unitsPerEm;
  }

  /// Total number of glyphs in the font.
  int get glyphCount => _parser.numGlyphs;

  /// Whether a kern table is present.
  bool get hasKerning => _kern.isNotEmpty;

  /// The set of TTF table tags available in this font.
  Set<String> get availableTables => _parser.availableTables;
}
