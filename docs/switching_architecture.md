# Switchable `dart:ui` / `pure_ui` architecture

Implementation of `pure_ui_switching_architecture_plan.md`. The goal: write
drawing code once and run it on either the Flutter engine (`dart:ui`) or the
pure-Dart `pure_ui`, switching backend **without changing imports** — just by
swapping one backend instance.

## Package layout

```
packages/
  dart_ui_interface/    # contract: value types, enums, UiBackend, abstract types   (no Flutter)
  pure_ui_adapter/      # PureUiBackend — adapts pure_ui                              (no Flutter)
  dart_ui_wrapper/      # ui.dart drop-in surface + switch API; default = pure_ui     (no Flutter)
  dart_ui_adapter/      # DartUiBackend — adapts dart:ui                              (Flutter only)
  dart_ui_conformance/  # backend-agnostic parity tests                              (dev)
  pure_ui/              # existing pure-Dart engine (unchanged; still a drop-in)
```

Dependency direction (no cycles):

```
app (Flutter) ─▶ dart_ui_wrapper ─▶ dart_ui_interface ◀─ pure_ui_adapter ─▶ pure_ui
app (Flutter) ─▶ dart_ui_adapter ─▶ dart_ui_interface
                 dart_ui_adapter ─▶ dart:ui (Flutter)
app (CLI)     ─▶ dart_ui_wrapper (default pure_ui backend)
```

Flutter is isolated to `dart_ui_adapter` only (plan §1.2). `dart_ui_adapter`
is intentionally **excluded from the Dart workspace** (see root `pubspec.yaml`
`workspace:` list and melos `ignore:`) so that `dart pub get` / Dart-only CI
never need the Flutter SDK.

## Three coexisting usage modes (§6.0)

| Mode | import | backend setup |
|---|---|---|
| Flutter native | `import 'dart:ui'` | — |
| pure_ui standalone drop-in | `import 'package:pure_ui/pure_ui.dart'` | none |
| switchable | `import 'package:dart_ui_wrapper/ui.dart' as ui` | choose a backend once |

`pure_ui` itself is untouched, so mode 2 keeps working exactly as before.

## Usage

### Non-Flutter (CLI / server / tests)
```dart
import 'package:dart_ui_wrapper/dart_ui_wrapper.dart';
import 'package:dart_ui_wrapper/ui.dart' as ui;

void main() {
  installPureUiBackend(); // default backend; call once
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));
  canvas.drawCircle(const ui.Offset(50, 50), 40, ui.Paint()..color = const ui.Color(0xFF2196F3));
  // ...
}
```

### Flutter (switch to the engine backend)
```dart
import 'package:dart_ui_interface/dart_ui_interface.dart';
import 'package:dart_ui_adapter/dart_ui_adapter.dart';

void main() {
  UiBackend.instance = const DartUiBackend(); // route to dart:ui
  runApp(const MyApp());
}
```

### Scoped switch (e.g. isolate a golden render to pure_ui)
```dart
UiBackend.runWith(const PureUiBackend(), () {
  // Paint(), Canvas(...), ... all resolve to pure_ui here, even on Flutter.
});
```

## Design rules honoured

- **Value types are concrete & `const`** in the interface layer; never routed
  through factory dispatch (§1.3). Only resource-holding types dispatch.
- **One type layer**: abstract type + factory + contract all live in
  `dart_ui_interface`; backends only `implements` them (§1.4).
- **Enums map explicitly** with exhaustive switches, never by `index` (§4.2).
- **Unsupported features throw** `UnsupportedError` rather than silent no-op
  (§5); `UiBackend.supports(BackendFeature)` reports capability.
- **Not pixel-exact** across backends; conformance asserts API behaviour and
  stable values (e.g. ARGB32), not bit-identical floats (§1.5).

## Testing

```bash
# fast, Flutter-free path
dart test packages/dart_ui_interface
dart test packages/pure_ui_adapter
dart test packages/dart_ui_conformance     # parity suite on PureUiBackend

# dart:ui path (requires Flutter)
cd packages/dart_ui_adapter && flutter test  # run the same parity suite on DartUiBackend
```

## Status

Implemented and green (Flutter-free): the drawing vertical slice
(`Paint`/`Path`/`Canvas`/`PictureRecorder`/`Picture`/`Image`) end-to-end,
the backend switch mechanism (global + zone), and the pure_ui drop-in
regression guard. `DartUiBackend` is implemented but unverified in this
environment (no Flutter SDK). See `docs/api_inventory.md` for the full
coverage matrix and the horizontal-expansion backlog (text, codecs, shaders).
