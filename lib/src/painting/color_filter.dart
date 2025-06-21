// ignore_for_file: missing_code_block_language_in_doc_comment, lines_longer_than_80_chars

import 'package:meta/meta.dart';
import 'package:pure_ui/pure_ui.dart' show Paint;
import 'package:pure_ui/src/color.dart';
import 'package:pure_ui/src/enums.dart';
import 'package:pure_ui/src/paint.dart' show Paint;

/// A color filter to apply to a color or an image.
///
/// This is used with [Paint.colorFilter] to specify a color filter
/// for drawing images or shapes.
@immutable
abstract class ColorFilter {
  /// Creates a color filter that is a composition of two color filters.
  ///
  /// The `inner` filter is applied to the source, and then the `outer` filter is
  /// applied to the result of the inner filter.
  const factory ColorFilter.compose(ColorFilter outer, ColorFilter inner) =
      _ComposeColorFilter;

  /// Creates a color filter that applies a linear color transformation.
  ///
  /// This filter transformations are applied in the following way:
  /// ```js
  /// R' = effectR * R + effectG * G + effectB * B + effectA * A + offsetR
  /// G' = effectR * R + effectG * G + effectB * B + effectA * A + offsetG
  /// B' = effectR * R + effectG * G + effectB * B + effectA * A + offsetB
  /// A' = effectR * R + effectG * G + effectB * B + effectA * A + offsetA
  /// ```
  const factory ColorFilter.linearToSrgbGamma() = _LinearToSrgbGammaColorFilter;

  /// Creates a color filter that transforms colors based on the provided matrix.
  ///
  /// The matrix is applied in a 4x5 format, where the last column represents
  /// a constant addition to each color channel.
  const factory ColorFilter.matrix(List<double> matrix) = _MatrixColorFilter;

  /// Creates a color filter that multiplies the source color by the specified color.
  ///
  /// This can be used to tint an image with a specific color.
  const factory ColorFilter.mode(Color color, BlendMode blendMode) =
      _ModeColorFilter;

  /// Creates a color filter that applies the sRGB gamma curve to a linear color.
  ///
  /// This is the inverse operation of [ColorFilter.linearToSrgbGamma].
  const factory ColorFilter.srgbToLinearGamma() = _SrgbToLinearGammaColorFilter;
}

/// A color filter that is a composition of two color filters.
@immutable
class _ComposeColorFilter implements ColorFilter {
  /// Creates a color filter that is a composition of two color filters.
  const _ComposeColorFilter(this.outer, this.inner);

  /// The outer color filter, which is applied after the inner filter.
  final ColorFilter outer;

  /// The inner color filter, which is applied first.
  final ColorFilter inner;

  @override
  int get hashCode => Object.hash(outer, inner);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _ComposeColorFilter &&
        other.outer == outer &&
        other.inner == inner;
  }

  @override
  String toString() => 'ColorFilter.compose($outer, $inner)';
}

/// A color filter that applies the linear to sRGB gamma curve.
@immutable
class _LinearToSrgbGammaColorFilter implements ColorFilter {
  /// Creates a color filter that applies the linear to sRGB gamma curve.
  const _LinearToSrgbGammaColorFilter();

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _LinearToSrgbGammaColorFilter;
  }

  @override
  String toString() => 'ColorFilter.linearToSrgbGamma()';
}

/// A color filter that transforms colors based on a matrix.
@immutable
class _MatrixColorFilter implements ColorFilter {
  /// Creates a color filter that transforms colors based on a matrix.
  const _MatrixColorFilter(this.matrix)
      : assert(
          matrix.length == 20,
          'Color matrix must have 20 entries for a 4x5 matrix',
        );

  /// The matrix used to transform colors.
  ///
  /// The 20 values are stored in column-major order, as a 4x5 matrix.
  /// The transformation is applied as follows:
  /// ```
  /// R' = matrix[0] * R + matrix[4] * G + matrix[8] * B + matrix[12] * A + matrix[16]
  /// G' = matrix[1] * R + matrix[5] * G + matrix[9] * B + matrix[13] * A + matrix[17]
  /// B' = matrix[2] * R + matrix[6] * G + matrix[10] * B + matrix[14] * A + matrix[18]
  /// A' = matrix[3] * R + matrix[7] * G + matrix[11] * B + matrix[15] * A + matrix[19]
  /// ```
  final List<double> matrix;

  @override
  int get hashCode => Object.hashAll(matrix);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _MatrixColorFilter && _listEquals(other.matrix, matrix);
  }

  @override
  String toString() => 'ColorFilter.matrix($matrix)';

  bool _listEquals(List<double> a, List<double> b) {
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

/// A color filter that applies a color and a blend mode.
@immutable
class _ModeColorFilter implements ColorFilter {
  /// Creates a color filter that applies a color and a blend mode.
  const _ModeColorFilter(this.color, this.blendMode);

  /// The color to apply to the source.
  final Color color;

  /// The blend mode used to apply the color to the source.
  final BlendMode blendMode;

  @override
  int get hashCode => Object.hash(color, blendMode);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _ModeColorFilter &&
        other.color == color &&
        other.blendMode == blendMode;
  }

  @override
  String toString() => 'ColorFilter.mode($color, $blendMode)';
}

/// A color filter that applies the sRGB to linear gamma curve.
@immutable
class _SrgbToLinearGammaColorFilter implements ColorFilter {
  /// Creates a color filter that applies the sRGB to linear gamma curve.
  const _SrgbToLinearGammaColorFilter();

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _SrgbToLinearGammaColorFilter;
  }

  @override
  String toString() => 'ColorFilter.srgbToLinearGamma()';
}
