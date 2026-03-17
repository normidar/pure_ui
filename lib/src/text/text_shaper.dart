part of dart.ui;

/// A single glyph after text shaping, with all metrics resolved to pixels.
///
/// Produced by [shapeText] for each logical character in a text span.
class ShapedGlyph {
  /// The Unicode code point this glyph represents.
  final int codePoint;

  /// The glyph ID within [font].
  final int glyphId;

  /// The [TtfFont] that contains this glyph.
  final TtfFont font;

  /// Resolved font size in logical pixels.
  final double fontSize;

  /// Horizontal advance (in pixels) including kerning and letterSpacing.
  final double advance;

  /// Resolved text colour.
  final Color color;

  const ShapedGlyph({
    required this.codePoint,
    required this.glyphId,
    required this.font,
    required this.fontSize,
    required this.advance,
    required this.color,
  });

  /// True if this glyph represents a newline character (U+000A).
  bool get isNewline => codePoint == 0x0A;

  /// True if this glyph represents a space character (U+0020).
  bool get isSpace => codePoint == 0x0020;
}

/// Converts [text] into a list of [ShapedGlyph] objects using [font].
///
/// Handles:
/// - Surrogate pairs (via `String.runes`)
/// - `TextStyle.letterSpacing` added to every glyph's advance
/// - `TextStyle.wordSpacing` added to the advance of U+0020 SPACE
/// - Pair kerning via [TtfFont.getKerning]
///
/// Glyphs for unmapped code points are represented by the font's `.notdef`
/// glyph (ID 0) so the advance width is still accounted for.
List<ShapedGlyph> shapeText(String text, TextStyle style, TtfFont font) {
  final double fontSize = style._fontSize ?? 14.0;
  final double letterSpacing = style._letterSpacing ?? 0.0;
  final double wordSpacing = style._wordSpacing ?? 0.0;

  // Resolve colour (bit 1 of encoded[0]).
  Color color = const Color(0xFF000000);
  if ((style._encoded[0] & (1 << 1)) != 0) {
    color = Color(style._encoded[1]);
  }

  final List<ShapedGlyph> result = [];

  for (final codePoint in text.runes) {
    // Newlines have zero advance and no ink; they are handled by the layout
    // engine as hard line breaks.
    if (codePoint == 0x0A) {
      result.add(ShapedGlyph(
        codePoint: codePoint,
        glyphId: 0,
        font: font,
        fontSize: fontSize,
        advance: 0,
        color: color,
      ));
      continue;
    }

    // Map code point → glyph ID; fall back to .notdef (ID 0).
    final int glyphId = font.getGlyphId(codePoint) ?? 0;

    // Base advance from font hmtx table.
    double advance = font.getAdvanceWidth(glyphId, fontSize);

    // Pair kerning with the previous non-newline glyph.
    if (result.isNotEmpty && !result.last.isNewline) {
      advance += font.getKerning(result.last.glyphId, glyphId, fontSize);
    }

    // letterSpacing is added after every glyph.
    advance += letterSpacing;

    // wordSpacing is added for U+0020 SPACE.
    if (codePoint == 0x0020) {
      advance += wordSpacing;
    }

    result.add(ShapedGlyph(
      codePoint: codePoint,
      glyphId: glyphId,
      font: font,
      fontSize: fontSize,
      advance: advance,
      color: color,
    ));
  }

  return result;
}
