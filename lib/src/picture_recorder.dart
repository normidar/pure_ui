import 'package:pure_ui/src/canvas/canvas.dart';
import 'package:pure_ui/src/picture.dart';

/// A recorder for graphical operations.
///
/// [PictureRecorder] objects are used to record graphical operations for later
/// playback. To begin recording, construct a [Canvas] to record the drawing
/// commands. When endRecording() is called, the resulting [Picture] can be used
/// to playback the drawing operations or to convert to an image.
///
/// This class is designed to be API-compatible with dart:ui's PictureRecorder.
class PictureRecorder {
  /// Creates a new PictureRecorder for recording canvas operations.
  PictureRecorder()
      : _picture = Picture(),
        _isRecording = true {
    _canvas = Canvas(this);
  }

  final Picture _picture;
  bool _isRecording;
  late final Canvas _canvas;

  /// The canvas that records drawing operations.
  ///
  /// Throws an exception if recording has ended.
  Canvas get canvas {
    if (!_isRecording) {
      throw Exception('PictureRecorder is not recording');
    }
    return _canvas;
  }

  /// Whether this recorder is currently recording.
  ///
  /// Becomes false after [endRecording] is called.
  bool get isRecording => _isRecording;

  /// Finishes recording canvas draw operations and returns a picture.
  ///
  /// After calling this method, both this recorder and any canvas objects
  /// vended by [canvas] should no longer be used.
  Picture endRecording() {
    if (!_isRecording) {
      throw Exception('PictureRecorder is not recording');
    }
    _isRecording = false;
    _picture.endRecording();
    return _picture;
  }

  /// Sets the canvas for this recorder's picture.
  void setCanvasForPicture(Canvas canvas) {
    _picture.setCanvas(canvas);
  }
}
