// PureUiBackend: adapts pure_ui's concrete types to the interface contract.
//
// Per the plan (§2.1) this uses the "pure_ui_adapter" option rather than making
// pure_ui implement the interface directly, so pure_ui keeps its standalone
// drop-in behaviour untouched (§6.0). The only cost is value-type conversion at
// the boundary.

import 'dart:typed_data';

import 'package:dart_ui_interface/dart_ui_interface.dart' as i;
import 'package:pure_ui/pure_ui.dart' as p;

import 'conv.dart';

/// A [i.UiBackend] backed by the pure-Dart `pure_ui` implementation. Works in
/// any Dart environment; no Flutter required.
class PureUiBackend implements i.UiBackend {
  const PureUiBackend();

  @override
  String get name => 'pure_ui';

  @override
  bool supports(i.BackendFeature feature) {
    switch (feature) {
      case i.BackendFeature.drawing:
      case i.BackendFeature.imageCodec:
      case i.BackendFeature.text:
      case i.BackendFeature.shaders:
      case i.BackendFeature.atlas:
        return true;
      // drawShadow and drawVertices are recorded by pure_ui's Canvas but the
      // rasterizer has no handler — refuse here so callers don't get a silent
      // no-op.
      case i.BackendFeature.drawShadow:
      case i.BackendFeature.vertices:
      case i.BackendFeature.imageFilters:
      case i.BackendFeature.fragmentShaders:
        return false;
    }
  }

  @override
  i.Paint createPaint() => PureUiPaint(p.Paint());

  @override
  i.Path createPath() => PureUiPath(p.Path());

  @override
  i.PictureRecorder createPictureRecorder() =>
      PureUiPictureRecorder(p.PictureRecorder());

  @override
  i.Canvas createCanvas(i.PictureRecorder recorder, [i.Rect? cullRect]) {
    final p.PictureRecorder raw = (recorder as PureUiPictureRecorder).raw;
    final p.Canvas canvas =
        cullRect == null ? p.Canvas(raw) : p.Canvas(raw, rectToPure(cullRect));
    return PureUiCanvas(canvas);
  }

  @override
  Future<i.Image> decodeImageFromPixels(
    Uint8List pixels,
    int width,
    int height,
    i.PixelFormat format,
  ) async {
    // pure_ui treats incoming pixel data as RGBA.
    return PureUiImage(p.createPureDartImage(pixels, width, height));
  }

  @override
  i.Image createImageFromPixels(Uint8List pixels, int width, int height) =>
      PureUiImage(p.createPureDartImage(pixels, width, height));

  @override
  i.ParagraphBuilder createParagraphBuilder(i.ParagraphStyle style) =>
      PureUiParagraphBuilder(p.ParagraphBuilder(paragraphStyleToPure(style)));

  @override
  Future<void> loadFont(
    String family,
    Uint8List bytes, {
    i.FontWeight weight = i.FontWeight.normal,
    i.FontStyle style = i.FontStyle.normal,
  }) async {
    p.FontLoader.load(
      family,
      bytes,
      weight: fontWeightToPure(weight),
      style: fontStyleToPure(style),
    );
  }

  @override
  i.Vertices createVertices(
    i.VertexMode mode,
    List<i.Offset> positions, {
    List<i.Offset>? textureCoordinates,
    List<i.Color>? colors,
    List<int>? indices,
  }) {
    // pure_ui's Vertices is an engine stub (NativeFieldWrapperClass1) and the
    // rasterizer's drawVertices isn't actually wired. Refuse instead of
    // returning a half-broken object — gate with supports(vertices).
    throw UnsupportedError(
      'pure_ui backend does not implement Vertices yet; '
      'check UiBackend.instance.supports(BackendFeature.vertices) before use.',
    );
  }

