# CLAUDE.md - Pure UI Developer Guide

**Pure UI** is a pure Dart implementation of Flutter's `dart:ui` Canvas API for non-Flutter environments.

## Quick Setup

```bash
dart pub get
make build
make ci        # Verify everything
```

## Essential Structure

```
lib/
├── pure_ui.dart              # Main library entry
├── painting.dart             # Canvas, Paint, Path, Color (~10,000 lines)
├── pure_dart_implementations.dart  # Core implementations
└── [19 other part files]

test/                          # 8 test files covering major features
Makefile                       # Build automation
```

## Key Commands

```bash
make analyze      # Lint code
make format       # Format code
make ci           # analyze + format (run before commit)
dart test         # Run tests
make build        # Build library
make pub_publish  # Publish to pub.dev
```

## Code Style

- **Classes:** `PascalCase` → `Canvas`, `_PureDartCanvas`
- **Methods/Variables:** `camelCase` → `drawCircle()`, `strokeWidth`
- **Documentation:** `///` for public APIs
- **Formatting:** Auto via `dart format` (2-space indent)

## Development Workflow

1. **Adding Features:** Update API in `painting.dart` → Implementation in `pure_dart_implementations.dart` → Add tests
2. **Bug Fixes:** Create test that reproduces bug → Fix code → Verify tests pass
3. **Commits:** Run `make ci` first, then commit with descriptive message

## Core Classes

| Class | Location | Purpose |
|-------|----------|---------|
| `Canvas` | painting.dart | Main drawing API |
| `Paint` | painting.dart | Drawing style (color, width, etc.) |
| `Path` | painting.dart | Vector path with curves |
| `PictureRecorder` | painting.dart | Record drawing commands |
| `_PureDartCanvas` | pure_dart_implementations.dart | Pure Dart implementation |

## Testing

```dart
import 'package:test/test.dart';
import 'package:pure_ui/pure_ui.dart';

void main() {
  group('Canvas', () {
    test('drawCircle', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 200, 200));
      canvas.drawCircle(const ui.Offset(100, 100), 50, ui.Paint());

      final image = await recorder.endRecording().toImage(200, 200);
      expect(image.width, 200);
      image.dispose();
    });
  });
}
```

## Key Files by Task

| Task | File |
|------|------|
| Add drawing method | `lib/painting.dart` |
| Implement logic | `lib/pure_dart_implementations.dart` |
| Add type/struct | `lib/geometry.dart` |
| Add test | `test/*.dart` |
| CI/CD config | `.github/workflows/check.yml` |

## Dependencies

| Package | Use |
|---------|-----|
| `vector_math` | Matrix4 transforms |
| `image` | PNG export |
| `collection` | Collection utils |
| `ffi` | Future native code |
| `meta` | Annotations |

## Version Info

- **Dart SDK:** 3.3.0+
- **Flutter:** 3.35.2 (via FVM)
- **Pure UI:** 0.1.4

## Before Committing

```bash
make ci           # Must pass
dart test         # Must pass
git status        # Review changes
```

---

For detailed API docs, see `README.md`. For troubleshooting, check GitHub issues.
