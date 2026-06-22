/// Drop-in `dart:ui` replacement surface.
///
/// Import this with the same prefix you used for `dart:ui`:
///
/// ```dart
/// // before
/// import 'dart:ui' as ui;
/// // after
/// import 'package:dart_ui_wrapper/ui.dart' as ui;
/// ```
///
/// All construction (`ui.Paint()`, `ui.Canvas(recorder)`, ...) dispatches to the
/// currently-selected [UiBackend]. Select one once at startup via
/// `installPureUiBackend()` (the Flutter-free default) or
/// `UiBackend.instance = ...`. See `dart_ui_wrapper.dart`.
library ui;

export 'package:dart_ui_interface/dart_ui_interface.dart';
