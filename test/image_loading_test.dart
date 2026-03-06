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

      srcImage.dispose();
      output.dispose();
      picture.dispose();
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
    });
  });
}
