import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pure_ui/src/color.dart';
import 'package:pure_ui/src/enums.dart';
import 'package:pure_ui/src/image.dart';
import 'package:pure_ui/src/offset.dart';
import 'package:pure_ui/src/paint.dart';
import 'package:pure_ui/src/painting/gradient.dart';
import 'package:pure_ui/src/painting/tile_mode.dart';
import 'package:pure_ui/src/path.dart';
import 'package:pure_ui/src/picture.dart';
import 'package:pure_ui/src/picture_recorder.dart';
import 'package:pure_ui/src/rect.dart';
import 'package:pure_ui/src/text/paragraph/paragraph_builder.dart';
import 'package:pure_ui/src/vertices/vertices.dart';

part 'canvas_operations.dart';
part 'drawing_methods.dart';
part 'geometry_utils.dart';
part 'gradient_utils.dart';
part 'rendering_implementations.dart';
part 'text_rendering.dart';

/// A canvas on which to draw.
///
/// This pure implementation mirrors the Flutter Canvas API
/// without dependencies on Flutter.
class Canvas {
  final Image? _image;

  final List<_CanvasOperation> _operations;

  final bool _isRecording;

  /// Creates a canvas for the given [PictureRecorder].
  ///
  /// The [PictureRecorder] will record the drawing operations
  /// performed on this canvas.
  Canvas(PictureRecorder recorder)
      : _image = null,
        _operations = [],
        _isRecording = true {
    // Set this canvas to the recorder's picture
    recorder.setCanvasForPicture(this);
  }

  /// Creates a canvas for the given image.
  Canvas.forImage(Image image)
      : _image = image,
        _operations = [],
        _isRecording = false;

  /// Creates a canvas for recording operations only.
  Canvas.forRecording()
      : _image = Image(1, 1),
        _operations = [],
        _isRecording = true;

  /// Replays recorded operations onto another canvas.
  void replayOnto(Canvas canvas) {
    for (final op in _operations) {
      op.apply(canvas);
    }
  }

  /// Records an operation.
  void _addOperation(_CanvasOperation operation) {
    _operations.add(operation);
  }

  img.BlendMode _blendModeToImgBlend(BlendMode mode) {
    return img.BlendMode.values.first;
  }
}
