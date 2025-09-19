// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of dart.ui;

class _DrawCommand {
  final _DrawCommandType type;
  final List<dynamic> args;

  _DrawCommand(this.type, this.args);
}

/// Pure Dart implementation to replace @Native function calls
/// This provides a software-based implementation of dart:ui functionality

// Drawing command types for recording canvas operations
enum _DrawCommandType {
  save,
  restore,
  translate,
  scale,
  rotate,
  transform,
  clipRect,
  clipPath,
  drawColor,
  drawRect,
  drawOval,
  drawCircle,
  drawPath,
  drawLine,
  drawPoints,
  drawPaint,
  drawImage,
  drawImageRect,
  drawParagraph,
  drawVertices,
  drawShadow,
  drawPicture,
  drawAtlas,
  drawRawAtlas,
}

class _PathCommand {
  final _PathCommandType type;
  final List<dynamic> args;
  _PathCommand(this.type, this.args);
}

enum _PathCommandType {
  setFillType,
  moveTo,
  relativeMoveTo,
  lineTo,
  relativeLineTo,
  quadraticBezierTo,
  relativeQuadraticBezierTo,
  cubicTo,
  relativeCubicTo,
  conicTo,
  relativeConicTo,
  arcTo,
  arcToPoint,
  relativeArcToPoint,
  addRect,
  addOval,
  addArc,
  addPolygon,
  addRRect,
  addPath,
  extendWithPath,
  close,
  shift,
  transform,
  addRSuperellipse,
}

/// Pure Dart implementation of Canvas
class _PureDartCanvas implements Canvas {
  final List<_DrawCommand> _commands = [];
  final List<Matrix4> _transformStack = [Matrix4.identity()];
  final List<Rect> _clipStack = [];
  _PureDartPictureRecorder? _recorder;
  final Rect _cullRect;

  _PureDartCanvas(PictureRecorder recorder, [Rect? cullRect])
      : _recorder = recorder as _PureDartPictureRecorder,
        _cullRect = cullRect ?? Rect.largest {
    if (_recorder!._canvas != null) {
      throw ArgumentError(
          '"recorder" must not already be associated with another Canvas.');
    }
    _recorder!._canvas = this;
  }

  Matrix4 get _currentTransform => _transformStack.last;

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {
    _commands.add(_DrawCommand(_DrawCommandType.clipPath, [path, doAntiAlias]));
    // For simplicity, use path bounds as clip rect
    clipRect(path.getBounds(), doAntiAlias: doAntiAlias);
  }

  @override
  void clipRect(Rect rect,
      {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true}) {
    _commands.add(
        _DrawCommand(_DrawCommandType.clipRect, [rect, clipOp, doAntiAlias]));
    // Simple clipping - just track the rect
    if (clipOp == ClipOp.intersect) {
      if (_clipStack.isEmpty) {
        _clipStack.add(rect);
      } else {
        _clipStack.add(_clipStack.last.intersect(rect));
      }
    }
  }

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {
    // Convert RRect to Rect for simple clipping
    clipRect(rrect.outerRect, doAntiAlias: doAntiAlias);
  }

  @override
  void clipRSuperellipse(RSuperellipse rsuperellipse,
      {bool doAntiAlias = true}) {
    // For simplicity, convert RSuperellipse to Rect
    clipRect(rsuperellipse.outerRect, doAntiAlias: doAntiAlias);
  }

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {
    // For simplicity, draw as oval
    drawOval(rect, paint);
  }

  @override
  void drawAtlas(Image atlas, List<RSTransform> transforms, List<Rect> rects,
      List<Color>? colors, BlendMode? blendMode, Rect? cullRect, Paint paint) {
    _commands.add(_DrawCommand(_DrawCommandType.drawAtlas,
        [atlas, transforms, rects, colors, blendMode, cullRect, paint]));
  }

  @override
  void drawCircle(Offset center, double radius, Paint paint) {
    _commands.add(
        _DrawCommand(_DrawCommandType.drawCircle, [center, radius, paint]));
  }

  @override
  void drawColor(Color color, BlendMode blendMode) {
    _commands.add(_DrawCommand(_DrawCommandType.drawColor, [color, blendMode]));
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    // For simplicity, just draw outer
    drawRRect(outer, paint);
  }

  @override
  void drawImage(Image image, Offset offset, Paint paint) {
    _commands
        .add(_DrawCommand(_DrawCommandType.drawImage, [image, offset, paint]));
  }

