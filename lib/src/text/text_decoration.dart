import 'package:meta/meta.dart';
import 'package:pure_ui/src/color.dart';

/// A linear decoration to draw near the text.
class TextDecoration {
  /// Creates a decoration that is a combination of the given decorations.
  factory TextDecoration.combine(List<TextDecoration> decorations) {
    var mask = 0;
    for (final decoration in decorations) {
      mask |= decoration._mask;
    }
    return TextDecoration._(mask);
  }

  /// Creates a decoration that paints a horizontal line
  const TextDecoration._(this._mask);

  /// Creates a decoration that paints no lines.
  static const TextDecoration none = TextDecoration._(0x0);

  /// Creates a decoration that paints a horizontal line below the text.
  static const TextDecoration underline = TextDecoration._(0x1);

  /// Creates a decoration that paints a horizontal line above the text.
  static const TextDecoration overline = TextDecoration._(0x2);

  /// Creates a decoration that paints a horizontal line through the middle of the text.
  static const TextDecoration lineThrough = TextDecoration._(0x4);

  /// The bitmask for this decoration.
  final int _mask;

  @override
  int get hashCode => _mask.hashCode;

  /// Whether this decoration will paint a line through the text.
  bool get isLineThrough => (_mask & lineThrough._mask) != 0;

  /// Whether this decoration will paint at least one line.
  bool get isNone => _mask == 0;

  /// Whether this decoration will paint a line above the text.
  bool get isOverline => (_mask & overline._mask) != 0;

  /// Whether this decoration will paint a line below the text.
  bool get isUnderline => (_mask & underline._mask) != 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TextDecoration && other._mask == _mask;
  }

  @override
  String toString() {
    if (isNone) {
      return 'TextDecoration.none';
    }
    final values = <String>[];
    if (isUnderline) {
      values.add('underline');
    }
    if (isOverline) {
      values.add('overline');
    }
    if (isLineThrough) {
      values.add('lineThrough');
    }
    if (values.length == 1) {
      return 'TextDecoration.${values[0]}';
    }
    return 'TextDecoration.combine([${values.join(", ")}])';
  }
}

/// The style in which to draw a text decoration.
enum TextDecorationStyle {
  /// Draw a solid line.
  solid,

  /// Draw two lines.
  double,

  /// Draw a dotted line.
  dotted,

  /// Draw a dashed line.
  dashed,

  /// Draw a wavy line.
  wavy,
}

/// The style information for text decorations.
@immutable
class TextDecorationThemeData {
  /// Creates the text decoration styling information.
  const TextDecorationThemeData({this.color, this.style, this.thickness});

  /// The color of the text decoration.
  final Color? color;

  /// The style of the text decoration.
  final TextDecorationStyle? style;

  /// The thickness of the decoration, in logical pixels.
  final double? thickness;

  @override
  int get hashCode => Object.hash(color, style, thickness);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TextDecorationThemeData &&
        other.color == color &&
        other.style == style &&
        other.thickness == thickness;
  }
}
