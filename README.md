# Pure UI - Pure Dart Alternative to Flutter's dart:ui

[![GitHub](https://img.shields.io/github/license/normidar/pure_ui.svg)](https://github.com/normidar/pure_ui/blob/main/LICENSE)
[![pub package](https://img.shields.io/pub/v/pure_ui.svg)](https://pub.dartlang.org/packages/pure_ui)
[![GitHub Stars](https://img.shields.io/github/stars/normidar/pure_ui.svg)](https://github.com/normidar/pure_ui/stargazers)
[![Twitter](https://img.shields.io/twitter/url/https/twitter.com/normidar2.svg?style=social&label=Follow%20%40normidar2)](https://twitter.com/normidar2)
[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/normidar)

Pure UI is a Canvas API implemented in pure Dart without Flutter dependencies. It provides a fully compatible API with Flutter's dart:ui, enabling image processing, drawing operations, and **text rendering** anywhere Dart runs.

**🎯 Why Choose Pure UI?**

- Use dart:ui APIs outside Flutter projects
- Migrate existing Flutter code seamlessly
- Perfect for server-side and CLI image generation
- Render text from TTF fonts with no Flutter engine required

## Key Features

- **🚀 Flutter Independent**: Implemented in pure Dart, usable outside Flutter projects
- **🔄 dart:ui Full Compatibility**: Use Flutter Canvas code as-is with complete API compatibility
- **🖼️ PNG Output**: Export drawings in PNG format
- **📐 Vector Graphics**: Path-based drawing support
- **✍️ Text Rendering**: Full `ParagraphBuilder` / `Canvas.drawParagraph()` pipeline powered by TTF font parsing
- **⚡ Server-Side Ready**: Image generation for web servers and batch processing

## Switchable backend architecture (`dart:ui` ↔ `pure_ui`)

This repository is a melos monorepo. Alongside `pure_ui`, it ships a
backend-switching layer that lets the **same drawing code** run on either the
Flutter engine (`dart:ui`) or `pure_ui`, selected by swapping one backend
instance — no import changes required.

| Package | Flutter | Role |
|---|:---:|---|
| `dart_ui_interface` | ✗ | value types, enums, `UiBackend`, abstract resource types |
| `pure_ui_adapter` | ✗ | `PureUiBackend` (default, non-Flutter) |
| `dart_ui_wrapper` | ✗ | `ui.dart` drop-in surface + switch API |
| `dart_ui_adapter` | ✔ | `DartUiBackend` (Flutter engine) |
| `dart_ui_conformance` | dev | backend-agnostic parity tests |

```dart
import 'package:dart_ui_wrapper/dart_ui_wrapper.dart';
import 'package:dart_ui_wrapper/ui.dart' as ui;

void main() {
  installPureUiBackend(); // or: UiBackend.instance = const DartUiBackend();
  final r = ui.PictureRecorder();
  ui.Canvas(r, const ui.Rect.fromLTWH(0, 0, 100, 100))
      .drawCircle(const ui.Offset(50, 50), 40, ui.Paint()..color = const ui.Color(0xFF2196F3));
}
```

See [`docs/switching_architecture.md`](docs/switching_architecture.md) and
[`docs/api_inventory.md`](docs/api_inventory.md) for the full design and
coverage status. `pure_ui` itself remains an unchanged standalone drop-in.

### Use cases

The point of swapping one backend instead of one import is that the **same
drawing code runs in two worlds** — the Flutter engine on device, and plain
Dart everywhere else. That unlocks:

- **Server-side / serverless image generation.** Render OG share images,
  certificates, tickets, invoices/receipts, charts, QR-with-branding, or PDF
  page bitmaps from a Dart backend or cloud function — no Flutter engine, no
  headless browser. Use `dart:ui` in the app and `pure_ui` on the server with
  one codebase.
- **Write-once rendering libraries.** Ship a charting / diagram / signature-pad
  / barcode package that draws identically for Flutter consumers (`dart:ui`)
  and pure-Dart consumers (CLI, server) without forking the rendering code.
- **Fast, engine-free golden tests.** Run your painting logic under plain
  `dart test` by selecting `PureUiBackend` (optionally scoped with
  `UiBackend.runWith`), instead of the slower `flutter test` + engine. Great
  for CI and deterministic, reproducible snapshots.
- **Batch / offline rendering pipelines.** Pre-generate thumbnails, sprite
  atlases, map tiles, or report pages in a build step or worker isolate, then
  ship the PNGs.
- **Gradual migration & dual-target code.** Move existing Flutter `Canvas`
  code behind `dart_ui_wrapper` once; afterwards you switch engines by changing
  a single line at startup, not your imports.

| You want to… | Backend | How |
|---|---|---|
| Draw on screen in a Flutter app | `dart:ui` | `UiBackend.instance = const DartUiBackend();` |
| Generate images on a server / CLI | `pure_ui` | `installPureUiBackend();` |
| Golden-test painting without Flutter | `pure_ui` | `UiBackend.runWith(const PureUiBackend(), () { … });` |

## Migrating from dart:ui

Migrating Flutter Canvas code to Pure UI requires minimal changes:

```dart
// Before: Using dart:ui in Flutter projects
import 'dart:ui' as ui;

void drawInFlutter() {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  // ... drawing code ...
  final picture = recorder.endRecording();
  final image = picture.toImage(200, 200); // Sync in Flutter
}

// After: Using Pure UI (almost identical!)
import 'package:pure_ui/pure_ui.dart' as ui;

void drawWithPureUI() async { // Add async
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 200, 200)); // Add bounds
  // ... same drawing code ...
  final picture = recorder.endRecording();
  final image = await picture.toImage(200, 200); // Add await
}
```

## Quick Start

```dart
import 'dart:io';
import 'package:pure_ui/pure_ui.dart';

void main() async {
  // Create recorder and canvas
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 200, 200));

  // Draw a red circle
  final paint = Paint()
    ..color = const Color(0xFFFF0000)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(const Offset(100, 100), 50, paint);

  // Save as PNG
  final picture = recorder.endRecording();
  final image = await picture.toImage(200, 200);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  await File('circle.png').writeAsBytes(bytes!.buffer.asUint8List());

  // Clean up
  image.dispose();
  picture.dispose();
}
```

## Text Rendering

Pure UI includes a full TTF text rendering pipeline compatible with Flutter's `ParagraphBuilder` API.

### Setup

Register your TTF font file with `FontLoader` before building paragraphs:

```dart
import 'dart:io';
import 'package:pure_ui/pure_ui.dart';

void main() async {
  // Register a TTF font (supports weight / style variants)
  FontLoader.load('MyFont', File('path/to/MyFont-Regular.ttf').readAsBytesSync());
  FontLoader.load('MyFont', File('path/to/MyFont-Bold.ttf').readAsBytesSync(),
      weight: FontWeight.bold);
```

### Basic Text Rendering

```dart
  // Build a paragraph
  final para = (ParagraphBuilder(ParagraphStyle(
    fontFamily: 'MyFont',
    fontSize: 32,
  ))
        ..pushStyle(TextStyle(
          fontFamily: 'MyFont',
          fontSize: 32,
          color: const Color(0xFF222222),
        ))
        ..addText('Hello, World!')
        ..pop())
      .build()
    ..layout(const ParagraphConstraints(width: 600));

  // Draw it on a canvas
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 700, 100));
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 700, 100),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  canvas.drawParagraph(para, const Offset(20, 10));

  // Export
  final image = await recorder.endRecording().toImage(700, 100);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  await File('hello.png').writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
}
```

### Multi-Style Spans

```dart
final para = (ParagraphBuilder(ParagraphStyle(fontFamily: 'MyFont', fontSize: 24))
      ..pushStyle(TextStyle(fontFamily: 'MyFont', fontSize: 24,
          color: const Color(0xFF000000)))
      ..addText('Normal ')
      ..pushStyle(TextStyle(color: const Color(0xFFCC0000))) // inherits font/size
      ..addText('Red ')
      ..pop()
      ..pushStyle(TextStyle(fontWeight: FontWeight.bold))
      ..addText('Bold')
      ..pop()
      ..pop())
    .build()
  ..layout(const ParagraphConstraints(width: 500));
```

### Text Features

| Feature | API |
|---------|-----|
| Font size | `TextStyle(fontSize: 24)` |
| Color | `TextStyle(color: Color(0xFFRRGGBB))` |
| Bold / italic | `TextStyle(fontWeight: FontWeight.bold)` |
| Underline | `TextStyle(decoration: TextDecoration.underline)` |
| Strikethrough | `TextStyle(decoration: TextDecoration.lineThrough)` |
| Letter spacing | `TextStyle(letterSpacing: 2.0)` |
| Word spacing | `TextStyle(wordSpacing: 4.0)` |
| Shadow | `TextStyle(shadows: [Shadow(color: ..., offset: Offset(2, 2))])` |
| Text align | `ParagraphStyle(textAlign: TextAlign.center)` |
| Max lines | `ParagraphStyle(maxLines: 2)` |
| Ellipsis | `ParagraphStyle(maxLines: 1, ellipsis: '...')` |
| Line wrapping | Automatic greedy word-wrap |
| Hard line break | `\n` in text |

### Unicode and Japanese Text

Any language supported by your TTF font works out of the box:

```dart
FontLoader.load('ArialUnicode', File('/Library/Fonts/Arial Unicode.ttf').readAsBytesSync());

final para = (ParagraphBuilder(ParagraphStyle(fontFamily: 'ArialUnicode', fontSize: 64))
      ..pushStyle(TextStyle(fontFamily: 'ArialUnicode', fontSize: 64,
          color: const Color(0xFF222222)))
      ..addText('君、いいね')
      ..pop())
    .build()
  ..layout(const ParagraphConstraints(width: 600));
```

## Usage Examples

### Basic Drawing

```dart
import 'dart:io';
import 'package:pure_ui/pure_ui.dart';

void main() async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 300));

  // Background
  canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 300),
      Paint()..color = const Color.fromARGB(255, 240, 240, 255));

  // Circle
  canvas.drawCircle(const Offset(200, 150), 80,
      Paint()..color = const Color.fromARGB(255, 255, 0, 0));

  // Stroked rectangle
  canvas.drawRect(const Rect.fromLTRB(50, 50, 350, 250),
      Paint()
        ..color = const Color.fromARGB(255, 0, 0, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4);

  // Path
  final path = Path()
    ..moveTo(50, 150)
    ..lineTo(150, 250)
    ..lineTo(250, 50)
    ..lineTo(350, 150);
  canvas.drawPath(path,
      Paint()
        ..color = const Color.fromARGB(255, 0, 180, 0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);

  final image = await recorder.endRecording().toImage(400, 300);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  await File('output.png').writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
}
```

### Complex Drawing with Transformations

```dart
import 'dart:io';
import 'dart:math' as math;
import 'package:pure_ui/pure_ui.dart';

void main() async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 300, 300));

  canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 300),
      Paint()..color = const Color(0xFF1a1a2e));

  canvas.save();
  canvas.translate(150, 150);

  for (int i = 0; i < 36; i++) {
    canvas.save();
    canvas.rotate(i * math.pi / 18);

    final path = Path()
      ..moveTo(0, -50)
      ..quadraticBezierTo(20, -30, 0, -10)
      ..quadraticBezierTo(-20, -30, 0, -50)
      ..close();

    canvas.drawPath(path,
        Paint()
          ..color = Color.fromARGB(200,
              (255 * math.sin(i * math.pi / 18)).abs().round(),
              (255 * math.cos(i * math.pi / 12)).abs().round(),
              255 - (i * 5))
          ..style = PaintingStyle.fill);
    canvas.restore();
  }
  canvas.restore();

  final image = await recorder.endRecording().toImage(300, 300);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  await File('artistic_pattern.png').writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
}
```

### Simplified Export with exportImage

```dart
import 'dart:io';
import 'package:pure_ui/pure_ui.dart';

void main() async {
  await exportImage(
    canvasFunction: (canvas) {
      canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 200),
          Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawCircle(const Offset(150, 100), 50,
          Paint()..color = const Color(0xFFFF0000));
    },
    size: const Size(300, 200),
    exportFile: File('simple_drawing.png'),
  );
}
```

## dart:ui Compatible Classes

Pure UI provides complete reimplementations of Flutter's dart:ui core classes:

- **Canvas**: Main drawing operations class with full transformation support
- **Path**: Shape path definition with Bézier curves and complex paths
- **Paint**: Drawing style with colors, stroke width, and painting styles
- **Color**: Color representation with ARGB support
- **Rect**: Rectangle operations and utilities
- **Offset**: 2D coordinate points
- **Picture**: Drawing operation recording with async image conversion
- **PictureRecorder**: Drawing recording management
- **Image**: Image representation with PNG export capabilities
- **ParagraphBuilder**: Multi-span text building with style stack
- **Paragraph**: Laid-out text with metrics (`height`, `longestLine`, `computeLineMetrics()`, …)
- **TextStyle**: Per-span style (font, size, color, decoration, shadows, …)
- **ParagraphStyle**: Paragraph-level style (alignment, maxLines, ellipsis, …)
- **FontLoader**: Font registry for TTF/OTF files

**Key API features:**

- **Transformations**: `save()`, `restore()`, `translate()`, `rotate()`, `scale()`
- **Clipping**: `clipRect()`, `clipPath()` with proper clipping boundaries
- **Advanced Drawing**: Paths with quadratic/cubic Bézier curves
- **Text**: `ParagraphBuilder` → `Paragraph` → `Canvas.drawParagraph()` — full pipeline
- **Async Operations**: `picture.toImage()` and `image.toByteData()` return Futures
- **Memory Management**: Proper `dispose()` methods for resource cleanup

## Implemented Features

### Canvas & Drawing
- Complete Canvas API — all major drawing operations
- Advanced transformations (rotation, translation, scaling, save/restore stack)
- Path drawing with quadratic and cubic Bézier curves
- Clipping (rectangle and path-based)
- PNG export via `ImageByteFormat.png`
- Color management with full ARGB / transparency support

### Text Rendering
- TTF binary parser (cmap, glyf, hmtx, kern tables)
- Glyph rasterisation via TrueType quadratic-Bézier outlines + scanline fill
- Text shaper: advance widths, pair kerning, letter/word spacing
- Layout engine: greedy word-wrap, hard line breaks (`\n`), `maxLines`, ellipsis, `TextAlign`
- `ParagraphBuilder` style stack with proper inheritance (`pushStyle` / `pop`)
- Font weight and style variants (`FontWeight.bold`, `FontStyle.italic`)
- Text decorations: underline, overline, line-through
- Text shadows
- Unicode support (Latin, Japanese, CJK, and any script your font covers)
- Performance caches: parsed font cache + glyph polygon cache (skips Bézier re-tessellation)

## Why Pure UI is Needed?

### dart:ui Limitations

- Only usable within Flutter applications
- Cannot be used in CLI tools or batch processing
- Not available for web application backends

### Pure UI Solutions

- **Works Everywhere**: Runs anywhere Dart VM is available
- **Server-Side Image Generation**: Chart/graph/label generation for web servers
- **CLI Tools**: Command-line image processing and text rendering

**With Pure UI, you can leverage Flutter's excellent Canvas API anywhere!**

## License

MIT License
