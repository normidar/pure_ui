import 'package:pure_ui/src/color.dart';
import 'package:pure_ui/src/enums.dart';
import 'package:pure_ui/src/painting/color_filter.dart';
import 'package:pure_ui/src/painting/shader.dart';

/// A description of the style to use when drawing on a Canvas.
class Paint {
  /// Creates a paint object with default properties.
  Paint()
      : color = Color.black,
        strokeWidth = 0.0,
        strokeCap = StrokeCap.butt,
        strokeJoin = StrokeJoin.miter,
        strokeMiterLimit = 4.0,
        style = PaintingStyle.fill,
        blendMode = BlendMode.srcOver,
        isAntiAlias = true,
        colorFilter = null,
        shader = null;

  /// The color to use when drawing with this paint.
  Color color;

  /// The width of the stroke, in logical pixels.
  double strokeWidth;

  /// The kind of finish to place on the end of lines drawn when
  /// [style] is set to [PaintingStyle.stroke].
  StrokeCap strokeCap;

  /// The kind of finish to place on the joins between segments.
  StrokeJoin strokeJoin;

  /// The limit for the ratio of the miter length to the stroke width.
  ///
  /// The miter length is the distance from the outside corner of the stroked
  /// path to the inside corner. The miter limit is the maximum ratio of the
  /// miter length to the stroke width. When the limit is exceeded, the join is
  /// converted to a bevel.
  ///
  /// The default value is 4.0.
  double strokeMiterLimit;

  /// Whether to apply anti-aliasing to lines and images drawn on the canvas.
  bool isAntiAlias;

  /// Whether to fill or stroke shapes drawn on the canvas.
  PaintingStyle style;

  /// The blend mode to use when drawing.
  BlendMode blendMode;

  /// A color filter to apply when drawing.
  ColorFilter? colorFilter;

  /// A shader to use when drawing.
  Shader? shader;

  @override
  String toString() {
    return 'Paint('
        'color: $color, '
        'strokeWidth: $strokeWidth, '
        'strokeCap: $strokeCap, '
        'strokeJoin: $strokeJoin, '
        'strokeMiterLimit: $strokeMiterLimit, '
        'style: $style, '
        'blendMode: $blendMode, '
        'isAntiAlias: $isAntiAlias, '
        'colorFilter: $colorFilter, '
        'shader: $shader)';
  }
}

/// Whether to paint inside shapes, or the outline of shapes, when drawing.
enum PaintingStyle {
  /// Paint the inside of the shape.
  fill,

  /// Paint the outline of the shape.
  stroke,
}
