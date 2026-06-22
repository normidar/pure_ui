/// Adapts Flutter's engine-provided `dart:ui` to the [UiBackend] contract.
///
/// This is the only package in the switching architecture that depends on
/// Flutter. A Flutter app installs it with:
///
/// ```dart
/// import 'package:dart_ui_interface/dart_ui_interface.dart';
/// import 'package:dart_ui_adapter/dart_ui_adapter.dart';
///
/// void main() {
///   UiBackend.instance = const DartUiBackend();
///   runApp(...);
/// }
/// ```
library dart_ui_adapter;

export 'package:dart_ui_interface/dart_ui_interface.dart';

export 'src/backend.dart'
    show
        DartUiBackend,
        DartUiPaint,
        DartUiPath,
        DartUiCanvas,
        DartUiPicture,
        DartUiPictureRecorder,
        DartUiImage;