  @override
  i.Gradient createLinearGradient(
    i.Offset from,
    i.Offset to,
    List<i.Color> colors,
    List<double>? colorStops,
    i.TileMode tileMode,
    Float64List? matrix4,
  ) =>
      PureUiGradient(p.Gradient.linear(
        offsetToPure(from),
        offsetToPure(to),
        colors.map(colorToPure).toList(),
        colorStops,
        tileModeToPure(tileMode),
        matrix4,
      ));

  @override
  i.Gradient createRadialGradient(
    i.Offset center,
    double radius,
    List<i.Color> colors,
    List<double>? colorStops,
    i.TileMode tileMode,
    Float64List? matrix4,
    i.Offset? focal,
    double focalRadius,
  ) =>
      PureUiGradient(p.Gradient.radial(
        offsetToPure(center),
        radius,
        colors.map(colorToPure).toList(),
        colorStops,
        tileModeToPure(tileMode),
        matrix4,
        focal == null ? null : offsetToPure(focal),
        focalRadius,
      ));

  @override
  i.Gradient createSweepGradient(
    i.Offset center,
    List<i.Color> colors,
    List<double>? colorStops,
    i.TileMode tileMode,
    double startAngle,
    double endAngle,
    Float64List? matrix4,
  ) =>
      PureUiGradient(p.Gradient.sweep(
        offsetToPure(center),
        colors.map(colorToPure).toList(),
        colorStops,
        tileModeToPure(tileMode),
        startAngle,
        endAngle,
        matrix4,
      ));

  @override
  i.ColorFilter createColorFilterMode(i.Color color, i.BlendMode blendMode) {
    // pure_ui's Paint.colorFilter setter goes through an FFI native that isn't
    // resolvable outside Flutter — refuse construction up front rather than
    // hand back an object that crashes on first assignment.
    throw UnsupportedError(
      'pure_ui backend does not implement ColorFilter; '
      'check UiBackend.instance.supports(BackendFeature.imageFilters) before use.',
    );
  }

  @override
  i.ColorFilter createColorFilterMatrix(List<double> matrix) {
    throw UnsupportedError(
      'pure_ui backend does not implement ColorFilter; '
      'check UiBackend.instance.supports(BackendFeature.imageFilters) before use.',
    );
  }

  @override
  i.ImageFilter createBlurFilter({
    required double sigmaX,
    required double sigmaY,
    required i.TileMode tileMode,
  }) {
    throw UnsupportedError(
      'pure_ui backend does not implement ImageFilter; '
      'check UiBackend.instance.supports(BackendFeature.imageFilters) before use.',
    );
  }

  @override
  i.MaskFilter createMaskFilterBlur(i.BlurStyle style, double sigma) =>
      PureUiMaskFilter(p.MaskFilter.blur(blurStyleToPure(style), sigma));
}

/// Wraps a pure_ui [p.Paint].
class PureUiPaint implements i.Paint {
  PureUiPaint(this.raw);

  final p.Paint raw;

  @override
  i.BlendMode get blendMode => blendModeFromPure(raw.blendMode);
  @override
  set blendMode(i.BlendMode value) => raw.blendMode = blendModeToPure(value);

  @override
  i.Color get color => colorFromPure(raw.color);
  @override
  set color(i.Color value) => raw.color = colorToPure(value);

  @override
  i.FilterQuality get filterQuality => filterQualityFromPure(raw.filterQuality);
  @override
  set filterQuality(i.FilterQuality value) =>
      raw.filterQuality = filterQualityToPure(value);

  @override
  bool get invertColors => raw.invertColors;
  @override
  set invertColors(bool value) => raw.invertColors = value;

  @override
  bool get isAntiAlias => raw.isAntiAlias;
  @override
  set isAntiAlias(bool value) => raw.isAntiAlias = value;

  @override
  i.StrokeCap get strokeCap => strokeCapFromPure(raw.strokeCap);
  @override
  set strokeCap(i.StrokeCap value) => raw.strokeCap = strokeCapToPure(value);

  @override
  i.StrokeJoin get strokeJoin => strokeJoinFromPure(raw.strokeJoin);
  @override
  set strokeJoin(i.StrokeJoin value) =>
      raw.strokeJoin = strokeJoinToPure(value);

