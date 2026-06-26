// Public abstract resource types with factory dispatch (plan §3.3).
//
// `Paint()`, `Canvas(recorder)`, etc. route to `UiBackend.instance`. Each
// backend returns its own concrete type that `implements` these contracts.

import 'dart:typed_data';

import 'backend.dart';
import 'enums.dart';
import 'shaders.dart';
import 'text.dart';
import 'values.dart';

/// A description of the style to use when drawing on a [Canvas].
abstract class Paint {
  factory Paint() => UiBackend.instance.createPaint();

  BlendMode get blendMode;
  set blendMode(BlendMode value);

  Color get color;
  set color(Color value);

  Shader? get shader;
  set shader(Shader? value);

  ColorFilter? get colorFilter;
  set colorFilter(ColorFilter? value);

  ImageFilter? get imageFilter;
  set imageFilter(ImageFilter? value);

  MaskFilter? get maskFilter;
  set maskFilter(MaskFilter? value);

  FilterQuality get filterQuality;
  set filterQuality(FilterQuality value);

  bool get invertColors;
  set invertColors(bool value);

  bool get isAntiAlias;
  set isAntiAlias(bool value);

  StrokeCap get strokeCap;
  set strokeCap(StrokeCap value);

  StrokeJoin get strokeJoin;
  set strokeJoin(StrokeJoin value);

  double get strokeMiterLimit;
  set strokeMiterLimit(double value);

  double get strokeWidth;
  set strokeWidth(double value);

  PaintingStyle get style;
  set style(PaintingStyle value);
}

/// A complex, one-dimensional subset of a plane.
abstract class Path {
  factory Path() => UiBackend.instance.createPath();

  PathFillType get fillType;
  set fillType(PathFillType value);

  void moveTo(double x, double y);
  void lineTo(double x, double y);
  void relativeMoveTo(double dx, double dy);
  void relativeLineTo(double dx, double dy);
  void quadraticBezierTo(double x1, double y1, double x2, double y2);
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2);
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3);
  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3);
  void conicTo(double x1, double y1, double x2, double y2, double w);
  void relativeConicTo(double x1, double y1, double x2, double y2, double w);
  void arcTo(Rect rect, double startAngle, double sweepAngle, bool forceMoveTo);
  void arcToPoint(
    Offset arcEnd, {
    Radius radius,
    double rotation,
    bool largeArc,
    bool clockwise,
  });
  void addArc(Rect oval, double startAngle, double sweepAngle);
  void addOval(Rect oval);
  void addRect(Rect rect);
  void addRRect(RRect rrect);
  void addPolygon(List<Offset> points, bool close);
  void addPath(Path path, Offset offset, {Float64List? matrix4});
  void extendWithPath(Path path, Offset offset, {Float64List? matrix4});
  void close();
  void reset();
  bool contains(Offset point);
  Rect getBounds();
  Path shift(Offset offset);
  Path transform(Float64List matrix4);
}

/// An interface for recording graphical operations.
abstract class Canvas {
  factory Canvas(PictureRecorder recorder, [Rect? cullRect]) =>
      UiBackend.instance.createCanvas(recorder, cullRect);

  void save();
  void saveLayer(Rect? bounds, Paint paint);
  void restore();
  void restoreToCount(int count);
  int getSaveCount();
  void translate(double dx, double dy);
  void scale(double sx, [double? sy]);
  void rotate(double radians);
  void skew(double sx, double sy);
  void transform(Float64List matrix4);
  Float64List getTransform();

  void clipRect(Rect rect,
      {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true});
  void clipRRect(RRect rrect, {bool doAntiAlias = true});
  void clipPath(Path path, {bool doAntiAlias = true});
  Rect getLocalClipBounds();
  Rect getDestinationClipBounds();

  void drawColor(Color color, BlendMode blendMode);
  void drawPaint(Paint paint);
  void drawLine(Offset p1, Offset p2, Paint paint);
  void drawRect(Rect rect, Paint paint);
  void drawRRect(RRect rrect, Paint paint);
  void drawDRRect(RRect outer, RRect inner, Paint paint);
  void drawOval(Rect rect, Paint paint);
  void drawCircle(Offset c, double radius, Paint paint);
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint);
  void drawPath(Path path, Paint paint);
  void drawImage(Image image, Offset offset, Paint paint);
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint);
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint);
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint);
  void drawPicture(Picture picture);
  void drawParagraph(Paragraph paragraph, Offset offset);

  /// Draw a sprite atlas. Backends without atlas support throw
  /// [UnsupportedError]; gate with `UiBackend.supports(BackendFeature.atlas)`.
  void drawRawAtlas(
    Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  );

  /// Vertices drawing. Backends without support throw [UnsupportedError].
  void drawVertices(
    Vertices vertices,
    BlendMode blendMode,
    Paint paint,
  );

  /// Draws an elevation shadow under the given path. Backends without support
  /// throw [UnsupportedError].
  void drawShadow(
    Path path,
    Color color,
    double elevation,
    bool transparentOccluder,
  );
}

/// Vertex data for [Canvas.drawVertices]. Construction is backend-dispatched
/// so each engine can build its native vertex buffer.
abstract class Vertices {
  factory Vertices(
    VertexMode mode,
    List<Offset> positions, {
    List<Offset>? textureCoordinates,
    List<Color>? colors,
    List<int>? indices,
  }) =>
      UiBackend.instance.createVertices(
        mode,
        positions,
        textureCoordinates: textureCoordinates,
        colors: colors,
        indices: indices,
      );

  void dispose();
  bool get debugDisposed;
}

/// An object representing a sequence of recorded graphical operations.
abstract class Picture {
  int get approximateBytesUsed;
  bool get debugDisposed;
  Future<Image> toImage(int width, int height);
  Image toImageSync(int width, int height);
  void dispose();
}

/// A class that enables the creation of a [Picture] from a series of canvas
/// drawing commands.
abstract class PictureRecorder {
  factory PictureRecorder() => UiBackend.instance.createPictureRecorder();

  bool get isRecording;
  Picture endRecording();
}

/// An immutable, rasterized image.
abstract class Image {
  int get width;
  int get height;
  bool get debugDisposed;
  Image clone();
  bool isCloneOf(Image other);
  Future<ByteData?> toByteData(
      {ImageByteFormat format = ImageByteFormat.rawRgba});
  void dispose();
}
