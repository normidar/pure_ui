part of dart.ui;

/// Typographic metrics for a loaded TTF/OTF font.
///
/// All values are in font design units (as stored in the font file).
/// To convert to pixels at a given [fontSize]:
///
/// ```dart
/// final scale = fontSize / metrics.unitsPerEm;
/// final ascenderPx = metrics.ascender * scale;
/// ```
class FontMetrics {
  /// Number of font design units per em.
  ///
  /// Common values: 1000 (PostScript/OTF) or 2048 (TrueType).
  final int unitsPerEm;

  /// Distance from the baseline to the top of the em square, in font units.
  ///
  /// Positive value (above baseline).
  final int ascender;

  /// Distance from the baseline to the bottom of the em square, in font units.
  ///
  /// Negative value (below baseline).
  final int descender;

  /// Additional line spacing recommended by the font designer, in font units.
  final int lineGap;

  /// Height of capital letters above the baseline, in font units.
  ///
  /// Sourced from the `OS/2` table (version ≥ 2). Zero if unavailable.
  final int capHeight;

  /// Height of lowercase 'x' above the baseline, in font units.
  ///
  /// Sourced from the `OS/2` table (version ≥ 2). Zero if unavailable.
  final int xHeight;

  const FontMetrics({
    required this.unitsPerEm,
    required this.ascender,
    required this.descender,
    required this.lineGap,
    required this.capHeight,
    required this.xHeight,
  });

  /// Line height recommended for this font at the given [fontSize] in pixels.
  ///
  /// Equals `(ascender - descender + lineGap) * fontSize / unitsPerEm`.
  double lineHeightAt(double fontSize) {
    final scale = fontSize / unitsPerEm;
    return (ascender - descender + lineGap) * scale;
  }

  /// Distance from the top of the line box to the baseline, in pixels.
  double baselineOffsetAt(double fontSize) {
    return ascender * fontSize / unitsPerEm;
  }

  @override
  String toString() =>
      'FontMetrics(unitsPerEm: $unitsPerEm, ascender: $ascender, '
      'descender: $descender, lineGap: $lineGap, '
      'capHeight: $capHeight, xHeight: $xHeight)';
}
