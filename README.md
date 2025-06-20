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

Migrating Flutter Canvas code to Pure UI is incredibly simple:

```dart
// Before: Using dart:ui in Flutter projects
import 'dart:ui';

// After: Using Pure UI (same API!)
import 'package:pure_ui/pure_ui.dart';

// Your code remains exactly the same
final canvas = Canvas(pictureRecorder);
canvas.drawCircle(Offset(100, 100), 50, paint);
```

## Usage Examples

### Basic Drawing Example (Same as dart:ui!)

```dart
import 'dart:io';
import 'package:pure_ui/pure_ui.dart';

void main() {
  // Create an image
  final image = PureImage(400, 300);

  // Create a canvas
  final canvas = PureCanvas.forImage(image);

  // Draw background
  final bgPaint = Paint()
    ..color = Color.fromRGB(240, 240, 255)
    ..style = PaintingStyle.fill;
  canvas.drawRect(Rect.fromLTWH(0, 0, 400, 300), bgPaint);

  // Draw a circle
  final circlePaint = Paint()
    ..color = Color.fromRGB(255, 0, 0)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(200, 150), 80, circlePaint);

  // Draw a rectangle
  final rectPaint = Paint()
    ..color = Color.fromRGB(0, 0, 255)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  canvas.drawRect(Rect.fromLTRB(50, 50, 350, 250), rectPaint);

  // Draw a path
  final pathPaint = Paint()
    ..color = Color.fromRGB(0, 180, 0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  final path = Path();
  path.moveTo(50, 150);
  path.lineTo(150, 250);
  path.lineTo(250, 50);
  path.lineTo(350, 150);

  canvas.drawPath(path, pathPaint);

  // Save the image as PNG
  final pngData = image.toPng();
  File('output.png').writeAsBytesSync(pngData);
}
```

### PictureRecorder Example

```dart
import 'dart:io';
import 'package:pure_ui/pure_ui.dart';

void main() {
  // Create a PictureRecorder
  final recorder = PictureRecorder();

  // Get Canvas from PictureRecorder
  final canvas = recorder.canvas;

  // Record drawing operations
  final paint = Paint()
    ..color = Color.fromRGB(0, 100, 255)
    ..style = PaintingStyle.fill;

  canvas.drawCircle(Offset(100, 100), 50, paint);

  // Draw a rectangle
  canvas.drawRect(
    Rect.fromLTRB(50, 50, 150, 150),
    Paint()
      ..color = Color.fromRGB(255, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );

  // End recording and get the Picture
  final picture = recorder.endRecording();

  // Create an image from the Picture (size 200x200)
  final image = picture.toImage(200, 200);

  // Save the image as PNG
  final pngData = image.toPng();
  File('recorded_output.png').writeAsBytesSync(pngData);
}
```

## dart:ui Compatible Classes

Pure UI provides complete reimplementations of Flutter's dart:ui core classes:

- **Canvas**: Main drawing operations class (same API as `dart:ui.Canvas`)
- **Path**: Shape path definition class (same API as `dart:ui.Path`)
- **Paint**: Drawing style definition class (same API as `dart:ui.Paint`)
- **Color**: Color representation class (same API as `dart:ui.Color`)
- **Rect**: Rectangle representation class (same API as `dart:ui.Rect`)
- **Offset**: Coordinate point class (same API as `dart:ui.Offset`)
- **Picture**: Drawing operation recording class (same API as `dart:ui.Picture`)
- **PictureRecorder**: Drawing recording management class (same API as `dart:ui.PictureRecorder`)
- **Image**: Image representation class (same API as `dart:ui.Image`)

**💡 Simply change your import statement and your existing Flutter code works!**

## Roadmap

Pure UI is under active development. Current implementation status:

### ✅ Implemented

- Basic shape drawing (circles, rectangles, paths)
- PNG image output
- Drawing operation recording and playback
- dart:ui compatible API
- Gradient support

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
