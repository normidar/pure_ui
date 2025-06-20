import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:pure_ui/src/offset.dart';
import 'package:pure_ui/src/offset_base.dart';

/// Holds a 2D floating-point size.
///
/// You can think of this as an Offset from the origin.
@immutable
class Size extends OffsetBase {
  /// Creates a Size with the given [width] and [height].
  const Size(this.width, this.height);

  /// Creates an instance of Size that has the same values as another.
  Size.copy(Size source) : this(source.width, source.height);

  /// Creates a Size with the given [height] and an infinite width.
  const Size.fromHeight(double height) : this(double.infinity, height);

  /// Creates a square Size whose width and height are twice the given dimension.
  const Size.fromRadius(double radius) : this(radius * 2.0, radius * 2.0);

  /// Creates a Size with the given [width] and an infinite height.
  const Size.fromWidth(double width) : this(width, double.infinity);

  /// Creates a square Size whose width and height are the given dimension.
  const Size.square(double dimension) : this(dimension, dimension);

  /// A size whose width and height are infinite.
  static const Size infinite = Size(double.infinity, double.infinity);

  /// An empty size, one with a zero width and a zero height.
  static const Size zero = Size(0, 0);

  /// The horizontal extent of this size.
  final double width;

  /// The vertical extent of this size.
  final double height;

  /// The aspect ratio of this size.
  ///
  /// This returns the [width] divided by the [height].
  ///
  /// If the [width] is zero, the result is zero.
  /// If the [height] is zero, the result is [double.infinity] or [double.nan].
  double get aspectRatio {
    if (height != 0.0) {
      return width / height;
    }
    if (width > 0.0) {
      return double.infinity;
    }
    if (width < 0.0) {
      return double.negativeInfinity;
    }
    return 0;
  }

  /// The horizontal component of this vector.
  @override
  double get dx => width;

  /// The vertical component of this vector.
  @override
  double get dy => height;

  /// A Size with the width and height swapped.
  Size get flipped => Size(height, width);

  @override
  int get hashCode => Object.hash(width, height);

  /// Whether this size encloses a non-zero area.
  ///
  /// Negative areas are considered empty.
  bool get isEmpty => width <= 0.0 || height <= 0.0;

  /// Whether both components are finite (neither infinite nor NaN).
  bool get isFinite => width.isFinite && height.isFinite;

  /// Whether either component is [double.infinity], and neither is NaN.
  bool get isInfinite => width >= double.infinity || height >= double.infinity;

  /// The greater of the magnitudes of the [width] and the [height].
  double get longestSide => math.max(width.abs(), height.abs());

  /// The lesser of the magnitudes of the [width] and the [height].
  double get shortestSide => math.min(width.abs(), height.abs());

  /// Modulo (remainder) operator.
  Size operator %(double operand) => Size(width % operand, height % operand);

  /// Multiplication operator.
  Size operator *(double operand) => Size(width * operand, height * operand);

  /// Binary addition operator for adding an Offset to a Size.
  Size operator +(Offset other) => Size(width + other.dx, height + other.dy);

  /// Binary subtraction operator for Size.
  Offset operator -(OffsetBase other) =>
      Offset(width - other.dx, height - other.dy);

  /// Division operator.
  Size operator /(double operand) => Size(width / operand, height / operand);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Size && other.width == width && other.height == height;
  }

  /// The offset to the center of the bottom edge of the rectangle described by
  /// the given offset (which is interpreted as the top-left corner) and this size.
  ///
  /// See also [topCenter], [bottomLeft], [bottomRight], [center].
  Offset bottomCenter(Offset origin) =>
      Offset(origin.dx + width / 2.0, origin.dy + height);

  /// The offset to the intersection of the bottom and left edges of the
  /// rectangle described by the given offset (which is interpreted as the
  /// top-left corner) and this size.
  ///
  /// See also [topLeft], [bottomRight], [topRight], [center].
  Offset bottomLeft(Offset origin) => Offset(origin.dx, origin.dy + height);

  /// The offset to the intersection of the bottom and right edges of the
  /// rectangle described by the given offset (which is interpreted as the
  /// top-left corner) and this size.
  ///
  /// See also [topLeft], [bottomLeft], [topRight], [center].
  Offset bottomRight(Offset origin) =>
      Offset(origin.dx + width, origin.dy + height);

  /// The offset to the point halfway between the left and right and the top and
  /// bottom edges of the rectangle described by the given offset (which is
  /// interpreted as the top-left corner) and this size.
  ///
  /// See also [topCenter], [bottomCenter], [centerLeft], [centerRight].
  Offset center(Offset origin) =>
      Offset(origin.dx + width / 2.0, origin.dy + height / 2.0);

  /// The offset to the center of the left edge of the rectangle described by the
  /// given offset (which is interpreted as the top-left corner) and this size.
  ///
  /// See also [topLeft], [bottomLeft], [centerRight], [center].
  Offset centerLeft(Offset origin) =>
      Offset(origin.dx, origin.dy + height / 2.0);

  /// The offset to the center of the right edge of the rectangle described by the
  /// given offset (which is interpreted as the top-left corner) and this size.
  ///
  /// See also [topRight], [bottomRight], [centerLeft], [center].
  Offset centerRight(Offset origin) =>
      Offset(origin.dx + width, origin.dy + height / 2.0);

  /// Whether the point specified by the given offset (which is assumed to be
  /// relative to the top left of the size) lies between the left and right and
  /// the top and bottom edges of a rectangle of this size.
  ///
  /// Rectangles include their top and left edges but exclude their bottom and
  /// right edges.
  bool contains(Offset offset) {
    return offset.dx >= 0.0 &&
        offset.dx < width &&
        offset.dy >= 0.0 &&
        offset.dy < height;
  }

  /// The offset to the center of the top edge of the rectangle described by the
  /// given offset (which is interpreted as the top-left corner) and this size.
  ///
  /// See also [topLeft], [topRight], [bottomCenter], [center].
  Offset topCenter(Offset origin) => Offset(origin.dx + width / 2.0, origin.dy);

  /// The offset to the intersection of the top and left edges of the rectangle
  /// described by the given offset (which is interpreted as the top-left corner)
  /// and this size.
  ///
  /// See also [bottomLeft], [bottomRight], [topRight], [center].
  Offset topLeft(Offset origin) => origin;

  /// The offset to the intersection of the top and right edges of the rectangle
  /// described by the given offset (which is interpreted as the top-left corner)
  /// and this size.
  ///
  /// See also [topLeft], [bottomRight], [bottomLeft], [center].
  Offset topRight(Offset origin) => Offset(origin.dx + width, origin.dy);

  @override
  String toString() => 'Size($width, $height)';

  /// Integer (truncating) division operator.
  Size operator ~/(double operand) =>
      Size((width ~/ operand).toDouble(), (height ~/ operand).toDouble());

  /// Linearly interpolate between two sizes.
  ///
  /// If either size is null, this function interpolates from [Size.zero].
  ///
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid.
  static Size? lerp(Size? a, Size? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return b! * t;
    }
    if (b == null) {
      return a * (1.0 - t);
    }
    return Size(
      a.width + (b.width - a.width) * t,
      a.height + (b.height - a.height) * t,
    );
  }
}
