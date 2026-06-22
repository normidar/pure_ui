// Concrete value types shared by every backend.
//
// Per the switching-architecture plan (§1.3), these are pure data types with
// no engine resources. They are implemented *once* here, with their `const`
// constructors preserved, and re-exported by every backend. They are never
// routed through `UiBackend` factory dispatch.

import 'dart:math' as math;

/// Base class for [Offset] and [Size], holding two doubles.
abstract class OffsetBase {
  const OffsetBase(this._dx, this._dy);

  final double _dx;
  final double _dy;

  /// Whether either component is [double.infinity] or [double.nan].
  bool get isInfinite => _dx >= double.infinity || _dy >= double.infinity;

  /// Whether both components are finite.
  bool get isFinite => _dx.isFinite && _dy.isFinite;

  bool operator <(OffsetBase other) => _dx < other._dx && _dy < other._dy;
  bool operator <=(OffsetBase other) => _dx <= other._dx && _dy <= other._dy;
  bool operator >(OffsetBase other) => _dx > other._dx && _dy > other._dy;
  bool operator >=(OffsetBase other) => _dx >= other._dx && _dy >= other._dy;

  @override
  bool operator ==(Object other) =>
      other is OffsetBase && other._dx == _dx && other._dy == _dy;

  @override
  int get hashCode => Object.hash(_dx, _dy);

  @override
  String toString() => 'OffsetBase(${_dx.toStringAsFixed(1)}, '
      '${_dy.toStringAsFixed(1)})';
}

/// An immutable 2D floating-point offset.
class Offset extends OffsetBase {
  const Offset(super.dx, super.dy);

  /// Creates an offset from its [direction] (radians) and [distance].
  factory Offset.fromDirection(double direction, [double distance = 1.0]) {
    return Offset(
        distance * math.cos(direction), distance * math.sin(direction));
  }

  /// An offset with zero magnitude.
  static const Offset zero = Offset(0.0, 0.0);

  /// An offset with infinite x and y components.
  static const Offset infinite = Offset(double.infinity, double.infinity);

  double get dx => _dx;
  double get dy => _dy;

  /// The magnitude of the offset.
  double get distance => math.sqrt(_dx * _dx + _dy * _dy);

  /// The square of the magnitude of the offset.
  double get distanceSquared => _dx * _dx + _dy * _dy;

  /// The angle of this offset in radians.
  double get direction => math.atan2(_dy, _dx);

  Offset scale(double scaleX, double scaleY) =>
      Offset(_dx * scaleX, _dy * scaleY);

  Offset translate(double translateX, double translateY) =>
      Offset(_dx + translateX, _dy + translateY);

  Offset operator -() => Offset(-_dx, -_dy);
  Offset operator -(Offset other) => Offset(_dx - other._dx, _dy - other._dy);
  Offset operator +(Offset other) => Offset(_dx + other._dx, _dy + other._dy);
  Offset operator *(double operand) => Offset(_dx * operand, _dy * operand);
  Offset operator /(double operand) => Offset(_dx / operand, _dy / operand);
  Offset operator %(double operand) => Offset(_dx % operand, _dy % operand);

  Rect operator &(Size other) =>
      Rect.fromLTWH(_dx, _dy, other.width, other.height);

  static Offset? lerp(Offset? a, Offset? b, double t) {
    if (b == null) {
      if (a == null) {
        return null;
      }
      return a * (1.0 - t);
    }
    if (a == null) {
      return b * t;
    }
    return Offset(_lerpD(a._dx, b._dx, t), _lerpD(a._dy, b._dy, t));
  }

  @override
  String toString() =>
      'Offset(${_dx.toStringAsFixed(1)}, ${_dy.toStringAsFixed(1)})';
}

/// Holds a 2D floating-point size.
class Size extends OffsetBase {
  const Size(super.width, super.height);
  Size.copy(Size source) : super(source.width, source.height);
  const Size.square(double dimension) : super(dimension, dimension);
  const Size.fromWidth(double width) : super(width, double.infinity);
  const Size.fromHeight(double height) : super(double.infinity, height);
  const Size.fromRadius(double radius) : super(radius * 2.0, radius * 2.0);