  @override
  double get strokeMiterLimit => raw.strokeMiterLimit;
  @override
  set strokeMiterLimit(double value) => raw.strokeMiterLimit = value;

  @override
  double get strokeWidth => raw.strokeWidth;
  @override
  set strokeWidth(double value) => raw.strokeWidth = value;

  @override
  i.PaintingStyle get style => paintingStyleFromPure(raw.style);
  @override
  set style(i.PaintingStyle value) => raw.style = paintingStyleToPure(value);

  // The wrapper objects below remember what the interface caller assigned so
  // we can return the same `i.*` instance back through the getter without
  // having to reconstruct it from pure_ui's stored value.
  i.Shader? _shader;
  i.ColorFilter? _colorFilter;
  i.ImageFilter? _imageFilter;
  i.MaskFilter? _maskFilter;

  @override
  i.Shader? get shader => _shader;
  @override
  set shader(i.Shader? value) {
    _shader = value;
    if (value == null) {
      raw.shader = null;
    } else if (value is PureUiGradient) {
      raw.shader = value.raw;
    } else {
      throw UnsupportedError(
          'Unknown Shader implementation: ${value.runtimeType}');
    }
  }

  @override
  i.ColorFilter? get colorFilter => _colorFilter;
  @override
  set colorFilter(i.ColorFilter? value) {
    _colorFilter = value;
    raw.colorFilter = value == null ? null : (value as PureUiColorFilter).raw;
  }

  @override
  i.ImageFilter? get imageFilter => _imageFilter;
  @override
  set imageFilter(i.ImageFilter? value) {
    _imageFilter = value;
    raw.imageFilter = value == null ? null : (value as PureUiImageFilter).raw;
  }

  @override
  i.MaskFilter? get maskFilter => _maskFilter;
  @override
  set maskFilter(i.MaskFilter? value) {
    _maskFilter = value;
    raw.maskFilter = value == null ? null : (value as PureUiMaskFilter).raw;
  }
}

/// Wraps a pure_ui [p.Path].
class PureUiPath implements i.Path {
  PureUiPath(this.raw);

  final p.Path raw;

  @override
  i.PathFillType get fillType => pathFillTypeFromPure(raw.fillType);
  @override
  set fillType(i.PathFillType value) =>
      raw.fillType = pathFillTypeToPure(value);

  @override
  void moveTo(double x, double y) => raw.moveTo(x, y);
  @override
  void lineTo(double x, double y) => raw.lineTo(x, y);
  @override
  void relativeMoveTo(double dx, double dy) => raw.relativeMoveTo(dx, dy);
  @override
  void relativeLineTo(double dx, double dy) => raw.relativeLineTo(dx, dy);
  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) =>
      raw.quadraticBezierTo(x1, y1, x2, y2);
  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) =>
      raw.relativeQuadraticBezierTo(x1, y1, x2, y2);
  @override
  void cubicTo(
          double x1, double y1, double x2, double y2, double x3, double y3) =>
      raw.cubicTo(x1, y1, x2, y2, x3, y3);
  @override
  void relativeCubicTo(
          double x1, double y1, double x2, double y2, double x3, double y3) =>
      raw.relativeCubicTo(x1, y1, x2, y2, x3, y3);
  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) =>
      raw.conicTo(x1, y1, x2, y2, w);
  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) =>
      raw.relativeConicTo(x1, y1, x2, y2, w);
  @override
  void arcTo(i.Rect rect, double startAngle, double sweepAngle,
          bool forceMoveTo) =>
      raw.arcTo(rectToPure(rect), startAngle, sweepAngle, forceMoveTo);
  @override
  void arcToPoint(
    i.Offset arcEnd, {
    i.Radius radius = i.Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) =>
      raw.arcToPoint(
        offsetToPure(arcEnd),
        radius: radiusToPure(radius),
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise,
      );
  @override
  void addArc(i.Rect oval, double startAngle, double sweepAngle) =>
      raw.addArc(rectToPure(oval), startAngle, sweepAngle);
  @override
  void addOval(i.Rect oval) => raw.addOval(rectToPure(oval));
  @override
  void addRect(i.Rect rect) => raw.addRect(rectToPure(rect));
  @override
  void addRRect(i.RRect rrect) => raw.addRRect(rrectToPure(rrect));
  @override
  void addPolygon(List<i.Offset> points, bool close) =>
      raw.addPolygon(points.map(offsetToPure).toList(), close);
  @override
  void addPath(i.Path path, i.Offset offset, {Float64List? matrix4}) =>
      raw.addPath((path as PureUiPath).raw, offsetToPure(offset),
          matrix4: matrix4);
  @override
  void extendWithPath(i.Path path, i.Offset offset, {Float64List? matrix4}) =>
      raw.extendWithPath((path as PureUiPath).raw, offsetToPure(offset),
          matrix4: matrix4);
  @override
  void close() => raw.close();
  @override
  void reset() => raw.reset();
  @override
  bool contains(i.Offset point) => raw.contains(offsetToPure(point));
  @override
  i.Rect getBounds() => rectFromPure(raw.getBounds());
  @override
  i.Path shift(i.Offset offset) => PureUiPath(raw.shift(offsetToPure(offset)));
  @override
  i.Path transform(Float64List matrix4) => PureUiPath(raw.transform(matrix4));
}

