import 'package:pure_ui/src/canvas.dart';
import 'package:pure_ui/src/image.dart';
import 'package:pure_ui/src/paint.dart';
import 'package:pure_ui/src/rect.dart';
import 'package:pure_ui/src/color.dart';

/// A picture consisting of a sequence of canvas operations.
class Picture {
  /// Creates a new picture that will record canvas operations.
  Picture() : _isRecording = true;

  bool _isRecording;
  Canvas? _canvas;

  /// Returns true if the picture is still recording.
  bool get isRecording => _isRecording;

  /// Stops recording canvas operations.
  void endRecording() {
    _isRecording = false;
  }

  /// Draws this picture into the given canvas.
  void playback(Canvas canvas) {
    if (_isRecording) {
      throw Exception('Cannot playback a picture that is still recording');
    }
    if (_canvas == null) {
      throw Exception('No canvas was set for this picture');
    }
    _canvas!.replayOnto(canvas);
  }

  /// Sets the canvas for this picture.
  void setCanvas(Canvas canvas) {
    _canvas = canvas;
  }

  /// Creates an image from this picture.
  Image toImage(int width, int height) {
    if (_isRecording) {
      throw Exception(
        'Cannot convert a picture to an image while it is still recording',
      );
    }

    // Create a new image with the specified dimensions
    final image = Image(width, height);

    // Fill with white background to ensure visibility
    final clearCanvas = Canvas.forImage(image);
    final clearPaint = Paint()
      ..color = Color.fromRGBA(255, 255, 255, 255) // White background
      ..style = PaintingStyle.fill;
    clearCanvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      clearPaint,
    );

    // Draw the picture onto the image
    final canvas = Canvas.forImage(image);
    playback(canvas);

    return image;
  }

  /// Creates an image from this picture synchronously.
  ///
  /// This is the same as [toImage] but synchronous.
  Image toImageSync(int width, int height) {
    return toImage(width, height);
  }

  void dispose() {}
}