  @override
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {
    // For simplicity, draw as image rect
    drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        dst,
        paint);
  }

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {
    _commands.add(
        _DrawCommand(_DrawCommandType.drawImageRect, [image, src, dst, paint]));
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    _commands.add(_DrawCommand(_DrawCommandType.drawLine, [p1, p2, paint]));
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    _commands.add(_DrawCommand(_DrawCommandType.drawOval, [rect, paint]));
  }

  @override
  void drawPaint(Paint paint) {
    _commands.add(_DrawCommand(_DrawCommandType.drawPaint, [paint]));
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    _commands
        .add(_DrawCommand(_DrawCommandType.drawParagraph, [paragraph, offset]));
  }

  @override
  void drawPath(Path path, Paint paint) {
    _commands.add(_DrawCommand(_DrawCommandType.drawPath, [path, paint]));
  }

  @override
  void drawPicture(Picture picture) {
    _commands.add(_DrawCommand(_DrawCommandType.drawPicture, [picture]));
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    _commands.add(
        _DrawCommand(_DrawCommandType.drawPoints, [pointMode, points, paint]));
  }

  @override
  void drawRawAtlas(Image atlas, Float32List rstTransforms, Float32List rects,
      Int32List? colors, BlendMode? blendMode, Rect? cullRect, Paint paint) {
    _commands.add(_DrawCommand(_DrawCommandType.drawRawAtlas,
        [atlas, rstTransforms, rects, colors, blendMode, cullRect, paint]));
  }

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    // Convert Float32List to List<Offset>
    final offsetPoints = <Offset>[];
    for (int i = 0; i < points.length; i += 2) {
      offsetPoints.add(Offset(points[i], points[i + 1]));
    }
    drawPoints(pointMode, offsetPoints, paint);
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    _commands.add(_DrawCommand(_DrawCommandType.drawRect, [rect, paint]));
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    // For simplicity, draw as rectangle
    drawRect(rrect.outerRect, paint);
  }

  @override
  void drawRSuperellipse(RSuperellipse rsuperellipse, Paint paint) {
    // For simplicity, draw as rectangle
    drawRect(rsuperellipse.outerRect, paint);
  }

  @override
  void drawShadow(
      Path path, Color color, double elevation, bool transparentOccluder) {
    _commands.add(_DrawCommand(_DrawCommandType.drawShadow,
        [path, color, elevation, transparentOccluder]));
  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    _commands.add(_DrawCommand(
        _DrawCommandType.drawVertices, [vertices, blendMode, paint]));
  }

  @override
  Rect getDestinationClipBounds() {
    final local = getLocalClipBounds();
    // Transform the local bounds to destination space
    return _transformRect(local, _currentTransform);
  }

  @override
  Rect getLocalClipBounds() {
    if (_clipStack.isEmpty) return _cullRect;
    return _clipStack.last;
  }

  @override
  int getSaveCount() => _transformStack.length;

  @override
  Float64List getTransform() {
    return _currentTransform.storage;
  }

  @override
  void restore() {
    _commands.add(_DrawCommand(_DrawCommandType.restore, []));
    if (_transformStack.length > 1) {
      _transformStack.removeLast();
    }
    if (_clipStack.isNotEmpty) {
      _clipStack.removeLast();
    }
  }

  @override
  void restoreToCount(int count) {
    while (_transformStack.length > count && _transformStack.length > 1) {
      restore();
    }
  }

  @override
  void rotate(double radians) {
    _commands.add(_DrawCommand(_DrawCommandType.rotate, [radians]));
    _currentTransform.rotateZ(radians);
  }

  @override
  void save() {
    _commands.add(_DrawCommand(_DrawCommandType.save, []));
    _transformStack.add(_currentTransform.clone());
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    // Simple implementation - just save for now
    save();
  }

  @override
  void scale(double sx, [double? sy]) {
    sy ??= sx;
    _commands.add(_DrawCommand(_DrawCommandType.scale, [sx, sy]));
    _currentTransform.scaleByVector3(Vector3(sx, sy, 1.0));
  }

  @override
  void skew(double sx, double sy) {
    // Implement skew transformation
    final skewMatrix = Matrix4.identity();
    skewMatrix.setEntry(0, 1, math.tan(sx));
    skewMatrix.setEntry(1, 0, math.tan(sy));
    _currentTransform.multiply(skewMatrix);
  }

  @override
  void transform(Float64List matrix4) {
    _commands.add(_DrawCommand(_DrawCommandType.transform, [matrix4]));
    final transform = Matrix4.fromFloat64List(matrix4);
    _currentTransform.multiply(transform);
  }

  @override
  void translate(double dx, double dy) {
    _commands.add(_DrawCommand(_DrawCommandType.translate, [dx, dy]));
    _currentTransform.translateByVector3(Vector3(dx, dy, 0.0));
  }

  Rect _transformRect(Rect rect, Matrix4 transform) {
    // Simple transform - just apply to corners
    final topLeft = transform.transform3(Vector3(rect.left, rect.top, 0));
    final bottomRight =
        transform.transform3(Vector3(rect.right, rect.bottom, 0));
    return Rect.fromLTRB(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y);
  }
}

/// Pure Dart implementation of Image
class _PureDartImage implements Image {
  final Uint8List _pixels;
  final int _width;
  final int _height;
  bool _disposed = false;

  // Required fields for Image interface compatibility
  @override
  late final _Image _image = _Image._();

  @override
  StackTrace? _debugStack;

  _PureDartImage(this._pixels, this._width, this._height);

  @override
  ColorSpace get colorSpace => ColorSpace.sRGB;

  @override
  bool get debugDisposed => _disposed;

  @override
  int get height => _height;

  @override
  int get width => _width;

  @override
  Image clone() => _PureDartImage(Uint8List.fromList(_pixels), _width, _height);

  @override
  List<StackTrace>? debugGetOpenHandleStackTraces() => null;

  @override
  void dispose() {
    _disposed = true;
    Image.onDispose?.call(this);
  }

  Color getPixel(int x, int y) {
    if (_disposed) throw StateError('Image is disposed');
    if (x < 0 || x >= _width || y < 0 || y >= _height) {
      throw RangeError('Pixel coordinates ($x, $y) are out of bounds');
    }

    final pixelIndex = (y * _width + x) * 4;
    final r = _pixels[pixelIndex];
    final g = _pixels[pixelIndex + 1];
    final b = _pixels[pixelIndex + 2];
    final a = _pixels[pixelIndex + 3];

    return Color.fromARGB(a, r, g, b);
  }

  @override
  bool isCloneOf(Image other) {
    return other is _PureDartImage &&
        other._width == _width &&
        other._height == _height;
  }

  @override
  Future<ByteData?> toByteData(
      {ImageByteFormat format = ImageByteFormat.rawRgba}) async {
    if (_disposed) return null;

    switch (format) {
      case ImageByteFormat.rawRgba:
        return ByteData.sublistView(_pixels);
      case ImageByteFormat.rawUnmodified:
      case ImageByteFormat.rawStraightRgba:
      case ImageByteFormat.rawExtendedRgba128:
        // For simplicity, return RGBA data
        return ByteData.sublistView(_pixels);
      case ImageByteFormat.png:
        return _encodeToPng();
    }
  }

