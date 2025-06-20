/// Defines what happens at the edge of a gradient or shader.
enum TileMode {
  /// Edge is clamped to the final color.
  clamp,

  /// Edge is repeated from first color to last.
  repeated,

  /// Edge is mirrored from last color to first.
  mirror,

  /// The gradient/shader stops at the edge and the remaining area is transparent.
  decal,
}