/// Wraps a pure_ui [p.Canvas].
class PureUiCanvas implements i.Canvas {
  PureUiCanvas(this.raw);

  final p.Canvas raw;

  p.Paint _paint(i.Paint paint) => (paint as PureUiPaint).raw;

  @override
  void save() => raw.save();
  @override
  void saveLayer(i.Rect? bounds, i.Paint paint) =>
      raw.saveLayer(bounds == null ? null : rectToPure(bounds), _paint(paint));
  @override
  void restore() => raw.restore();
  @override
  void restoreToCount(int count) => raw.restoreToCount(count);
  @override
  int getSaveCount() => raw.getSaveCount();
  @override
  void translate(double dx, double dy) => raw.translate(dx, dy);
  @override
  void scale(double sx, [double? sy]) => raw.scale(sx, sy);
  @override
  void rotate(double radians) => raw.rotate(radians);
  @override
  void skew(double sx, double sy) => raw.skew(sx, sy);
  @override
  void transform(Float64List matrix4) => raw.transform(matrix4);
  @override
  Float64List getTransform() => raw.getTransform();

  @override
  void clipRect(i.Rect rect,
          {i.ClipOp clipOp = i.ClipOp.intersect, bool doAntiAlias = true}) =>
      raw.clipRect(rectToPure(rect),
          clipOp: clipOpToPure(clipOp), doAntiAlias: doAntiAlias);
  @override
  void clipRRect(i.RRect rrect, {bool doAntiAlias = true}) =>
      raw.clipRRect(rrectToPure(rrect), doAntiAlias: doAntiAlias);
  @override
  void clipPath(i.Path path, {bool doAntiAlias = true}) =>
      raw.clipPath((path as PureUiPath).raw, doAntiAlias: doAntiAlias);
  @override
  i.Rect getLocalClipBounds() => rectFromPure(raw.getLocalClipBounds());
  @override
  i.Rect getDestinationClipBounds() =>
      rectFromPure(raw.getDestinationClipBounds());