  static const Size zero = Size(0.0, 0.0);
  static const Size infinite = Size(double.infinity, double.infinity);

  double get width => _dx;
  double get height => _dy;

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
    return 0.0;
  }

  bool get isEmpty => width <= 0.0 || height <= 0.0;

  double get longestSide => math.max(width.abs(), height.abs());
  double get shortestSide => math.min(width.abs(), height.abs());

  Offset get topLeft => Offset.zero;
  Offset center(Offset origin) =>
      Offset(origin.dx + width / 2.0, origin.dy + height / 2.0);

  bool contains(Offset offset) =>
      offset.dx >= 0.0 &&
      offset.dx < width &&
      offset.dy >= 0.0 &&
      offset.dy < height;

  OffsetBase operator -(OffsetBase other) {
    if (other is Size) {
      return Offset(width - other.width, height - other.height);
    }
    if (other is Offset) {
      return Size(width - other.dx, height - other.dy);
    }
    throw ArgumentError(other);
  }

  Size operator +(Offset other) => Size(width + other.dx, height + other.dy);
  Size operator *(double operand) => Size(width * operand, height * operand);
  Size operator /(double operand) => Size(width / operand, height / operand);

  static Size? lerp(Size? a, Size? b, double t) {
    if (b == null) {
      if (a == null) {
        return null;
      }
      return a * (1.0 - t);
    }
    if (a == null) {
      return b * t;
    }
    return Size(_lerpD(a.width, b.width, t), _lerpD(a.height, b.height, t));
  }

  @override
  String toString() =>
      'Size(${width.toStringAsFixed(1)}, ${height.toStringAsFixed(1)})';
}

/// An immutable, 2D, axis-aligned, floating-point rectangle.
class Rect {
  const Rect.fromLTRB(this.left, this.top, this.right, this.bottom);

  const Rect.fromLTWH(double left, double top, double width, double height)
      : this.fromLTRB(left, top, left + width, top + height);

