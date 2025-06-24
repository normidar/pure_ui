part of 'canvas.dart';

extension CanvasRenderingMethods on Canvas {
  // Utility methods

  List<Offset> _renderArc(
    Offset start,
    Offset center,
    Offset end,
    double radius,
    bool clockwise,
    Paint paint,
  ) {
    // Approximate with lines
    const segments = 30; // Increased number of segments

    final startAngle = (start - center).direction;
    final endAngle = (end - center).direction;

    var sweepAngle = endAngle - startAngle;

    // Normalize sweepAngle
    if (clockwise && sweepAngle > 0) {
      sweepAngle = sweepAngle - 2 * math.pi;
    } else if (!clockwise && sweepAngle < 0) {
      sweepAngle = sweepAngle + 2 * math.pi;
    }

    var current = start;
    final List<Offset> arcPoints = [start];

    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final angle = startAngle + sweepAngle * t;

      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (paint.style == PaintingStyle.stroke) {
        _renderLine(current, point, paint);
      }
      current = point;
      arcPoints.add(point);
    }

    return arcPoints;
  }

  void _renderCircle(Offset center, double radius, Paint paint) {
    if (_image == null) return;

    final target = _image.image;

    // Use shader if available
    if (paint.shader != null) {
      // Calculate circle bounds
      final int centerX = center.dx.round();
      final int centerY = center.dy.round();
      final int r = radius.round();

      // Calculate circle bounding rectangle
      final int left = (centerX - r).floor();
      final int top = (centerY - r).floor();
      final int right = (centerX + r).ceil();
      final int bottom = (centerY + r).ceil();

      // Scan inside the circle
      for (int y = top; y <= bottom; y++) {
        for (int x = left; x <= right; x++) {
          if (x < 0 || x >= target.width || y < 0 || y >= target.height) {
            continue;
          }

          // Calculate distance from pixel center
          final dx = x + 0.5 - centerX;
          final dy = y + 0.5 - centerY;
          final distance = math.sqrt(dx * dx + dy * dy);

          // Apply shader color if inside the circle
          if (distance <= r) {
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
      return;
    }

    // Regular color processing when no shader is present
    // Use RGB values directly with the latest image package version
    final red = paint.color.red;
    final green = paint.color.green;
    final blue = paint.color.blue;
    final alpha = paint.color.alpha;

    final color = img.ColorRgba8(red, green, blue, alpha);

    // Circle center and radius
    final centerX = center.dx;
    final centerY = center.dy;
    final r = radius;

    // Add anti-aliasing processing
    final double antiAliasRadius = 1.0; // Anti-aliasing width

    if (paint.style == PaintingStyle.fill ||
        paint.style == PaintingStyle.stroke && paint.strokeWidth > 1) {
      // Filled circle or thick stroked circle
      for (int y = (centerY - r - antiAliasRadius).floor();
          y <= (centerY + r + antiAliasRadius).ceil();
          y++) {
        for (int x = (centerX - r - antiAliasRadius).floor();
            x <= (centerX + r + antiAliasRadius).ceil();
            x++) {
          if (x < 0 || x >= target.width || y < 0 || y >= target.height) {
            continue;
          }

          // Calculate distance from pixel center
          final dx = x + 0.5 - centerX;
          final dy = y + 0.5 - centerY;
          final distance = math.sqrt(dx * dx + dy * dy);

          if (paint.style == PaintingStyle.fill) {
            // For fill mode
            if (distance <= r) {
              // Completely fill the inside
              if (distance >= r - antiAliasRadius) {
                // Anti-aliasing near edges
                final opacity = (r - distance) / antiAliasRadius;
                final alphaValue = (alpha * opacity).round().clamp(0, 255);
                target.setPixel(
                  x,
                  y,
                  img.ColorRgba8(red, green, blue, alphaValue),
                );
              } else {
                // Completely inside
                target.setPixel(x, y, color);
              }
            }
          } else if (paint.style == PaintingStyle.stroke) {
            // For stroke mode (thick lines)
            final strokeHalfWidth = paint.strokeWidth / 2;
            final innerRadius = r - strokeHalfWidth;
            final outerRadius = r + strokeHalfWidth;

            if (distance >= innerRadius && distance <= outerRadius) {
              // Inside the stroke
              if (distance <= innerRadius + antiAliasRadius ||
                  distance >= outerRadius - antiAliasRadius) {
                // Anti-aliasing near edges
                final opacity = distance <= innerRadius + antiAliasRadius
                    ? (distance - innerRadius) / antiAliasRadius
                    : (outerRadius - distance) / antiAliasRadius;
                final alphaValue = (alpha * opacity).round().clamp(0, 255);
                target.setPixel(
                  x,
                  y,
                  img.ColorRgba8(red, green, blue, alphaValue),
                );
              } else {
                // Center of the stroke
                target.setPixel(x, y, color);
              }
            }
          }
        }
      }
    } else if (paint.style == PaintingStyle.stroke) {
      // Use image package's drawCircle for thin lines
      img.drawCircle(
        target,
        x: centerX.round(),
        y: centerY.round(),
        radius: radius.round(),
        color: color,
        antialias: true,
      );
    }
  }

  void _renderClipPath(Path path) {
    // In a real implementation, we would set up clipping
    // For this placeholder, we don't do anything as the _image doesn't support clipping
  }

  void _renderClipRect(Rect rect) {
    // In a real implementation, we would set up clipping
    // For this placeholder, we don't do anything as the _image doesn't support clipping
  }

  List<Offset> _renderCubicBezier(
    Offset start,
    Offset control1,
    Offset control2,
    Offset end,
    Paint paint,
  ) {
    // Approximate with lines
    const segments = 30; // Increased number of segments
    var current = start;
    final List<Offset> bezierPoints = [start]; // Collect bezier curve points

    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final oneMinusT = 1 - t;

      final point = Offset(
        oneMinusT * oneMinusT * oneMinusT * start.dx +
            3 * oneMinusT * oneMinusT * t * control1.dx +
            3 * oneMinusT * t * t * control2.dx +
            t * t * t * end.dx,
        oneMinusT * oneMinusT * oneMinusT * start.dy +
            3 * oneMinusT * oneMinusT * t * control1.dy +
            3 * oneMinusT * t * t * control2.dy +
            t * t * t * end.dy,
      );

      if (paint.style == PaintingStyle.stroke) {
        _renderLine(current, point, paint);
      }
      current = point;
      bezierPoints.add(point); // Record all points
    }

    // Return the list of bezier curve points
    return bezierPoints;
  }

  void _renderImage(Image image, Offset offset, Paint paint) {
    if (_image == null) return;

    final target = _image.image;
    final source = image.image;

    img.compositeImage(
      target,
      source,
      dstX: offset.dx.round(),
      dstY: offset.dy.round(),
      blend: _blendModeToImgBlend(paint.blendMode),
    );
  }

  void _renderImageRect(Image image, Rect src, Rect dst, Paint paint) {
    if (_image == null) return;

    final target = _image.image;
    final source = image.image;

    // Crop and resize the source image
    final croppedSource = img.copyCrop(
      source,
      x: src.left.round(),
      y: src.top.round(),
      width: src.width.round(),
      height: src.height.round(),
    );

    final resizedSource = img.copyResize(
      croppedSource,
      width: dst.width.round(),
      height: dst.height.round(),
    );

    img.compositeImage(
      target,
      resizedSource,
      dstX: dst.left.round(),
      dstY: dst.top.round(),
      blend: _blendModeToImgBlend(paint.blendMode),
    );
  }

  void _renderOval(Rect rect, Paint paint) {
    if (_image == null) return;

    final target = _image.image;

    // Calculate ellipse center and radius
    final centerX = rect.left + rect.width / 2;
    final centerY = rect.top + rect.height / 2;
    final radiusX = rect.width / 2;
    final radiusY = rect.height / 2;

    // Use shader if available
    if (paint.shader != null) {
      // Outline processing is done through path
      if (paint.style == PaintingStyle.stroke) {
        final path = Path()..addOval(rect);
        _renderPath(path, paint);
        return;
      }

      // Fill processing
      if (paint.style == PaintingStyle.fill) {
        // Calculate and draw each pixel of the ellipse directly
        final centerXi = centerX.round();
        final centerYi = centerY.round();
        final radiusXi = radiusX.round();
        final radiusYi = radiusY.round();

        // Scan within ellipse range
        for (int y = centerYi - radiusYi; y <= centerYi + radiusYi; y++) {
          for (int x = centerXi - radiusXi; x <= centerXi + radiusXi; x++) {
            // Ellipse equation: (x-h)²/a² + (y-k)²/b² <= 1
            final dx = x - centerXi;
            final dy = y - centerYi;

            // Use correct ellipse formula
            final value = (dx * dx) / (radiusXi * radiusXi) +
                (dy * dy) / (radiusYi * radiusYi);

            if (value <= 1.0) {
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
    final color = img.ColorRgba8(red, green, blue, alpha);

    // Outline processing is done through path
    if (paint.style == PaintingStyle.stroke) {
      final path = Path()..addOval(rect);
      _renderPath(path, paint);
      return;
    }

    // Fill processing
    if (paint.style == PaintingStyle.fill) {
      // Calculate and draw each pixel of the ellipse directly
      final centerXi = centerX.round();
      final centerYi = centerY.round();
      final radiusXi = radiusX.round();
      final radiusYi = radiusY.round();

      // Scan within ellipse range
      for (int y = centerYi - radiusYi; y <= centerYi + radiusYi; y++) {
        for (int x = centerXi - radiusXi; x <= centerXi + radiusXi; x++) {
          // Ellipse equation: (x-h)²/a² + (y-k)²/b² <= 1
          final dx = x - centerXi;
          final dy = y - centerYi;

          // Use correct ellipse formula
          final value = (dx * dx) / (radiusXi * radiusXi) +
              (dy * dy) / (radiusYi * radiusYi);

          if (value <= 1.0) {
            if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
              target.setPixel(x, y, color);
            }
          }
        }
      }
    }
  }

  void _renderPath(Path path, Paint paint) {
    if (_image == null) return;

    // For simplicity, convert the path to a series of lines and render those
    final commands = path.commands;
    final points = path.points;

    if (commands.isEmpty) return;

    var currentPoint = Offset.zero;
    var pointIndex = 0;

    // Collect path points for SVG fill processing
    final List<Offset> pathPoints = [];

    for (var i = 0; i < commands.length; i++) {
      final command = commands[i];

      switch (command) {
        case PathCommand.moveTo:
          currentPoint = points[pointIndex++];
          pathPoints.add(currentPoint);
        case PathCommand.lineTo:
          final nextPoint = points[pointIndex++];
          if (paint.style == PaintingStyle.stroke) {
            _renderLine(currentPoint, nextPoint, paint);
          }
          currentPoint = nextPoint;
          pathPoints.add(currentPoint);
        case PathCommand.quadraticBezierTo:
          final controlPoint = points[pointIndex++];
          final endPoint = points[pointIndex++];

          // Draw quadratic bezier curve and get detailed point list
          final bezierPoints = _renderQuadraticBezier(
            currentPoint,
            controlPoint,
            endPoint,
            paint,
          );

          // Add more detailed point list for fill
          if (paint.style == PaintingStyle.fill && bezierPoints.length > 1) {
            // Add from second point since first might already be added
            pathPoints.addAll(bezierPoints.sublist(1));
          } else {
            // For stroke or single point, add only end point
            pathPoints.add(endPoint);
          }

          currentPoint = endPoint;
        case PathCommand.cubicTo:
          final controlPoint1 = points[pointIndex++];
          final controlPoint2 = points[pointIndex++];
          final endPoint = points[pointIndex++];

          // Draw bezier curve and get detailed point list
          final bezierPoints = _renderCubicBezier(
            currentPoint,
            controlPoint1,
            controlPoint2,
            endPoint,
            paint,
          );

          // Add more detailed point list for fill
          if (paint.style == PaintingStyle.fill && bezierPoints.length > 1) {
            // Add from second point since first might already be added
            pathPoints.addAll(bezierPoints.sublist(1));
          } else {
            // For stroke or single point, add only end point
            pathPoints.add(endPoint);
          }

          currentPoint = endPoint;
        case PathCommand.arcTo:
          final center = points[pointIndex++];
          final endPoint = points[pointIndex++];
          final radiusAndClockwise = points[pointIndex++];

          // Arc also generates detailed point list
          final arcPoints = _renderArc(
            currentPoint,
            center,
            endPoint,
            radiusAndClockwise.dx,
            radiusAndClockwise.dy > 0,
            paint,
          );

          if (paint.style == PaintingStyle.fill && arcPoints.length > 1) {
            pathPoints.addAll(arcPoints.sublist(1));
          } else {
            pathPoints.add(endPoint);
          }

          currentPoint = endPoint;
        case PathCommand.close:
          // Close the path
          if (pathPoints.isNotEmpty) {
            if (paint.style == PaintingStyle.stroke) {
              _renderLine(currentPoint, pathPoints.first, paint);
            }
            // For fill mode, explicitly show return to first point
            if (currentPoint != pathPoints.first) {
              pathPoints.add(pathPoints.first);
            }
          }
          break;
      }
    }

    // If fill is specified, fill the path interior
    if (paint.style == PaintingStyle.fill && pathPoints.length > 2) {
      _fillPolygon(pathPoints, paint);
    }
  }

  void _renderPicture(Picture picture) {
    // Create a temporary canvas for the image
    final Image tempImage = _image!.clone();
    final Canvas tempCanvas = Canvas.forImage(tempImage);

    // Replay picture operations onto the temporary canvas
    picture.playback(tempCanvas);

    // Now copy the rendered image back to our canvas
    // This avoids the recursive loop of playback onto self
    final targetImg = _image.image;
    final sourceImg = tempImage.image;

    // Copy all pixels from the source to target
    for (int y = 0; y < sourceImg.height; y++) {
      for (int x = 0; x < sourceImg.width; x++) {
        final pixel = sourceImg.getPixel(x, y);
        targetImg.setPixel(x, y, pixel);
      }
    }

    // Dispose of temporary resources
    tempImage.dispose();
  }

  List<Offset> _renderQuadraticBezier(
    Offset start,
    Offset control,
    Offset end,
    Paint paint,
  ) {
    // Approximate with lines
    const segments = 20; // Increased number of segments
    var current = start;
    final List<Offset> bezierPoints = [start];

    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final oneMinusT = 1 - t;

      final point = Offset(
        oneMinusT * oneMinusT * start.dx +
            2 * oneMinusT * t * control.dx +
            t * t * end.dx,
        oneMinusT * oneMinusT * start.dy +
            2 * oneMinusT * t * control.dy +
            t * t * end.dy,
      );

      if (paint.style == PaintingStyle.stroke) {
        _renderLine(current, point, paint);
      }
      current = point;
      bezierPoints.add(point);
    }

    return bezierPoints;
  }

  void _renderRect(Rect rect, Paint paint) {
    if (_image == null) return;

    final target = _image.image;

    // Use shader if available
    if (paint.shader != null) {
      // Scan rectangle range
      for (int y = rect.top.round(); y <= rect.bottom.round(); y++) {
        for (int x = rect.left.round(); x <= rect.right.round(); x++) {
          if (x < 0 || x >= target.width || y < 0 || y >= target.height) {
            continue;
          }

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
      return;
    }

    // Regular color processing when no shader is present
    // Use RGB values directly with the latest image package version
    final red = paint.color.red;
    final green = paint.color.green;
    final blue = paint.color.blue;
    final alpha = paint.color.alpha;

    if (paint.style == PaintingStyle.fill) {
      img.fillRect(
        target,
        x1: rect.left.round(),
        y1: rect.top.round(),
        x2: rect.right.round(),
        y2: rect.bottom.round(),
        color: img.ColorRgba8(red, green, blue, alpha),
      );
    } else {
      img.drawRect(
        target,
        x1: rect.left.round(),
        y1: rect.top.round(),
        x2: rect.right.round(),
        y2: rect.bottom.round(),
        color: img.ColorRgba8(red, green, blue, alpha),
        thickness: paint.strokeWidth.round(),
      );
    }
  }

  void _renderRRect(Rect rect, double radiusX, double radiusY, Paint paint) {
    // For simplicity, convert to a path and render that
    final path = Path()..addRRect(rect, radiusX, radiusY);
    _renderPath(path, paint);
  }

  void _renderSaveLayer(Rect? bounds, Paint paint) {
    // In a real implementation, we would create a new bitmap buffer
    // For this placeholder, we don't do anything as we're not supporting layers
  }

  void _renderTransform(Float64List matrix4) {
    // In a real implementation, we would apply the transform to all subsequent drawing operations
    // For this placeholder, we don't do anything as the _image doesn't support transformations directly
  }

  void _renderVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    if (_image == null) return;

    // Simple implementation that renders each triangle as a filled path
    final List<Offset> positions = vertices.positions;
    final List<int>? indices = vertices.indices;

    final Path path = Path();

    if (indices != null) {
      // Render triangles using indices
      for (int i = 0; i < indices.length; i += 3) {
        if (i + 2 < indices.length) {
          final Offset p1 = positions[indices[i]];
          final Offset p2 = positions[indices[i + 1]];
          final Offset p3 = positions[indices[i + 2]];

          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy);
          path.lineTo(p3.dx, p3.dy);
          path.close();
        }
      }
    } else {
      // Render triangles in sequence
      for (int i = 0; i < positions.length; i += 3) {
        if (i + 2 < positions.length) {
          final Offset p1 = positions[i];
          final Offset p2 = positions[i + 1];
          final Offset p3 = positions[i + 2];

          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy);
          path.lineTo(p3.dx, p3.dy);
          path.close();
        }
      }
    }

    _renderPath(path, paint);
  }
}
