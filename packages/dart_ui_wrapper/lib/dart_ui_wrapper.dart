/// Backend lifecycle / switching API for the `dart:ui` ↔ `pure_ui` wrapper.
///
/// This library is Flutter-free: its only default backend is [PureUiBackend].
/// Flutter apps that want the `dart:ui` backend depend on `dart_ui_adapter`
/// separately and call `UiBackend.instance = DartUiBackend()` — keeping the
/// Flutter dependency out of this package (plan §1.2).
library dart_ui_wrapper;

import 'package:pure_ui_adapter/pure_ui_adapter.dart';

export 'package:dart_ui_interface/dart_ui_interface.dart';
export 'package:pure_ui_adapter/pure_ui_adapter.dart' show PureUiBackend;

/// Installs the pure-Dart [PureUiBackend] as the global default backend.
///
/// Idempotent: a no-op if a backend is already registered, unless [force] is
/// set. Call once near application startup in non-Flutter environments.
void installPureUiBackend({bool force = false}) {
  if (force || !UiBackend.hasInstance) {
    UiBackend.instance = const PureUiBackend();
  }
}

/// Installs an explicit [backend] as the global default.
void installBackend(UiBackend backend) {
  UiBackend.instance = backend;
}

/// Runs [body] with the pure-Dart backend selected for its dynamic extent.
T runWithPureUi<T>(T Function() body) =>
    UiBackend.runWith(const PureUiBackend(), body);
