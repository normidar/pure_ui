// DartUiBackend: adapts Flutter's engine-provided `dart:ui` types to the
// interface contract. This is the only package in the architecture that
// depends on Flutter (plan §1.2). It cannot be analyzed or tested without the
// Flutter SDK.

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dart_ui_interface/dart_ui_interface.dart' as i;

import 'conv.dart';

/// A [i.UiBackend] backed by Flutter's `dart:ui` engine. Install it in a
/// Flutter app's startup: `UiBackend.instance = DartUiBackend();`.
class DartUiBackend implements i.UiBackend {
  const DartUiBackend();

  @override
  String get name => 'dart:ui';

  @override
  bool supports(i.BackendFeature feature) => true;

  @override
  i.Paint createPaint() => DartUiPaint(ui.Paint());

  @override
  i.Path createPath() => DartUiPath(ui.Path());

  @override
  i.PictureRecorder createPictureRecorder() =>
      DartUiPictureRecorder(ui.PictureRecorder());

  @override
  i.Canvas createCanvas(i.PictureRecorder recorder, [i.Rect? cullRect]) {
    final ui.PictureRecorder raw = (recorder as DartUiPictureRecorder).raw;
    final ui.Canvas canvas = cullRect == null
        ? ui.Canvas(raw)
        : ui.Canvas(raw, rectToUi(cullRect));
    return DartUiCanvas(canvas);
  }

  @override
  Future<i.Image> decodeImageFromPixels(
    Uint8List pixels,
    int width,
    int height,
    i.PixelFormat format,
  ) {
    final completer = Completer<i.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      pixelFormatToUi(format),
      (ui.Image image) => completer.complete(DartUiImage(image)),
    );
    return completer.future;
  }

  @override
  i.Image createImageFromPixels(Uint8List pixels, int width, int height) {
    // dart:ui only exposes asynchronous pixel decoding; there is no synchronous
    // image-from-pixels constructor (plan §5: throw rather than silently no-op).
    throw UnsupportedError(
      'createImageFromPixels is not supported on the dart:ui backend; use '
      'decodeImageFromPixels (async) instead.',
    );
  }
}

/// Wraps a `dart:ui` [ui.Paint].
class DartUiPaint implements i.Paint {
  DartUiPaint(this.raw);

  final ui.Paint raw;

  @override
  i.BlendMode get blendMode => i.BlendMode.values[raw.blendMode.index];
  @override
  set blendMode(i.BlendMode value) => raw.blendMode = blendModeToUi(value);

  @override
  i.Color get color => colorFromUi(raw.color);
  @override
  set color(i.Color value) => raw.color = colorToUi(value);

  @override
  i.FilterQuality get filterQuality => filterQualityFromUi(raw.filterQuality);
  @override
  set filterQuality(i.FilterQuality value) =>
      raw.filterQuality = filterQualityToUi(value);

  @override
  bool get invertColors => raw.invertColors;
  @override
  set invertColors(bool value) => raw.invertColors = value;

  @override
  bool get isAntiAlias => raw.isAntiAlias;
  @override
  set isAntiAlias(bool value) => raw.isAntiAlias = value;

  @override
  i.StrokeCap get strokeCap => strokeCapFromUi(raw.strokeCap);
  @override
  set strokeCap(i.StrokeCap value) => raw.strokeCap = strokeCapToUi(value);

  @override
  i.StrokeJoin get strokeJoin => strokeJoinFromUi(raw.strokeJoin);
  @override
  set strokeJoin(i.StrokeJoin value) => raw.strokeJoin = strokeJoinToUi(value);

  @override
  double get strokeMiterLimit => raw.strokeMiterLimit;
  @override
  set strokeMiterLimit(double value) => raw.strokeMiterLimit = value;

  @override
  double get strokeWidth => raw.strokeWidth;
  @override
  set strokeWidth(double value) => raw.strokeWidth = value;

  @override
  i.PaintingStyle get style => paintingStyleFromUi(raw.style);
  @override
  set style(i.PaintingStyle value) => raw.style = paintingStyleToUi(value);
}

