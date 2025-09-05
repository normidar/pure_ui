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
    _currentTransform.scale(sx, sy);
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
    _currentTransform.translate(dx, dy);
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
