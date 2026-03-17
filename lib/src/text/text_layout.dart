part of dart.ui;

/// A single laid-out line of text within a paragraph.
///
/// Produced by [layoutText]. All positions are relative to the top-left of
/// the paragraph (i.e. the [Offset] passed to [Canvas.drawParagraph] is
/// applied separately by the renderer).
class LayoutLine {
  /// The shaped glyphs that make up this line, in visual order.
  final List<ShapedGlyph> glyphs;

  /// X offset of each glyph from the line's left ink edge (before [left]).
  final List<double> xOffsets;

  /// Horizontal offset from the paragraph's left edge, applied by [TextAlign].
  final double left;

  /// Y position of the baseline measured from the paragraph's top edge.
  final double baseline;

  /// Pixels above the baseline (positive value).
  final double ascent;

  /// Pixels below the baseline (positive value).
  final double descent;

  /// Total advance width of the line's glyphs.
  final double width;

  /// True when this line ends with an explicit `\n` or is the last line.
  final bool hardBreak;

  double get height => ascent + descent;

  const LayoutLine({
    required this.glyphs,
    required this.xOffsets,
    required this.left,
    required this.baseline,
    required this.ascent,
    required this.descent,
    required this.width,
    required this.hardBreak,
  });
}

/// Result returned by [layoutText].
class _LayoutResult {
  final List<LayoutLine> lines;
  final bool didExceedMaxLines;
  const _LayoutResult(this.lines, this.didExceedMaxLines);
}