/// Wraps a `dart:ui` [ui.Path].
class DartUiPath implements i.Path {
  DartUiPath(this.raw);

  final ui.Path raw;

  @override
  i.PathFillType get fillType => pathFillTypeFromUi(raw.fillType);
  @override
  set fillType(i.PathFillType value) => raw.fillType = pathFillTypeToUi(value);

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
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => raw.cubicTo(x1, y1, x2, y2, x3, y3);
  @override
  void relativeCubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => raw.relativeCubicTo(x1, y1, x2, y2, x3, y3);
  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) =>
      raw.conicTo(x1, y1, x2, y2, w);
  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) =>
      raw.relativeConicTo(x1, y1, x2, y2, w);
  @override
  void arcTo(
    i.Rect rect,
    double startAngle,
    double sweepAngle,
    bool forceMoveTo,
  ) => raw.arcTo(rectToUi(rect), startAngle, sweepAngle, forceMoveTo);
  @override
  void arcToPoint(
    i.Offset arcEnd, {
    i.Radius radius = i.Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) => raw.arcToPoint(
    offsetToUi(arcEnd),
    radius: radiusToUi(radius),
    rotation: rotation,
    largeArc: largeArc,
    clockwise: clockwise,
  );
  @override
  void addArc(i.Rect oval, double startAngle, double sweepAngle) =>
      raw.addArc(rectToUi(oval), startAngle, sweepAngle);
  @override
  void addOval(i.Rect oval) => raw.addOval(rectToUi(oval));
  @override
  void addRect(i.Rect rect) => raw.addRect(rectToUi(rect));
  @override
  void addRRect(i.RRect rrect) => raw.addRRect(rrectToUi(rrect));
  @override
  void addPolygon(List<i.Offset> points, bool close) =>
      raw.addPolygon(points.map(offsetToUi).toList(), close);
  @override
  void addPath(i.Path path, i.Offset offset, {Float64List? matrix4}) => raw
      .addPath((path as DartUiPath).raw, offsetToUi(offset), matrix4: matrix4);
  @override
  void extendWithPath(i.Path path, i.Offset offset, {Float64List? matrix4}) =>
      raw.extendWithPath(
        (path as DartUiPath).raw,
        offsetToUi(offset),
        matrix4: matrix4,
      );
  @override
  void close() => raw.close();
  @override
  void reset() => raw.reset();
  @override
  bool contains(i.Offset point) => raw.contains(offsetToUi(point));
  @override
  i.Rect getBounds() => rectFromUi(raw.getBounds());
  @override
  i.Path shift(i.Offset offset) => DartUiPath(raw.shift(offsetToUi(offset)));
  @override
  i.Path transform(Float64List matrix4) => DartUiPath(raw.transform(matrix4));
}

/// Wraps a `dart:ui` [ui.Canvas].
class DartUiCanvas implements i.Canvas {
  DartUiCanvas(this.raw);

  final ui.Canvas raw;

  ui.Paint _paint(i.Paint paint) => (paint as DartUiPaint).raw;

  @override
  void save() => raw.save();
  @override
  void saveLayer(i.Rect? bounds, i.Paint paint) =>
      raw.saveLayer(bounds == null ? null : rectToUi(bounds), _paint(paint));
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
  void clipRect(
    i.Rect rect, {
    i.ClipOp clipOp = i.ClipOp.intersect,
    bool doAntiAlias = true,
  }) => raw.clipRect(
    rectToUi(rect),
    clipOp: clipOpToUi(clipOp),
    doAntiAlias: doAntiAlias,
  );
  @override
  void clipRRect(i.RRect rrect, {bool doAntiAlias = true}) =>
      raw.clipRRect(rrectToUi(rrect), doAntiAlias: doAntiAlias);
  @override
  void clipPath(i.Path path, {bool doAntiAlias = true}) =>
      raw.clipPath((path as DartUiPath).raw, doAntiAlias: doAntiAlias);
  @override
  i.Rect getLocalClipBounds() => rectFromUi(raw.getLocalClipBounds());
  @override
  i.Rect getDestinationClipBounds() =>
      rectFromUi(raw.getDestinationClipBounds());

