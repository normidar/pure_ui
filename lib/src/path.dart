import 'dart:math' as math;

import 'package:pure_ui/src/offset.dart';
import 'package:pure_ui/src/rect.dart';

/// A complex, one-dimensional subset of a plane.
///
/// A path consists of a number of subpaths, and a current point.
///
/// Subpaths consist of segments of various types, such as lines,
/// arcs, or beziers. Subpaths can be open or closed, and can
/// self-intersect.
class Path {
  /// Creates an empty path.
  Path() : _commands = [], _points = [], _fillType = PathFillType.nonZero;

  final List<PathCommand> _commands;
  final List<Offset> _points;
  Offset _currentPoint = Offset.zero;
  PathFillType _fillType;

  /// Returns a list of commands in this path.
  List<PathCommand> get commands => List.unmodifiable(_commands);

  /// Returns a list of points in this path.
  List<Offset> get points => List.unmodifiable(_points);

  /// Gets or sets the fill type used when filling the path.
  PathFillType get fillType => _fillType;
  set fillType(PathFillType value) => _fillType = value;

  /// Adds a circle to the path.
  void addCircle(double x, double y, double radius) {
    addOval(Rect.fromLTRB(x - radius, y - radius, x + radius, y + radius));
  }

  /// Adds an oval to the path.
  void addOval(Rect rect) {
    final centerX = rect.left + rect.width / 2;
    final centerY = rect.top + rect.height / 2;
    final radiusX = rect.width / 2;
    final radiusY = rect.height / 2;

    // Approximate an oval with 4 bezier curves
    const kappa = 0.5522848; // Magic number for bezier approximation of circle
    final offsetX = radiusX * kappa;
    final offsetY = radiusY * kappa;

    moveTo(centerX + radiusX, centerY); // Start at right middle

    cubicTo(
      centerX + radiusX,
      centerY - offsetY, // First control point
      centerX + offsetX,
      centerY - radiusY, // Second control point
      centerX,
      centerY - radiusY, // End point (top middle)
    );

    cubicTo(
      centerX - offsetX,
      centerY - radiusY, // First control point
      centerX - radiusX,
      centerY - offsetY, // Second control point
      centerX - radiusX,
      centerY, // End point (left middle)
    );

    cubicTo(
      centerX - radiusX,
      centerY + offsetY, // First control point
      centerX - offsetX,
      centerY + radiusY, // Second control point
      centerX,
      centerY + radiusY, // End point (bottom middle)
    );

    cubicTo(
      centerX + offsetX,
      centerY + radiusY, // First control point
      centerX + radiusX,
      centerY + offsetY, // Second control point
      centerX + radiusX,
      centerY, // End point (back to right middle)
    );

    close();
  }

  /// Adds a rectangle to the path.
  void addRect(Rect rect) {
    moveTo(rect.left, rect.top);
    lineTo(rect.right, rect.top);
    lineTo(rect.right, rect.bottom);
    lineTo(rect.left, rect.bottom);
    close();
  }

  /// Adds a rounded rectangle to the path.
  void addRRect(Rect rect, double radiusX, double radiusY) {
    // Clamp radius to half the rect's width and height
    final double rx = math.min(radiusX, rect.width / 2);
    final double ry = math.min(radiusY, rect.height / 2);

    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;

    final offsetX = rx * 0.5522848; // Magic number for bezier approximation
    final offsetY = ry * 0.5522848;

    // Start at top-middle of the right side
    moveTo(right, top + ry);

    // Top-right corner
    cubicTo(
      right,
      top + ry - offsetY,
      right - rx + offsetX,
      top,
      right - rx,
      top,
    );

    // Top side
    lineTo(left + rx, top);

    // Top-left corner
    cubicTo(left + rx - offsetX, top, left, top + ry - offsetY, left, top + ry);

    // Left side
    lineTo(left, bottom - ry);

    // Bottom-left corner
    cubicTo(
      left,
      bottom - ry + offsetY,
      left + rx - offsetX,
      bottom,
      left + rx,
      bottom,
    );

    // Bottom side
    lineTo(right - rx, bottom);

    // Bottom-right corner
    cubicTo(
      right - rx + offsetX,
      bottom,
      right,
      bottom - ry + offsetY,
      right,
      bottom - ry,
    );

    // Right side
    lineTo(right, top + ry);

    close();
  }

