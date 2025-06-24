part of 'canvas.dart';

extension CanvasDrawingMethods on Canvas {
  /// Clips to the intersection of the current clip and the given path.
  void clipPath(Path path) {
    _addOperation(_CanvasOperation.clipPath(path));

    if (!_isRecording && _image != null) {
      _renderClipPath(path);
    }
  }

  /// Clips to the intersection of the current clip and the given rectangle.
  void clipRect(Rect rect) {
    _addOperation(_CanvasOperation.clipRect(rect));

    if (!_isRecording && _image != null) {
      _renderClipRect(rect);
    }
  }

  /// Draws a circle centered at (x,y) with the given radius.
  void drawCircle(Offset center, double radius, Paint paint) {
    _addOperation(_CanvasOperation.drawCircle(center, radius, paint));

    if (!_isRecording && _image != null) {
      _renderCircle(center, radius, paint);
    }
  }

  /// Draws the given image at the given offset.
  void drawImage(Image image, Offset offset, Paint paint) {
    _addOperation(_CanvasOperation.drawImage(image, offset, paint));

    if (!_isRecording && _image != null) {
      _renderImage(image, offset, paint);
    }
  }

  /// Draws the given image into the given rectangle.
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {
    _addOperation(_CanvasOperation.drawImageRect(image, src, dst, paint));

    if (!_isRecording && _image != null) {
      _renderImageRect(image, src, dst, paint);
    }
  }

  /// Draws a line from (x1,y1) to (x2,y2).
  void drawLine(Offset p1, Offset p2, Paint paint) {
    _addOperation(_CanvasOperation.drawLine(p1, p2, paint));

    if (!_isRecording && _image != null) {
      _renderLine(p1, p2, paint);
    }
  }

  /// Draws an oval inside the given rectangle.
  void drawOval(Rect rect, Paint paint) {
    _addOperation(_CanvasOperation.drawOval(rect, paint));

    if (!_isRecording && _image != null) {
      _renderOval(rect, paint);
    }
  }

  /// Draws the given paragraph at the given offset.
  void drawParagraph(Paragraph paragraph, Offset offset) {
    _addOperation(_CanvasOperation.drawParagraph(paragraph, offset));

    if (!_isRecording && _image != null) {
      _renderParagraph(paragraph, offset);
    }
  }

  /// Draws the given path.
  void drawPath(Path path, Paint paint) {
    _addOperation(_CanvasOperation.drawPath(path, paint));

    if (!_isRecording && _image != null) {
      _renderPath(path, paint);
    }
  }

  /// Draws the given picture onto the canvas.
  void drawPicture(Picture picture) {
    _addOperation(_CanvasOperation.drawPicture(picture));

    if (!_isRecording && _image != null) {
      _renderPicture(picture);
    }
  }

  /// Draws a rectangle.
  void drawRect(Rect rect, Paint paint) {
    _addOperation(_CanvasOperation.drawRect(rect, paint));

    if (!_isRecording && _image != null) {
      _renderRect(rect, paint);
    }
  }

  /// Draws a rounded rectangle.
  void drawRRect(Rect rect, double radiusX, double radiusY, Paint paint) {
    _addOperation(_CanvasOperation.drawRRect(rect, radiusX, radiusY, paint));

    if (!_isRecording && _image != null) {
      _renderRRect(rect, radiusX, radiusY, paint);
    }
  }

  /// Draws the given vertices with the given paint.
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    _addOperation(_CanvasOperation.drawVertices(vertices, blendMode, paint));

    if (!_isRecording && _image != null) {
      _renderVertices(vertices, blendMode, paint);
    }
  }

  /// Restores the most recently saved state.
  void restore() {
    _addOperation(_CanvasOperation.restore());
    if (!_isRecording && _image != null) {
      // Implement restore state in a real rendering context
    }
  }

  /// Saves the current state of the canvas.
  void save() {
    _addOperation(_CanvasOperation.save());
    if (!_isRecording && _image != null) {
      // Implement save state in a real rendering context
    }
  }

  /// Saves the current state of the canvas to a save stack and applies
  /// the given paint as a clipping rectangle.
  void saveLayer(Rect? bounds, Paint paint) {
    _addOperation(_CanvasOperation.saveLayer(bounds, paint));

    if (!_isRecording && _image != null) {
      _renderSaveLayer(bounds, paint);
    }
  }

  /// Transforms the canvas by the given matrix.
  void transform(Float64List matrix4) {
    _addOperation(_CanvasOperation.transform(matrix4));

    if (!_isRecording && _image != null) {
      _renderTransform(matrix4);
    }
  }
}
