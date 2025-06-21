import 'package:meta/meta.dart';
import 'package:pure_ui/src/color.dart';
import 'package:pure_ui/src/offset.dart';
import 'package:pure_ui/src/vertices/vertex_mode.dart';

/// A set of vertex data used for drawing geometric shapes.
///
/// Used with [Canvas.drawVertices].
@immutable
class Vertices {
  /// Creates a set of vertices using the specified vertex mode.
  ///
  /// The positions argument specifies the mesh coordinates. The indices argument,
  /// if non-null, specifies the order in which the positions should be drawn.
  ///
  /// If textureCoordinates is non-null, each vertex is also associated with
  /// a coordinate within a texture. If colors is non-null, each vertex
  /// is also associated with a specific color.
  const Vertices(
    this.mode,
    this.positions, {
    this.textureCoordinates,
    this.colors,
    this.indices,
  }) : assert(
          (textureCoordinates == null ||
                  positions.length == textureCoordinates.length) &&
              (colors == null || positions.length == colors.length),
          'textureCoordinates and colors must have the same length as positions',
        );

  /// Creates a set of vertices for a rectangle using the specified vertex mode.
  ///
  /// The rectangle is centered on (x, y) and has width w and height h.
  factory Vertices.rectangle(
    VertexMode mode,
    double x,
    double y,
    double w,
    double h, {
    List<Color>? colors,
  }) {
    final left = x - w / 2;
    final right = x + w / 2;
    final top = y - h / 2;
    final bottom = y + h / 2;

    final positions = <Offset>[
      Offset(left, top),
      Offset(right, top),
      Offset(right, bottom),
      Offset(left, bottom),
    ];

    final indices = <int>[0, 1, 2, 0, 2, 3];

    final textureCoordinates = <Offset>[
      const Offset(0, 0),
      const Offset(1, 0),
      const Offset(1, 1),
      const Offset(0, 1),
    ];

    return Vertices(
      mode,
      positions,
      textureCoordinates: textureCoordinates,
      colors: colors,
      indices: indices,
    );
  }

  /// The vertex mode used when drawing the vertices.
  final VertexMode mode;

  /// The positions of the vertices.
  final List<Offset> positions;

  /// The indices of the vertices in [positions] to use when drawing.
  ///
  /// When this is null, the first [positions.length] indices are used.
  final List<int>? indices;

  /// The texture coordinates of the vertices.
  ///
  /// When this is null, the positions are used as texture coordinates.
  final List<Offset>? textureCoordinates;

  /// The colors of the vertices.
  ///
  /// When this is null, all vertices use the color of the [Paint] used
  /// to draw them.
  final List<Color>? colors;

  @override
  int get hashCode => Object.hash(
        mode,
        Object.hashAll(positions),
        indices != null ? Object.hashAll(indices!) : null,
        textureCoordinates != null ? Object.hashAll(textureCoordinates!) : null,
        colors != null ? Object.hashAll(colors!) : null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Vertices &&
        other.mode == mode &&
        _listEquals(other.positions, positions) &&
        _listEquals(other.indices, indices) &&
        _listEquals(other.textureCoordinates, textureCoordinates) &&
        _listEquals(other.colors, colors);
  }

  void dispose() {
    // Currently, the underlying image library doesn't require explicit disposal
    // This method is added for API compatibility and future use
  }

  /// Returns a raw handle to the native platform's vertices object.
  ///
  /// This method is used to access the underlying platform-specific implementation.
  /// The returned value should be used only by the rendering engine.
  int raw() {
    // In a real implementation, this would return a platform-specific handle.
    // For this pure implementation, we return a placeholder value.
    return hashCode;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
