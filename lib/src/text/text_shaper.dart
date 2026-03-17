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

  /// Bit mask of active text decorations.
  /// 0x1 = underline, 0x2 = overline, 0x4 = line-through.
  final int decorationMask;

  /// Colour override for the text decoration, or null to use [color].
  final Color? decorationColor;

  /// Text shadows to render behind this glyph, or null if none.
  final List<Shadow>? shadows;

  const ShapedGlyph({
    required this.codePoint,
    required this.glyphId,
    required this.font,
    required this.fontSize,
    required this.advance,
    required this.color,
    this.decorationMask = 0,
    this.decorationColor,
    this.shadows,
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

  // Resolve text decorations (bit 2 of encoded[0] → mask in encoded[2]).
  final int decorationMask =
      (style._encoded[0] & (1 << 2)) != 0 ? style._encoded[2] : 0;

  // Resolve decoration colour (bit 3 of encoded[0] → ARGB in encoded[3]).
  final Color? decorationColor =
      (style._encoded[0] & (1 << 3)) != 0 ? Color(style._encoded[3]) : null;

  // Resolve shadows from the direct _shadows field.
  final List<Shadow>? shadows =
      (style._shadows != null && style._shadows!.isNotEmpty)
          ? style._shadows
          : null;

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
        decorationMask: decorationMask,
        decorationColor: decorationColor,
        shadows: shadows,
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
      decorationMask: decorationMask,
      decorationColor: decorationColor,
      shadows: shadows,
    ));
  }

  return result;
}
