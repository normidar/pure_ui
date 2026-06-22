// Enums shared by every backend.
//
// Per the plan (§4.2) these are defined once here. Adapters must map them to
// the backend's native enums with *explicit* switches — never by relying on
// `index` matching, which can drift between versions.

/// Algorithms to use when painting on the canvas.
enum BlendMode {
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

/// Strategies for painting shapes and paths on a canvas.
enum PaintingStyle {
  fill,
  stroke,
}

/// Styles to use for line endings.
enum StrokeCap {
  butt,
  round,
  square,
}

/// Styles to use for line segment joins.
enum StrokeJoin {
  miter,
  round,
  bevel,
}

/// Styles to use for blurs in [MaskFilter] objects.
enum BlurStyle {
  normal,
  solid,
  outer,
  inner,
}

/// Quality levels for image sampling in [ImageFilter] and [Shader] objects.
enum FilterQuality {
  none,
  low,
  medium,
  high,
}

/// Different ways to clip a widget's content.
enum Clip {
  none,
  hardEdge,
  antiAlias,
  antiAliasWithSaveLayer,
}

/// How to clip a [Rect] in a canvas.
enum ClipOp {
  difference,
  intersect,
}

/// Determines the winding rule that decides how the interior of a [Path] is
/// calculated.
enum PathFillType {
  nonZero,
  evenOdd,
}

/// Strategies for combining paths.
enum PathOperation {
  difference,
  intersect,
  union,
  xor,
  reverseDifference,
}

/// Defines how a list of points is interpreted when drawing a set of triangles.
enum VertexMode {
  triangles,
  triangleStrip,
  triangleFan,
}

/// Defines how a list of points is interpreted when drawing a set of points.
enum PointMode {
  points,
  lines,
  polygon,
}

/// Defines what happens at the edge of a gradient or the sampling of a source
/// image in an [ImageFilter].
enum TileMode {
  clamp,
  repeated,
  mirror,
  decal,
}

/// The format of pixel data given to [decodeImageFromPixels].
enum PixelFormat {
  rgba8888,
  bgra8888,
  rgbaFloat32,
}

/// The format in which image bytes should be returned.
enum ImageByteFormat {
  rawRgba,
  rawStraightRgba,
  rawUnmodified,
  png,
  rawExtendedRgba128,
}
