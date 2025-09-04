# Pure UI - Pure Dart Alternative to Flutter's dart:ui

Pure UI is a Canvas API implemented in pure Dart without Flutter dependencies. It provides a fully compatible API with Flutter's dart:ui, enabling image processing and drawing operations anywhere Dart runs.

**🎯 Why Choose Pure UI?**

- Use dart:ui APIs outside Flutter projects
- Migrate existing Flutter code seamlessly
- Perfect for server-side and CLI image generation

## Key Features

- **🚀 Flutter Independent**: Implemented in pure Dart, usable outside Flutter projects
- **🔄 dart:ui Full Compatibility**: Use Flutter Canvas code as-is with complete API compatibility
- **🖼️ PNG Output**: Export drawings in PNG format
- **📐 Vector Graphics**: Path-based drawing support
- **⚡ Server-Side Ready**: Image generation for web servers and batch processing

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

**Key differences:**

- Canvas constructor requires bounds: `Canvas(recorder, bounds)`
- `picture.toImage()` is async: `await picture.toImage(width, height)`
- `image.toByteData()` is async: `await image.toByteData(format: ImageByteFormat.png)`

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

## Usage Examples

### Basic Drawing Example (Same as dart:ui!)

```dart
import 'dart:io';
import 'package:pure_ui/pure_ui.dart';

void main() async {
  // Create a picture recorder
  final recorder = PictureRecorder();

  // Create a canvas with the recorder and bounds
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 300));

  // Draw background
  final bgPaint = Paint()
    ..color = const Color.fromARGB(255, 240, 240, 255)
    ..style = PaintingStyle.fill;
  canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 300), bgPaint);

  // Draw a circle
  final circlePaint = Paint()
    ..color = const Color.fromARGB(255, 255, 0, 0)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(const Offset(200, 150), 80, circlePaint);

  // Draw a rectangle
  final rectPaint = Paint()
    ..color = const Color.fromARGB(255, 0, 0, 255)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  canvas.drawRect(const Rect.fromLTRB(50, 50, 350, 250), rectPaint);

  // Draw a path
  final pathPaint = Paint()
    ..color = const Color.fromARGB(255, 0, 180, 0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  final path = Path();
  path.moveTo(50, 150);
  path.lineTo(150, 250);
  path.lineTo(250, 50);
  path.lineTo(350, 150);

  canvas.drawPath(path, pathPaint);

  // End recording and get the picture
  final picture = recorder.endRecording();

  // Convert picture to image
  final image = await picture.toImage(400, 300);

  // Save the image as PNG
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();
  await File('output.png').writeAsBytes(pngBytes);

  // Clean up resources
  image.dispose();
  picture.dispose();
}
```

### Complex Drawing with Transformations

```dart
import 'dart:io';
import 'dart:math' as math;
import 'package:pure_ui/pure_ui.dart';

void main() async {
  // Create a PictureRecorder
  final recorder = PictureRecorder();

  // Create Canvas with bounds
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 300, 300));

  // Background
  final bgPaint = Paint()
    ..color = const Color(0xFF1a1a2e)
    ..style = PaintingStyle.fill;
  canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 300), bgPaint);

  // Create spiral pattern with transformations
  canvas.save();
  canvas.translate(150, 150);

  for (int i = 0; i < 36; i++) {
    canvas.save();
    canvas.rotate(i * math.pi / 18);

    // Create path for complex shape
    final path = Path();
    path.moveTo(0, -50);
    path.quadraticBezierTo(20, -30, 0, -10);
    path.quadraticBezierTo(-20, -30, 0, -50);
    path.close();

    final paint = Paint()
      ..color = Color.fromARGB(
          200,
          (255 * math.sin(i * math.pi / 18)).abs().round(),
          (255 * math.cos(i * math.pi / 12)).abs().round(),
          255 - (i * 5))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
    canvas.restore();
  }
  canvas.restore();

  // End recording and get the Picture
  final picture = recorder.endRecording();

  // Create an image from the Picture
  final image = await picture.toImage(300, 300);

  // Save the image as PNG
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  await File('artistic_pattern.png').writeAsBytes(byteData!.buffer.asUint8List());

  // Clean up resources
  image.dispose();
  picture.dispose();
}
```