  Rect.fromCircle({required Offset center, required double radius})
      : this.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 2,
        );

  Rect.fromCenter(
      {required Offset center, required double width, required double height})
      : this.fromLTRB(
          center.dx - width / 2,
          center.dy - height / 2,
          center.dx + width / 2,
          center.dy + height / 2,
        );

  Rect.fromPoints(Offset a, Offset b)
      : this.fromLTRB(
          math.min(a.dx, b.dx),
          math.min(a.dy, b.dy),
          math.max(a.dx, b.dx),
          math.max(a.dy, b.dy),
        );

  final double left;
  final double top;
  final double right;
  final double bottom;

  static const Rect zero = Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);

  static const double _giantScalar = 1.0E+9;
  static const Rect largest =
      Rect.fromLTRB(-_giantScalar, -_giantScalar, _giantScalar, _giantScalar);

  double get width => right - left;
  double get height => bottom - top;
  Size get size => Size(width, height);

  bool get hasNaN => left.isNaN || top.isNaN || right.isNaN || bottom.isNaN;
  bool get isInfinite =>
      left >= double.infinity ||
      top >= double.infinity ||
      right >= double.infinity ||
      bottom >= double.infinity;
  bool get isFinite =>
      left.isFinite && top.isFinite && right.isFinite && bottom.isFinite;
  bool get isEmpty => left >= right || top >= bottom;

  Offset get topLeft => Offset(left, top);
  Offset get topCenter => Offset(left + width / 2.0, top);
  Offset get topRight => Offset(right, top);
  Offset get centerLeft => Offset(left, top + height / 2.0);
  Offset get center => Offset(left + width / 2.0, top + height / 2.0);
  Offset get centerRight => Offset(right, top + height / 2.0);
  Offset get bottomLeft => Offset(left, bottom);
  Offset get bottomCenter => Offset(left + width / 2.0, bottom);
  Offset get bottomRight => Offset(right, bottom);
  double get shortestSide => math.min(width.abs(), height.abs());
  double get longestSide => math.max(width.abs(), height.abs());

  Rect shift(Offset offset) => Rect.fromLTRB(
      left + offset.dx, top + offset.dy, right + offset.dx, bottom + offset.dy);

  Rect translate(double translateX, double translateY) => Rect.fromLTRB(
      left + translateX,
      top + translateY,
      right + translateX,
      bottom + translateY);

  Rect inflate(double delta) =>
      Rect.fromLTRB(left - delta, top - delta, right + delta, bottom + delta);

  Rect deflate(double delta) => inflate(-delta);

  Rect intersect(Rect other) => Rect.fromLTRB(
        math.max(left, other.left),
        math.max(top, other.top),
        math.min(right, other.right),
        math.min(bottom, other.bottom),
      );

  Rect expandToInclude(Rect other) => Rect.fromLTRB(
        math.min(left, other.left),
        math.min(top, other.top),
        math.max(right, other.right),
        math.max(bottom, other.bottom),
      );

  bool overlaps(Rect other) {
    if (right <= other.left || other.right <= left) {
      return false;
    }
    if (bottom <= other.top || other.bottom <= top) {
      return false;
    }
    return true;
  }

  bool contains(Offset offset) =>
      offset.dx >= left &&
      offset.dx < right &&
      offset.dy >= top &&
      offset.dy < bottom;

  static Rect? lerp(Rect? a, Rect? b, double t) {
    if (b == null) {
      if (a == null) {
        return null;
      }
      final double k = 1.0 - t;
      return Rect.fromLTRB(a.left * k, a.top * k, a.right * k, a.bottom * k);
    }
    if (a == null) {
      return Rect.fromLTRB(b.left * t, b.top * t, b.right * t, b.bottom * t);
    }
    return Rect.fromLTRB(
      _lerpD(a.left, b.left, t),
      _lerpD(a.top, b.top, t),
      _lerpD(a.right, b.right, t),
      _lerpD(a.bottom, b.bottom, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Rect &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'Rect.fromLTRB(${left.toStringAsFixed(1)}, '
      '${top.toStringAsFixed(1)}, ${right.toStringAsFixed(1)}, '
      '${bottom.toStringAsFixed(1)})';
}

/// A radius for either circular or elliptical (oval) shapes.
class Radius {
  const Radius.circular(double radius) : this.elliptical(radius, radius);
  const Radius.elliptical(this.x, this.y);

  final double x;
  final double y;

  static const Radius zero = Radius.circular(0.0);

  Radius operator -() => Radius.elliptical(-x, -y);
  Radius operator -(Radius other) =>
      Radius.elliptical(x - other.x, y - other.y);
  Radius operator +(Radius other) =>
      Radius.elliptical(x + other.x, y + other.y);
  Radius operator *(double operand) =>
      Radius.elliptical(x * operand, y * operand);
  Radius operator /(double operand) =>
      Radius.elliptical(x / operand, y / operand);

  static Radius? lerp(Radius? a, Radius? b, double t) {
    if (b == null) {
      if (a == null) {
        return null;
      }
      final double k = 1.0 - t;
      return Radius.elliptical(a.x * k, a.y * k);
    }
    if (a == null) {
      return Radius.elliptical(b.x * t, b.y * t);
    }
    return Radius.elliptical(_lerpD(a.x, b.x, t), _lerpD(a.y, b.y, t));
  }

  @override
  bool operator ==(Object other) =>
      other is Radius && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => x == y
      ? 'Radius.circular(${x.toStringAsFixed(1)})'
      : 'Radius.elliptical(${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)})';
}

/// An immutable rounded rectangle with possibly non-uniform corner radii.
class RRect {
  const RRect.fromLTRBXY(
    this.left,
    this.top,
    this.right,
    this.bottom,
    double radiusX,
    double radiusY,
  )   : tlRadiusX = radiusX,
        tlRadiusY = radiusY,
        trRadiusX = radiusX,
        trRadiusY = radiusY,
        brRadiusX = radiusX,
        brRadiusY = radiusY,
        blRadiusX = radiusX,
        blRadiusY = radiusY;

  RRect.fromLTRBR(
      double left, double top, double right, double bottom, Radius radius)
      : this.fromLTRBXY(left, top, right, bottom, radius.x, radius.y);

  RRect.fromRectXY(Rect rect, double radiusX, double radiusY)
      : this.fromLTRBXY(
            rect.left, rect.top, rect.right, rect.bottom, radiusX, radiusY);

  RRect.fromRectAndRadius(Rect rect, Radius radius)
      : this.fromLTRBXY(
            rect.left, rect.top, rect.right, rect.bottom, radius.x, radius.y);

  const RRect._raw({
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    this.tlRadiusX = 0.0,
    this.tlRadiusY = 0.0,
    this.trRadiusX = 0.0,
    this.trRadiusY = 0.0,
    this.brRadiusX = 0.0,
    this.brRadiusY = 0.0,
    this.blRadiusX = 0.0,
    this.blRadiusY = 0.0,
  });

  RRect.fromLTRBAndCorners(
    double left,
    double top,
    double right,
    double bottom, {
    Radius topLeft = Radius.zero,
    Radius topRight = Radius.zero,
    Radius bottomRight = Radius.zero,
    Radius bottomLeft = Radius.zero,
  }) : this._raw(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          tlRadiusX: topLeft.x,
          tlRadiusY: topLeft.y,
          trRadiusX: topRight.x,
          trRadiusY: topRight.y,
          brRadiusX: bottomRight.x,
          brRadiusY: bottomRight.y,
          blRadiusX: bottomLeft.x,
          blRadiusY: bottomLeft.y,
        );

  RRect.fromRectAndCorners(
    Rect rect, {
    Radius topLeft = Radius.zero,
    Radius topRight = Radius.zero,
    Radius bottomRight = Radius.zero,
    Radius bottomLeft = Radius.zero,
  }) : this.fromLTRBAndCorners(
          rect.left,
          rect.top,
          rect.right,
          rect.bottom,
          topLeft: topLeft,
          topRight: topRight,
          bottomRight: bottomRight,
          bottomLeft: bottomLeft,
        );

  final double left;
  final double top;
  final double right;
  final double bottom;
  final double tlRadiusX;
  final double tlRadiusY;
  final double trRadiusX;
  final double trRadiusY;
  final double brRadiusX;
  final double brRadiusY;
  final double blRadiusX;
  final double blRadiusY;

  static const RRect zero = RRect._raw();

  Radius get tlRadius => Radius.elliptical(tlRadiusX, tlRadiusY);
  Radius get trRadius => Radius.elliptical(trRadiusX, trRadiusY);
  Radius get brRadius => Radius.elliptical(brRadiusX, brRadiusY);
  Radius get blRadius => Radius.elliptical(blRadiusX, blRadiusY);

  double get width => right - left;
  double get height => bottom - top;
  Rect get outerRect => Rect.fromLTRB(left, top, right, bottom);
  Offset get center => Offset(left + width / 2.0, top + height / 2.0);

  RRect shift(Offset offset) => RRect.fromLTRBAndCorners(
        left + offset.dx,
        top + offset.dy,
        right + offset.dx,
        bottom + offset.dy,
        topLeft: tlRadius,
        topRight: trRadius,
        bottomRight: brRadius,
        bottomLeft: blRadius,
      );

  @override
  bool operator ==(Object other) =>
      other is RRect &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom &&
      other.tlRadiusX == tlRadiusX &&
      other.tlRadiusY == tlRadiusY &&
      other.trRadiusX == trRadiusX &&
      other.trRadiusY == trRadiusY &&
      other.brRadiusX == brRadiusX &&
      other.brRadiusY == brRadiusY &&
      other.blRadiusX == blRadiusX &&
      other.blRadiusY == blRadiusY;

  @override
  int get hashCode => Object.hash(
      left,
      top,
      right,
      bottom,
      tlRadiusX,
      tlRadiusY,
      trRadiusX,
      trRadiusY,
      brRadiusX,
      brRadiusY,
      blRadiusX,
      blRadiusY);

  @override
  String toString() => 'RRect.fromLTRBR(${left.toStringAsFixed(1)}, '
      '${top.toStringAsFixed(1)}, ${right.toStringAsFixed(1)}, '
      '${bottom.toStringAsFixed(1)}, $tlRadius)';
}

/// An immutable 32 bit color value in ARGB format, with wide-gamut support.
class Color {
  const Color(int value)
      : this._fromARGBC(
          (0xff000000 & value) >> 24,
          (0x00ff0000 & value) >> 16,
          (0x0000ff00 & value) >> 8,
          (0x000000ff & value) >> 0,
        );

  const Color._fromARGBC(int a, int r, int g, int b)
      : a = a / 255.0,
        r = r / 255.0,
        g = g / 255.0,
        b = b / 255.0;

  const Color.fromARGB(int a, int r, int g, int b)
      : this._fromARGBC(a, r, g, b);

  const Color.fromRGBO(int r, int g, int b, double opacity)
      : a = opacity,
        r = r / 255.0,
        g = g / 255.0,
        b = b / 255.0;

  const Color.from({
    required double alpha,
    required double red,
    required double green,
    required double blue,
  })  : a = alpha,
        r = red,
        g = green,
        b = blue;

  /// The alpha channel as a double between 0.0 and 1.0.
  final double a;

  /// The red channel as a double between 0.0 and 1.0.
  final double r;

  /// The green channel as a double between 0.0 and 1.0.
  final double g;

  /// The blue channel as a double between 0.0 and 1.0.
  final double b;

  int get alpha => (a * 255.0).round() & 0xff;
  int get red => (r * 255.0).round() & 0xff;
  int get green => (g * 255.0).round() & 0xff;
  int get blue => (b * 255.0).round() & 0xff;
  double get opacity => alpha / 0xFF;

  /// The 32-bit ARGB representation of this color.
  int get value => toARGB32();

  int toARGB32() =>
      ((alpha & 0xff) << 24) |
      ((red & 0xff) << 16) |
      ((green & 0xff) << 8) |
      ((blue & 0xff) << 0);

  Color withAlpha(int a) => Color.fromARGB(a, red, green, blue);

  Color withRed(int r) => Color.fromARGB(alpha, r, green, blue);
  Color withGreen(int g) => Color.fromARGB(alpha, red, g, blue);
  Color withBlue(int b) => Color.fromARGB(alpha, red, green, b);

  @Deprecated('Use .withValues() to avoid precision loss.')
  Color withOpacity(double opacity) => withAlpha((255.0 * opacity).round());

  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    return Color.from(
      alpha: alpha ?? a,
      red: red ?? r,
      green: green ?? g,
      blue: blue ?? b,
    );
  }

  double computeLuminance() {
    double linearize(double component) {
      if (component <= 0.03928) {
        return component / 12.92;
      }
      return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * linearize(r) +
        0.7152 * linearize(g) +
        0.0722 * linearize(b);
  }

  static Color? lerp(Color? a, Color? b, double t) {
    if (b == null) {
      if (a == null) {
        return null;
      }
      return a.withValues(alpha: a.a * (1.0 - t));
    }
    if (a == null) {
      return b.withValues(alpha: b.a * t);
    }
    return Color.from(
      alpha: _clamp01(_lerpD(a.a, b.a, t)),
      red: _clamp01(_lerpD(a.r, b.r, t)),
      green: _clamp01(_lerpD(a.g, b.g, t)),
      blue: _clamp01(_lerpD(a.b, b.b, t)),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Color &&
      other.a == a &&
      other.r == r &&
      other.g == g &&
      other.b == b;

  @override
  int get hashCode => Object.hash(a, r, g, b);

  @override
  String toString() =>
      'Color(0x${toARGB32().toRadixString(16).padLeft(8, '0')})';
}

double _lerpD(double a, double b, double t) => a + (b - a) * t;

double _clamp01(double v) => v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v);