  /// Adds a arc segment that curves from
  /// the current point to the given point (x,y),
  /// with radius `radius`.
  void arcToPoint(
    Offset arcEnd, {
    Offset? arcCenter,
    double radius = 0.0,
    bool clockwise = true,
  }) {
    // If we have a center point, use it; otherwise, calculate from radius.
    Offset center;
    if (arcCenter != null) {
      center = arcCenter;
    } else {
      // Calculate center from start, end, and radius
      final start = _currentPoint;
      final end = arcEnd;
      final distance = (end - start).distance;

      if (distance > radius * 2) {
        // Too far apart, just draw a line
        lineTo(arcEnd.dx, arcEnd.dy);
        return;
      }

      // Calculate center of the arc
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

      final distanceToCenter = math.sqrt(
        (radius * radius) - ((distance * distance) / 4),
      );
      final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);

      // Perpendicular angle
      final perpAngle = angle + (clockwise ? -math.pi / 2 : math.pi / 2);

      center = Offset(
        mid.dx + distanceToCenter * math.cos(perpAngle),
        mid.dy + distanceToCenter * math.sin(perpAngle),
      );
    }

    // Encode radius and direction
    _commands.add(PathCommand.arcTo);
    _points
      ..add(center)
      ..add(arcEnd)
      ..add(Offset(radius, clockwise ? 1.0 : 0.0));

    _currentPoint = arcEnd;
  }

  /// Closes the current subpath.
  void close() {
    _commands.add(PathCommand.close);
  }

  /// Returns a copy of the path.
  Path copy() {
    final result = Path();
    result._commands.addAll(_commands);
    result._points.addAll(_points);
    result._currentPoint = _currentPoint;
    result._fillType = _fillType;
    return result;
  }

  /// Adds a cubic bezier segment that curves from the current point
  /// to the given point (x3,y3), using the control points (x1,y1) and (x2,y2).
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    _commands.add(PathCommand.cubicTo);
    _points
      ..add(Offset(x1, y1))
      ..add(Offset(x2, y2))
      ..add(Offset(x3, y3));
    _currentPoint = Offset(x3, y3);
  }

  /// Adds a straight line segment from the current point to the given point.
  void lineTo(double x, double y) {
    _commands.add(PathCommand.lineTo);
    _points.add(Offset(x, y));
    _currentPoint = Offset(x, y);
  }

  /// Starts a new subpath at the given coordinate.
  void moveTo(double x, double y) {
    _commands.add(PathCommand.moveTo);
    _points.add(Offset(x, y));
    _currentPoint = Offset(x, y);
  }

  /// Adds a quadratic bezier segment that curves from the current point
  /// to the given point (x2,y2), using the control point (x1,y1).
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _commands.add(PathCommand.quadraticBezierTo);
    _points
      ..add(Offset(x1, y1))
      ..add(Offset(x2, y2));
    _currentPoint = Offset(x2, y2);
  }

  /// Adds a cubic bezier segment that curves from the current point
  /// to the point at the offset (x3,y3) from the current point, using the
  /// control points at the offsets (x1,y1) and (x2,y2) from the current point.
  void relativeCubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    cubicTo(
      _currentPoint.dx + x1,
      _currentPoint.dy + y1,
      _currentPoint.dx + x2,
      _currentPoint.dy + y2,
      _currentPoint.dx + x3,
      _currentPoint.dy + y3,
    );
  }

  /// Adds a straight line segment from the current point to the point
  /// at the given offset from the current point.
  void relativeLineTo(double dx, double dy) {
    lineTo(_currentPoint.dx + dx, _currentPoint.dy + dy);
  }

  /// Starts a new subpath at the given offset from the current point.
  void relativeMoveTo(double dx, double dy) {
    moveTo(_currentPoint.dx + dx, _currentPoint.dy + dy);
  }

  /// Adds a quadratic bezier segment that curves from the current point
  /// to the point at the offset (x2,y2) from the current point, using the
  /// control point at the offset (x1,y1) from the current point.
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    quadraticBezierTo(
      _currentPoint.dx + x1,
      _currentPoint.dy + y1,
      _currentPoint.dx + x2,
      _currentPoint.dy + y2,
    );
  }

  /// Clears the path.
  void reset() {
    _commands.clear();
    _points.clear();
    _currentPoint = Offset.zero;
  }
}

/// The types of path drawing commands.
enum PathCommand { moveTo, lineTo, quadraticBezierTo, cubicTo, arcTo, close }

/// The fill type for a path.
///
/// The fill type determines how overlapping areas of the path are filled.
enum PathFillType {
  /// Corresponds to the "non-zero" fill rule.
  ///
  /// For a given point, count the number of times a ray from that point to
  /// infinity crosses path segments going in one direction, and subtract the
  /// number of times the ray crosses path segments going in the opposite
  /// direction. If the result is zero, the point is outside the path. If it's
  /// non-zero, the point is inside the path.
  nonZero,

  /// Corresponds to the "even-odd" fill rule.
  ///
  /// For a given point, count the total number of times a ray from that point
  /// to infinity crosses path segments. If the result is an odd number, the
  /// point is inside the path. If it's an even number, the point is outside the
  /// path.
  evenOdd,
}