### Advanced Features: Clipping & Bezier Curves

```dart
import 'dart:io';
import 'dart:math' as math;
import 'package:pure_ui/pure_ui.dart';

void main() async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 400));

  // Background gradient simulation
  for (int y = 0; y < 400; y += 5) {
    final gradient = y / 399.0;
    final paint = Paint()
      ..color = Color.fromARGB(255, (50 + (gradient * 100)).round(),
          (100 + (gradient * 50)).round(), (200 - (gradient * 50)).round())
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, y.toDouble(), 400, 5), paint);
  }

  // Clipping operations
  canvas.save();
  canvas.clipRect(const Rect.fromLTWH(50, 50, 300, 300));

  // Complex transformations with overlapping shapes
  for (int i = 0; i < 8; i++) {
    canvas.save();
    canvas.translate(200, 200);
    canvas.rotate(i * math.pi / 4);

    final paint = Paint()
      ..color = Color.fromARGB(100, (i * 32) % 255, 255 - (i * 32), (i * 64) % 255)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 150, height: 50), paint);
    canvas.restore();
  }
  canvas.restore();

  // Bezier curves and complex paths
  final path = Path();
  path.moveTo(50, 350);
  path.quadraticBezierTo(200, 250, 350, 350);
  path.cubicTo(300, 320, 250, 280, 200, 320);
  path.lineTo(100, 380);
  path.close();

  final pathPaint = Paint()
    ..color = const Color(0xFF00AA44)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0;
  canvas.drawPath(path, pathPaint);

  final picture = recorder.endRecording();
  final image = await picture.toImage(400, 400);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  await File('advanced_features.png').writeAsBytes(bytes!.buffer.asUint8List());

  image.dispose();
  picture.dispose();
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
- **ImageByteFormat**: Support for PNG and other image formats

**💡 Full API compatibility with dart:ui - just change your import and go!**

### Key API Features:

- **Transformations**: `save()`, `restore()`, `translate()`, `rotate()`, `scale()`
- **Clipping**: `clipRect()`, `clipPath()` with proper clipping boundaries
- **Advanced Drawing**: Paths with quadratic Bézier curves, complex compositions
- **Async Operations**: `picture.toImage()` and `image.toByteData()` return Futures
- **Memory Management**: Proper `dispose()` methods for resource cleanup

## Roadmap

Pure UI is under active development. Current implementation status:

### ✅ Implemented

- **Complete Canvas API**: All major drawing operations
- **Advanced Transformations**: Rotation, translation, scaling with save/restore
- **Path Drawing**: Complex paths with Bézier curves and path operations
- **PNG Export**: Direct PNG output via `ImageByteFormat.png`
- **Clipping Operations**: Rectangle and path-based clipping
- **Color Management**: Full ARGB color support with transparency
- **Memory Management**: Proper resource disposal patterns

### 🚧 In Development / Planned

- Text drawing functionality
- More image blend modes
- Performance optimization
- Improved anti-aliasing

**💪 Continuously improving to become a complete dart:ui alternative!**

## Why Pure UI is Needed?

### 🚫 dart:ui Limitations

- Only usable within Flutter applications
- Cannot be used in CLI tools or batch processing
- Not available for web application backends

### ✅ Pure UI Solutions

- **Works Everywhere**: Runs anywhere Dart VM is available
- **Server-Side Image Generation**: Chart/Graph generation for web servers
- **CLI Tools**: Create command-line image processing tools

**With Pure UI, you can leverage Flutter's excellent Canvas API anywhere!**

## License

MIT License
