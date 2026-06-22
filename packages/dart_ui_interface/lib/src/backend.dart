// The backend contract and its global/zone-scoped selection mechanism.
//
// See plan §3.1 and §3.2.

import 'dart:async';
import 'dart:typed_data';

import 'enums.dart';
import 'painting.dart';
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

  /// Whether a global backend has been registered.
  static bool get hasInstance => _global != null;

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
}

/// Capabilities that a backend may or may not implement (plan §5).
enum BackendFeature {
  drawing,
  imageCodec,
  shaders,
  imageFilters,
  text,
  fragmentShaders,
}
