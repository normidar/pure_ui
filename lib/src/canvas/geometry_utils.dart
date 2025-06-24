part of 'canvas.dart';

extension CanvasGeometryUtils on Canvas {
  /// Line drawing considering StrokeCap implementation
  void _drawLineWithStrokeCap(img.Image target, Offset p1, Offset p2,
      double strokeWidth, StrokeCap strokeCap, img.Color color) {
    // Draw the basic line
    img.drawLine(
      target,
      x1: p1.dx.round(),
      y1: p1.dy.round(),
      x2: p2.dx.round(),
      y2: p2.dy.round(),
      color: color,
      thickness: strokeWidth.round(),
    );

    // Add shapes to both ends according to StrokeCap
    final halfWidth = strokeWidth / 2;

    switch (strokeCap) {
      case StrokeCap.butt:
        // Default flat ends - do nothing
        break;

      case StrokeCap.round:
        // Add semicircles to both ends
        img.fillCircle(
          target,
          x: p1.dx.round(),
          y: p1.dy.round(),
          radius: halfWidth.round(),
          color: color,
        );
        img.fillCircle(
          target,
          x: p2.dx.round(),
          y: p2.dy.round(),
          radius: halfWidth.round(),
          color: color,
        );
        break;

      case StrokeCap.square:
        // Add rectangular extensions to both ends
        final lineDx = p2.dx - p1.dx;
        final lineDy = p2.dy - p1.dy;
        final length = math.sqrt(lineDx * lineDx + lineDy * lineDy);

        if (length > 0) {
          // Normalized direction vector
          final dirX = lineDx / length;
          final dirY = lineDy / length;

          // Perpendicular vector
          final perpX = -dirY;
          final perpY = dirX;

          // Start point extension rectangle
          final startCorner1 = Offset(
            p1.dx - dirX * halfWidth + perpX * halfWidth,
            p1.dy - dirY * halfWidth + perpY * halfWidth,
          );
          final startCorner2 = Offset(
            p1.dx - dirX * halfWidth - perpX * halfWidth,
            p1.dy - dirY * halfWidth - perpY * halfWidth,
          );
          final startCorner3 = Offset(
            p1.dx + perpX * halfWidth,
            p1.dy + perpY * halfWidth,
          );
          final startCorner4 = Offset(
            p1.dx - perpX * halfWidth,
            p1.dy - perpY * halfWidth,
          );

          // End point extension rectangle
          final endCorner1 = Offset(
            p2.dx + dirX * halfWidth + perpX * halfWidth,
            p2.dy + dirY * halfWidth + perpY * halfWidth,
          );
          final endCorner2 = Offset(
            p2.dx + dirX * halfWidth - perpX * halfWidth,
            p2.dy + dirY * halfWidth - perpY * halfWidth,
          );
          final endCorner3 = Offset(
            p2.dx + perpX * halfWidth,
            p2.dy + perpY * halfWidth,
          );
          final endCorner4 = Offset(
            p2.dx - perpX * halfWidth,
            p2.dy - perpY * halfWidth,
          );

          // Draw start point extension rectangle
          _fillQuadrilateral(target, startCorner1, startCorner2, startCorner4,
              startCorner3, color);

          // Draw end point extension rectangle
          _fillQuadrilateral(
              target, endCorner3, endCorner4, endCorner2, endCorner1, color);
        }
        break;
    }
  }

  // Helper method for filling polygon interior
  void _fillPolygon(List<Offset> points, Paint paint) {
    if (_image == null || points.length < 3) return;

    final target = _image.image;

    // Calculate bounds
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in points) {
      minX = math.min(minX, point.dx);
      minY = math.min(minY, point.dy);
      maxX = math.max(maxX, point.dx);
      maxY = math.max(maxY, point.dy);
    }

