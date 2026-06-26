/// Drop-in `dart:ui` replacement surface.
///
/// Import this with the same prefix you used for `dart:ui`:
///
/// ```dart
/// // before
/// import 'dart:ui' as ui;
/// // after
/// import 'package:dart_ui_wrapper/ui.dart' as ui;
///
/// void main() {
///   ui.installPureUiBackend(); // one-line bootstrap in non-Flutter apps
///   // ...
/// }
/// ```
///
/// All construction (`ui.Paint()`, `ui.Canvas(recorder)`, ...) dispatches to the
/// currently-selected [UiBackend]. Select one once at startup via
/// `ui.installPureUiBackend()` (Flutter-free), `ui.installBackend(...)`, or
/// `ui.UiBackend.instance = const DartUiBackend()` from `dart_ui_adapter`.
library ui;

export 'package:dart_ui_interface/dart_ui_interface.dart';
export 'dart_ui_wrapper.dart'
    show installBackend, installPureUiBackend, runWithPureUi;
