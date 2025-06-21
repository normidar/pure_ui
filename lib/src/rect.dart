import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:pure_ui/src/offset.dart';

/// An immutable, 2D, axis-aligned, floating-point rectangle.
@immutable
class Rect {
  /// Construct a rectangle from its left, top, right, and bottom edges.
  const Rect.fromLTRB(this.left, this.top, this.right, this.bottom);

  /// Construct a rectangle from its left and top edges,
  /// its width, and its height.
  const Rect.fromLTWH(double left, double top, double width, double height)
      : this.fromLTRB(left, top, left + width, top + height);

  /// A rectangle with all coordinates set to zero.
  static const Rect zero = Rect.fromLTRB(0, 0, 0, 0);

  /// The offset of the left edge of this rectangle from the x axis.
  final double left;

  /// The offset of the top edge of this rectangle from the y axis.
  final double top;

  /// The offset of the right edge of this rectangle from the x axis.
  final double right;

  /// The offset of the bottom edge of this rectangle from the y axis.
  final double bottom;

  /// The bottom-left corner of the rectangle.
  Offset get bottomLeft => Offset(left, bottom);

  /// The bottom-right corner of the rectangle.
  Offset get bottomRight => Offset(right, bottom);

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  /// The distance between the top and bottom edges of this rectangle.
  double get height => bottom - top;

  /// The top-left corner of the rectangle.
  Offset get topLeft => Offset(left, top);

  /// The top-right corner of the rectangle.
  Offset get topRight => Offset(right, top);

  /// The distance between the left and right edges of this rectangle.
  double get width => right - left;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Rect &&
        other.left == left &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom;
  }

  /// Whether the given point is contained inside this rectangle.
  bool contains(Offset point) {
    return point.dx >= left &&
        point.dx < right &&
        point.dy >= top &&
        point.dy < bottom;
  }

  /// Returns a new rectangle with edges moved inwards by the given delta.
  Rect deflate(double delta) => inflate(-delta);

  /// Returns a new rectangle with edges moved outwards by the given delta.
  Rect inflate(double delta) {
    return Rect.fromLTRB(
      left - delta,
      top - delta,
      right + delta,
      bottom + delta,
    );
  }

  /// Returns a new rectangle that is the intersection of
  /// the given rectangle and this rectangle.
  Rect intersect(Rect other) {
    return Rect.fromLTRB(
      math.max(left, other.left),
      math.max(top, other.top),
      math.min(right, other.right),
      math.min(bottom, other.bottom),
    );
  }

  @override
  String toString() => 'Rect.fromLTRB($left, $top, $right, $bottom)';

  /// Returns a new rectangle translated by the given offset.
  Rect translate(double dx, double dy) {
    return Rect.fromLTRB(left + dx, top + dy, right + dx, bottom + dy);
  }
}
