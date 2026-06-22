// Runs the shared conformance suite against the pure_ui backend. This requires
// no Flutter and is the fast CI path (plan §7.4).

import 'package:dart_ui_conformance/dart_ui_conformance.dart';
import 'package:pure_ui_adapter/pure_ui_adapter.dart';

void main() {
  UiBackend.instance = const PureUiBackend();
  runDrawingConformanceTests();
}
