import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'offset_base.dart';
import 'rect.dart';
import 'size.dart';

/// An immutable 2D floating-point offset.
///
/// This represents the distance between two points in Cartesian space.
@immutable
class Offset extends OffsetBase {
  /// The x component of the offset.
  @override
  final double dx;

  /// The y component of the offset.
  @override
  final double dy;

  /// Creates an offset. The first argument sets [dx], the horizontal component,
  /// and the second sets [dy], the vertical component.
  const Offset(this.dx, this.dy);

  /// Creates an offset from a [Size].
  ///
  /// The returned offset has the x component set to [size.width] and the y
  /// component set to [size.height].
  Offset.fromSize(Size size) : this(size.width, size.height);

  /// The offset with zero magnitude.
  static const Offset zero = Offset(0.0, 0.0);

  /// Returns the angle in radians from the positive x-axis to this offset.
  double get direction => math.atan2(dy, dx);

  /// Returns the distance between this offset and the origin.
  double get distance => math.sqrt(dx * dx + dy * dy);

  /// Returns the square of the distance between this offset and the origin.
  double get distanceSquared => dx * dx + dy * dy;

  /// Returns a new offset with the same direction as this offset but with a
  /// magnitude of 1.0.
  Offset get normalized {
    final magnitude = distance;
    if (magnitude == 0.0) {
      return Offset.zero;
    }
    return Offset(dx / magnitude, dy / magnitude);
  }

  /// Create a rectangle from this offset and a size.
  ///
  /// The returned rectangle has this offset as its top-left coordinate, and the
  /// given size as its size.
  Rect operator &(Size size) => Rect.fromLTWH(dx, dy, size.width, size.height);

  /// Returns a new offset whose coordinates are the coordinates of the this
  /// offset plus the coordinates of the given offset.
  Offset operator +(Offset other) => Offset(dx + other.dx, dy + other.dy);

  /// Returns a new offset whose coordinates are the coordinates of the this
  /// offset minus the coordinates of the given offset.
  Offset operator -(Offset other) => Offset(dx - other.dx, dy - other.dy);

  /// Returns a new offset whose coordinates are the coordinates of the this
  /// offset multiplied by the given factor.
  Offset operator *(double operand) => Offset(dx * operand, dy * operand);

  /// Returns a new offset whose coordinates are the coordinates of the this
  /// offset divided by the given factor.
  Offset operator /(double operand) => Offset(dx / operand, dy / operand);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Offset && other.dx == dx && other.dy == dy;
  }

  @override
  int get hashCode => Object.hash(dx, dy);

  /// Returns a new offset with the x component scaled by [scaleX] and the y
  /// component scaled by [scaleY].
  Offset scale(double scaleX, double scaleY) =>
      Offset(dx * scaleX, dy * scaleY);

  @override
  String toString() => 'Offset($dx, $dy)';

  /// Returns a new offset with translateX added to the x component and
  /// translateY added to the y component.
  Offset translate(double translateX, double translateY) =>
      Offset(dx + translateX, dy + translateY);

  /// The distance from this offset to another offset.
  double distanceTo(Offset other) {
    final dx = this.dx - other.dx;
    final dy = this.dy - other.dy;
    return math.sqrt(dx * dx + dy * dy);
  }
}
