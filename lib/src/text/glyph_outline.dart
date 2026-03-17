part of dart.ui;

/// A single point in a TrueType glyph contour.
///
/// Coordinates are in font design units with **Y increasing upward** (TTF
/// convention). The rasterizer must flip the Y axis when converting to screen
/// coordinates.
///
/// [onCurve] determines how the point participates in Bézier curve
/// construction:
/// - `true`: the point lies on the curve (endpoint of a segment or quadratic
///   Bézier endpoint).
/// - `false`: the point is a quadratic Bézier control point (off-curve).
///
/// TrueType uses quadratic Bézier curves (unlike PostScript/CFF which uses
/// cubic). Two consecutive off-curve points imply an implicit on-curve point
/// halfway between them.
class GlyphPoint {
  final double x;
  final double y;
  final bool onCurve;

  const GlyphPoint(this.x, this.y, this.onCurve);

  GlyphPoint translated(double dx, double dy) =>
      GlyphPoint(x + dx, y + dy, onCurve);

  GlyphPoint transformed(double a, double b, double c, double d) =>
      GlyphPoint(x * a + y * c, x * b + y * d, onCurve);

  @override
  String toString() => 'GlyphPoint($x, $y, onCurve: $onCurve)';
}

/// A closed contour (outline loop) within a glyph.
///
/// The last point implicitly connects back to the first, closing the contour.
/// Contours are wound clockwise for filled areas and counter-clockwise for
/// holes (counter inside counter = filled, etc.).
class GlyphContour {
  final List<GlyphPoint> points;

  const GlyphContour(this.points);

  GlyphContour translated(double dx, double dy) => GlyphContour(
        points.map((p) => p.translated(dx, dy)).toList(growable: false),
      );

  GlyphContour transformed(double a, double b, double c, double d) =>
      GlyphContour(
        points
            .map((p) => p.transformed(a, b, c, d))
            .toList(growable: false),
      );

  @override
  String toString() => 'GlyphContour(${points.length} points)';
}

/// The complete outline of a single glyph, in font design units.
///
/// Instances are produced by [TtfFont.getGlyphOutline].
///
/// [advanceWidth] is the horizontal advance width (how far to move the pen
/// after this glyph). [lsb] is the left side bearing (distance from the
/// pen origin to the start of the ink bounding box).
///
/// Both [advanceWidth] and [lsb] are in font design units. Multiply by
/// `fontSize / font.metrics.unitsPerEm` to convert to pixels.
class GlyphOutline {
  /// The contours that form the glyph's outline.
  final List<GlyphContour> contours;

  /// Advance width in font design units.
  final double advanceWidth;

  /// Left side bearing in font design units.
  final double lsb;

  const GlyphOutline({
    required this.contours,
    required this.advanceWidth,
    required this.lsb,
  });

  bool get isEmpty => contours.isEmpty;

  @override
  String toString() =>
      'GlyphOutline(${contours.length} contours, '
      'advanceWidth: $advanceWidth, lsb: $lsb)';
}
