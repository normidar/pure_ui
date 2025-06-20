import 'package:pure_ui/pure_ui.dart';
import 'package:test/test.dart';

void main() {
  group('PictureRecorder', () {
    test('is recording in initial state', () {
      final recorder = PictureRecorder();
      expect(recorder.isRecording, true);
    });

    test('can access canvas', () {
      final recorder = PictureRecorder();
      expect(recorder.canvas, isA<Canvas>());
    });

    test('returns Picture on endRecording', () {
      final recorder = PictureRecorder();
      final picture = recorder.endRecording();
      expect(picture, isA<Picture>());
      expect(recorder.isRecording, false);
    });

    test('throws error when accessing canvas after endRecording', () {
      final recorder = PictureRecorder()..endRecording();
      expect(() => recorder.canvas, throwsException);
    });

    test('throws error when calling endRecording twice', () {
      final recorder = PictureRecorder()..endRecording();
      expect(recorder.endRecording, throwsException);
    });

    test('can save drawing operations to Picture', () {
      final recorder = PictureRecorder();
      final canvas = recorder.canvas;

      // Draw circle
      final paint = Paint()
        ..color = const Color.fromRGB(255, 0, 0)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(100, 100), 50, paint);

      final picture = recorder.endRecording();

      // Convert to image
      final image = picture.toImage(200, 200);
      expect(image, isA<Image>());
      expect(image.width, 200);
      expect(image.height, 200);
    });
  });
}