    // Use shader if available
    if (paint.shader != null) {
      // Scan polygon bounds
      for (int y = minY.floor(); y <= maxY.ceil(); y++) {
        final List<double> intersections = [];

        // Find y intersections with each edge
        for (int i = 0; i < points.length - 1; i++) {
          final p1 = points[i];
          final p2 = points[i + 1];

          if ((p1.dy <= y && p2.dy > y) || (p2.dy <= y && p1.dy > y)) {
            // Edge intersects with scan line
            if (p1.dy != p2.dy) {
              // Not a horizontal line
              final x = p1.dx + (y - p1.dy) / (p2.dy - p1.dy) * (p2.dx - p1.dx);
              intersections.add(x);
            }
          }
        }

        // Sort intersections
        intersections.sort();

        // Fill between intersection pairs
        for (int i = 0; i < intersections.length - 1; i += 2) {
          if (i + 1 < intersections.length) {
            final startX = intersections[i].floor();
            final endX = intersections[i + 1].ceil();

            for (int x = startX; x <= endX; x++) {
              if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
                // For LinearGradient
                if (paint.shader is LinearGradient) {
                  final gradient = paint.shader as LinearGradient;
                  final colorValue = _evaluateLinearGradient(
                    gradient,
                    Offset(x.toDouble(), y.toDouble()),
                  );
                  target.setPixel(x, y, _colorToImgColor(colorValue));
                }
                // For RadialGradient
                else if (paint.shader is RadialGradient) {
                  final gradient = paint.shader as RadialGradient;
                  final colorValue = _evaluateRadialGradient(
                    gradient,
                    Offset(x.toDouble(), y.toDouble()),
                  );
                  target.setPixel(x, y, _colorToImgColor(colorValue));
                }
                // For SweepGradient
                else if (paint.shader is SweepGradient) {
                  final gradient = paint.shader as SweepGradient;
                  final colorValue = _evaluateSweepGradient(
                    gradient,
                    Offset(x.toDouble(), y.toDouble()),
                  );
                  target.setPixel(x, y, _colorToImgColor(colorValue));
                }
              }
            }
          }
        }
      }
      return;
    }

    // Regular color processing when no shader is present
    // Get RGB values
    final red = paint.color.red;
    final green = paint.color.green;
    final blue = paint.color.blue;
    final alpha = paint.color.alpha;

    // Check all pixels and fill polygon interior
    final color = img.ColorRgba8(red, green, blue, alpha);

    // Simple polygon fill (scanline method)
    for (int y = minY.floor(); y <= maxY.ceil(); y++) {
      final List<double> intersections =
          []; // Changed from int to double for more accuracy

      // Find y intersections with each edge
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        if ((p1.dy <= y && p2.dy > y) || (p2.dy <= y && p1.dy > y)) {
          // Edge intersects with scan line, more accurate calculation
          if (p1.dy != p2.dy) {
            // Not a horizontal line
            final x = p1.dx + (y - p1.dy) / (p2.dy - p1.dy) * (p2.dx - p1.dx);
            intersections.add(x);
          }
        }
      }

      // Sort intersections
      intersections.sort();

      // Fill between intersection pairs
      for (int i = 0; i < intersections.length - 1; i += 2) {
        if (i + 1 < intersections.length) {
          final startX = intersections[i].floor();
          final endX = intersections[i + 1].ceil();

          for (int x = startX; x <= endX; x++) {
            if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
              target.setPixel(x, y, color);
            }
          }
        }
      }
    }
  }

  /// Fill quadrilateral (specify four vertices)
  void _fillQuadrilateral(img.Image target, Offset p1, Offset p2, Offset p3,
      Offset p4, img.Color color) {
    // Calculate quadrilateral bounds
    final minX = [p1.dx, p2.dx, p3.dx, p4.dx].reduce(math.min).floor();
    final maxX = [p1.dx, p2.dx, p3.dx, p4.dx].reduce(math.max).ceil();
    final minY = [p1.dy, p2.dy, p3.dy, p4.dy].reduce(math.min).floor();
    final maxY = [p1.dy, p2.dy, p3.dy, p4.dy].reduce(math.max).ceil();

    // Check if each pixel is inside the quadrilateral
    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
          final point = Offset(x.toDouble(), y.toDouble());
          if (_isPointInQuadrilateral(point, p1, p2, p3, p4)) {
            target.setPixel(x, y, color);
          }
        }
      }
    }
  }

  /// Determine if a point is inside a quadrilateral
  bool _isPointInQuadrilateral(
      Offset point, Offset p1, Offset p2, Offset p3, Offset p4) {
    // Check if the point is inside all four edges
    final vertices = [p1, p2, p3, p4];

    // Check if the point is on the left side of all edges
    for (int i = 0; i < 4; i++) {
      final current = vertices[i];
      final next = vertices[(i + 1) % 4];

      // Use cross product to check if the point is on the left side of the edge
      final cross = (next.dx - current.dx) * (point.dy - current.dy) -
          (next.dy - current.dy) * (point.dx - current.dx);

      if (cross < 0) {
        return false;
      }
    }

    return true;
  }

  void _renderLine(Offset p1, Offset p2, Paint paint) {
    if (_image == null) return;

    final target = _image.image;

    // Use shader if available
    if (paint.shader != null) {
      // Calculate each pixel based on the line equation
      final lineDx = p2.dx - p1.dx;
      final lineDy = p2.dy - p1.dy;
      final length = math.sqrt(lineDx * lineDx + lineDy * lineDy);

      if (length < 1) {
        // Draw as a single point if the length is very short
        final x = p1.dx.round();
        final y = p1.dy.round();
        if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
          // For LinearGradient
          if (paint.shader is LinearGradient) {
            final gradient = paint.shader as LinearGradient;
            final colorValue = _evaluateLinearGradient(
              gradient,
              Offset(x.toDouble(), y.toDouble()),
            );
            target.setPixel(x, y, _colorToImgColor(colorValue));
          }
          // For RadialGradient
          else if (paint.shader is RadialGradient) {
            final gradient = paint.shader as RadialGradient;
            final colorValue = _evaluateRadialGradient(
              gradient,
              Offset(x.toDouble(), y.toDouble()),
            );
            target.setPixel(x, y, _colorToImgColor(colorValue));
          }
          // For SweepGradient
          else if (paint.shader is SweepGradient) {
            final gradient = paint.shader as SweepGradient;
            final colorValue = _evaluateSweepGradient(
              gradient,
              Offset(x.toDouble(), y.toDouble()),
            );
            target.setPixel(x, y, _colorToImgColor(colorValue));
          }
        }
        return;
      }

      // Consider line width
      final halfWidth = (paint.strokeWidth / 2).round();
      if (halfWidth <= 0) {
        // Use Bresenham's algorithm for lines with 1px or less thickness
        final steep = lineDy.abs() > lineDx.abs();

        // Swap x,y coordinates
        int x0, y0, x1, y1;
        if (steep) {
          x0 = p1.dy.round();
          y0 = p1.dx.round();
          x1 = p2.dy.round();
          y1 = p2.dx.round();
        } else {
          x0 = p1.dx.round();
          y0 = p1.dy.round();
          x1 = p2.dx.round();
          y1 = p2.dy.round();
        }

        // Always draw from left to right
        if (x0 > x1) {
          final temp = x0;
          x0 = x1;
          x1 = temp;
          final temp2 = y0;
          y0 = y1;
          y1 = temp2;
        }

        final lineDeltaX = x1 - x0;
        final lineDeltaY = (y1 - y0).abs();
        int error = lineDeltaX ~/ 2;
        int ystep = (y0 < y1) ? 1 : -1;
        int y = y0;

        for (int x = x0; x <= x1; x++) {
          int px, py;
          if (steep) {
            px = y;
            py = x;
          } else {
            px = x;
            py = y;
          }

          if (px >= 0 && px < target.width && py >= 0 && py < target.height) {
            // For LinearGradient
            if (paint.shader is LinearGradient) {
              final gradient = paint.shader as LinearGradient;
              final colorValue = _evaluateLinearGradient(
                gradient,
                Offset(px.toDouble(), py.toDouble()),
              );
              target.setPixel(px, py, _colorToImgColor(colorValue));
            }
            // For RadialGradient
            else if (paint.shader is RadialGradient) {
              final gradient = paint.shader as RadialGradient;
              final colorValue = _evaluateRadialGradient(
                gradient,
                Offset(px.toDouble(), py.toDouble()),
              );
              target.setPixel(px, py, _colorToImgColor(colorValue));
            }
            // For SweepGradient
            else if (paint.shader is SweepGradient) {
              final gradient = paint.shader as SweepGradient;
              final colorValue = _evaluateSweepGradient(
                gradient,
                Offset(px.toDouble(), py.toDouble()),
              );
              target.setPixel(px, py, _colorToImgColor(colorValue));
            }
          }

          error -= lineDeltaY;
          if (error < 0) {
            y += ystep;
            error += lineDeltaX;
          }
        }
      } else {
        // Calculate line bounds
        final x0 = math.min(p1.dx, p2.dx) - halfWidth;
        final y0 = math.min(p1.dy, p2.dy) - halfWidth;
        final x1 = math.max(p1.dx, p2.dx) + halfWidth;
        final y1 = math.max(p1.dy, p2.dy) + halfWidth;

        for (int y = y0.floor(); y <= y1.ceil(); y++) {
          for (int x = x0.floor(); x <= x1.ceil(); x++) {
            if (x < 0 || x >= target.width || y < 0 || y >= target.height) {
              continue;
            }

            // Calculate distance from point to line
            final px = x - p1.dx;
            final py = y - p1.dy;

            // Calculate parameter t for the closest point on the line
            final t = (px * lineDx + py * lineDy) / (length * length);

            if (t < 0 || t > 1) {
              // Outside the line segment
              continue;
            }

            // Closest point on the line
            final nearestX = p1.dx + t * lineDx;
            final nearestY = p1.dy + t * lineDy;

            // Distance from point to line
            final distance = math.sqrt(
              (x - nearestX) * (x - nearestX) + (y - nearestY) * (y - nearestY),
            );

            if (distance <= paint.strokeWidth / 2) {
              // For LinearGradient
              if (paint.shader is LinearGradient) {
                final gradient = paint.shader as LinearGradient;
                final colorValue = _evaluateLinearGradient(
                  gradient,
                  Offset(x.toDouble(), y.toDouble()),
                );
                target.setPixel(x, y, _colorToImgColor(colorValue));
              }
              // For RadialGradient
              else if (paint.shader is RadialGradient) {
                final gradient = paint.shader as RadialGradient;
                final colorValue = _evaluateRadialGradient(
                  gradient,
                  Offset(x.toDouble(), y.toDouble()),
                );
                target.setPixel(x, y, _colorToImgColor(colorValue));
              }
              // For SweepGradient
              else if (paint.shader is SweepGradient) {
                final gradient = paint.shader as SweepGradient;
                final colorValue = _evaluateSweepGradient(
                  gradient,
                  Offset(x.toDouble(), y.toDouble()),
                );
                target.setPixel(x, y, _colorToImgColor(colorValue));
              }
            }
          }
        }
      }
      return;
    }

    // Regular color processing when no shader is present
    // Use RGB values directly with the latest image package version
    final red = paint.color.red;
    final green = paint.color.green;
    final blue = paint.color.blue;
    final alpha = paint.color.alpha;
    final color = img.ColorRgba8(red, green, blue, alpha);

    // Line drawing considering StrokeCap
    _drawLineWithStrokeCap(
        target, p1, p2, paint.strokeWidth, paint.strokeCap, color);
  }
}
