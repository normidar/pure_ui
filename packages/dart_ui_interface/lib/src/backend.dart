// The backend contract and its global/zone-scoped selection mechanism.
//
// See plan §3.1 and §3.2.

import 'dart:async';
import 'dart:typed_data';

import 'enums.dart';
import 'painting.dart';
import 'shaders.dart';
import 'text.dart';
import 'values.dart';

/// The factory contract a drawing backend (`pure_ui` or `dart:ui`) must
/// satisfy. Only *resource-holding* types are dispatched through here; pure
/// value types ([Offset], [Rect], [Color], ...) are never routed through a
/// backend.
abstract interface class UiBackend {
  static UiBackend? _global;

  /// The current backend. A zone override (installed by [runWith]) takes
  /// precedence over the global default.
  static UiBackend get instance {
    final Object? zoned = Zone.current[#dartUiBackend];
    if (zoned is UiBackend) {
      return zoned;
    }
    final UiBackend? g = _global;
    if (g == null) {
      throw StateError(
        'No UiBackend registered. Import package:dart_ui_wrapper/ui.dart '
        '(which wires a default), or set UiBackend.instance = ... explicitly.',
      );
    }
    return g;
  }

  /// Installs [backend] as the global default (typically once at startup).
  static set instance(UiBackend backend) => _global = backend;

  /// Whether a backend is currently resolvable — either as a zone override
  /// (installed by [runWith]) or as the global default. Symmetric with the
  /// resolution order used by [instance].
  static bool get hasInstance =>
      Zone.current[#dartUiBackend] is UiBackend || _global != null;

  /// Runs [body] with [backend] selected for the dynamic extent of the call.
  /// Concurrency-safe and nestable (plan §3.2).
  static T runWith<T>(UiBackend backend, T Function() body) =>
      runZoned(body, zoneValues: <Object?, Object?>{#dartUiBackend: backend});

  /// A short identifier for diagnostics, e.g. `'pure_ui'` or `'dart:ui'`.
  String get name;

  /// Whether the backend implements [feature]. See [BackendFeature].
  bool supports(BackendFeature feature);

  // --- painting ---
  Paint createPaint();
  Path createPath();
  PictureRecorder createPictureRecorder();
  Canvas createCanvas(PictureRecorder recorder, [Rect? cullRect]);

  // --- image / async ---
  Future<Image> decodeImageFromPixels(
    Uint8List pixels,
    int width,
    int height,
    PixelFormat format,
  );

  /// Creates an [Image] directly from already-decoded RGBA pixel data.
  Image createImageFromPixels(Uint8List pixels, int width, int height);

  // --- text ---
  ParagraphBuilder createParagraphBuilder(ParagraphStyle style);

  /// Registers a font for use by the backend's text rasterizer. Returns when
  /// the font is ready (pure_ui completes synchronously; dart:ui awaits the
  /// engine).
  Future<void> loadFont(
    String family,
    Uint8List bytes, {
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
  });

  // --- vertices ---
  Vertices createVertices(
    VertexMode mode,
    List<Offset> positions, {
    List<Offset>? textureCoordinates,
    List<Color>? colors,
    List<int>? indices,
  });

  // --- shaders / filters ---
  Gradient createLinearGradient(
    Offset from,
    Offset to,
    List<Color> colors,
    List<double>? colorStops,
    TileMode tileMode,
    Float64List? matrix4,
  );

  Gradient createRadialGradient(
    Offset center,
    double radius,
    List<Color> colors,
    List<double>? colorStops,
    TileMode tileMode,
    Float64List? matrix4,
    Offset? focal,
    double focalRadius,
  );

  Gradient createSweepGradient(
    Offset center,
    List<Color> colors,
    List<double>? colorStops,
    TileMode tileMode,
    double startAngle,
    double endAngle,
    Float64List? matrix4,
  );

  ColorFilter createColorFilterMode(Color color, BlendMode blendMode);
  ColorFilter createColorFilterMatrix(List<double> matrix);

  ImageFilter createBlurFilter({
    required double sigmaX,
    required double sigmaY,
    required TileMode tileMode,
  });

  MaskFilter createMaskFilterBlur(BlurStyle style, double sigma);
}

/// Capabilities that a backend may or may not implement (plan §5).
enum BackendFeature {
  drawing,
  imageCodec,
  shaders,
  imageFilters,
  text,
  fragmentShaders,
  atlas,
  vertices,
  drawShadow,
}
