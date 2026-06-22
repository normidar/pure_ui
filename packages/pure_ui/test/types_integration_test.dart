// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

import '../lib/pure_ui.dart';

/// Comprehensive test to verify that all the previously missing types and
/// imports are now working correctly in the pure_ui library.
void main() {
  group('dart:ui Types Integration Tests', () {
    test('Uint8List - basic typed data support', () {
      // Test that Uint8List works correctly
      final pixels = Uint8List(16); // 2x2 RGBA image

      // Set red pixel at (0,0)
      pixels[0] = 255; // R
      pixels[1] = 0; // G
      pixels[2] = 0; // B
      pixels[3] = 255; // A

      // Set green pixel at (1,0)
      pixels[4] = 0; // R
      pixels[5] = 255; // G
      pixels[6] = 0; // B
      pixels[7] = 255; // A

      // Set blue pixel at (0,1)
      pixels[8] = 0; // R
      pixels[9] = 0; // G
      pixels[10] = 255; // B
      pixels[11] = 255; // A

      // Set white pixel at (1,1)
      pixels[12] = 255; // R
      pixels[13] = 255; // G
      pixels[14] = 255; // B
      pixels[15] = 255; // A

      expect(pixels.length, equals(16));
      expect(pixels[0], equals(255)); // Red pixel
      expect(pixels[5], equals(255)); // Green pixel
      expect(pixels[10], equals(255)); // Blue pixel
    });

    test('Color - basic color operations', () {
      // Test Color creation and operations
      final red = Color.fromARGB(255, 255, 0, 0);
      final green = Color.fromARGB(255, 0, 255, 0);
      final white = Color.fromARGB(255, 255, 255, 255);

      // Test color properties using new non-deprecated accessors
      expect((red.r * 255).round(), equals(255));
      expect((red.g * 255).round(), equals(0));
      expect((red.b * 255).round(), equals(0));
      expect((red.a * 255).round(), equals(255));

      // Test color operations
      final redWithAlpha = red.withAlpha(128);
      expect((redWithAlpha.a * 255).round(), equals(128));

      final greenWithBlue = green.withBlue(100);
      expect((greenWithBlue.b * 255).round(), equals(100));

      // Test color from ARGB32
      final colorValue = white.toARGB32();
      expect(colorValue, equals(0xFFFFFFFF));
    });

    test('Rect - rectangle operations', () {
      // Test Rect creation and operations
      final rect1 = Rect.fromLTWH(10.0, 20.0, 100.0, 50.0);
      final rect2 = Rect.fromLTRB(0.0, 0.0, 50.0, 80.0);

      expect(rect1.left, equals(10.0));
      expect(rect1.top, equals(20.0));
      expect(rect1.width, equals(100.0));
      expect(rect1.height, equals(50.0));
      expect(rect1.right, equals(110.0));
      expect(rect1.bottom, equals(70.0));

      // Test rectangle operations
      final intersection = rect1.intersect(rect2);
      expect(intersection.left, equals(10.0));
      expect(intersection.top, equals(20.0));

      final union = rect1.expandToInclude(rect2);
      expect(union.left, equals(0.0));
      expect(union.top, equals(0.0));

      // Test contains
      expect(rect1.contains(Offset(50.0, 40.0)), isTrue);
      expect(rect1.contains(Offset(5.0, 40.0)), isFalse);
    });

    test('Picture and PictureRecorder - basic drawing operations', () async {
      // Test Picture creation and usage
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 100, 100));

      // Draw something on the canvas
      final paint = Paint()..color = Color.fromARGB(255, 255, 0, 0);
      canvas.drawRect(Rect.fromLTWH(10, 10, 50, 50), paint);
      canvas.drawCircle(Offset(75, 25), 15, paint);

      // End recording and get picture
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
      expect(picture.approximateBytesUsed, greaterThan(0));

      // Convert to image
      final image = picture.toImageSync(100, 100);
      expect(image, isNotNull);
      expect(image.width, equals(100));
      expect(image.height, equals(100));

      // Test that we can convert to byte data
      final byteData = await image.toByteData();
      expect(byteData, isNotNull);
      expect(byteData!.lengthInBytes, equals(100 * 100 * 4)); // RGBA

      picture.dispose();
      image.dispose();
    });

    test('Float32List and Float64List - typed data lists', () {
      // Test Float32List for raw atlas data
      final transforms =
          Float32List(8); // 2 RSTransforms: scos, ssin, tx, ty each
      transforms[0] = 1.0; // scos
      transforms[1] = 0.0; // ssin
      transforms[2] = 50.0; // tx
      transforms[3] = 50.0; // ty

      transforms[4] = 0.5; // scos (scaled)
      transforms[5] = 0.0; // ssin
      transforms[6] = 100.0; // tx
      transforms[7] = 100.0; // ty

      expect(transforms.length, equals(8));
      expect(transforms[0], equals(1.0));
      expect(transforms[4], equals(0.5));

      // Test Float64List for matrix transformations
      final matrix = Float64List(16);
      for (int i = 0; i < 16; i++) {
        matrix[i] = i.toDouble();
      }

      expect(matrix.length, equals(16));
      expect(matrix[0], equals(0.0));
      expect(matrix[15], equals(15.0));
    });

    test('Int32List - integer typed data', () {
      // Test Int32List basic functionality
      final colors = Int32List(4);
      colors[0] = 100;
      colors[1] = 200;
      colors[2] = 300;
      colors[3] = 400;

      expect(colors.length, equals(4));
      expect(colors[0], equals(100));
      expect(colors[3], equals(400));

      // Test that we can use it for color storage
      final colorValue = Color.fromARGB(255, 255, 255, 255).toARGB32();
      expect(colorValue, isA<int>());
    });
  });

  group('dart:math Integration Tests', () {
    test('Math constants and basic functions', () {
      // Test that math constants are accessible
      expect(math.pi, closeTo(3.14159, 0.001));
      expect(math.e, closeTo(2.71828, 0.001));

      // Test basic math functions
      expect(math.sin(math.pi / 2), closeTo(1.0, 0.001));
      expect(math.cos(0), closeTo(1.0, 0.001));
      expect(math.sqrt(16), equals(4.0));
      expect(math.pow(2, 3), equals(8.0));
    });

    test('Math functions in canvas operations', () {
      // Test math functions used in canvas transformations
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 200, 200));

      // Test rotation using math functions
      canvas.save();
      canvas.translate(100, 100);
      canvas.rotate(math.pi / 4); // 45 degrees

      final paint = Paint()..color = Color.fromARGB(255, 0, 255, 0);
      canvas.drawRect(Rect.fromLTWH(-25, -25, 50, 50), paint);

      canvas.restore();

      // Test skew using math.tan
      canvas.save();
      canvas.skew(math.tan(math.pi / 8), 0); // Skew transformation
      canvas.drawRect(Rect.fromLTWH(50, 50, 30, 30), paint);
      canvas.restore();

      final picture = recorder.endRecording();
      expect(picture, isNotNull);

      picture.dispose();
    });

    test('Math min/max functions', () {
      // Test min/max functions used throughout the library
      expect(math.min(10, 5), equals(5));
      expect(math.max(10, 5), equals(10));
      expect(math.min(-5, -10), equals(-10));
      expect(math.max(-5, -10), equals(-5));

      // Test with doubles
      expect(math.min(3.14, 2.71), equals(2.71));
      expect(math.max(3.14, 2.71), equals(3.14));
    });
  });

  group('vector_math Integration Tests', () {
    test('Matrix4 - 4x4 transformation matrices', () {
      // Test Matrix4 creation and operations
      final identity = Matrix4.identity();
      expect(identity.isIdentity(), isTrue);

      // Test translation matrix
      final translation = Matrix4.translation(Vector3(10.0, 20.0, 0.0));
      final point = Vector3(5.0, 5.0, 0.0);
      final transformed = translation.transform3(point);

      expect(transformed.x, equals(15.0));
      expect(transformed.y, equals(25.0));
      expect(transformed.z, equals(0.0));

      // Test rotation matrix
      final rotation = Matrix4.rotationZ(math.pi / 2); // 90 degrees
      final rightVector = Vector3(1.0, 0.0, 0.0);
      final rotated = rotation.transform3(rightVector);

      expect(rotated.x, closeTo(0.0, 0.001));
      expect(rotated.y, closeTo(1.0, 0.001));

      // Test scaling matrix
      final scaling = Matrix4.diagonal3Values(2.0, 3.0, 1.0);
      final scaled = scaling.transform3(Vector3(4.0, 5.0, 6.0));

      expect(scaled.x, equals(8.0));
      expect(scaled.y, equals(15.0));
      expect(scaled.z, equals(6.0));
    });

    test('Vector3 - 3D vector operations', () {
      // Test Vector3 creation and operations
      final v1 = Vector3(1.0, 2.0, 3.0);
      final v2 = Vector3(4.0, 5.0, 6.0);

      expect(v1.x, equals(1.0));
      expect(v1.y, equals(2.0));
      expect(v1.z, equals(3.0));

      // Test vector addition
      final sum = v1 + v2;
      expect(sum.x, equals(5.0));
      expect(sum.y, equals(7.0));
      expect(sum.z, equals(9.0));

      // Test dot product
      final dot = v1.dot(v2);
      expect(dot, equals(32.0)); // 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32

      // Test length
      final unitX = Vector3(1.0, 0.0, 0.0);
      expect(unitX.length, equals(1.0));

      final v3 = Vector3(3.0, 4.0, 0.0);
      expect(v3.length, equals(5.0)); // 3-4-5 triangle
    });

    test('Matrix4 in Canvas transformations', () {
      // Test Matrix4 usage in canvas operations
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 200, 200));

      // Create a complex transformation matrix
      final transform = Matrix4.identity()
        ..translate(100.0, 100.0, 0.0)
        ..rotateZ(math.pi / 6) // 30 degrees
        ..scale(1.5, 1.5, 1.0);

      // Apply the transformation
      canvas.transform(transform.storage);

      final paint = Paint()..color = Color.fromARGB(255, 255, 165, 0);
      canvas.drawRect(Rect.fromLTWH(-20, -20, 40, 40), paint);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);

      picture.dispose();
    });

    test('Float64List compatibility with Matrix4', () {
      // Test that Matrix4.storage works with Float64List
      final matrix = Matrix4.identity();
      final storage = matrix.storage;

      expect(storage, isA<Float64List>());
      expect(storage.length, equals(16));

      // Test that we can modify the storage
      storage[0] = 2.0; // Scale X by 2
      storage[5] = 3.0; // Scale Y by 3

      // Apply to a vector
      final testVector = Vector3(1.0, 1.0, 1.0);
      final result = matrix.transform3(testVector);

      expect(result.x, equals(2.0));
      expect(result.y, equals(3.0));
      expect(result.z, equals(1.0));
    });
  });

  group('Integration Test - Complex Scenario', () {
    test('All types working together in complex drawing', () {
      // Create a complex drawing that uses all the types we've tested
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 300, 300));

      // Background with typed data color
      final bgColor = Color.fromARGB(255, 240, 240, 240);
      canvas.drawColor(bgColor, BlendMode.src);

      // Draw shapes using math functions
      final paint = Paint()..color = Color.fromARGB(255, 100, 150, 200);

      // Draw a spiral using math functions
      canvas.save();
      canvas.translate(150, 150);

      for (int i = 0; i < 50; i++) {
        final angle = i * math.pi / 10;
        final radius = i * 2.0;
        final x = radius * math.cos(angle);
        final y = radius * math.sin(angle);

        canvas.drawCircle(Offset(x, y), 3.0, paint);
      }
      canvas.restore();

      // Use Matrix4 for complex transformation
      final transform = Matrix4.identity()
        ..translate(50.0, 50.0, 0.0)
        ..rotateZ(math.pi / 4)
        ..scale(0.8, 0.8, 1.0);

      canvas.save();
      canvas.transform(transform.storage);

      // Draw rectangles
      final rectPaint = Paint()..color = Color.fromARGB(180, 255, 100, 100);
      for (int i = 0; i < 5; i++) {
        final rect = Rect.fromLTWH(i * 20.0, i * 15.0, 40.0, 30.0);
        canvas.drawRect(rect, rectPaint);
      }
      canvas.restore();

      // Create atlas data using typed arrays
      final atlasPixels = Uint8List(64); // 4x4 RGBA
      for (int i = 0; i < 16; i++) {
        final idx = i * 4;
        atlasPixels[idx] = (i * 16) % 256; // R
        atlasPixels[idx + 1] = (i * 32) % 256; // G
        atlasPixels[idx + 2] = (i * 48) % 256; // B
        atlasPixels[idx + 3] = 255; // A
      }

      final atlasImage = createPureDartImage(atlasPixels, 4, 4);

      // Use raw atlas drawing with typed arrays
      final transforms = Float32List(4); // 1 RSTransform
      transforms[0] = math.cos(math.pi / 6); // scos
      transforms[1] = math.sin(math.pi / 6); // ssin
      transforms[2] = 200.0; // tx
      transforms[3] = 200.0; // ty

      final rects = Float32List(4); // 1 source rect
      rects[0] = 0.0; // left
      rects[1] = 0.0; // top
      rects[2] = 4.0; // right
      rects[3] = 4.0; // bottom

      final colors = Int32List(1);
      colors[0] = Color.fromARGB(255, 255, 255, 255).toARGB32();

      canvas.drawRawAtlas(
        atlasImage,
        transforms,
        rects,
        colors,
        BlendMode.srcOver,
        null,
        Paint(),
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);

      // Convert to image and verify
      final finalImage = picture.toImageSync(300, 300);
      expect(finalImage.width, equals(300));
      expect(finalImage.height, equals(300));

      // Clean up
      picture.dispose();
      finalImage.dispose();
      atlasImage.dispose();
    });
  });
}
