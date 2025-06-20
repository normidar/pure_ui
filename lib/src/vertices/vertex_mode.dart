/// Defines how a list of points is interpreted when drawing.
enum VertexMode {
  /// Draw each sequence of three points as a separate triangle.
  triangles,

  /// Draw each sequence of three points as a separate triangle, with a gap in between sequences.
  triangleStrip,

  /// Draw the first point, then each subsequent point is paired with the previously drawn point
  /// and the first point to form a triangle.
  triangleFan,
}