  ByteData? toByteDataSync({ImageByteFormat format = ImageByteFormat.rawRgba}) {
    if (_disposed) return null;
    return ByteData.sublistView(_pixels);
  }

  Future<ByteData?> _encodeToPng() async {
    // Convert RGBA pixel data to PNG using the image package
    final image = img.Image(width: _width, height: _height);

    // Convert our RGBA data to the image package format
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        final pixelIndex = (y * _width + x) * 4;
        final r = _pixels[pixelIndex];
        final g = _pixels[pixelIndex + 1];
        final b = _pixels[pixelIndex + 2];
        final a = _pixels[pixelIndex + 3];

        // Set pixel in the image package format
        image.setPixelRgba(x, y, r, g, b, a);
      }
    }

    // Encode to PNG
    final pngBytes = img.encodePng(image);
    return ByteData.sublistView(Uint8List.fromList(pngBytes));
  }

  /// Factory method to create a PureDartImage from pixel data
  static _PureDartImage fromPixels(Uint8List pixels, int width, int height) {
    return _PureDartImage(pixels, width, height);
  }
}

/// Pure Dart implementation of Path
class _PureDartPath implements Path {
  final List<_PathCommand> _commands = [];

  _PureDartPath();

  @override
  PathFillType get fillType => PathFillType.nonZero;

  @override
  set fillType(PathFillType value) {
    _commands.add(_PathCommand(_PathCommandType.setFillType, [value]));
  }

  @override
  void addArc(Rect oval, double startAngle, double sweepAngle) {
    _commands.add(
        _PathCommand(_PathCommandType.addArc, [oval, startAngle, sweepAngle]));
  }

  @override
  void addOval(Rect oval) {
    _commands.add(_PathCommand(_PathCommandType.addOval, [oval]));
  }

  @override
  void addPath(Path path, Offset offset, {Float64List? matrix4}) {
    _commands
        .add(_PathCommand(_PathCommandType.addPath, [path, offset, matrix4]));
  }

  @override
  void addPolygon(List<Offset> points, bool close) {
    _commands.add(_PathCommand(_PathCommandType.addPolygon, [points, close]));
  }

  @override
  void addRect(Rect rect) {
    _commands.add(_PathCommand(_PathCommandType.addRect, [rect]));
  }

  @override
  void addRRect(RRect rrect) {
    _commands.add(_PathCommand(_PathCommandType.addRRect, [rrect]));
  }

  @override
  void addRSuperellipse(RSuperellipse rsuperellipse) {
    _commands
        .add(_PathCommand(_PathCommandType.addRSuperellipse, [rsuperellipse]));
  }

  @override
  void arcTo(
      Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    _commands.add(_PathCommand(
        _PathCommandType.arcTo, [rect, startAngle, sweepAngle, forceMoveTo]));
  }

  @override
  void arcToPoint(Offset arcEnd,
      {Radius radius = Radius.zero,
      double rotation = 0.0,
      bool largeArc = false,
      bool clockwise = true}) {
    _commands.add(_PathCommand(_PathCommandType.arcToPoint,
        [arcEnd, radius, rotation, largeArc, clockwise]));
  }

  @override
  void close() {
    _commands.add(_PathCommand(_PathCommandType.close, []));
  }

  @override
  PathMetrics computeMetrics({bool forceClosed = false}) {
    // Create a simple PathMetrics that returns empty for now
    return PathMetrics._(this, forceClosed);
  }

  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) {
    _commands.add(_PathCommand(_PathCommandType.conicTo, [x1, y1, x2, y2, w]));
  }

  @override
  bool contains(Offset point) {
    final bounds = getBounds();
    return bounds.contains(point);
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _commands
        .add(_PathCommand(_PathCommandType.cubicTo, [x1, y1, x2, y2, x3, y3]));
  }

  @override
  void extendWithPath(Path path, Offset offset, {Float64List? matrix4}) {
    _commands.add(
        _PathCommand(_PathCommandType.extendWithPath, [path, offset, matrix4]));
  }

  @override
  Rect getBounds() {
    double minX = 0, minY = 0, maxX = 0, maxY = 0;
    bool hasPoints = false;

    for (final command in _commands) {
      switch (command.type) {
        case _PathCommandType.moveTo:
        case _PathCommandType.lineTo:
          final x = command.args[0] as double;
          final y = command.args[1] as double;
          if (!hasPoints) {
            minX = maxX = x;
            minY = maxY = y;
            hasPoints = true;
          } else {
            minX = math.min(minX, x);
            maxX = math.max(maxX, x);
            minY = math.min(minY, y);
            maxY = math.max(maxY, y);
          }
          break;
        case _PathCommandType.addRect:
          final rect = command.args[0] as Rect;
          if (!hasPoints) {
            minX = rect.left;
            maxX = rect.right;
            minY = rect.top;
            maxY = rect.bottom;
            hasPoints = true;
          } else {
            minX = math.min(minX, rect.left);
            maxX = math.max(maxX, rect.right);
            minY = math.min(minY, rect.top);
            maxY = math.max(maxY, rect.bottom);
          }
          break;
        default:
          break;
      }
    }

    return hasPoints ? Rect.fromLTRB(minX, minY, maxX, maxY) : Rect.zero;
  }

  @override
  void lineTo(double x, double y) {
    _commands.add(_PathCommand(_PathCommandType.lineTo, [x, y]));
  }

  @override
  void moveTo(double x, double y) {
    _commands.add(_PathCommand(_PathCommandType.moveTo, [x, y]));
  }

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _commands.add(
        _PathCommand(_PathCommandType.quadraticBezierTo, [x1, y1, x2, y2]));
  }

  @override
  void relativeArcToPoint(Offset arcEndDelta,
      {Radius radius = Radius.zero,
      double rotation = 0.0,
      bool largeArc = false,
      bool clockwise = true}) {
    _commands.add(_PathCommand(_PathCommandType.relativeArcToPoint,
        [arcEndDelta, radius, rotation, largeArc, clockwise]));
  }

  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    _commands.add(
        _PathCommand(_PathCommandType.relativeConicTo, [x1, y1, x2, y2, w]));
  }

  @override
  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _commands.add(_PathCommand(
        _PathCommandType.relativeCubicTo, [x1, y1, x2, y2, x3, y3]));
  }

  @override
  void relativeLineTo(double dx, double dy) {
    _commands.add(_PathCommand(_PathCommandType.relativeLineTo, [dx, dy]));
  }

  @override
  void relativeMoveTo(double dx, double dy) {
    _commands.add(_PathCommand(_PathCommandType.relativeMoveTo, [dx, dy]));
  }

  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    _commands.add(_PathCommand(
        _PathCommandType.relativeQuadraticBezierTo, [x1, y1, x2, y2]));
  }

  @override
  void reset() {
    _commands.clear();
  }

  @override
  Path shift(Offset offset) {
    final newPath = _PureDartPath();
    newPath._commands.addAll(_commands);
    newPath._commands.add(_PathCommand(_PathCommandType.shift, [offset]));
    return newPath;
  }

  @override
  Path transform(Float64List matrix4) {
    final newPath = _PureDartPath();
    newPath._commands.addAll(_commands);
    newPath._commands.add(_PathCommand(_PathCommandType.transform, [matrix4]));
    return newPath;
  }
}