  @override
  void drawColor(i.Color color, i.BlendMode blendMode) =>
      raw.drawColor(colorToUi(color), blendModeToUi(blendMode));
  @override
  void drawPaint(i.Paint paint) => raw.drawPaint(_paint(paint));
  @override
  void drawLine(i.Offset p1, i.Offset p2, i.Paint paint) =>
      raw.drawLine(offsetToUi(p1), offsetToUi(p2), _paint(paint));
  @override
  void drawRect(i.Rect rect, i.Paint paint) =>
      raw.drawRect(rectToUi(rect), _paint(paint));
  @override
  void drawRRect(i.RRect rrect, i.Paint paint) =>
      raw.drawRRect(rrectToUi(rrect), _paint(paint));
  @override
  void drawDRRect(i.RRect outer, i.RRect inner, i.Paint paint) =>
      raw.drawDRRect(rrectToUi(outer), rrectToUi(inner), _paint(paint));
  @override
  void drawOval(i.Rect rect, i.Paint paint) =>
      raw.drawOval(rectToUi(rect), _paint(paint));
  @override
  void drawCircle(i.Offset c, double radius, i.Paint paint) =>
      raw.drawCircle(offsetToUi(c), radius, _paint(paint));
  @override
  void drawArc(
    i.Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    i.Paint paint,
  ) => raw.drawArc(
    rectToUi(rect),
    startAngle,
    sweepAngle,
    useCenter,
    _paint(paint),
  );
  @override
  void drawPath(i.Path path, i.Paint paint) =>
      raw.drawPath((path as DartUiPath).raw, _paint(paint));
  @override
  void drawImage(i.Image image, i.Offset offset, i.Paint paint) => raw
      .drawImage((image as DartUiImage).raw, offsetToUi(offset), _paint(paint));
  @override
  void drawImageRect(i.Image image, i.Rect src, i.Rect dst, i.Paint paint) =>
      raw.drawImageRect(
        (image as DartUiImage).raw,
        rectToUi(src),
        rectToUi(dst),
        _paint(paint),
      );
  @override
  void drawPoints(
    i.PointMode pointMode,
    List<i.Offset> points,
    i.Paint paint,
  ) => raw.drawPoints(
    pointModeToUi(pointMode),
    points.map(offsetToUi).toList(),
    _paint(paint),
  );
  @override
  void drawPicture(i.Picture picture) =>
      raw.drawPicture((picture as DartUiPicture).raw);
}

/// Wraps a `dart:ui` [ui.PictureRecorder].
class DartUiPictureRecorder implements i.PictureRecorder {
  DartUiPictureRecorder(this.raw);

  final ui.PictureRecorder raw;

  @override
  bool get isRecording => raw.isRecording;

  @override
  i.Picture endRecording() => DartUiPicture(raw.endRecording());
}

/// Wraps a `dart:ui` [ui.Picture].
class DartUiPicture implements i.Picture {
  DartUiPicture(this.raw);

  final ui.Picture raw;

  @override
  int get approximateBytesUsed => raw.approximateBytesUsed;
  @override
  bool get debugDisposed => raw.debugDisposed;
  @override
  Future<i.Image> toImage(int width, int height) async =>
      DartUiImage(await raw.toImage(width, height));
  @override
  i.Image toImageSync(int width, int height) =>
      DartUiImage(raw.toImageSync(width, height));
  @override
  void dispose() => raw.dispose();
}

/// Wraps a `dart:ui` [ui.Image].
class DartUiImage implements i.Image {
  DartUiImage(this.raw);

  final ui.Image raw;

  @override
  int get width => raw.width;
  @override
  int get height => raw.height;
  @override
  bool get debugDisposed => raw.debugDisposed;
  @override
  i.Image clone() => DartUiImage(raw.clone());
  @override
  bool isCloneOf(i.Image other) =>
      other is DartUiImage && raw.isCloneOf(other.raw);
  @override
  Future<ByteData?> toByteData({
    i.ImageByteFormat format = i.ImageByteFormat.rawRgba,
  }) => raw.toByteData(format: imageByteFormatToUi(format));
  @override
  void dispose() => raw.dispose();
}