/// Lays out [spans] according to [paraStyle] and [maxWidth].
///
/// Steps performed:
/// 1. Shape each span with [shapeText] to get [ShapedGlyph] objects.
/// 2. Wrap glyphs greedily at word boundaries (U+0020) to fit [maxWidth].
/// 3. Handle hard line-breaks (`\n`).
/// 4. Apply [ParagraphStyle.maxLines] and [ParagraphStyle.ellipsis].
/// 5. Apply [TextAlign] to compute each line's [LayoutLine.left] offset.
/// 6. Compute per-line ascent/descent from font metrics.
_LayoutResult layoutText(
  List<_TextSpan> spans,
  ParagraphStyle paraStyle,
  double maxWidth,
) {
  // ── Step 1: shape all spans into a flat glyph list ──────────────────────
  final List<ShapedGlyph> allGlyphs = [];

  for (final span in spans) {
    final style = span.style;
    final String? spanFont =
        style != null && style._fontFamily.isNotEmpty ? style._fontFamily : null;
    final String? fontFamily = spanFont ??
        (paraStyle._fontFamily?.isNotEmpty == true ? paraStyle._fontFamily : null);
    if (fontFamily == null) continue;

    // Resolve font weight and style for variant lookup.
    final FontWeight fontWeight = (style != null &&
            (style._encoded[0] & (1 << 5)) != 0)
        ? FontWeight.values[style._encoded[5]]
        : FontWeight.normal;
    final FontStyle fontStyle =
        (style != null && (style._encoded[0] & (1 << 6)) != 0)
            ? FontStyle.values[style._encoded[6]]
            : FontStyle.normal;

    final fontBytes =
        FontLoader.getFont(fontFamily, weight: fontWeight, style: fontStyle);
    if (fontBytes == null) continue;

    final cacheKey = _fontCacheKey(fontFamily, fontWeight, fontStyle);
    final font = _pureDartFontCache.putIfAbsent(
        cacheKey, () => TtfFont.load(fontBytes));
    final double fontSize = style?._fontSize ?? paraStyle._fontSize ?? 14.0;
    final effectiveStyle =
        style ?? TextStyle(fontSize: fontSize, fontFamily: fontFamily);

    allGlyphs.addAll(
        shapeText(span.text, effectiveStyle, font, fontKey: cacheKey));
  }

  if (allGlyphs.isEmpty) return const _LayoutResult([], false);

  // ── Step 2: resolve layout parameters from ParagraphStyle ───────────────
  final bool hasTextAlign = (paraStyle._encoded[0] & (1 << 1)) != 0;
  final TextAlign textAlign =
      hasTextAlign ? TextAlign.values[paraStyle._encoded[1]] : TextAlign.left;
  final bool hasMaxLines = (paraStyle._encoded[0] & (1 << 5)) != 0;
  final int? maxLines = hasMaxLines ? paraStyle._encoded[5] : null;
  final String? ellipsis =
      (paraStyle._ellipsis?.isNotEmpty == true) ? paraStyle._ellipsis : null;

  // ── Step 3: greedy word-wrap ─────────────────────────────────────────────
  // Each entry: (glyphs on that line, isHardBreak)
  final List<(List<ShapedGlyph>, bool)> rawLines = [];

  List<ShapedGlyph> currentLine = [];
  double currentWidth = 0.0;
  // Index into currentLine of the last space glyph (potential break point).
  int lastBreakIdx = -1;

  void _flushLine(List<ShapedGlyph> glyphs, bool hard) {
    // Strip trailing spaces.
    int end = glyphs.length;
    while (end > 0 && glyphs[end - 1].isSpace) {
      end--;
    }
    rawLines.add((glyphs.sublist(0, end), hard));
  }

  for (final glyph in allGlyphs) {
    // Hard break on newline.
    if (glyph.isNewline) {
      _flushLine(List.of(currentLine), true);
      currentLine = [];
      currentWidth = 0.0;
      lastBreakIdx = -1;
      continue;
    }

    // Would adding this glyph overflow the line?
    if (currentLine.isNotEmpty &&
        maxWidth.isFinite &&
        currentWidth + glyph.advance > maxWidth) {
      if (lastBreakIdx >= 0) {
        // Break at last space: keep glyphs before the space on this line.
        final beforeBreak = currentLine.sublist(0, lastBreakIdx);
        final afterBreak = currentLine.sublist(lastBreakIdx + 1);
        _flushLine(beforeBreak, false);
        currentLine = List.of(afterBreak);
        currentWidth = currentLine.fold(0.0, (s, g) => s + g.advance);
        lastBreakIdx = -1;
      } else {
        // No break point found: force a character-boundary break.
        _flushLine(List.of(currentLine), false);
        currentLine = [];
        currentWidth = 0.0;
        lastBreakIdx = -1;
      }
    }

    if (glyph.isSpace) lastBreakIdx = currentLine.length;
    currentLine.add(glyph);
    currentWidth += glyph.advance;
  }

  if (currentLine.isNotEmpty) _flushLine(List.of(currentLine), true);

  // ── Step 4: apply maxLines and ellipsis ──────────────────────────────────
  bool didExceed = false;
  List<(List<ShapedGlyph>, bool)> visibleLines = rawLines;

  if (maxLines != null && rawLines.length > maxLines) {
    visibleLines = rawLines.sublist(0, maxLines);
    didExceed = true;
  }

  // Apply ellipsis: trim last line so that text + ellipsis fits in maxWidth.
  if (ellipsis != null && didExceed && visibleLines.isNotEmpty) {
    final lastEntry = visibleLines.last;
    final lastGlyphs = List<ShapedGlyph>.of(lastEntry.$1);

    // Measure ellipsis width using the style of the last glyph.
    double ellipsisWidth = 0.0;
    if (lastGlyphs.isNotEmpty) {
      final ref = lastGlyphs.last;
      final effectiveStyle = TextStyle(
          fontSize: ref.fontSize, fontFamily: ref.font.availableTables.first);
      for (final g in shapeText(ellipsis, effectiveStyle, ref.font)) {
        ellipsisWidth += g.advance;
      }
    }

    // Remove glyphs from the end until the line + ellipsis fits.
    double lineW = lastGlyphs.fold(0.0, (s, g) => s + g.advance);
    while (lastGlyphs.isNotEmpty && lineW + ellipsisWidth > maxWidth) {
      lineW -= lastGlyphs.last.advance;
      lastGlyphs.removeLast();
    }

    // Append ellipsis glyphs.
    if (lastGlyphs.isNotEmpty) {
      final ref = lastGlyphs.last;
      final effectiveStyle =
          TextStyle(fontSize: ref.fontSize, color: ref.color);
      lastGlyphs.addAll(shapeText(ellipsis, effectiveStyle, ref.font));
    }

    visibleLines = [
      ...visibleLines.sublist(0, visibleLines.length - 1),
      (lastGlyphs, true),
    ];
  }

  // ── Step 5: build LayoutLine objects with positions ──────────────────────
  final List<LayoutLine> lines = [];
  double yTop = 0.0; // top of current line

  for (int i = 0; i < visibleLines.length; i++) {
    final (glyphs, hardBreak) = visibleLines[i];

    // Per-line ascent/descent from font metrics.
    double ascent = 0.0;
    double descent = 0.0;
    for (final g in glyphs) {
      if (g.font.metrics.unitsPerEm == 0) continue;
      final scale = g.fontSize / g.font.metrics.unitsPerEm;
      final a = g.font.metrics.ascender * scale;
      final d = g.font.metrics.descender.abs() * scale;
      if (a > ascent) ascent = a;
      if (d > descent) descent = d;
    }
    // Fallback for empty lines.
    if (ascent == 0 && descent == 0) {
      final fs = paraStyle._fontSize ?? 14.0;
      ascent = fs * 0.8;
      descent = fs * 0.2;
    }

    final double baseline = yTop + ascent;

    // Glyph x offsets and total line width.
    final xOffsets = <double>[];
    double x = 0.0;
    for (final g in glyphs) {
      xOffsets.add(x);
      x += g.advance;
    }
    final lineWidth = x;

    // TextAlign horizontal offset.
    double left = 0.0;
    if (maxWidth.isFinite) {
      switch (textAlign) {
        case TextAlign.right:
        case TextAlign.end:
          left = math.max(0.0, maxWidth - lineWidth);
        case TextAlign.center:
          left = math.max(0.0, (maxWidth - lineWidth) / 2);
        default:
          left = 0.0;
      }
    }

    lines.add(LayoutLine(
      glyphs: glyphs,
      xOffsets: xOffsets,
      left: left,
      baseline: baseline,
      ascent: ascent,
      descent: descent,
      width: lineWidth,
      hardBreak: hardBreak,
    ));

    yTop = baseline + descent;
  }

  return _LayoutResult(lines, didExceed);
}