  @override
  void drawColor(i.Color color, i.BlendMode blendMode) =>
      raw.drawColor(colorToPure(color), blendModeToPure(blendMode));
  @override
  void drawPaint(i.Paint paint) => raw.drawPaint(_paint(paint));
  @override
  void drawLine(i.Offset p1, i.Offset p2, i.Paint paint) =>
      raw.drawLine(offsetToPure(p1), offsetToPure(p2), _paint(paint));
  @override
  void drawRect(i.Rect rect, i.Paint paint) =>
      raw.drawRect(rectToPure(rect), _paint(paint));
  @override
  void drawRRect(i.RRect rrect, i.Paint paint) =>
      raw.drawRRect(rrectToPure(rrect), _paint(paint));
  @override
  void drawDRRect(i.RRect outer, i.RRect inner, i.Paint paint) =>
      raw.drawDRRect(rrectToPure(outer), rrectToPure(inner), _paint(paint));
  @override
  void drawOval(i.Rect rect, i.Paint paint) =>
      raw.drawOval(rectToPure(rect), _paint(paint));
  @override
  void drawCircle(i.Offset c, double radius, i.Paint paint) =>
      raw.drawCircle(offsetToPure(c), radius, _paint(paint));
  @override
  void drawArc(i.Rect rect, double startAngle, double sweepAngle,
          bool useCenter, i.Paint paint) =>
      raw.drawArc(
          rectToPure(rect), startAngle, sweepAngle, useCenter, _paint(paint));
  @override
  void drawPath(i.Path path, i.Paint paint) =>
      raw.drawPath((path as PureUiPath).raw, _paint(paint));
  @override
  void drawImage(i.Image image, i.Offset offset, i.Paint paint) =>
      raw.drawImage(
          (image as PureUiImage).raw, offsetToPure(offset), _paint(paint));
  @override
  void drawImageRect(i.Image image, i.Rect src, i.Rect dst, i.Paint paint) =>
      raw.drawImageRect((image as PureUiImage).raw, rectToPure(src),
          rectToPure(dst), _paint(paint));
  @override
  void drawPoints(
          i.PointMode pointMode, List<i.Offset> points, i.Paint paint) =>
      raw.drawPoints(pointModeToPure(pointMode),
          points.map(offsetToPure).toList(), _paint(paint));
  @override
  void drawPicture(i.Picture picture) =>
      raw.drawPicture((picture as PureUiPicture).raw);

  @override
  void drawImageNine(i.Image image, i.Rect center, i.Rect dst, i.Paint paint) =>
      raw.drawImageNine((image as PureUiImage).raw, rectToPure(center),
          rectToPure(dst), _paint(paint));

  @override
  void drawParagraph(i.Paragraph paragraph, i.Offset offset) => raw
      .drawParagraph((paragraph as PureUiParagraph).raw, offsetToPure(offset));

  @override
  void drawRawAtlas(
    i.Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    i.BlendMode? blendMode,
    i.Rect? cullRect,
    i.Paint paint,
  ) =>
      raw.drawRawAtlas(
        (atlas as PureUiImage).raw,
        rstTransforms,
        rects,
        colors,
        blendMode == null ? null : blendModeToPure(blendMode),
        cullRect == null ? null : rectToPure(cullRect),
        _paint(paint),
      );

  @override
  void drawVertices(
    i.Vertices vertices,
    i.BlendMode blendMode,
    i.Paint paint,
  ) {
    throw UnsupportedError(
      'pure_ui backend does not implement drawVertices; '
      'check UiBackend.instance.supports(BackendFeature.vertices) before use.',
    );
  }

  @override
  void drawShadow(
    i.Path path,
    i.Color color,
    double elevation,
    bool transparentOccluder,
  ) {
    // pure_ui records the command but its rasterizer doesn't paint it — refuse
    // rather than letting the shadow silently disappear.
    throw UnsupportedError(
      'pure_ui backend does not implement drawShadow; '
      'check UiBackend.instance.supports(BackendFeature.drawShadow) before use.',
    );
  }
}

/// Wraps a pure_ui [p.PictureRecorder].
class PureUiPictureRecorder implements i.PictureRecorder {
  PureUiPictureRecorder(this.raw);

  final p.PictureRecorder raw;

  @override
  bool get isRecording => raw.isRecording;

  @override
  i.Picture endRecording() => PureUiPicture(raw.endRecording());
}

