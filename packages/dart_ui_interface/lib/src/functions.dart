// Top-level helpers that are pure computation (plan §4.4). These do not depend
// on a backend.

/// Linearly interpolate between [a] and [b] by [t]. Returns null if both are
/// null, matching `dart:ui`.
double? lerpDouble(num? a, num? b, double t) {
  if (a == b || (a?.isNaN ?? false) && (b?.isNaN ?? false)) {
    return a?.toDouble();
  }
  a ??= 0.0;
  b ??= 0.0;
  return a.toDouble() * (1.0 - t) + b.toDouble() * t;
}

/// Same as [num.clamp] but specialized for non-null [double]s; avoids the
/// boxing overhead and matches `dart:ui.clampDouble`.
double clampDouble(double x, double min, double max) {
  if (x < min) {
    return min;
  }
  if (x > max) {
    return max;
  }
  if (x.isNaN) {
    return max;
  }
  return x;
}