/// Pure Dart implementation of Picture
class _PureDartPicture implements Picture {
  final List<_DrawCommand> _commands;
  bool _disposed = false;

  _PureDartPicture(this._commands, Rect _cullRect);

  @override
  int get approximateBytesUsed => _commands.length * 100; // Rough estimate

  @override
  bool get debugDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    Picture.onDispose?.call(this);
  }

  @override
  Future<Image> toImage(int width, int height) async {
    if (_disposed) throw StateError('Picture has been disposed');
    if (width <= 0 || height <= 0) {
      throw Exception('Invalid image dimensions.');
    }

    // Create a bitmap representation
    final pixels = _rasterize(width, height);
    return _PureDartImage(pixels, width, height);
  }

  @override
  Image toImageSync(int width, int height) {
    if (_disposed) throw StateError('Picture has been disposed');
    if (width <= 0 || height <= 0) {
      throw Exception('Invalid image dimensions.');
    }

    final pixels = _rasterize(width, height);
    return _PureDartImage(pixels, width, height);
  }

  void _drawAtlasToPixels(
      Image atlas,
      List<RSTransform> transforms,
      List<Rect> rects,
      List<Color>? colors,
      BlendMode? blendMode,
      Rect? cullRect,
      Paint paint,
      Uint8List pixels,
      int width,
      int height) {
    if (atlas is! _PureDartImage) return;

    final atlasPixels = atlas._pixels;
    final atlasWidth = atlas._width;
    final atlasHeight = atlas._height;

    // Draw each sprite from the atlas
    for (int i = 0; i < math.min(transforms.length, rects.length); i++) {
      final transform = transforms[i];
      final srcRect = rects[i];
      final color = colors != null && i < colors.length ? colors[i] : null;

      // Skip if source rect is outside atlas bounds
      if (srcRect.left < 0 ||
          srcRect.top < 0 ||
          srcRect.right > atlasWidth ||
          srcRect.bottom > atlasHeight) continue;

      // RSTransform contains: scos, ssin, tx, ty
      // where scos = cos(rotation) * scale, ssin = sin(rotation) * scale
      final scos = transform.scos;
      final ssin = transform.ssin;
      final tx = transform.tx;
      final ty = transform.ty;

      // Calculate destination bounds using scale factor from scos/ssin
      final scale = math.sqrt(scos * scos + ssin * ssin);
      final srcWidth = srcRect.width.round();
      final srcHeight = srcRect.height.round();
      final dstWidth = (srcWidth * scale).round();
      final dstHeight = (srcHeight * scale).round();

      // Draw the sprite
      for (int dy = -dstHeight ~/ 2; dy < dstHeight ~/ 2; dy++) {
        for (int dx = -dstWidth ~/ 2; dx < dstWidth ~/ 2; dx++) {
          // Apply transform using RSTransform matrix
          // The actual coordinate after transformation
          final transformedX = (dx * scos - dy * ssin + tx).round();
          final transformedY = (dx * ssin + dy * scos + ty).round();

          // Check bounds
          if (transformedX < 0 ||
              transformedX >= width ||
              transformedY < 0 ||
              transformedY >= height) continue;

          // Map back to source coordinates
          // dx and dy range from -dstWidth/2 to +dstWidth/2, we need to map to srcRect
          final normalizedX = (dx + dstWidth ~/ 2) / dstWidth; // 0 to 1
          final normalizedY = (dy + dstHeight ~/ 2) / dstHeight; // 0 to 1
          final srcX = (srcRect.left + normalizedX * srcRect.width).round();
          final srcY = (srcRect.top + normalizedY * srcRect.height).round();

          if (srcX >= srcRect.left &&
              srcX < srcRect.right &&
              srcY >= srcRect.top &&
              srcY < srcRect.bottom) {
            final srcIndex = (srcY * atlasWidth + srcX) * 4;
            final dstIndex = (transformedY * width + transformedX) * 4;

            if (srcIndex >= 0 &&
                srcIndex < atlasPixels.length - 3 &&
                dstIndex >= 0 &&
                dstIndex < pixels.length - 3) {
              int r = atlasPixels[srcIndex];
              int g = atlasPixels[srcIndex + 1];
              int b = atlasPixels[srcIndex + 2];
              int a = atlasPixels[srcIndex + 3];

              // Apply color tint if provided
              if (color != null) {
                r = ((r * color.r) * 255).round() & 0xff;
                g = ((g * color.g) * 255).round() & 0xff;
                b = ((b * color.b) * 255).round() & 0xff;
                a = ((a * color.a) * 255).round() & 0xff;
              }

              // Simple alpha blending
              if (a > 0) {
                pixels[dstIndex] = r;
                pixels[dstIndex + 1] = g;
                pixels[dstIndex + 2] = b;
                pixels[dstIndex + 3] = a;
              }
            }
          }
        }
      }
    }
  }

  void _drawCircleAt(int centerX, int centerY, int radius, Uint8List pixels,
      int width, int height, int r, int g, int b, int a) {
    final radiusSquared = radius * radius;

    for (int y = centerY - radius; y <= centerY + radius; y++) {
      for (int x = centerX - radius; x <= centerX + radius; x++) {
        if (x >= 0 && x < width && y >= 0 && y < height) {
          final dx = x - centerX;
          final dy = y - centerY;
          final distanceSquared = dx * dx + dy * dy;

          if (distanceSquared <= radiusSquared) {
            final index = (y * width + x) * 4;
            if (index >= 0 && index < pixels.length - 3) {
              pixels[index] = r;
              pixels[index + 1] = g;
              pixels[index + 2] = b;
              pixels[index + 3] = a;
            }
          }
        }
      }
    }
  }

  void _drawCircleToPixels(Offset center, double radius, Paint paint,
      Uint8List pixels, int width, int height) {
    final color = paint.color;
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    final a = (color.a * 255).round() & 0xff;

    final centerX = center.dx.round();
    final centerY = center.dy.round();
    final radiusSquared = radius * radius;

    final left = math.max(0, (centerX - radius).round());
    final top = math.max(0, (centerY - radius).round());
    final right = math.min(width, (centerX + radius).round());
    final bottom = math.min(height, (centerY + radius).round());

    if (paint.style == PaintingStyle.fill) {
      // Fill the entire circle
      for (int y = top; y < bottom; y++) {
        for (int x = left; x < right; x++) {
          final dx = x - centerX;
          final dy = y - centerY;
          final distanceSquared = dx * dx + dy * dy;

          if (distanceSquared <= radiusSquared) {
            final index = (y * width + x) * 4;
            if (index >= 0 && index < pixels.length - 3) {
              pixels[index] = r;
              pixels[index + 1] = g;
              pixels[index + 2] = b;
              pixels[index + 3] = a;
            }
          }
        }
      }
    } else if (paint.style == PaintingStyle.stroke) {
      // Draw only the circle border
      final strokeWidth = math.max(1, paint.strokeWidth.round());
      final innerRadiusSquared =
          math.max(0, (radius - strokeWidth) * (radius - strokeWidth));

      for (int y = top; y < bottom; y++) {
        for (int x = left; x < right; x++) {
          final dx = x - centerX;
          final dy = y - centerY;
          final distanceSquared = dx * dx + dy * dy;

          // Point is in the stroke area if it's within the outer circle but outside the inner circle
          if (distanceSquared <= radiusSquared &&
              distanceSquared >= innerRadiusSquared) {
            final index = (y * width + x) * 4;
            if (index >= 0 && index < pixels.length - 3) {
              pixels[index] = r;
              pixels[index + 1] = g;
              pixels[index + 2] = b;
              pixels[index + 3] = a;
            }
          }
        }
      }
    }
  }

  void _drawColorToPixels(
      Color color, Uint8List pixels, int width, int height) {
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    final a = (color.a * 255).round() & 0xff;

    for (int i = 0; i < pixels.length; i += 4) {
      pixels[i] = r;
      pixels[i + 1] = g;
      pixels[i + 2] = b;
      pixels[i + 3] = a;
    }
  }

  void _drawLine(Offset p1, Offset p2, double strokeWidth, Uint8List pixels,
      int width, int height, int r, int g, int b, int a) {
    // Bresenham's line algorithm with stroke width support
    int x0 = p1.dx.round();
    int y0 = p1.dy.round();
    int x1 = p2.dx.round();
    int y1 = p2.dy.round();

    final strokeRadius = math.max(1, (strokeWidth / 2).round());

    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;

    while (true) {
      // Draw a circle at current position to simulate stroke width
      _drawCircleAt(x0, y0, strokeRadius, pixels, width, height, r, g, b, a);

      if (x0 == x1 && y0 == y1) break;

      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }
  }

  void _drawLineToPixels(Offset p1, Offset p2, Paint paint, Uint8List pixels,
      int width, int height) {
    final color = paint.color;
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    final a = (color.a * 255).round() & 0xff;

    _drawLine(p1, p2, paint.strokeWidth, pixels, width, height, r, g, b, a);
  }

  void _drawOvalToPixels(
      Rect rect, Paint paint, Uint8List pixels, int width, int height) {
    final color = paint.color;
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    final a = (color.a * 255).round() & 0xff;

    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final radiusX = rect.width / 2;
    final radiusY = rect.height / 2;

    final left = math.max(0, rect.left.round());
    final top = math.max(0, rect.top.round());
    final right = math.min(width, rect.right.round());
    final bottom = math.min(height, rect.bottom.round());

    for (int y = top; y < bottom; y++) {
      for (int x = left; x < right; x++) {
        final dx = x - centerX;
        final dy = y - centerY;
        final normalized =
            (dx * dx) / (radiusX * radiusX) + (dy * dy) / (radiusY * radiusY);

        if (normalized <= 1.0) {
          final index = (y * width + x) * 4;
          if (index >= 0 && index < pixels.length - 3) {
            pixels[index] = r;
            pixels[index + 1] = g;
            pixels[index + 2] = b;
            pixels[index + 3] = a;
          }
        }
      }
    }
  }

  void _drawPaintToPixels(
      Paint paint, Uint8List pixels, int width, int height) {
    final color = paint.color;
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    final a = (color.a * 255).round() & 0xff;

    // Fill entire canvas with the paint color
    for (int i = 0; i < pixels.length; i += 4) {
      pixels[i] = r;
      pixels[i + 1] = g;
      pixels[i + 2] = b;
      pixels[i + 3] = a;
    }
  }

  void _drawPathToPixels(
      Path path, Paint paint, Uint8List pixels, int width, int height) {
    if (path is! _PureDartPath) return;

    final color = paint.color;
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    final a = (color.a * 255).round() & 0xff;

    // For now, implement a simple path renderer that handles basic shapes
    // This is a simplified implementation that focuses on the most common path operations
    _renderPath(path, paint, pixels, width, height, r, g, b, a);
  }

  void _drawPictureToPixels(
      Picture picture, Uint8List pixels, int width, int height) {
    if (picture is _PureDartPicture) {
      // Recursively process the commands from the nested picture
      for (final command in picture._commands) {
        _processCommand(command, pixels, width, height);
      }
    }
    // For other picture implementations, we can't access their internal commands
    // so we would need to rasterize them differently, but for now we'll just
    // handle our own _PureDartPicture implementation
  }

  void _drawPoint(Offset point, double strokeWidth, Uint8List pixels, int width,
      int height, int r, int g, int b, int a) {
    final radius = math.max(1, (strokeWidth / 2).round());
    _drawCircleAt(point.dx.round(), point.dy.round(), radius, pixels, width,
        height, r, g, b, a);
  }

  void _drawPointsToPixels(PointMode pointMode, List<Offset> points,
      Paint paint, Uint8List pixels, int width, int height) {
    final color = paint.color;
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    final a = (color.a * 255).round() & 0xff;

    switch (pointMode) {
      case PointMode.points:
        for (final point in points) {
          _drawPoint(
              point, paint.strokeWidth, pixels, width, height, r, g, b, a);
        }
        break;
      case PointMode.lines:
        for (int i = 0; i < points.length - 1; i += 2) {
          if (i + 1 < points.length) {
            _drawLine(points[i], points[i + 1], paint.strokeWidth, pixels,
                width, height, r, g, b, a);
          }
        }
        break;
      case PointMode.polygon:
        for (int i = 0; i < points.length - 1; i++) {
          _drawLine(points[i], points[i + 1], paint.strokeWidth, pixels, width,
              height, r, g, b, a);
        }
        break;
    }
  }

  void _drawRawAtlasToPixels(
      Image atlas,
      Float32List rstTransforms,
      Float32List rects,
      Int32List? colors,
      BlendMode? blendMode,
      Rect? cullRect,
      Paint paint,
      Uint8List pixels,
      int width,
      int height) {
    if (atlas is! _PureDartImage) return;

    // Convert raw data to structured data and delegate to drawAtlas
    final transforms = <RSTransform>[];
    final rectList = <Rect>[];
    final colorList = colors != null ? <Color>[] : null;

    // Parse RSTransform data (4 floats per transform: scos, ssin, tx, ty)
    for (int i = 0; i < rstTransforms.length; i += 4) {
      if (i + 3 < rstTransforms.length) {
        transforms.add(RSTransform(
          rstTransforms[i], // scos
          rstTransforms[i + 1], // ssin
          rstTransforms[i + 2], // tx
          rstTransforms[i + 3], // ty
        ));
      }
    }

    // Parse rect data (4 floats per rect: left, top, right, bottom)
    for (int i = 0; i < rects.length; i += 4) {
      if (i + 3 < rects.length) {
        rectList.add(Rect.fromLTRB(
          rects[i], // left
          rects[i + 1], // top
          rects[i + 2], // right
          rects[i + 3], // bottom
        ));
      }
    }

    // Parse color data if provided
    if (colors != null && colorList != null) {
      for (int colorValue in colors) {
        colorList.add(Color(colorValue));
      }
    }

    // Delegate to the main atlas drawing method
    _drawAtlasToPixels(atlas, transforms, rectList, colorList, blendMode,
        cullRect, paint, pixels, width, height);
  }

  void _drawRectToPixels(
      Rect rect, Paint paint, Uint8List pixels, int width, int height) {
    final color = paint.color;
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    final a = (color.a * 255).round() & 0xff;

    final left = math.max(0, rect.left.round());
    final top = math.max(0, rect.top.round());
    final right = math.min(width, rect.right.round());
    final bottom = math.min(height, rect.bottom.round());

    if (paint.style == PaintingStyle.fill) {
      // Fill the entire rectangle
      for (int y = top; y < bottom; y++) {
        for (int x = left; x < right; x++) {
          final index = (y * width + x) * 4;
          if (index >= 0 && index < pixels.length - 3) {
            pixels[index] = r;
            pixels[index + 1] = g;
            pixels[index + 2] = b;
            pixels[index + 3] = a;
          }
        }
      }
    } else if (paint.style == PaintingStyle.stroke) {
      // Draw only the border
      final strokeWidth = math.max(1, paint.strokeWidth.round());

      // Top border
      for (int y = top; y < math.min(top + strokeWidth, bottom); y++) {
        for (int x = left; x < right; x++) {
          final index = (y * width + x) * 4;
          if (index >= 0 && index < pixels.length - 3) {
            pixels[index] = r;
            pixels[index + 1] = g;
            pixels[index + 2] = b;
            pixels[index + 3] = a;
          }
        }
      }

      // Bottom border
      for (int y = math.max(bottom - strokeWidth, top); y < bottom; y++) {
        for (int x = left; x < right; x++) {
          final index = (y * width + x) * 4;
          if (index >= 0 && index < pixels.length - 3) {
            pixels[index] = r;
            pixels[index + 1] = g;
            pixels[index + 2] = b;
            pixels[index + 3] = a;
          }
        }
      }

      // Left border
      for (int y = top; y < bottom; y++) {
        for (int x = left; x < math.min(left + strokeWidth, right); x++) {
          final index = (y * width + x) * 4;
          if (index >= 0 && index < pixels.length - 3) {
            pixels[index] = r;
            pixels[index + 1] = g;
            pixels[index + 2] = b;
            pixels[index + 3] = a;
          }
        }
      }

      // Right border
      for (int y = top; y < bottom; y++) {
        for (int x = math.max(right - strokeWidth, left); x < right; x++) {
          final index = (y * width + x) * 4;
          if (index >= 0 && index < pixels.length - 3) {
            pixels[index] = r;
            pixels[index + 1] = g;
            pixels[index + 2] = b;
            pixels[index + 3] = a;
          }
        }
      }
    }
  }

  void _fillPolygon(List<Offset> points, Uint8List pixels, int width,
      int height, int r, int g, int b, int a) {
    // Simple polygon fill using scanline algorithm
    if (points.length < 3) return;

    // Find bounding box
    double minY = points.first.dy;
    double maxY = points.first.dy;
    for (final point in points) {
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }

    final startY = math.max(0, minY.floor());
    final endY = math.min(height, maxY.ceil());

    // For each scanline
    for (int y = startY; y < endY; y++) {
      final intersections = <double>[];

      // Find intersections with polygon edges
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        if ((p1.dy <= y && p2.dy > y) || (p2.dy <= y && p1.dy > y)) {
          // Edge crosses the scanline
          final x = p1.dx + (y - p1.dy) * (p2.dx - p1.dx) / (p2.dy - p1.dy);
          intersections.add(x);
        }
      }

      // Sort intersections
      intersections.sort();

      // Fill between pairs of intersections
      for (int i = 0; i < intersections.length - 1; i += 2) {
        final startX = math.max(0, intersections[i].round());
        final endX = math.min(width, intersections[i + 1].round());

        for (int x = startX; x < endX; x++) {
          final index = (y * width + x) * 4;
          if (index >= 0 && index < pixels.length - 3) {
            pixels[index] = r;
            pixels[index + 1] = g;
            pixels[index + 2] = b;
            pixels[index + 3] = a;
          }
        }
      }
    }
  }

  void _fillRect(Rect rect, Uint8List pixels, int width, int height, int r,
      int g, int b, int a) {
    final left = math.max(0, rect.left.round());
    final top = math.max(0, rect.top.round());
    final right = math.min(width, rect.right.round());
    final bottom = math.min(height, rect.bottom.round());

    for (int y = top; y < bottom; y++) {
      for (int x = left; x < right; x++) {
        final index = (y * width + x) * 4;
        if (index >= 0 && index < pixels.length - 3) {
          pixels[index] = r;
          pixels[index + 1] = g;
          pixels[index + 2] = b;
          pixels[index + 3] = a;
        }
      }
    }
  }

  bool _isSimpleRectanglePath(_PureDartPath path) {
    // Check if the path consists of a single addRect command
    if (path._commands.length == 1) {
      final command = path._commands[0];
      return command.type == _PathCommandType.addRect;
    }
    return false;
  }

  void _processCommand(
      _DrawCommand command, Uint8List pixels, int width, int height) {
    switch (command.type) {
      case _DrawCommandType.drawColor:
        _drawColorToPixels(command.args[0] as Color, pixels, width, height);
        break;
      case _DrawCommandType.drawRect:
        _drawRectToPixels(
          command.args[0] as Rect,
          command.args[1] as Paint,
          pixels,
          width,
          height,
        );
        break;
      case _DrawCommandType.drawCircle:
        _drawCircleToPixels(
          command.args[0] as Offset,
          command.args[1] as double,
          command.args[2] as Paint,
          pixels,
          width,
          height,
        );
        break;
      case _DrawCommandType.drawOval:
        _drawOvalToPixels(
          command.args[0] as Rect,
          command.args[1] as Paint,
          pixels,
          width,
          height,
        );
        break;
      case _DrawCommandType.drawPicture:
        _drawPictureToPixels(
          command.args[0] as Picture,
          pixels,
          width,
          height,
        );
        break;
      case _DrawCommandType.drawAtlas:
        _drawAtlasToPixels(
          command.args[0] as Image,
          command.args[1] as List<RSTransform>,
          command.args[2] as List<Rect>,
          command.args[3] as List<Color>?,
          command.args[4] as BlendMode?,
          command.args[5] as Rect?,
          command.args[6] as Paint,
          pixels,
          width,
          height,
        );
        break;
      case _DrawCommandType.drawRawAtlas:
        _drawRawAtlasToPixels(
          command.args[0] as Image,
          command.args[1] as Float32List,
          command.args[2] as Float32List,
          command.args[3] as Int32List?,
          command.args[4] as BlendMode?,
          command.args[5] as Rect?,
          command.args[6] as Paint,
          pixels,
          width,
          height,
        );
        break;
      case _DrawCommandType.drawPath:
        _drawPathToPixels(
          command.args[0] as Path,
          command.args[1] as Paint,
          pixels,
          width,
          height,
        );
        break;
      case _DrawCommandType.drawLine:
        _drawLineToPixels(
          command.args[0] as Offset,
          command.args[1] as Offset,
          command.args[2] as Paint,
          pixels,
          width,
          height,
        );
        break;
      case _DrawCommandType.drawPoints:
        _drawPointsToPixels(
          command.args[0] as PointMode,
          command.args[1] as List<Offset>,
          command.args[2] as Paint,
          pixels,
          width,
          height,
        );
        break;
      case _DrawCommandType.drawPaint:
        _drawPaintToPixels(
          command.args[0] as Paint,
          pixels,
          width,
          height,
        );
        break;
      // Add more command processing as needed
      default:
        // Ignore unsupported commands for now
        break;
    }
  }

  // Simple software rasterization (basic implementation)
  Uint8List _rasterize(int width, int height) {
    final pixels = Uint8List(width * height * 4); // RGBA

    // Fill with transparent
    for (int i = 0; i < pixels.length; i += 4) {
      pixels[i] = 0; // R
      pixels[i + 1] = 0; // G
      pixels[i + 2] = 0; // B
      pixels[i + 3] = 0; // A (transparent)
    }

    // Process drawing commands
    for (final command in _commands) {
      _processCommand(command, pixels, width, height);
    }

    return pixels;
  }

  void _rasterizeComplexPath(_PureDartPath path, Paint paint, Uint8List pixels,
      int width, int height, int r, int g, int b, int a) {
    // For now, implement a basic path rasterizer that handles common path operations
    // This is a simplified version that will handle basic shapes and can be extended

    double currentX = 0;
    double currentY = 0;
    final pathPoints = <Offset>[];

    // Process path commands to build a list of points
    for (final command in path._commands) {
      switch (command.type) {
        case _PathCommandType.moveTo:
          currentX = command.args[0] as double;
          currentY = command.args[1] as double;
          pathPoints.clear();
          pathPoints.add(Offset(currentX, currentY));
          break;
        case _PathCommandType.lineTo:
          currentX = command.args[0] as double;
          currentY = command.args[1] as double;
          pathPoints.add(Offset(currentX, currentY));
          break;
        case _PathCommandType.addRect:
          final rect = command.args[0] as Rect;
          if (paint.style == PaintingStyle.fill) {
            _fillRect(rect, pixels, width, height, r, g, b, a);
          } else if (paint.style == PaintingStyle.stroke) {
            _strokeRect(
                rect, paint.strokeWidth, pixels, width, height, r, g, b, a);
          }
          break;
        case _PathCommandType.close:
          if (pathPoints.isNotEmpty) {
            // Close the path by adding the first point
            pathPoints.add(pathPoints.first);
          }
          break;
        // Add more path command handling as needed
        default:
          // Skip unsupported commands for now
          break;
      }
    }

    // If we have points, render them as a simple polygon
    if (pathPoints.length >= 3 && paint.style == PaintingStyle.fill) {
      _fillPolygon(pathPoints, pixels, width, height, r, g, b, a);
    }
  }

  void _renderPath(_PureDartPath path, Paint paint, Uint8List pixels, int width,
      int height, int r, int g, int b, int a) {
    // Process path commands to render the path
    // For this initial implementation, we'll handle the most common path operations

    // Start with a simple approach: check if this is a simple rectangular path
    // and handle more complex paths in future iterations
    final bounds = path.getBounds();

    // Check if this path is a simple rectangle (very common case)
    if (_isSimpleRectanglePath(path)) {
      // Render as a rectangle for now
      if (paint.style == PaintingStyle.fill) {
        _fillRect(bounds, pixels, width, height, r, g, b, a);
      } else if (paint.style == PaintingStyle.stroke) {
        _strokeRect(
            bounds, paint.strokeWidth, pixels, width, height, r, g, b, a);
      }
    } else {
      // For more complex paths, we'll implement a basic scanline rasterizer
      // For now, let's handle simple paths that are composed of basic operations
      _rasterizeComplexPath(path, paint, pixels, width, height, r, g, b, a);
    }
  }

  void _strokeRect(Rect rect, double strokeWidth, Uint8List pixels, int width,
      int height, int r, int g, int b, int a) {
    final left = math.max(0, rect.left.round());
    final top = math.max(0, rect.top.round());
    final right = math.min(width, rect.right.round());
    final bottom = math.min(height, rect.bottom.round());
    final stroke = math.max(1, strokeWidth.round());

    // Top border
    for (int y = top; y < math.min(top + stroke, bottom); y++) {
      for (int x = left; x < right; x++) {
        final index = (y * width + x) * 4;
        if (index >= 0 && index < pixels.length - 3) {
          pixels[index] = r;
          pixels[index + 1] = g;
          pixels[index + 2] = b;
          pixels[index + 3] = a;
        }
      }
    }

    // Bottom border
    for (int y = math.max(bottom - stroke, top); y < bottom; y++) {
      for (int x = left; x < right; x++) {
        final index = (y * width + x) * 4;
        if (index >= 0 && index < pixels.length - 3) {
          pixels[index] = r;
          pixels[index + 1] = g;
          pixels[index + 2] = b;
          pixels[index + 3] = a;
        }
      }
    }

    // Left border
    for (int y = top; y < bottom; y++) {
      for (int x = left; x < math.min(left + stroke, right); x++) {
        final index = (y * width + x) * 4;
        if (index >= 0 && index < pixels.length - 3) {
          pixels[index] = r;
          pixels[index + 1] = g;
          pixels[index + 2] = b;
          pixels[index + 3] = a;
        }
      }
    }

    // Right border
    for (int y = top; y < bottom; y++) {
      for (int x = math.max(right - stroke, left); x < right; x++) {
        final index = (y * width + x) * 4;
        if (index >= 0 && index < pixels.length - 3) {
          pixels[index] = r;
          pixels[index + 1] = g;
          pixels[index + 2] = b;
          pixels[index + 3] = a;
        }
      }
    }
  }
}

/// Pure Dart implementation of PictureRecorder
class _PureDartPictureRecorder implements PictureRecorder {
  _PureDartCanvas? _canvas;
  bool _isRecording = true; // Start recording immediately
  final List<_DrawCommand> _commands = [];

  @override
  bool get isRecording => _isRecording;

  @override
  Picture endRecording() {
    if (!_isRecording) {
      throw Exception('PictureRecorder did not start recording.');
    }

    // Get commands from canvas if available, otherwise use direct commands
    final commands = _canvas?._commands ?? _commands;
    final cullRect = _canvas?._cullRect ?? Rect.largest;

    if (_canvas != null) {
      _canvas!._recorder = null;
      _canvas = null;
    }

    _isRecording = false;

    final picture =
        _PureDartPicture(List<_DrawCommand>.from(commands), cullRect);
    Picture.onCreate?.call(picture);
    return picture;
  }
}

// PathMetrics and PathMetric classes are handled by the main library
