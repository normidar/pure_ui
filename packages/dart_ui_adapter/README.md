# dart_ui_adapter

Adapts Flutter's engine-provided `dart:ui` to the
[`dart_ui_interface`](../dart_ui_interface) `UiBackend` contract, providing
`DartUiBackend`.

This is the **only** package in the switching architecture that depends on
Flutter (plan §1.2). For that reason it is **excluded from the Dart pub
workspace** (see the root `pubspec.yaml` `workspace:` list and the melos
`ignore:` entry) so that the rest of the monorepo resolves and tests without a
Flutter SDK.

## Install in a Flutter app

```dart
import 'package:dart_ui_interface/dart_ui_interface.dart';
import 'package:dart_ui_adapter/dart_ui_adapter.dart';

void main() {
  UiBackend.instance = const DartUiBackend();
  runApp(const MyApp());
}
```

## Run the conformance suite on this backend

```bash
cd packages/dart_ui_adapter
flutter pub get
flutter test
```

`test/conformance_test.dart` wires `DartUiBackend` and runs the same
backend-agnostic suite from `dart_ui_conformance` that the pure_ui backend
passes.

## Notes / limitations

- `createImageFromPixels` (synchronous) is unsupported on `dart:ui`, which only
  exposes asynchronous `decodeImageFromPixels`; it throws `UnsupportedError`
  per plan §5.
- Cannot be analyzed or tested without the Flutter SDK present.
