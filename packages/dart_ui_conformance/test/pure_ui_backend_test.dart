// Runs the shared conformance suite against the pure_ui backend. This requires
// no Flutter and is the fast CI path (plan §7.4).

import 'dart:io';

import 'package:dart_ui_conformance/dart_ui_conformance.dart';
import 'package:pure_ui_adapter/pure_ui_adapter.dart';
import 'package:test/test.dart';

void main() {
  // Install the backend just for this test's run and restore whatever state
  // existed before, so concurrent or chained test files aren't affected.
  UiBackend? previous;
  setUpAll(() {
    previous = UiBackend.hasInstance ? UiBackend.instance : null;
    UiBackend.instance = const PureUiBackend();
  });
  tearDownAll(() {
    if (previous != null) {
      UiBackend.instance = previous!;
    }
  });

  runDrawingConformanceTests();
  runShaderConformanceTests();
  runTextConformanceTests(
    fontBytes: File('test/fixtures/Roboto-Regular.ttf').readAsBytesSync(),
    family: 'TestRoboto',
  );
}