/// Wraps a pure_ui [p.Picture].
class PureUiPicture implements i.Picture {
  PureUiPicture(this.raw);

  final p.Picture raw;

  @override
  int get approximateBytesUsed => raw.approximateBytesUsed;
  @override
  bool get debugDisposed => raw.debugDisposed;
  @override
  Future<i.Image> toImage(int width, int height) async =>
      PureUiImage(await raw.toImage(width, height));
  @override
  i.Image toImageSync(int width, int height) =>
      PureUiImage(raw.toImageSync(width, height));
  @override
  void dispose() => raw.dispose();
}

/// Wraps a pure_ui [p.Image].
class PureUiImage implements i.Image {
  PureUiImage(this.raw);

  final p.Image raw;

  @override
  int get width => raw.width;
  @override
  int get height => raw.height;
  @override
  bool get debugDisposed => raw.debugDisposed;
  @override
  i.Image clone() => PureUiImage(raw.clone());
  @override
  bool isCloneOf(i.Image other) =>
      other is PureUiImage && raw.isCloneOf(other.raw);
  @override
  Future<ByteData?> toByteData(
          {i.ImageByteFormat format = i.ImageByteFormat.rawRgba}) =>
      raw.toByteData(format: imageByteFormatToPure(format));
  @override
  void dispose() => raw.dispose();
}

// --- text ---

/// Wraps a pure_ui [p.ParagraphBuilder].
class PureUiParagraphBuilder implements i.ParagraphBuilder {
  PureUiParagraphBuilder(this.raw);

  final p.ParagraphBuilder raw;

  @override
  void pushStyle(i.TextStyle style) => raw.pushStyle(textStyleToPure(style));
  @override
  void pop() => raw.pop();
  @override
  void addText(String text) => raw.addText(text);
  @override
  i.Paragraph build() => PureUiParagraph(raw.build());
}

/// Wraps a pure_ui [p.Paragraph].
class PureUiParagraph implements i.Paragraph {
  PureUiParagraph(this.raw);

  final p.Paragraph raw;

  @override
  double get width => raw.width;
  @override
  double get height => raw.height;
  @override
  double get longestLine => raw.longestLine;
  @override
  double get minIntrinsicWidth => raw.minIntrinsicWidth;
  @override
  double get maxIntrinsicWidth => raw.maxIntrinsicWidth;
  @override
  double get alphabeticBaseline => raw.alphabeticBaseline;
  @override
  double get ideographicBaseline => raw.ideographicBaseline;
  @override
  bool get didExceedMaxLines => raw.didExceedMaxLines;
  @override
  int get numberOfLines => raw.numberOfLines;
  @override
  bool get debugDisposed => raw.debugDisposed;
  @override
  void layout(i.ParagraphConstraints constraints) =>
      raw.layout(p.ParagraphConstraints(width: constraints.width));
  @override
  List<i.LineMetrics> computeLineMetrics() =>
      raw.computeLineMetrics().map(lineMetricsFromPure).toList();
  @override
  void dispose() => raw.dispose();
}

// --- shaders / filters ---

/// Wraps a pure_ui [p.Gradient]. Acts as a [i.Shader] when assigned to a Paint.
class PureUiGradient implements i.Gradient {
  PureUiGradient(this.raw);

  final p.Gradient raw;

  @override
  bool get debugDisposed => false;
  @override
  void dispose() {/* pure_ui Gradients are GC-managed */}
}

/// Wraps a pure_ui [p.ColorFilter].
class PureUiColorFilter implements i.ColorFilter {
  PureUiColorFilter(this.raw);
  final p.ColorFilter raw;
}

/// Wraps a pure_ui [p.ImageFilter].
class PureUiImageFilter implements i.ImageFilter {
  PureUiImageFilter(this.raw);
  final p.ImageFilter raw;
}

/// Wraps a pure_ui [p.MaskFilter].
class PureUiMaskFilter implements i.MaskFilter {
  PureUiMaskFilter(this.raw);
  final p.MaskFilter raw;
}
