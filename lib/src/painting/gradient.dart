import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:pure_ui/src/color.dart';
import 'package:pure_ui/src/offset.dart';
import 'package:pure_ui/src/painting/shader.dart';
import 'package:pure_ui/src/painting/tile_mode.dart';

/// Base class for all gradient shaders.
///
/// A gradient is a mapping of a range of input values to a range of colors, which
/// can be used to shade drawings on a canvas. This class provides an abstract
/// interface for describing the color mapping.
@immutable
abstract class Gradient extends Shader {
  /// Construct a new gradient.
  const Gradient();

  /// Creates a linear gradient from the specified points and colors.
  ///
  /// The [colors] argument must not be null. If [colorStops] is non-null, it must have
  /// the same length as [colors].
  static LinearGradient linear(
    Offset from,
    Offset to,
    List<Color> colors,
    List<double>? colorStops,
    TileMode tileMode,
  ) {
    return LinearGradient(
      colors: colors,
      stops: colorStops,
      from: from,
      to: to,
      tileMode: tileMode,
    );
  }

  /// Creates a radial gradient from the specified parameters.
  ///
  /// The [colors] argument must not be null. If [colorStops] is non-null, it must have
  /// the same length as [colors].
  static RadialGradient radial(
    Offset center,
    double radius,
    List<Color> colors,
    List<double>? colorStops,
    TileMode tileMode,
    Float64List? matrix4,
    Offset? focal,
  ) {
    return RadialGradient(
      colors: colors,
      stops: colorStops,
      center: center,
      radius: radius,
      tileMode: tileMode,
      focal: focal,
      matrix4: matrix4,
    );
  }
}

/// A 2D linear gradient.
///
/// This gradient draws a line between two points and produces even color
/// distribution from the start point to the end point.
class LinearGradient extends Gradient {
  /// Creates a linear gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must have
  /// the same length as [colors].
  const LinearGradient({
    required this.colors,
    this.stops,
    this.from = Offset.zero,
    this.to = const Offset(1, 0),
    this.tileMode = TileMode.clamp,
  });

  /// The colors the gradient should obtain at each of the stops.
  ///
  /// If [stops] is non-null, this list must have the same length as [stops].
  final List<Color> colors;

  /// A list of values from 0.0 to 1.0 that denote fractions along the gradient.
  ///
  /// If non-null, this list must have the same length as [colors].
  final List<double>? stops;

  /// The offset at which stop 0.0 of the gradient is placed.
  final Offset from;

  /// The offset at which stop 1.0 of the gradient is placed.
  final Offset to;

  /// How this gradient should tile the plane beyond in the region before
  /// [from] and after [to].
  final TileMode tileMode;

  @override
  int get hashCode => Object.hash(
        from,
        to,
        tileMode,
        Object.hashAll(colors),
        stops == null ? null : Object.hashAll(stops!),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LinearGradient &&
        other.from == from &&
        other.to == to &&
        other.tileMode == tileMode &&
        _colorsEqual(other.colors, colors) &&
        _stopsEqual(other.stops, stops);
  }

  bool _colorsEqual(List<Color> a, List<Color> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  bool _stopsEqual(List<double>? a, List<double>? b) {
    if (a == null && b == null) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

/// A 2D radial gradient.
///
/// This gradient draws a circle centered at [center] with radius [radius].
/// Colors specified in [colors] are arranged proportionally from the center of the circle to its edge.
class RadialGradient extends Gradient {
  /// Creates a radial gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must have
  /// the same length as [colors].
  const RadialGradient({
    required this.colors,
    this.stops,
    this.center = const Offset(0.5, 0.5),
    this.radius = 0.5,
    this.tileMode = TileMode.clamp,
    this.focal,
    this.focalRadius = 0.0,
    this.matrix4,
  });

  /// The colors the gradient should obtain at each of the stops.
  ///
  /// If [stops] is non-null, this list must have the same length as [stops].
  final List<Color> colors;

  /// A list of values from 0.0 to 1.0 that denote fractions along the gradient.
  ///
  /// If non-null, this list must have the same length as [colors].
  final List<double>? stops;

  /// The center of the gradient, as an offset into the unit square.
  final Offset center;

  /// The radius of the gradient, as a fraction of the shortest side
  /// of the paint box.
  final double radius;

  /// How this gradient should tile the plane beyond the circle.
  final TileMode tileMode;

  /// The focal point of the gradient, as an offset into the unit square.
  ///
  /// If this is specified and not equal to [center], then the gradient will
  /// be non-symmetric.
  final Offset? focal;

  /// The radius of the focal point of the gradient, as a fraction of the
  /// shortest side of the paint box.
  ///
  /// If this is specified and not equal to 0.0, then the gradient will
  /// be non-symmetric.
  final double focalRadius;

  /// The matrix4 transformation applied to the gradient.
  final Float64List? matrix4;

  @override
  int get hashCode => Object.hash(
        center,
        radius,
        tileMode,
        focal,
        focalRadius,
        matrix4,
        Object.hashAll(colors),
        stops == null ? null : Object.hashAll(stops!),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is RadialGradient &&
        other.center == center &&
        other.radius == radius &&
        other.tileMode == tileMode &&
        other.focal == focal &&
        other.focalRadius == focalRadius &&
        other.matrix4 == matrix4 &&
        _colorsEqual(other.colors, colors) &&
        _stopsEqual(other.stops, stops);
  }

  bool _colorsEqual(List<Color> a, List<Color> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  bool _stopsEqual(List<double>? a, List<double>? b) {
    if (a == null && b == null) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

/// A 2D sweep gradient.
///
/// This gradient draws colors in a circle around [center], starting at angle
/// [startAngle] and continuing clockwise for an angle of [endAngle - startAngle].
class SweepGradient extends Gradient {
  /// Creates a sweep gradient.
  ///
  /// The [colors] argument must not be null. If [stops] is non-null, it must have
  /// the same length as [colors].
  const SweepGradient({
    required this.colors,
    this.stops,
    this.center = const Offset(0.5, 0.5),
    this.startAngle = 0.0,
    this.endAngle = math.pi * 2,
    this.tileMode = TileMode.clamp,
  });

  /// The colors the gradient should obtain at each of the stops.
  ///
  /// If [stops] is non-null, this list must have the same length as [stops].
  final List<Color> colors;

  /// A list of values from 0.0 to 1.0 that denote fractions along the gradient.
  ///
  /// If non-null, this list must have the same length as [colors].
  final List<double>? stops;

  /// The center of the gradient, as an offset into the unit square.
  final Offset center;

  /// The angle in radians at which to begin the gradient.
  ///
  /// Angles are measured clockwise, with 0.0 pointing to the right.
  final double startAngle;

  /// The angle in radians at which to end the gradient.
  ///
  /// Angles are measured clockwise, with 0.0 pointing to the right.
  final double endAngle;

  /// How this gradient should tile the plane beyond the sweep.
  final TileMode tileMode;

  @override
  int get hashCode => Object.hash(
        center,
        startAngle,
        endAngle,
        tileMode,
        Object.hashAll(colors),
        stops == null ? null : Object.hashAll(stops!),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SweepGradient &&
        other.center == center &&
        other.startAngle == startAngle &&
        other.endAngle == endAngle &&
        other.tileMode == tileMode &&
        _colorsEqual(other.colors, colors) &&
        _stopsEqual(other.stops, stops);
  }

  bool _colorsEqual(List<Color> a, List<Color> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  bool _stopsEqual(List<double>? a, List<double>? b) {
    if (a == null && b == null) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
