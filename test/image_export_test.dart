import 'dart:io';
import 'package:pure_ui/pure_ui.dart';
import 'package:test/test.dart';

void main() {
  group('Image Export Tests', () {
    test('Can draw circles and ovals on an image and export as PNG', () {
      // Image size
      const int width = 400;
      const int height = 300;

      // Create PictureRecorder
      final recorder = PictureRecorder();
      final canvas = recorder.canvas;

      // Fill background with white
      final bgPaint = Paint()
        ..color = const Color.fromRGB(255, 255, 255)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        bgPaint,
      );

      // Draw circle (red fill)
      final circlePaint = Paint()
        ..color = const Color.fromRGB(255, 0, 0)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(100, 150), 80, circlePaint);

      // Draw oval (blue fill)
      final ovalPaint = Paint()
        ..color = const Color.fromRGB(0, 0, 255)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromLTWH(200, 50, 160, 200), ovalPaint);

      // Draw circle outline (green stroke)
      final strokePaint = Paint()
        ..color = const Color.fromRGB(0, 255, 0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawCircle(const Offset(100, 150), 80, strokePaint);

      // Create Picture
      final picture = recorder.endRecording();

      // Convert to image
      final image = picture.toImage(width, height);
      expect(image, isNotNull);
      expect(image.width, width);
      expect(image.height, height);

      // Encode as PNG
      final pngData = image.toPng();
      expect(pngData, isNotNull);
      expect(pngData.isNotEmpty, isTrue);

      // Save to file (for verification during test execution)
      try {
        final outputDir = Directory('test_output');
        if (!outputDir.existsSync()) {
          outputDir.createSync();
        }

        final file = File('test_output/circle_oval_test.png');
        file.writeAsBytesSync(pngData);

        print('PNG image saved to: ${file.absolute.path}');
        expect(file.existsSync(), isTrue);
      } catch (e) {
        print('Error saving image: $e');
        // Don't fail the test if file saving fails
      }
    });

    test('Can draw various shapes and export as PNG', () {
      // Image size
      const int width = 500;
      const int height = 400;

      // Create PictureRecorder
      final recorder = PictureRecorder();
      final canvas = recorder.canvas;

      // Fill background with light gray
      final bgPaint = Paint()
        ..color = const Color.fromRGB(240, 240, 240)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        bgPaint,
      );

      // Draw rectangle (red)
      final rectPaint = Paint()
        ..color = const Color.fromRGB(255, 0, 0)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(50, 50, 100, 80), rectPaint);

      // Draw rounded rectangle (green)
      final rrectPaint = Paint()
        ..color = const Color.fromRGB(0, 180, 0)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(Rect.fromLTWH(200, 50, 100, 80), 20, 20, rrectPaint);

      // Draw line (blue)
      final linePaint = Paint()
        ..color = const Color.fromRGB(0, 0, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawLine(const Offset(50, 200), const Offset(150, 250), linePaint);

      // Draw triangle using path (purple)
      final pathPaint = Paint()
        ..color = const Color.fromRGB(180, 0, 180)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(350, 80);
      path.lineTo(300, 160);
      path.lineTo(400, 160);
      path.close();

      canvas.drawPath(path, pathPaint);

      // Draw overlapping circles (semi-transparent)
      final circle1Paint = Paint()
        ..color = const Color.fromARGB(128, 255, 0, 0)
        ..style = PaintingStyle.fill;

      final circle2Paint = Paint()
        ..color = const Color.fromARGB(128, 0, 0, 255)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(const Offset(300, 300), 70, circle1Paint);
      canvas.drawCircle(const Offset(350, 250), 70, circle2Paint);

      // Create Picture
      final picture = recorder.endRecording();

      // Convert to image
      final image = picture.toImage(width, height);

      // Encode as PNG
      final pngData = image.toPng();

      // Save to file
      try {
        final outputDir = Directory('test_output');
        if (!outputDir.existsSync()) {
          outputDir.createSync();
        }

        final file = File('test_output/shapes_test.png');
        file.writeAsBytesSync(pngData);

        print('PNG image saved to: ${file.absolute.path}');
        expect(file.existsSync(), isTrue);
      } catch (e) {
        print('Error saving image: $e');
      }
    });

    test('Can draw paths with even-odd fill rule and export as PNG', () {
      // Image size
      const int width = 500;
      const int height = 400;

      // Create PictureRecorder
      final recorder = PictureRecorder();
      final canvas = recorder.canvas;

      // Draw path with even-odd fill rule (purple)
      final pathPaint = Paint()
        ..color = const Color.fromRGB(180, 0, 180)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..fillType = PathFillType.evenOdd
        ..moveTo(13.0, 5.5)
        ..cubicTo(17.139362683705, 5.5, 20.5, 8.860637316295001, 20.5, 13.0)
        ..cubicTo(20.5, 17.139362683705, 17.139362683705, 20.5, 13.0, 20.5)
        ..cubicTo(8.860637316295001, 20.5, 5.5, 17.139362683705, 5.5, 13.0)
        ..cubicTo(5.5, 8.860637316295001, 8.860637316295001, 5.5, 13.0, 5.5)
        ..close();

      canvas.drawPath(path, pathPaint);

      // Draw overlapping circles (semi-transparent)
      final circle1Paint = Paint()
        ..color = const Color.fromARGB(128, 255, 0, 0)
        ..style = PaintingStyle.fill;

      final circle2Paint = Paint()
        ..color = const Color.fromARGB(128, 0, 0, 255)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(const Offset(300, 300), 70, circle1Paint);
      canvas.drawCircle(const Offset(350, 250), 70, circle2Paint);

      // Create Picture
      final picture = recorder.endRecording();

      // Convert to image
      final image = picture.toImage(width, height);

      // Encode as PNG
      final pngData = image.toPng();

      // Save to file
      try {
        final outputDir = Directory('test_output');
        if (!outputDir.existsSync()) {
          outputDir.createSync();
        }

        final file = File('test_output/even_odd_test.png');
        file.writeAsBytesSync(pngData);

        print('PNG image saved to: ${file.absolute.path}');
        expect(file.existsSync(), isTrue);
      } catch (e) {
        print('Error saving image: $e');
      }
    });

    test('Can draw gradients and export as PNG', () {
      // Image size
      const int width = 600;
      const int height = 400;

      // Create PictureRecorder
      final recorder = PictureRecorder();
      final canvas = recorder.canvas;

      // Fill background with white
      final bgPaint = Paint()
        ..color = const Color.fromRGB(255, 255, 255)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        bgPaint,
      );

      // Linear gradient (left to right)
      final linearGradientPaint = Paint()
        ..shader = LinearGradient(
          from: const Offset(0, 0),
          to: const Offset(300, 0),
          colors: const [
            Color.fromRGB(255, 0, 0), // Red
            Color.fromRGB(0, 0, 255), // Blue
          ],
          stops: const [0.0, 1.0],
        );
      canvas.drawRect(Rect.fromLTWH(50, 50, 300, 150), linearGradientPaint);

      // Radial gradient
      final radialGradientPaint = Paint()
        ..shader = RadialGradient(
          center: const Offset(450, 200),
          radius: 100,
          colors: const [
            Color.fromRGB(255, 255, 0), // Yellow
            Color.fromRGB(0, 128, 0), // Green
          ],
          stops: const [0.0, 1.0],
        );
      canvas.drawCircle(const Offset(450, 200), 100, radialGradientPaint);

      // Sweep gradient (elliptical)
      final sweepGradientPaint = Paint()
        ..shader = SweepGradient(
          center: const Offset(200, 300),
          colors: const [
            Color.fromRGB(255, 0, 255), // Magenta
            Color.fromRGB(0, 255, 255), // Cyan
            Color.fromRGB(255, 0, 255), // Magenta (to complete the circle)
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      canvas.drawCircle(const Offset(200, 300), 80, sweepGradientPaint);

      // Create Picture
      final picture = recorder.endRecording();

      // Convert to image
      final image = picture.toImage(width, height);
      expect(image, isNotNull);
      expect(image.width, width);
      expect(image.height, height);

      // Encode as PNG
      final pngData = image.toPng();
      expect(pngData, isNotNull);
      expect(pngData.isNotEmpty, isTrue);

      // Save to file
      try {
        final outputDir = Directory('test_output');
        if (!outputDir.existsSync()) {
          outputDir.createSync();
        }

        final file = File('test_output/gradient_test.png');
        file.writeAsBytesSync(pngData);

        print('PNG image saved to: ${file.absolute.path}');
        expect(file.existsSync(), isTrue);
      } catch (e) {
        print('Error saving image: $e');
      }
    });

    test('Can draw text on an image and export as PNG', () {
      // Image size
      const int width = 800;
      const int height = 600;

      // Create PictureRecorder
      final recorder = PictureRecorder();
      final canvas = recorder.canvas;

      // Fill background with light blue
      final bgPaint = Paint()
        ..color = const Color.fromRGB(240, 248, 255)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        bgPaint,
      );

      // Create title paragraph style
      final titleParagraphStyle = ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 36.0,
        fontWeight: FontWeight.bold,
      );

      // Create title paragraph builder
      final titleParagraphBuilder = ParagraphBuilder(titleParagraphStyle);
      titleParagraphBuilder.pushStyle(
        TextStyle(
          color: const Color.fromRGB(0, 0, 139),
          fontSize: 36.0,
          fontWeight: FontWeight.bold,
        ),
      );
      titleParagraphBuilder.addText('Pure UIテキスト描画デモ');

      // Build and draw title
      final titleParagraph = titleParagraphBuilder.build();
      canvas.drawParagraph(titleParagraph, const Offset(50, 50));

      // Create subtitle paragraph
      final subtitleParagraphStyle = ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 24.0,
        fontWeight: FontWeight.normal,
      );

      final subtitleParagraphBuilder = ParagraphBuilder(subtitleParagraphStyle);
      subtitleParagraphBuilder.pushStyle(
        TextStyle(
          color: const Color.fromRGB(255, 69, 0),
          fontSize: 24.0,
          fontStyle: FontStyle.italic,
        ),
      );
      subtitleParagraphBuilder.addText('Hello, World!');

      final subtitleParagraph = subtitleParagraphBuilder.build();
      canvas.drawParagraph(subtitleParagraph, const Offset(100, 150));

      // Create multi-line text paragraph
      final multilineParagraphStyle = ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 18.0,
        fontWeight: FontWeight.normal,
      );

      final multilineParagraphBuilder = ParagraphBuilder(
        multilineParagraphStyle,
      );
      multilineParagraphBuilder.pushStyle(
        TextStyle(color: const Color.fromRGB(34, 139, 34), fontSize: 18.0),
      );
      multilineParagraphBuilder.addText(
        'これは複数行のテキストです。\n日本語と英語が混在しています。\nThis is a multi-line text example.',
      );

      final multilineParagraph = multilineParagraphBuilder.build();
      canvas.drawParagraph(multilineParagraph, const Offset(100, 220));

      // Create colored text with different sizes
      final coloredParagraphStyle = ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 20.0,
        fontWeight: FontWeight.normal,
      );

      final coloredParagraphBuilder = ParagraphBuilder(coloredParagraphStyle);

      // Red text
      coloredParagraphBuilder.pushStyle(
        TextStyle(
          color: const Color.fromRGB(255, 0, 0),
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      );
      coloredParagraphBuilder.addText('赤い文字');

      // Blue text
      coloredParagraphBuilder.pushStyle(
        TextStyle(
          color: const Color.fromRGB(0, 0, 255),
          fontSize: 24.0,
          fontWeight: FontWeight.normal,
        ),
      );
      coloredParagraphBuilder.addText(' 青い文字');

      // Green text
      coloredParagraphBuilder.pushStyle(
        TextStyle(
          color: const Color.fromRGB(0, 128, 0),
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
        ),
      );
      coloredParagraphBuilder.addText(' 緑の文字');

      final coloredParagraph = coloredParagraphBuilder.build();
      canvas.drawParagraph(coloredParagraph, const Offset(100, 350));

      // Add some decorative elements around the text
      final decorativePaint = Paint()
        ..color = const Color.fromRGB(255, 215, 0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      // Draw decorative border
      canvas.drawRect(
        Rect.fromLTWH(30, 30, width - 60, height - 60),
        decorativePaint,
      );

      // Draw decorative circles
      final circlePaint = Paint()
        ..color = const Color.fromARGB(100, 255, 192, 203)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(const Offset(150, 450), 30, circlePaint);
      canvas.drawCircle(const Offset(650, 450), 30, circlePaint);

      // Create Picture
      final picture = recorder.endRecording();

      // Convert to image
      final image = picture.toImage(width, height);
      expect(image, isNotNull);
      expect(image.width, width);
      expect(image.height, height);

      // Encode as PNG
      final pngData = image.toPng();
      expect(pngData, isNotNull);
      expect(pngData.isNotEmpty, isTrue);

      // Save to file
      try {
        final outputDir = Directory('test_output');
        if (!outputDir.existsSync()) {
          outputDir.createSync();
        }

        final file = File('test_output/text_test.png');
        file.writeAsBytesSync(pngData);

        print('PNG image saved to: ${file.absolute.path}');
        expect(file.existsSync(), isTrue);
      } catch (e) {
        print('Error saving image: $e');
      }
    });

    test('Can draw lines with different StrokeCap using Path and export as PNG',
        () {
      // 画像サイズ
      const int width = 400;
      const int height = 200;

      // PictureRecorderとCanvas作成
      final recorder = PictureRecorder();
      final canvas = recorder.canvas;

      // 背景を白で塗りつぶし
      final bgPaint = Paint()
        ..color = const Color.fromRGB(255, 255, 255)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        bgPaint,
      );

      // 直線1: StrokeCap.butt（赤）
      final paintButt = Paint()
        ..color = const Color.fromRGB(255, 0, 0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.butt;
      final pathButt = Path()
        ..moveTo(50, 40)
        ..lineTo(350, 40);
      canvas.drawPath(pathButt, paintButt);

      // 直線2: StrokeCap.round（緑）
      final paintRound = Paint()
        ..color = const Color.fromRGB(0, 200, 0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;
      final pathRound = Path()
        ..moveTo(50, 100)
        ..lineTo(350, 100);
      canvas.drawPath(pathRound, paintRound);

      // 直線3: StrokeCap.square（青）
      final paintSquare = Paint()
        ..color = const Color.fromRGB(0, 0, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.square;
      final pathSquare = Path()
        ..moveTo(50, 160)
        ..lineTo(350, 160);
      canvas.drawPath(pathSquare, paintSquare);

      // Picture作成
      final picture = recorder.endRecording();
      final image = picture.toImage(width, height);
      expect(image, isNotNull);
      expect(image.width, width);
      expect(image.height, height);

      // PNGエンコード
      final pngData = image.toPng();
      expect(pngData, isNotNull);
      expect(pngData.isNotEmpty, isTrue);

      // ファイル保存
      try {
        final outputDir = Directory('test_output');
        if (!outputDir.existsSync()) {
          outputDir.createSync();
        }
        final file = File('test_output/stroke_cap_test.png');
        file.writeAsBytesSync(pngData);
        print('PNG image saved to: [32m${file.absolute.path}[0m');
        expect(file.existsSync(), isTrue);
      } catch (e) {
        print('Error saving image: $e');
      }
    });
  });
}
