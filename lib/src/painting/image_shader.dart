import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:pure_ui/src/enums.dart';
import 'package:pure_ui/src/image.dart';
import 'package:pure_ui/src/painting/shader.dart';
import 'package:pure_ui/src/painting/tile_mode.dart';

/// A list of double-precision floating point numbers.
///
/// This class is a simplified version of the Flutter Float64List.
// class Float64List {
//   /// Creates a [Float64List] of the specified length.
//   ///
//   /// All elements are initially 0.0.
//   Float64List(int length) : _list = List<double>.filled(length, 0);

//   /// Creates a [Float64List] with the values from a list.
//   Float64List.fromList(List<double> list) : _list = List<double>.from(list);

//   final List<double> _list;

//   /// The number of elements in this list.
//   int get length => _list.length;

//   /// The element at the given [index] in the list.
//   double operator [](int index) => _list[index];

//   /// Sets the value at the given [index] in the list to [value].
//   void operator []=(int index, double value) {
//     _list[index] = value;
//   }

//   /// Returns a new list containing the elements between [start] and [end].
//   Float64List sublist(int start, [int? end]) {
//     return Float64List.fromList(_list.sublist(start, end));
//   }
// }

/// A shader (approximately, a color filter) that applies an [Image] to its input.
@immutable
class ImageShader extends Shader {
  /// Creates an image-based shader.
  ///
  /// The [image] argument must not be null.
  const ImageShader(
    this.image,
    this.tileModeX,
    this.tileModeY,
    this.matrix4, {
    this.filterQuality = FilterQuality.low,
  });

  /// The image that will be used to sample colors.
  final Image image;

  /// How to tile the image in the x direction.
  final TileMode tileModeX;

  /// How to tile the image in the y direction.
  final TileMode tileModeY;

  /// A 4x4 matrix that transforms the coordinate space of the image.
  ///
  /// This is used to achieve effects such as rotating or skewing the image.
  final Float64List matrix4;

  /// The quality of image filtering to apply.
  final FilterQuality filterQuality;

  @override
  int get hashCode => Object.hash(
        image,
        tileModeX,
        tileModeY,
        _matrixHashCode(matrix4),
        filterQuality,
      );

  @override
  void dispose() {
    image.dispose();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ImageShader &&
        other.image == image &&
        other.tileModeX == tileModeX &&
        other.tileModeY == tileModeY &&
        _listEquals(other.matrix4, matrix4) &&
        other.filterQuality == filterQuality;
  }

  bool _listEquals(Float64List a, Float64List b) {
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

  int _matrixHashCode(Float64List matrix) {
    // Simple hash code implementation for Float64List
    var result = 1;
    for (var i = 0; i < matrix.length; i++) {
      result = 31 * result + matrix[i].hashCode;
    }
    return result;
  }
}
