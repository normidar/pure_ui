import 'dart:io';

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

void main() {
  group('PictureRecorder', () {
    test('is recording in initial state', () {
      final recorder = ui.PictureRecorder();
      expect(recorder.isRecording, true);
    });

    test('returns Picture on endRecording', () {
      final recorder = ui.PictureRecorder();
      final picture = recorder.endRecording();
      expect(picture, isA<ui.Picture>());
      expect(recorder.isRecording, false);
    });

    test('throws error when calling endRecording twice', () {
      final recorder = ui.PictureRecorder()..endRecording();
      expect(recorder.endRecording, throwsException);
    });

    test('can save drawing operations to Picture', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      // Draw circle
      final paint = ui.Paint()
        ..color = const ui.Color.fromRGBO(255, 0, 0, 1.0)
        ..style = ui.PaintingStyle.fill;
      canvas.drawCircle(const ui.Offset(100, 100), 50, paint);

      final picture = recorder.endRecording();

      // Convert to image
      final image = await picture.toImage(200, 200);
      expect(image, isA<ui.Image>());
      expect(image.width, 200);
      expect(image.height, 200);
    });

    test('can save drawing operations to Picture and draw it', () async {
      // 1. Recorderを作成
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      // 2. 描画する
      final paint = ui.Paint()..color = const ui.Color(0xFF4285F4);
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 200, 100), paint);

      // 3. Picture → Image に変換
      final picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(200, 200);

      // 4. Image を PNG (ByteData) に変換
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // 5. ファイル保存
      final file = File('canvas_output.png');
      await file.writeAsBytes(buffer);

      print("保存完了: ${file.path}");
    });
  });
}
