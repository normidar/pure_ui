import 'dart:io';

import 'package:pure_ui/pure_ui.dart';

void main() async {
  print(
      'Pure UI Example - Demonstrating dart:ui functionality without Flutter Engine');

  // Create a picture recorder
  final recorder = PictureRecorder();
  print(
      '✓ PictureRecorder created successfully (isRecording: ${recorder.isRecording})');

  // Create a canvas for drawing
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 200, 200));
  print('✓ Canvas created successfully');

  // Create paint for drawing
  final paint = Paint()
    ..color = const Color(0xFFFF0000)
    ..style = PaintingStyle.fill;
  print('✓ Paint created successfully');

  // Draw some shapes
  canvas.drawRect(const Rect.fromLTWH(50, 50, 100, 100), paint);
  canvas.drawCircle(const Offset(100, 100), 30, paint);
  print('✓ Drawing operations completed');

  // End recording and get the picture
  final picture = recorder.endRecording();
  print(
      '✓ Picture recording ended (recorder.isRecording: ${recorder.isRecording})');

  // Convert picture to image
  final image = await picture.toImage(200, 200);
  print('✓ Picture converted to Image (${image.width}x${image.height})');

  // Get image data
  final byteData = await image.toByteData();
  if (byteData != null) {
    print(
        '✓ Image data extracted successfully (${byteData.lengthInBytes} bytes)');

    // Save as a simple file for demonstration
    final file = File('example_output.rgba');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print('✓ Image data saved to example_output.rgba');
  }

  // Clean up
  image.dispose();
  picture.dispose();
  print('✓ Resources disposed');

  print('\n🎉 Pure Dart implementation of dart:ui is working successfully!');
  print(
      '   This demonstrates that @Native FFI calls have been replaced with pure Dart implementations.');
}
