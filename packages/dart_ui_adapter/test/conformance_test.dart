// Runs the shared conformance suite against the dart:ui backend.
//
// Requires the Flutter SDK: run with `flutter test` (not `dart test`). The
// engine binding must be initialised so that Picture.toImage / toByteData work.

import 'package:dart_ui_adapter/dart_ui_adapter.dart';
import 'package:dart_ui_conformance/dart_ui_conformance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  UiBackend.instance = const DartUiBackend();
  runDrawingConformanceTests();
}
