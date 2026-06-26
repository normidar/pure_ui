// Shader / filter abstractions (plan §4.3 shader slice).
//
// All construction is backend-dispatched. Each backend returns its own
// concrete that `implements` these contracts. Where a backend lacks support
// (e.g. pure_ui has no MaskFilter) the factory throws UnsupportedError — gate
// with `UiBackend.supports(BackendFeature.shaders)` etc. before calling.

import 'dart:typed_data';

import 'backend.dart';
import 'enums.dart';
import 'values.dart';

/// Marker for objects that can be assigned to [Paint.shader] (currently just
/// gradients and image shaders).
abstract class Shader {
  bool get debugDisposed;
  void dispose();
}

/// A shader that linearly maps a one-dimensional progression of color stops to
/// a 2-D area. The factory dispatches to the active backend.
abstract class Gradient implements Shader {
  factory Gradient.linear(
    Offset from,
    Offset to,
    List<Color> colors, [
    List<double>? colorStops,
    TileMode tileMode = TileMode.clamp,
    Float64List? matrix4,
  ]) =>
      UiBackend.instance.createLinearGradient(
        from,
        to,
        colors,
        colorStops,
        tileMode,
        matrix4,
      );

  factory Gradient.radial(
    Offset center,
    double radius,
    List<Color> colors, [
    List<double>? colorStops,
    TileMode tileMode = TileMode.clamp,
    Float64List? matrix4,
    Offset? focal,
    double focalRadius = 0.0,
  ]) =>
      UiBackend.instance.createRadialGradient(
        center,
        radius,
        colors,
        colorStops,
        tileMode,
        matrix4,
        focal,
        focalRadius,
      );

  factory Gradient.sweep(
    Offset center,
    List<Color> colors, [
    List<double>? colorStops,
    TileMode tileMode = TileMode.clamp,
    double startAngle = 0.0,
    double endAngle = 6.283185307179586,
    Float64List? matrix4,
  ]) =>
      UiBackend.instance.createSweepGradient(
        center,
        colors,
        colorStops,
        tileMode,
        startAngle,
        endAngle,
        matrix4,
      );
}

/// A color filter applied at draw time. Construction dispatches to backend.
abstract class ColorFilter {
  factory ColorFilter.mode(Color color, BlendMode blendMode) =>
      UiBackend.instance.createColorFilterMode(color, blendMode);

  factory ColorFilter.matrix(List<double> matrix) =>
      UiBackend.instance.createColorFilterMatrix(matrix);
}

/// Image-space filter. Backends with no support throw `UnsupportedError`.
abstract class ImageFilter {
  factory ImageFilter.blur({
    double sigmaX = 0.0,
    double sigmaY = 0.0,
    TileMode tileMode = TileMode.clamp,
  }) =>
      UiBackend.instance.createBlurFilter(
        sigmaX: sigmaX,
        sigmaY: sigmaY,
        tileMode: tileMode,
      );
}

/// Mask filter applied to stroke or fill operations.
abstract class MaskFilter {
  factory MaskFilter.blur(BlurStyle style, double sigma) =>
      UiBackend.instance.createMaskFilterBlur(style, sigma);
}
