part of 'canvas.dart';

extension CanvasGradientUtils on Canvas {
  // Convert Color to img.ColorRgba8
  img.ColorRgba8 _colorToImgColor(Color color) {
    return img.ColorRgba8(color.red, color.green, color.blue, color.alpha);
  }

  // Helper method: Evaluate LinearGradient to get color
  Color _evaluateLinearGradient(LinearGradient gradient, Offset point) {
    // Calculate gradient vector
    final dx = gradient.to.dx - gradient.from.dx;
    final dy = gradient.to.dy - gradient.from.dy;
    final length = math.sqrt(dx * dx + dy * dy);

    // Vector from point to start point
    final px = point.dx - gradient.from.dx;
    final py = point.dy - gradient.from.dy;

    // Calculate projection distance along gradient vector
    double t = 0.0;
    if (length > 0) {
      // Dot product with normalized vector
      t = (px * dx + py * dy) / (length * length);
    }

    // Apply tile mode processing
    switch (gradient.tileMode) {
      case TileMode.clamp:
        t = t.clamp(0.0, 1.0);
        break;
      case TileMode.repeated:
        t = t - t.floor();
        break;
      case TileMode.mirror:
        // Reverse for odd number of repetitions
        final int intPart = t.floor();
        t = intPart.isOdd ? 1.0 - (t - intPart) : t - intPart;
        break;
      // Default is clamp
      default:
        t = t.clamp(0.0, 1.0);
        break;
    }

    // Color interpolation
    return _interpolateGradientColor(gradient.colors, gradient.stops, t);
  }

  // Helper method: Evaluate RadialGradient to get color
  Color _evaluateRadialGradient(RadialGradient gradient, Offset point) {
    // Vector from point to center
    final dx = point.dx - gradient.center.dx;
    final dy = point.dy - gradient.center.dy;

    // Calculate distance from center
    final distance = math.sqrt(dx * dx + dy * dy);

    // Normalized distance
    double t = (distance / gradient.radius).clamp(0.0, 1.0);

    // Apply tile mode processing
    switch (gradient.tileMode) {
      case TileMode.clamp:
        t = t.clamp(0.0, 1.0);
        break;
      case TileMode.repeated:
        t = t - t.floor();
        break;
      case TileMode.mirror:
        // Reverse for odd number of repetitions
        final int intPart = t.floor();
        t = intPart.isOdd ? 1.0 - (t - intPart) : t - intPart;
        break;
      // Default is clamp
      default:
        t = t.clamp(0.0, 1.0);
        break;
    }

    // Color interpolation
    return _interpolateGradientColor(gradient.colors, gradient.stops, t);
  }

  // Helper method: Evaluate SweepGradient to get color
  Color _evaluateSweepGradient(SweepGradient gradient, Offset point) {
    // Vector from point to center
    final dx = point.dx - gradient.center.dx;
    final dy = point.dy - gradient.center.dy;

    // Calculate angle (radians)
    double angle = math.atan2(dy, dx);
    if (angle < 0) {
      angle += 2 * math.pi; // Normalize to 0~2π range
    }

    // Normalize within start angle to end angle range
    final sweepAngle = gradient.endAngle - gradient.startAngle;
    final normalizedAngle = angle - gradient.startAngle;

    // Map to 0~1 range
    double t = (normalizedAngle / sweepAngle).clamp(0.0, 1.0);

    // Apply tile mode processing
    switch (gradient.tileMode) {
      case TileMode.clamp:
        t = t.clamp(0.0, 1.0);
        break;
      case TileMode.repeated:
        t = t - t.floor();
        break;
      case TileMode.mirror:
        // Reverse for odd number of repetitions
        final int intPart = t.floor();
        t = intPart.isOdd ? 1.0 - (t - intPart) : t - intPart;
        break;
      // Default is clamp
      default:
        t = t.clamp(0.0, 1.0);
        break;
    }

    // Color interpolation
    return _interpolateGradientColor(gradient.colors, gradient.stops, t);
  }

  // Helper method: Interpolate gradient colors
  Color _interpolateGradientColor(
    List<Color> colors,
    List<double>? stops,
    double t,
  ) {
    if (colors.isEmpty) {
      return Color.black;
    }
    if (colors.length == 1) {
      return colors[0];
    }

    // If stops are not specified, place them at equal intervals
    final List<double> effectiveStops;
    if (stops == null || stops.isEmpty) {
      effectiveStops = List<double>.generate(
        colors.length,
        (i) => i / (colors.length - 1),
      );
    } else {
      effectiveStops = stops;
    }

    // Find the index of stops closest to t
    int startIndex = 0;
    for (int i = 0; i < effectiveStops.length; i++) {
      if (effectiveStops[i] > t) {
        break;
      }
      startIndex = i;
    }

    // If it's the last color
    if (startIndex >= colors.length - 1) {
      return colors.last;
    }

    // Interpolate between two colors
    final startColor = colors[startIndex];
    final endColor = colors[startIndex + 1];
    final startStop = effectiveStops[startIndex];
    final endStop = effectiveStops[startIndex + 1];

    // Normalize
    final localT = (endStop > startStop)
        ? ((t - startStop) / (endStop - startStop)).clamp(0.0, 1.0)
        : 0.0;

    // Linear interpolation of color
    return Color.lerp(startColor, endColor, localT);
  }
}
