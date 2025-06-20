/// A blend mode to use when compositing a picture.
enum BlendMode {
  // These must be kept in sync with SkBlendMode.
  clear,
  src,
  dst,
  srcOver,
  dstOver,
  srcIn,
  dstIn,
  srcOut,
  dstOut,
  srcATop,
  dstATop,
  xor,
  plus,
  modulate,
  screen,
  overlay,
  darken,
  lighten,
  colorDodge,
  colorBurn,
  hardLight,
  softLight,
  difference,
  exclusion,
  multiply,
  hue,
  saturation,
  color,
  luminosity,
}

/// Different ways to paint a box.
enum BoxFit {
  /// Fill the target box by distorting the source's aspect ratio.
  fill,

  /// As large as possible while still containing the source entirely within the
  /// target box.
  contain,

  /// As small as possible while still covering the entire target box.
  cover,

  /// Align the source within the target box (by default, centering) and discard
  /// any portions of the source that lie outside the box.
  none,

  /// Align the source within the target box (by default, centering) and, if
  /// necessary, scale the source down to ensure
  /// that the source fits within the box.
  scaleDown,
}

/// The quality of image sampling to use.
enum FilterQuality {
  /// Fastest filtering, low quality.
  none,

  /// Low-quality filtering, faster than medium.
  low,

  /// Medium-quality filtering, faster than high.
  medium,

  /// High-quality filtering, slower than other options.
  high,
}

/// The styles to use for line endings.
enum StrokeCap {
  /// Begin and end contours with a flat edge and no extension.
  butt,

  /// Begin and end contours with a semi-circle extension.
  round,

  /// Begin and end contours with a half square extension.
  square,
}

/// The styles to use for line segment joins.
enum StrokeJoin {
  /// Joins between line segments form sharp corners.
  miter,

  /// Joins between line segments are rounded.
  round,

  /// Joins between line segments are beveled.
  bevel,
}

enum TextDirection {
  /// The text flows from right to left (e.g. Arabic, Hebrew).
  rtl,

  /// The text flows from left to right (e.g., English, French).
  ltr,
}
