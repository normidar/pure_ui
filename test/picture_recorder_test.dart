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
  });
}
