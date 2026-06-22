import 'dart:typed_data';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

void main() {
  group('ImmutableBuffer', () {
    test('fromUint8List returns pure Dart buffer without native calls',
        () async {
      final pixels = Uint8List.fromList([255, 0, 0, 255]); // 1x1 red pixel
      final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
      expect(buffer.length, equals(4));
      buffer.dispose();
    });
  });

  group('ImageDescriptor.raw', () {
    test('creates descriptor from raw RGBA pixels', () async {
      // 2x2 RGBA image: red, green, blue, white
      final pixels = Uint8List.fromList([
        255, 0, 0, 255, // red
        0, 255, 0, 255, // green
        0, 0, 255, 255, // blue
        255, 255, 255, 255, // white
      ]);
      final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
      final descriptor = ui.ImageDescriptor.raw(
        buffer,
        width: 2,
        height: 2,
        pixelFormat: ui.PixelFormat.rgba8888,
      );
      expect(descriptor.width, equals(2));
      expect(descriptor.height, equals(2));
      descriptor.dispose();
      buffer.dispose();
    });

    test('instantiateCodec produces a frame with the correct image', () async {
      // 2x2 RGBA image
      final pixels = Uint8List.fromList([
        255, 0, 0, 255, // red
        0, 255, 0, 255, // green
        0, 0, 255, 255, // blue
        255, 255, 255, 255, // white
      ]);
      final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
      final descriptor = ui.ImageDescriptor.raw(
        buffer,
        width: 2,
        height: 2,
        pixelFormat: ui.PixelFormat.rgba8888,
      );
      final codec = await descriptor.instantiateCodec();
      expect(codec.frameCount, equals(1));

      final frame = await codec.getNextFrame();
      expect(frame.image.width, equals(2));
      expect(frame.image.height, equals(2));

      // Verify pixel values are preserved correctly
      final image = frame.image;
      final redPixel = image.getPixel(0, 0);
      final greenPixel = image.getPixel(1, 0);
      final bluePixel = image.getPixel(0, 1);
      final whitePixel = image.getPixel(1, 1);

      expect((redPixel.r * 255).round(), equals(255));
      expect((redPixel.g * 255).round(), equals(0));
      expect((redPixel.b * 255).round(), equals(0));

      expect((greenPixel.r * 255).round(), equals(0));
      expect((greenPixel.g * 255).round(), equals(255));
      expect((greenPixel.b * 255).round(), equals(0));

      expect((bluePixel.r * 255).round(), equals(0));
      expect((bluePixel.g * 255).round(), equals(0));
      expect((bluePixel.b * 255).round(), equals(255));

      expect((whitePixel.r * 255).round(), equals(255));
      expect((whitePixel.g * 255).round(), equals(255));
      expect((whitePixel.b * 255).round(), equals(255));

      frame.image.dispose();
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
    });

    test('BGRA pixel format is correctly converted to RGBA', () async {
      // 1x1 BGRA pixel: blue=255, green=0, red=0 → should be read as red
      final bgraPixels = Uint8List.fromList([255, 0, 0, 255]); // BGRA: blue
      final buffer = await ui.ImmutableBuffer.fromUint8List(bgraPixels);
      final descriptor = ui.ImageDescriptor.raw(
        buffer,
        width: 1,
        height: 1,
        pixelFormat: ui.PixelFormat.bgra8888,
      );
      final codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();
      final pixel = frame.image.getPixel(0, 0);

      // BGRA [255,0,0,255] → RGBA should be [0,0,255,255] (blue)
      expect((pixel.r * 255).round(), equals(0));
      expect((pixel.g * 255).round(), equals(0));
      expect((pixel.b * 255).round(), equals(255));
      expect((pixel.a * 255).round(), equals(255));

      frame.image.dispose();
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
    });
  });

  group('Canvas drawImage', () {
    test('draws image at offset', () async {
      // Create a 10x10 red source image
      final srcPixels = Uint8List(10 * 10 * 4);
      for (int i = 0; i < srcPixels.length; i += 4) {
        srcPixels[i] = 255; // R
        srcPixels[i + 1] = 0; // G
        srcPixels[i + 2] = 0; // B
        srcPixels[i + 3] = 255; // A
      }

      final buffer = await ui.ImmutableBuffer.fromUint8List(srcPixels);
      final descriptor = ui.ImageDescriptor.raw(
        buffer,
        width: 10,
        height: 10,
        pixelFormat: ui.PixelFormat.rgba8888,
      );
      final codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();
      final srcImage = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(
          recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));
      canvas.drawImage(srcImage, const ui.Offset(5, 5), ui.Paint());

      final picture = recorder.endRecording();
      final output = await picture.toImage(100, 100);

      expect(output.width, equals(100));
      expect(output.height, equals(100));

      // Verify the red image was drawn at offset (5,5)
      final drawnPixel = output.getPixel(5, 5);
      expect((drawnPixel.r * 255).round(), equals(255));
      expect((drawnPixel.g * 255).round(), equals(0));
      expect((drawnPixel.b * 255).round(), equals(0));

      // Verify area outside image is empty (transparent)
      final emptyPixel = output.getPixel(0, 0);
      expect((emptyPixel.a * 255).round(), equals(0));

      srcImage.dispose();
      output.dispose();
      picture.dispose();
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
    });
  });

  group('Canvas drawImageRect', () {
    test('draws image portion scaled to destination rect', () async {
      // Create a 10x10 blue source image
      final srcPixels = Uint8List(10 * 10 * 4);
      for (int i = 0; i < srcPixels.length; i += 4) {
        srcPixels[i] = 0; // R
        srcPixels[i + 1] = 0; // G
        srcPixels[i + 2] = 255; // B
        srcPixels[i + 3] = 255; // A
      }

      final buffer = await ui.ImmutableBuffer.fromUint8List(srcPixels);
      final descriptor = ui.ImageDescriptor.raw(
        buffer,
        width: 10,
        height: 10,
        pixelFormat: ui.PixelFormat.rgba8888,
      );
      final codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();
      final srcImage = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(
          recorder, const ui.Rect.fromLTWH(0, 0, 200, 200));
      canvas.drawImageRect(
        srcImage,
        ui.Rect.fromLTWH(0, 0, srcImage.width.toDouble(),
            srcImage.height.toDouble()),
        const ui.Rect.fromLTWH(10, 10, 50, 50),
        ui.Paint(),
      );

      final picture = recorder.endRecording();
      final output = await picture.toImage(200, 200);

      expect(output.width, equals(200));
      expect(output.height, equals(200));

      // Verify the blue image was drawn inside the destination rect (10,10)-(60,60)
      final drawnPixel = output.getPixel(30, 30);
      expect((drawnPixel.r * 255).round(), equals(0));
      expect((drawnPixel.g * 255).round(), equals(0));
      expect((drawnPixel.b * 255).round(), equals(255));

      // Verify area outside destination rect is empty (transparent)
      final emptyPixel = output.getPixel(0, 0);
      expect((emptyPixel.a * 255).round(), equals(0));

      srcImage.dispose();
      output.dispose();
      picture.dispose();
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
    });
  });
}
