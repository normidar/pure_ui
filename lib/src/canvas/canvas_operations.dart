part of 'canvas.dart';

/// A canvas operation.
class _CanvasOperation {
  final _OperationType _type;

  final Offset? _p1;

  final Offset? _p2;

  final Rect? _rect;

  final Rect? _rect2;

  final double? _radiusX;

  final double? _radiusY;

  final Paint? _paint;

  final Path? _path;

  final Image? _image;

  final Picture? _picture;

  final Paragraph? _paragraph;

  final Vertices? _vertices;

  final BlendMode? _blendMode;

  final Float64List? _matrix4;

  _CanvasOperation.clipPath(this._path)
      : _type = _OperationType.clipPath,
        _p1 = null,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _paint = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;

  _CanvasOperation.clipRect(this._rect)
      : _type = _OperationType.clipRect,
        _p1 = null,
        _p2 = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _paint = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;

  _CanvasOperation.drawCircle(this._p1, this._radiusX, this._paint)
      : _type = _OperationType.drawCircle,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusY = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawImage(this._image, this._p1, this._paint)
      : _type = _OperationType.drawImage,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _path = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawImageRect(
    this._image,
    this._rect,
    this._rect2,
    this._paint,
  )   : _type = _OperationType.drawImageRect,
        _p1 = null,
        _p2 = null,
        _radiusX = null,
        _radiusY = null,
        _path = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawLine(this._p1, this._p2, this._paint)
      : _type = _OperationType.drawLine,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawOval(this._rect, this._paint)
      : _type = _OperationType.drawOval,
        _p1 = null,
        _p2 = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawParagraph(this._paragraph, this._p1)
      : _type = _OperationType.drawParagraph,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _paint = null,
        _path = null,
        _image = null,
        _picture = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawPath(this._path, this._paint)
      : _type = _OperationType.drawPath,
        _p1 = null,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawPicture(this._picture)
      : _type = _OperationType.drawPicture,
        _p1 = null,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _paint = null,
        _path = null,
        _image = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawRect(this._rect, this._paint)
      : _type = _OperationType.drawRect,
        _p1 = null,
        _p2 = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawRRect(
    this._rect,
    this._radiusX,
    this._radiusY,
    this._paint,
  )   : _type = _OperationType.drawRRect,
        _p1 = null,
        _p2 = null,
        _rect2 = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.drawVertices(this._vertices, this._blendMode, this._paint)
      : _type = _OperationType.drawVertices,
        _p1 = null,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _matrix4 = null;
  _CanvasOperation.restore()
      : _type = _OperationType.restore,
        _p1 = null,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _paint = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.save()
      : _type = _OperationType.save,
        _p1 = null,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _paint = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.saveLayer(this._rect, this._paint)
      : _type = _OperationType.saveLayer,
        _p1 = null,
        _p2 = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null,
        _matrix4 = null;
  _CanvasOperation.transform(this._matrix4)
      : _type = _OperationType.transform,
        _p1 = null,
        _p2 = null,
        _rect = null,
        _rect2 = null,
        _radiusX = null,
        _radiusY = null,
        _paint = null,
        _path = null,
        _image = null,
        _picture = null,
        _paragraph = null,
        _vertices = null,
        _blendMode = null;

  /// Applies this operation to the given canvas.
  void apply(Canvas canvas) {
    switch (_type) {
      case _OperationType.save:
        canvas.save();
      case _OperationType.restore:
        canvas.restore();
      case _OperationType.drawLine:
        canvas.drawLine(_p1!, _p2!, _paint!);
      case _OperationType.drawRect:
        canvas.drawRect(_rect!, _paint!);
      case _OperationType.drawRRect:
        canvas.drawRRect(_rect!, _radiusX!, _radiusY!, _paint!);
      case _OperationType.drawCircle:
        canvas.drawCircle(_p1!, _radiusX!, _paint!);
      case _OperationType.drawOval:
        canvas.drawOval(_rect!, _paint!);
      case _OperationType.drawPath:
        canvas.drawPath(_path!, _paint!);
      case _OperationType.drawImage:
        canvas.drawImage(_image!, _p1!, _paint!);
      case _OperationType.drawImageRect:
        canvas.drawImageRect(_image!, _rect!, _rect2!, _paint!);
      case _OperationType.drawPicture:
        canvas.drawPicture(_picture!);
      case _OperationType.drawVertices:
        canvas.drawVertices(_vertices!, _blendMode!, _paint!);
      case _OperationType.drawParagraph:
        canvas.drawParagraph(_paragraph!, _p1!);
      case _OperationType.transform:
        canvas.transform(_matrix4!);
      case _OperationType.saveLayer:
        canvas.saveLayer(_rect, _paint!);
      case _OperationType.clipPath:
        canvas.clipPath(_path!);
      case _OperationType.clipRect:
        canvas.clipRect(_rect!);
    }
  }
}

/// The type of canvas operation.
enum _OperationType {
  save,
  restore,
  drawLine,
  drawRect,
  drawRRect,
  drawCircle,
  drawOval,
  drawPath,
  drawImage,
  drawImageRect,
  drawPicture,
  drawVertices,
  drawParagraph,
  transform,
  saveLayer,
  clipPath,
  clipRect,
}
