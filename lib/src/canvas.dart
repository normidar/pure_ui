import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pure_ui/src/enums.dart';
import 'package:pure_ui/src/image.dart';
import 'package:pure_ui/src/offset.dart';
import 'package:pure_ui/src/paint.dart';
import 'package:pure_ui/src/path.dart';
import 'package:pure_ui/src/picture.dart';
import 'package:pure_ui/src/picture_recorder.dart';
import 'package:pure_ui/src/rect.dart';
import 'package:pure_ui/src/text/paragraph/paragraph_builder.dart';
import 'package:pure_ui/src/vertices/vertices.dart';
import 'package:pure_ui/src/painting/gradient.dart';
import 'package:pure_ui/src/painting/tile_mode.dart';
import 'package:pure_ui/src/color.dart';

/// A canvas on which to draw.
///
/// This pure implementation mirrors the Flutter Canvas API
/// without dependencies on Flutter.
class Canvas {
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

  final Image? _image;
  final List<_CanvasOperation> _operations;
  final bool _isRecording;

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

  /// Draws the given paragraph at the given offset.
  void drawParagraph(Paragraph paragraph, Offset offset) {
    _addOperation(_CanvasOperation.drawParagraph(paragraph, offset));

    if (!_isRecording && _image != null) {
      _renderParagraph(paragraph, offset);
    }
  }

  /// Transforms the canvas by the given matrix.
  void transform(Float64List matrix4) {
    _addOperation(_CanvasOperation.transform(matrix4));

    if (!_isRecording && _image != null) {
      _renderTransform(matrix4);
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

  /// Replays recorded operations onto another canvas.
  void replayOnto(Canvas canvas) {
    for (final op in _operations) {
      op.apply(canvas);
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

  /// Records an operation.
  void _addOperation(_CanvasOperation operation) {
    _operations.add(operation);
  }

  img.BlendMode _blendModeToImgBlend(BlendMode mode) {
    return img.BlendMode.values.first;
  }

  // int _paintToColor(Paint paint) {
  //   return paint.color.value;
  // }

  // Utility methods

  List<Offset> _renderArc(
    Offset start,
    Offset center,
    Offset end,
    double radius,
    bool clockwise,
    Paint paint,
  ) {
    // Approximate with lines
    const segments = 30; // セグメント数を増加

    final startAngle = (start - center).direction;
    final endAngle = (end - center).direction;

    var sweepAngle = endAngle - startAngle;

    // Normalize sweepAngle
    if (clockwise && sweepAngle > 0) {
      sweepAngle = sweepAngle - 2 * math.pi;
    } else if (!clockwise && sweepAngle < 0) {
      sweepAngle = sweepAngle + 2 * math.pi;
    }

    var current = start;
    final List<Offset> arcPoints = [start];

    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final angle = startAngle + sweepAngle * t;

      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (paint.style == PaintingStyle.stroke) {
        _renderLine(current, point, paint);
      }
      current = point;
      arcPoints.add(point);
    }

    return arcPoints;
  }

  void _renderCircle(Offset center, double radius, Paint paint) {
    if (_image == null) return;

    final target = _image.image;

    // シェーダーがある場合はシェーダーを使用する
    if (paint.shader != null) {
      // 円の範囲を計算
      final int centerX = center.dx.round();
      final int centerY = center.dy.round();
      final int r = radius.round();

      // 円の外接矩形を計算
      final int left = (centerX - r).floor();
      final int top = (centerY - r).floor();
      final int right = (centerX + r).ceil();
      final int bottom = (centerY + r).ceil();

      // 円の内部を走査
      for (int y = top; y <= bottom; y++) {
        for (int x = left; x <= right; x++) {
          if (x < 0 || x >= target.width || y < 0 || y >= target.height) {
            continue;
          }

          // ピクセル中心からの距離を計算
          final dx = x + 0.5 - centerX;
          final dy = y + 0.5 - centerY;
          final distance = math.sqrt(dx * dx + dy * dy);

          // 円の内側ならシェーダーの色を適用
          if (distance <= r) {
            // LinearGradientの場合
            if (paint.shader is LinearGradient) {
              final gradient = paint.shader as LinearGradient;
              final colorValue = _evaluateLinearGradient(
                gradient,
                Offset(x.toDouble(), y.toDouble()),
              );
              target.setPixel(x, y, _colorToImgColor(colorValue));
            }
            // RadialGradientの場合
            else if (paint.shader is RadialGradient) {
              final gradient = paint.shader as RadialGradient;
              final colorValue = _evaluateRadialGradient(
                gradient,
                Offset(x.toDouble(), y.toDouble()),
              );
              target.setPixel(x, y, _colorToImgColor(colorValue));
            }
            // SweepGradientの場合
            else if (paint.shader is SweepGradient) {
              final gradient = paint.shader as SweepGradient;
              final colorValue = _evaluateSweepGradient(
                gradient,
                Offset(x.toDouble(), y.toDouble()),
              );
              target.setPixel(x, y, _colorToImgColor(colorValue));
            }
          }
        }
      }
      return;
    }

    // シェーダーがない場合は通常のカラー処理
    // image パッケージの最新バージョンでは RGB 値を直接使う
    final red = paint.color.red;
    final green = paint.color.green;
    final blue = paint.color.blue;
    final alpha = paint.color.alpha;

    final color = img.ColorRgba8(red, green, blue, alpha);

    // 円の中心と半径
    final centerX = center.dx;
    final centerY = center.dy;
    final r = radius;

    // アンチエイリアス処理を追加
    final double antiAliasRadius = 1.0; // アンチエイリアシングの幅

    if (paint.style == PaintingStyle.fill ||
        paint.style == PaintingStyle.stroke && paint.strokeWidth > 1) {
      // 塗りつぶし円または太い線の円
      for (int y = (centerY - r - antiAliasRadius).floor();
          y <= (centerY + r + antiAliasRadius).ceil();
          y++) {
        for (int x = (centerX - r - antiAliasRadius).floor();
            x <= (centerX + r + antiAliasRadius).ceil();
            x++) {
          if (x < 0 || x >= target.width || y < 0 || y >= target.height)
            continue;

          // ピクセル中心からの距離を計算
          final dx = x + 0.5 - centerX;
          final dy = y + 0.5 - centerY;
          final distance = math.sqrt(dx * dx + dy * dy);

          if (paint.style == PaintingStyle.fill) {
            // 塗りつぶしの場合
            if (distance <= r) {
              // 内側は完全に塗りつぶし
              if (distance >= r - antiAliasRadius) {
                // エッジ付近はアンチエイリアシング
                final opacity = (r - distance) / antiAliasRadius;
                final alphaValue = (alpha * opacity).round().clamp(0, 255);
                target.setPixel(
                  x,
                  y,
                  img.ColorRgba8(red, green, blue, alphaValue),
                );
              } else {
                // 完全に内側
                target.setPixel(x, y, color);
              }
            }
          } else if (paint.style == PaintingStyle.stroke) {
            // 輪郭の場合（太い線）
            final strokeHalfWidth = paint.strokeWidth / 2;
            final innerRadius = r - strokeHalfWidth;
            final outerRadius = r + strokeHalfWidth;

            if (distance >= innerRadius && distance <= outerRadius) {
              // 線の内側
              if (distance <= innerRadius + antiAliasRadius ||
                  distance >= outerRadius - antiAliasRadius) {
                // エッジ付近はアンチエイリアシング
                final opacity = distance <= innerRadius + antiAliasRadius
                    ? (distance - innerRadius) / antiAliasRadius
                    : (outerRadius - distance) / antiAliasRadius;
                final alphaValue = (alpha * opacity).round().clamp(0, 255);
                target.setPixel(
                  x,
                  y,
                  img.ColorRgba8(red, green, blue, alphaValue),
                );
              } else {
                // 線の中央部分
                target.setPixel(x, y, color);
              }
            }
          }
        }
      }
    } else if (paint.style == PaintingStyle.stroke) {
      // 細い線の場合はimageパッケージのdrawCircleを使用
      img.drawCircle(
        target,
        x: centerX.round(),
        y: centerY.round(),
        radius: radius.round(),
        color: color,
        antialias: true,
      );
    }
  }

  List<Offset> _renderCubicBezier(
    Offset start,
    Offset control1,
    Offset control2,
    Offset end,
    Paint paint,
  ) {
    // Approximate with lines
    const segments = 30; // 増加したセグメント数
    var current = start;
    final List<Offset> bezierPoints = [start]; // ベジェ曲線の点を収集

    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final oneMinusT = 1 - t;

      final point = Offset(
        oneMinusT * oneMinusT * oneMinusT * start.dx +
            3 * oneMinusT * oneMinusT * t * control1.dx +
            3 * oneMinusT * t * t * control2.dx +
            t * t * t * end.dx,
        oneMinusT * oneMinusT * oneMinusT * start.dy +
            3 * oneMinusT * oneMinusT * t * control1.dy +
            3 * oneMinusT * t * t * control2.dy +
            t * t * t * end.dy,
      );

      if (paint.style == PaintingStyle.stroke) {
        _renderLine(current, point, paint);
      }
      current = point;
      bezierPoints.add(point); // 全ての点を記録
    }

    // ベジェ曲線の点のリストを返す
    return bezierPoints;
  }

  void _renderImage(Image image, Offset offset, Paint paint) {
    if (_image == null) return;

    final target = _image.image;
    final source = image.image;

    img.compositeImage(
      target,
      source,
      dstX: offset.dx.round(),
      dstY: offset.dy.round(),
      blend: _blendModeToImgBlend(paint.blendMode),
    );
  }

  void _renderImageRect(Image image, Rect src, Rect dst, Paint paint) {
    if (_image == null) return;

    final target = _image.image;
    final source = image.image;

    // Crop and resize the source image
    final croppedSource = img.copyCrop(
      source,
      x: src.left.round(),
      y: src.top.round(),
      width: src.width.round(),
      height: src.height.round(),
    );

    final resizedSource = img.copyResize(
      croppedSource,
      width: dst.width.round(),
      height: dst.height.round(),
    );

    img.compositeImage(
      target,
      resizedSource,
      dstX: dst.left.round(),
      dstY: dst.top.round(),
      blend: _blendModeToImgBlend(paint.blendMode),
    );
  }

  // Rendering implementations

  void _renderLine(Offset p1, Offset p2, Paint paint) {
    if (_image == null) return;

    final target = _image.image;

    // シェーダーがある場合はシェーダーを使用する
    if (paint.shader != null) {
      // 線分の方程式に基づいて各ピクセルを計算
      final lineDx = p2.dx - p1.dx;
      final lineDy = p2.dy - p1.dy;
      final length = math.sqrt(lineDx * lineDx + lineDy * lineDy);

      if (length < 1) {
        // 長さが非常に短い場合は単一点として描画
        final x = p1.dx.round();
        final y = p1.dy.round();
        if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
          // LinearGradientの場合
          if (paint.shader is LinearGradient) {
            final gradient = paint.shader as LinearGradient;
            final colorValue = _evaluateLinearGradient(
              gradient,
              Offset(x.toDouble(), y.toDouble()),
            );
            target.setPixel(x, y, _colorToImgColor(colorValue));
          }
          // RadialGradientの場合
          else if (paint.shader is RadialGradient) {
            final gradient = paint.shader as RadialGradient;
            final colorValue = _evaluateRadialGradient(
              gradient,
              Offset(x.toDouble(), y.toDouble()),
            );
            target.setPixel(x, y, _colorToImgColor(colorValue));
          }
          // SweepGradientの場合
          else if (paint.shader is SweepGradient) {
            final gradient = paint.shader as SweepGradient;
            final colorValue = _evaluateSweepGradient(
              gradient,
              Offset(x.toDouble(), y.toDouble()),
            );
            target.setPixel(x, y, _colorToImgColor(colorValue));
          }
        }
        return;
      }

      // 線の幅を考慮
      final halfWidth = (paint.strokeWidth / 2).round();
      if (halfWidth <= 0) {
        // 太さが1px以下の場合はブレゼンハムのアルゴリズムで描画
        final steep = lineDy.abs() > lineDx.abs();

        // x,y座標を入れ替え
        int x0, y0, x1, y1;
        if (steep) {
          x0 = p1.dy.round();
          y0 = p1.dx.round();
          x1 = p2.dy.round();
          y1 = p2.dx.round();
        } else {
          x0 = p1.dx.round();
          y0 = p1.dy.round();
          x1 = p2.dx.round();
          y1 = p2.dy.round();
        }

        // 常に左から右へ描画
        if (x0 > x1) {
          final temp = x0;
          x0 = x1;
          x1 = temp;
          final temp2 = y0;
          y0 = y1;
          y1 = temp2;
        }

        final lineDeltaX = x1 - x0;
        final lineDeltaY = (y1 - y0).abs();
        int error = lineDeltaX ~/ 2;
        int ystep = (y0 < y1) ? 1 : -1;
        int y = y0;

        for (int x = x0; x <= x1; x++) {
          int px, py;
          if (steep) {
            px = y;
            py = x;
          } else {
            px = x;
            py = y;
          }

          if (px >= 0 && px < target.width && py >= 0 && py < target.height) {
            // LinearGradientの場合
            if (paint.shader is LinearGradient) {
              final gradient = paint.shader as LinearGradient;
              final colorValue = _evaluateLinearGradient(
                gradient,
                Offset(px.toDouble(), py.toDouble()),
              );
              target.setPixel(px, py, _colorToImgColor(colorValue));
            }
            // RadialGradientの場合
            else if (paint.shader is RadialGradient) {
              final gradient = paint.shader as RadialGradient;
              final colorValue = _evaluateRadialGradient(
                gradient,
                Offset(px.toDouble(), py.toDouble()),
              );
              target.setPixel(px, py, _colorToImgColor(colorValue));
            }
            // SweepGradientの場合
            else if (paint.shader is SweepGradient) {
              final gradient = paint.shader as SweepGradient;
              final colorValue = _evaluateSweepGradient(
                gradient,
                Offset(px.toDouble(), py.toDouble()),
              );
              target.setPixel(px, py, _colorToImgColor(colorValue));
            }
          }

          error -= lineDeltaY;
          if (error < 0) {
            y += ystep;
            error += lineDeltaX;
          }
        }
      } else {
        // 線の範囲を計算
        final x0 = math.min(p1.dx, p2.dx) - halfWidth;
        final y0 = math.min(p1.dy, p2.dy) - halfWidth;
        final x1 = math.max(p1.dx, p2.dx) + halfWidth;
        final y1 = math.max(p1.dy, p2.dy) + halfWidth;

        for (int y = y0.floor(); y <= y1.ceil(); y++) {
          for (int x = x0.floor(); x <= x1.ceil(); x++) {
            if (x < 0 || x >= target.width || y < 0 || y >= target.height) {
              continue;
            }

            // 点と線の距離を計算
            final px = x - p1.dx;
            final py = y - p1.dy;

            // 線上の最も近い点のパラメータtを計算
            final t = (px * lineDx + py * lineDy) / (length * length);

            if (t < 0 || t > 1) {
              // 線分の外側
              continue;
            }

            // 線上の最も近い点
            final nearestX = p1.dx + t * lineDx;
            final nearestY = p1.dy + t * lineDy;

            // 点と線の距離
            final distance = math.sqrt(
              (x - nearestX) * (x - nearestX) + (y - nearestY) * (y - nearestY),
            );

            if (distance <= paint.strokeWidth / 2) {
              // LinearGradientの場合
              if (paint.shader is LinearGradient) {
                final gradient = paint.shader as LinearGradient;
                final colorValue = _evaluateLinearGradient(
                  gradient,
                  Offset(x.toDouble(), y.toDouble()),
                );
                target.setPixel(x, y, _colorToImgColor(colorValue));
              }
              // RadialGradientの場合
              else if (paint.shader is RadialGradient) {
                final gradient = paint.shader as RadialGradient;
                final colorValue = _evaluateRadialGradient(
                  gradient,
                  Offset(x.toDouble(), y.toDouble()),
                );
                target.setPixel(x, y, _colorToImgColor(colorValue));
              }
              // SweepGradientの場合
              else if (paint.shader is SweepGradient) {
                final gradient = paint.shader as SweepGradient;
                final colorValue = _evaluateSweepGradient(
                  gradient,
                  Offset(x.toDouble(), y.toDouble()),
                );
                target.setPixel(x, y, _colorToImgColor(colorValue));
              }
            }
          }
        }
      }
      return;
    }

    // シェーダーがない場合は通常のカラー処理
    // image パッケージの最新バージョンでは RGB 値を直接使う
    final red = paint.color.red;
    final green = paint.color.green;
    final blue = paint.color.blue;
    final alpha = paint.color.alpha;

    // Use image package to draw a line
    img.drawLine(
      target,
      x1: p1.dx.round(),
      y1: p1.dy.round(),
      x2: p2.dx.round(),
      y2: p2.dy.round(),
      color: img.ColorRgba8(red, green, blue, alpha),
      thickness: paint.strokeWidth.round(),
    );
  }

  void _renderOval(Rect rect, Paint paint) {
    if (_image == null) return;

    final target = _image.image;

    // 楕円の中心と半径を計算
    final centerX = rect.left + rect.width / 2;
    final centerY = rect.top + rect.height / 2;
    final radiusX = rect.width / 2;
    final radiusY = rect.height / 2;

    // シェーダーがある場合はシェーダーを使用する
    if (paint.shader != null) {
      // 輪郭処理はパスを通して行う
      if (paint.style == PaintingStyle.stroke) {
        final path = Path()..addOval(rect);
        _renderPath(path, paint);
        return;
      }

      // 塗りつぶし処理
      if (paint.style == PaintingStyle.fill) {
        // 楕円の各ピクセルを直接計算して描画
        final centerXi = centerX.round();
        final centerYi = centerY.round();
        final radiusXi = radiusX.round();
        final radiusYi = radiusY.round();

        // 楕円の範囲内を走査
        for (int y = centerYi - radiusYi; y <= centerYi + radiusYi; y++) {
          for (int x = centerXi - radiusXi; x <= centerXi + radiusXi; x++) {
            // 楕円の方程式: (x-h)²/a² + (y-k)²/b² <= 1
            final dx = x - centerXi;
            final dy = y - centerYi;

            // 正しい楕円の式を使用
            final value = (dx * dx) / (radiusXi * radiusXi) +
                (dy * dy) / (radiusYi * radiusYi);

            if (value <= 1.0) {
              if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
                // LinearGradientの場合
                if (paint.shader is LinearGradient) {
                  final gradient = paint.shader as LinearGradient;
                  final colorValue = _evaluateLinearGradient(
                    gradient,
                    Offset(x.toDouble(), y.toDouble()),
                  );
                  target.setPixel(x, y, _colorToImgColor(colorValue));
                }
                // RadialGradientの場合
                else if (paint.shader is RadialGradient) {
                  final gradient = paint.shader as RadialGradient;
                  final colorValue = _evaluateRadialGradient(
                    gradient,
                    Offset(x.toDouble(), y.toDouble()),
                  );
                  target.setPixel(x, y, _colorToImgColor(colorValue));
                }
                // SweepGradientの場合
                else if (paint.shader is SweepGradient) {
                  final gradient = paint.shader as SweepGradient;
                  final colorValue = _evaluateSweepGradient(
                    gradient,
                    Offset(x.toDouble(), y.toDouble()),
                  );
                  target.setPixel(x, y, _colorToImgColor(colorValue));
                }
              }
            }
          }
        }
      }
      return;
    }

    // シェーダーがない場合は通常のカラー処理
    // RGB値を取得
    final red = paint.color.red;
    final green = paint.color.green;
    final blue = paint.color.blue;
    final alpha = paint.color.alpha;
    final color = img.ColorRgba8(red, green, blue, alpha);

    // 輪郭処理はパスを通して行う
    if (paint.style == PaintingStyle.stroke) {
      final path = Path()..addOval(rect);
      _renderPath(path, paint);
      return;
    }

    // 塗りつぶし処理
    if (paint.style == PaintingStyle.fill) {
      // 楕円の各ピクセルを直接計算して描画
      final centerXi = centerX.round();
      final centerYi = centerY.round();
      final radiusXi = radiusX.round();
      final radiusYi = radiusY.round();

      // 楕円の範囲内を走査
      for (int y = centerYi - radiusYi; y <= centerYi + radiusYi; y++) {
        for (int x = centerXi - radiusXi; x <= centerXi + radiusXi; x++) {
          // 楕円の方程式: (x-h)²/a² + (y-k)²/b² <= 1
          final dx = x - centerXi;
          final dy = y - centerYi;

          // 正しい楕円の式を使用
          final value = (dx * dx) / (radiusXi * radiusXi) +
              (dy * dy) / (radiusYi * radiusYi);

          if (value <= 1.0) {
            if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
              target.setPixel(x, y, color);
            }
          }
        }
      }
    }
  }

  void _renderPath(Path path, Paint paint) {
    if (_image == null) return;

    // For simplicity, convert the path to a series of lines and render those
    final commands = path.commands;
    final points = path.points;

    if (commands.isEmpty) return;

    var currentPoint = Offset.zero;
    var pointIndex = 0;

    // SVGのfill処理のために、パスの点を収集
    final List<Offset> pathPoints = [];

    for (var i = 0; i < commands.length; i++) {
      final command = commands[i];

      switch (command) {
        case PathCommand.moveTo:
          currentPoint = points[pointIndex++];
          pathPoints.add(currentPoint);
        case PathCommand.lineTo:
          final nextPoint = points[pointIndex++];
          if (paint.style == PaintingStyle.stroke) {
            _renderLine(currentPoint, nextPoint, paint);
          }
          currentPoint = nextPoint;
          pathPoints.add(currentPoint);
        case PathCommand.quadraticBezierTo:
          final controlPoint = points[pointIndex++];
          final endPoint = points[pointIndex++];

          // 二次ベジェ曲線を描画して、詳細な点のリストを取得
          final bezierPoints = _renderQuadraticBezier(
            currentPoint,
            controlPoint,
            endPoint,
            paint,
          );

          // 塗りつぶし用に、より詳細な点のリストを追加
          if (paint.style == PaintingStyle.fill && bezierPoints.length > 1) {
            // 最初の点は既に追加済みの場合があるので、2番目の点から追加
            pathPoints.addAll(bezierPoints.sublist(1));
          } else {
            // strokeの場合や、fillでも1点だけの場合は終点のみ追加
            pathPoints.add(endPoint);
          }

          currentPoint = endPoint;
        case PathCommand.cubicTo:
          final controlPoint1 = points[pointIndex++];
          final controlPoint2 = points[pointIndex++];
          final endPoint = points[pointIndex++];

          // ベジェ曲線を描画して、詳細な点のリストを取得
          final bezierPoints = _renderCubicBezier(
            currentPoint,
            controlPoint1,
            controlPoint2,
            endPoint,
            paint,
          );

          // 塗りつぶし用に、より詳細な点のリストを追加
          if (paint.style == PaintingStyle.fill && bezierPoints.length > 1) {
            // 最初の点は既に追加済みの場合があるので、2番目の点から追加
            pathPoints.addAll(bezierPoints.sublist(1));
          } else {
            // strokeの場合や、fillでも1点だけの場合は終点のみ追加
            pathPoints.add(endPoint);
          }

          currentPoint = endPoint;
        case PathCommand.arcTo:
          final center = points[pointIndex++];
          final endPoint = points[pointIndex++];
          final radiusAndClockwise = points[pointIndex++];

          // アークも詳細な点のリストを生成するように修正
          final arcPoints = _renderArc(
            currentPoint,
            center,
            endPoint,
            radiusAndClockwise.dx,
            radiusAndClockwise.dy > 0,
            paint,
          );

          if (paint.style == PaintingStyle.fill && arcPoints.length > 1) {
            pathPoints.addAll(arcPoints.sublist(1));
          } else {
            pathPoints.add(endPoint);
          }

          currentPoint = endPoint;
        case PathCommand.close:
          // パスを閉じる
          if (pathPoints.isNotEmpty) {
            if (paint.style == PaintingStyle.stroke) {
              _renderLine(currentPoint, pathPoints.first, paint);
            }
            // 塗りつぶしモードの場合でも、最初の点に戻ることを明示的に示す
            if (currentPoint != pathPoints.first) {
              pathPoints.add(pathPoints.first);
            }
          }
          break;
      }
    }

    // fillが指定されている場合、パスの内部を塗りつぶす
    if (paint.style == PaintingStyle.fill && pathPoints.length > 2) {
      _fillPolygon(pathPoints, paint);
    }
  }

  void _renderPicture(Picture picture) {
    // Create a temporary canvas for the image
    final Image tempImage = _image!.clone();
    final Canvas tempCanvas = Canvas.forImage(tempImage);

    // Replay picture operations onto the temporary canvas
    picture.playback(tempCanvas);

    // Now copy the rendered image back to our canvas
    // This avoids the recursive loop of playback onto self
    final targetImg = _image.image;
    final sourceImg = tempImage.image;

    // Copy all pixels from the source to target
    for (int y = 0; y < sourceImg.height; y++) {
      for (int x = 0; x < sourceImg.width; x++) {
        final pixel = sourceImg.getPixel(x, y);
        targetImg.setPixel(x, y, pixel);
      }
    }

    // Dispose of temporary resources
    tempImage.dispose();
  }

  List<Offset> _renderQuadraticBezier(
    Offset start,
    Offset control,
    Offset end,
    Paint paint,
  ) {
    // Approximate with lines
    const segments = 20; // セグメント数を増加
    var current = start;
    final List<Offset> bezierPoints = [start];

    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final oneMinusT = 1 - t;

      final point = Offset(
        oneMinusT * oneMinusT * start.dx +
            2 * oneMinusT * t * control.dx +
            t * t * end.dx,
        oneMinusT * oneMinusT * start.dy +
            2 * oneMinusT * t * control.dy +
            t * t * end.dy,
      );

      if (paint.style == PaintingStyle.stroke) {
        _renderLine(current, point, paint);
      }
      current = point;
      bezierPoints.add(point);
    }

    return bezierPoints;
  }

  void _renderRect(Rect rect, Paint paint) {
    if (_image == null) return;

    final target = _image.image;

    // シェーダーがある場合はシェーダーを使用する
    if (paint.shader != null) {
      // 矩形の範囲を走査
      for (int y = rect.top.round(); y <= rect.bottom.round(); y++) {
        for (int x = rect.left.round(); x <= rect.right.round(); x++) {
          if (x < 0 || x >= target.width || y < 0 || y >= target.height) {
            continue;
          }

          // LinearGradientの場合
          if (paint.shader is LinearGradient) {
            final gradient = paint.shader as LinearGradient;
            final colorValue = _evaluateLinearGradient(
              gradient,
              Offset(x.toDouble(), y.toDouble()),
            );
            target.setPixel(x, y, _colorToImgColor(colorValue));
          }
          // RadialGradientの場合
          else if (paint.shader is RadialGradient) {
            final gradient = paint.shader as RadialGradient;
            final colorValue = _evaluateRadialGradient(
              gradient,
              Offset(x.toDouble(), y.toDouble()),
            );
            target.setPixel(x, y, _colorToImgColor(colorValue));
          }
          // SweepGradientの場合
          else if (paint.shader is SweepGradient) {
            final gradient = paint.shader as SweepGradient;
            final colorValue = _evaluateSweepGradient(
              gradient,
              Offset(x.toDouble(), y.toDouble()),
            );
            target.setPixel(x, y, _colorToImgColor(colorValue));
          }
        }
      }
      return;
    }

    // シェーダーがない場合は通常のカラー処理
    // image パッケージの最新バージョンでは RGB 値を直接使う
    final red = paint.color.red;
    final green = paint.color.green;
    final blue = paint.color.blue;
    final alpha = paint.color.alpha;

    if (paint.style == PaintingStyle.fill) {
      img.fillRect(
        target,
        x1: rect.left.round(),
        y1: rect.top.round(),
        x2: rect.right.round(),
        y2: rect.bottom.round(),
        color: img.ColorRgba8(red, green, blue, alpha),
      );
    } else {
      img.drawRect(
        target,
        x1: rect.left.round(),
        y1: rect.top.round(),
        x2: rect.right.round(),
        y2: rect.bottom.round(),
        color: img.ColorRgba8(red, green, blue, alpha),
        thickness: paint.strokeWidth.round(),
      );
    }
  }

  void _renderRRect(Rect rect, double radiusX, double radiusY, Paint paint) {
    // For simplicity, convert to a path and render that
    final path = Path()..addRRect(rect, radiusX, radiusY);
    _renderPath(path, paint);
  }

  void _renderVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    if (_image == null) return;

    // Simple implementation that renders each triangle as a filled path
    final List<Offset> positions = vertices.positions;
    final List<int>? indices = vertices.indices;

    final Path path = Path();

    if (indices != null) {
      // Render triangles using indices
      for (int i = 0; i < indices.length; i += 3) {
        if (i + 2 < indices.length) {
          final Offset p1 = positions[indices[i]];
          final Offset p2 = positions[indices[i + 1]];
          final Offset p3 = positions[indices[i + 2]];

          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy);
          path.lineTo(p3.dx, p3.dy);
          path.close();
        }
      }
    } else {
      // Render triangles in sequence
      for (int i = 0; i < positions.length; i += 3) {
        if (i + 2 < positions.length) {
          final Offset p1 = positions[i];
          final Offset p2 = positions[i + 1];
          final Offset p3 = positions[i + 2];

          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy);
          path.lineTo(p3.dx, p3.dy);
          path.close();
        }
      }
    }

    _renderPath(path, paint);
  }

  void _renderParagraph(Paragraph paragraph, Offset offset) {
    if (_image == null) return;

    final target = _image.image;
    final text = paragraph.text;

    // テキストスタイルから色とフォントサイズを取得
    final textStyle = paragraph.textStyle;
    final color = textStyle.color ?? const Color(0xFF000000);
    final fontSize = textStyle.fontSize ?? 14.0;

    // 基本的なビットマップフォント描画
    _drawSimpleText(target, text, offset, color, fontSize);
  }

  // シンプルなテキスト描画メソッド
  void _drawSimpleText(
    img.Image target,
    String text,
    Offset offset,
    Color color,
    double fontSize,
  ) {
    final imgColor = img.ColorRgba8(
      color.red,
      color.green,
      color.blue,
      color.alpha,
    );

    // 文字サイズに基づいてピクセルサイズを決定
    final charWidth = (fontSize * 0.6).round();
    final charHeight = fontSize.round();

    var x = offset.dx.round();
    var y = offset.dy.round();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '\n') {
        // 改行処理
        x = offset.dx.round();
        y += (charHeight * 1.2).round();
        continue;
      }

      // 各文字を簡単なピクセルパターンで描画
      _drawCharacter(target, char, x, y, charWidth, charHeight, imgColor);

      x += charWidth;

      // 画面外に出た場合は改行
      if (x + charWidth > target.width) {
        x = offset.dx.round();
        y += (charHeight * 1.2).round();
      }
    }
  }

  // 文字を描画するメソッド（シンプルなビットマップパターン）
  void _drawCharacter(
    img.Image target,
    String char,
    int x,
    int y,
    int width,
    int height,
    img.Color color,
  ) {
    // 基本的な文字パターン（5x7ピクセル）を使用
    final pattern = _getCharacterPattern(char);

    for (int py = 0; py < pattern.length && y + py < target.height; py++) {
      for (int px = 0; px < pattern[py].length && x + px < target.width; px++) {
        if (pattern[py][px] == 1 && x + px >= 0 && y + py >= 0) {
          target.setPixel(x + px, y + py, color);
        }
      }
    }
  }

  // 文字パターンを取得（5x7ピクセルの基本パターン）
  List<List<int>> _getCharacterPattern(String char) {
    switch (char) {
      case 'A':
      case 'a':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'B':
      case 'b':
        return [
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'C':
      case 'c':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'D':
      case 'd':
        return [
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'E':
      case 'e':
        return [
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'F':
      case 'f':
        return [
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'G':
      case 'g':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 0],
          [1, 0, 1, 1, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'H':
      case 'h':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'I':
      case 'i':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'J':
      case 'j':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 0, 1, 0],
          [0, 0, 0, 1, 0],
          [1, 0, 0, 1, 0],
          [0, 1, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'K':
      case 'k':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 1, 0],
          [1, 0, 1, 0, 0],
          [1, 1, 0, 0, 0],
          [1, 0, 1, 0, 0],
          [1, 0, 0, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'L':
      case 'l':
        return [
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'M':
      case 'm':
        return [
          [1, 0, 0, 0, 1],
          [1, 1, 0, 1, 1],
          [1, 0, 1, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'N':
      case 'n':
        return [
          [1, 0, 0, 0, 1],
          [1, 1, 0, 0, 1],
          [1, 0, 1, 0, 1],
          [1, 0, 0, 1, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'O':
      case 'o':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'P':
      case 'p':
        return [
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'Q':
      case 'q':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 1, 0, 1],
          [1, 0, 0, 1, 1],
          [0, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'R':
      case 'r':
        return [
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [1, 0, 1, 0, 0],
          [1, 0, 0, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'S':
      case 's':
        return [
          [0, 1, 1, 1, 1],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'T':
      case 't':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'U':
      case 'u':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'V':
      case 'v':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'W':
      case 'w':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 1, 0, 1],
          [1, 1, 0, 1, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'X':
      case 'x':
        return [
          [1, 0, 0, 0, 1],
          [0, 1, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'Y':
      case 'y':
        return [
          [1, 0, 0, 0, 1],
          [0, 1, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'Z':
      case 'z':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case '0':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 1, 1],
          [1, 0, 1, 0, 1],
          [1, 1, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '1':
        return [
          [0, 0, 1, 0, 0],
          [0, 1, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '2':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case '3':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 0, 1, 1, 0],
          [0, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '4':
        return [
          [0, 0, 0, 1, 0],
          [0, 0, 1, 1, 0],
          [0, 1, 0, 1, 0],
          [1, 0, 0, 1, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '5':
        return [
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [0, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '6':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '7':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case '8':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '9':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 1],
          [0, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case ' ':
        return [
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case '!':
        return [
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case '?':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case '.':
        return [
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case ',':
        return [
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case ':':
        return [
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      // 基本的な日本語文字のサポート
      case 'こ':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 1, 0, 1, 0],
          [1, 1, 0, 1, 1],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'ん':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 1, 0, 0, 0],
          [1, 0, 1, 1, 1],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'に':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'ち':
        return [
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [0, 1, 1, 1, 0],
          [1, 0, 1, 0, 1],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'は':
        return [
          [1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1],
          [1, 1, 1, 1, 1],
          [1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case '世':
        return [
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case '界':
        return [
          [1, 1, 1, 1, 1],
          [1, 0, 1, 0, 1],
          [1, 1, 1, 1, 1],
          [1, 0, 1, 0, 1],
          [1, 0, 1, 0, 1],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      default:
        // 不明な文字の場合は四角形で表示
        return [
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 1, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
    }
  }

  void _renderTransform(Float64List matrix4) {
    // In a real implementation, we would apply the transform to all subsequent drawing operations
    // For this placeholder, we don't do anything as the _image doesn't support transformations directly
  }

  void _renderSaveLayer(Rect? bounds, Paint paint) {
    // In a real implementation, we would create a new bitmap buffer
    // For this placeholder, we don't do anything as we're not supporting layers
  }

  void _renderClipPath(Path path) {
    // In a real implementation, we would set up clipping
    // For this placeholder, we don't do anything as the _image doesn't support clipping
  }

  void _renderClipRect(Rect rect) {
    // In a real implementation, we would set up clipping
    // For this placeholder, we don't do anything as the _image doesn't support clipping
  }

  // 多角形の内部を塗りつぶすヘルパーメソッド
  void _fillPolygon(List<Offset> points, Paint paint) {
    if (_image == null || points.length < 3) return;

    final target = _image.image;

    // 範囲を計算
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in points) {
      minX = math.min(minX, point.dx);
      minY = math.min(minY, point.dy);
      maxX = math.max(maxX, point.dx);
      maxY = math.max(maxY, point.dy);
    }

    // シェーダーがある場合はシェーダーを使用する
    if (paint.shader != null) {
      // 多角形の範囲を走査
      for (int y = minY.floor(); y <= maxY.ceil(); y++) {
        final List<double> intersections = [];

        // 各エッジとのy交点を見つける
        for (int i = 0; i < points.length - 1; i++) {
          final p1 = points[i];
          final p2 = points[i + 1];

          if ((p1.dy <= y && p2.dy > y) || (p2.dy <= y && p1.dy > y)) {
            // エッジがスキャンラインと交差する場合
            if (p1.dy != p2.dy) {
              // 水平線でない場合
              final x = p1.dx + (y - p1.dy) / (p2.dy - p1.dy) * (p2.dx - p1.dx);
              intersections.add(x);
            }
          }
        }

        // 交点をソート
        intersections.sort();

        // 交点ペアの間を塗りつぶす
        for (int i = 0; i < intersections.length - 1; i += 2) {
          if (i + 1 < intersections.length) {
            final startX = intersections[i].floor();
            final endX = intersections[i + 1].ceil();

            for (int x = startX; x <= endX; x++) {
              if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
                // LinearGradientの場合
                if (paint.shader is LinearGradient) {
                  final gradient = paint.shader as LinearGradient;
                  final colorValue = _evaluateLinearGradient(
                    gradient,
                    Offset(x.toDouble(), y.toDouble()),
                  );
                  target.setPixel(x, y, _colorToImgColor(colorValue));
                }
                // RadialGradientの場合
                else if (paint.shader is RadialGradient) {
                  final gradient = paint.shader as RadialGradient;
                  final colorValue = _evaluateRadialGradient(
                    gradient,
                    Offset(x.toDouble(), y.toDouble()),
                  );
                  target.setPixel(x, y, _colorToImgColor(colorValue));
                }
                // SweepGradientの場合
                else if (paint.shader is SweepGradient) {
                  final gradient = paint.shader as SweepGradient;
                  final colorValue = _evaluateSweepGradient(
                    gradient,
                    Offset(x.toDouble(), y.toDouble()),
                  );
                  target.setPixel(x, y, _colorToImgColor(colorValue));
                }
              }
            }
          }
        }
      }
      return;
    }

    // シェーダーがない場合は通常のカラー処理
    // RGB値を取得
    final red = paint.color.red;
    final green = paint.color.green;
    final blue = paint.color.blue;
    final alpha = paint.color.alpha;

    // すべてのピクセルをチェックして、多角形内部を塗りつぶす
    final color = img.ColorRgba8(red, green, blue, alpha);

    // 簡易的な多角形塗りつぶし（スキャンライン法）
    for (int y = minY.floor(); y <= maxY.ceil(); y++) {
      final List<double> intersections = []; // intからdoubleに変更してより正確に

      // 各エッジとのy交点を見つける
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        if ((p1.dy <= y && p2.dy > y) || (p2.dy <= y && p1.dy > y)) {
          // エッジがスキャンラインと交差する場合、より正確な計算
          if (p1.dy != p2.dy) {
            // 水平線でない場合
            final x = p1.dx + (y - p1.dy) / (p2.dy - p1.dy) * (p2.dx - p1.dx);
            intersections.add(x);
          }
        }
      }

      // 交点をソート
      intersections.sort();

      // 交点ペアの間を塗りつぶす
      for (int i = 0; i < intersections.length - 1; i += 2) {
        if (i + 1 < intersections.length) {
          final startX = intersections[i].floor();
          final endX = intersections[i + 1].ceil();

          for (int x = startX; x <= endX; x++) {
            if (x >= 0 && x < target.width && y >= 0 && y < target.height) {
              target.setPixel(x, y, color);
            }
          }
        }
      }
    }
  }

  // ヘルパーメソッド: LinearGradientを評価して色を取得
  Color _evaluateLinearGradient(LinearGradient gradient, Offset point) {
    // グラデーションベクトルを計算
    final dx = gradient.to.dx - gradient.from.dx;
    final dy = gradient.to.dy - gradient.from.dy;
    final length = math.sqrt(dx * dx + dy * dy);

    // 点から開始点へのベクトル
    final px = point.dx - gradient.from.dx;
    final py = point.dy - gradient.from.dy;

    // グラデーションベクトルに沿った投影距離を計算
    double t = 0.0;
    if (length > 0) {
      // 正規化ベクトルとの内積
      t = (px * dx + py * dy) / (length * length);
    }

    // タイルモードによる処理
    switch (gradient.tileMode) {
      case TileMode.clamp:
        t = t.clamp(0.0, 1.0);
        break;
      case TileMode.repeated:
        t = t - t.floor();
        break;
      case TileMode.mirror:
        // 奇数回反転の場合は反転
        final int intPart = t.floor();
        t = intPart.isOdd ? 1.0 - (t - intPart) : t - intPart;
        break;
      // デフォルトはclamp
      default:
        t = t.clamp(0.0, 1.0);
        break;
    }

    // カラーの補間
    return _interpolateGradientColor(gradient.colors, gradient.stops, t);
  }

  // ヘルパーメソッド: RadialGradientを評価して色を取得
  Color _evaluateRadialGradient(RadialGradient gradient, Offset point) {
    // 点から中心へのベクトル
    final dx = point.dx - gradient.center.dx;
    final dy = point.dy - gradient.center.dy;

    // 中心からの距離を計算
    final distance = math.sqrt(dx * dx + dy * dy);

    // 正規化距離
    double t = (distance / gradient.radius).clamp(0.0, 1.0);

    // タイルモードによる処理
    switch (gradient.tileMode) {
      case TileMode.clamp:
        t = t.clamp(0.0, 1.0);
        break;
      case TileMode.repeated:
        t = t - t.floor();
        break;
      case TileMode.mirror:
        // 奇数回反転の場合は反転
        final int intPart = t.floor();
        t = intPart.isOdd ? 1.0 - (t - intPart) : t - intPart;
        break;
      // デフォルトはclamp
      default:
        t = t.clamp(0.0, 1.0);
        break;
    }

    // カラーの補間
    return _interpolateGradientColor(gradient.colors, gradient.stops, t);
  }

  // ヘルパーメソッド: SweepGradientを評価して色を取得
  Color _evaluateSweepGradient(SweepGradient gradient, Offset point) {
    // 点から中心へのベクトル
    final dx = point.dx - gradient.center.dx;
    final dy = point.dy - gradient.center.dy;

    // 角度を計算（ラジアン）
    double angle = math.atan2(dy, dx);
    if (angle < 0) {
      angle += 2 * math.pi; // 0〜2πの範囲に正規化
    }

    // 開始角度から終了角度の範囲内に正規化
    final sweepAngle = gradient.endAngle - gradient.startAngle;
    final normalizedAngle = angle - gradient.startAngle;

    // 0～1の範囲にマッピング
    double t = (normalizedAngle / sweepAngle).clamp(0.0, 1.0);

    // タイルモードによる処理
    switch (gradient.tileMode) {
      case TileMode.clamp:
        t = t.clamp(0.0, 1.0);
        break;
      case TileMode.repeated:
        t = t - t.floor();
        break;
      case TileMode.mirror:
        // 奇数回反転の場合は反転
        final int intPart = t.floor();
        t = intPart.isOdd ? 1.0 - (t - intPart) : t - intPart;
        break;
      // デフォルトはclamp
      default:
        t = t.clamp(0.0, 1.0);
        break;
    }

    // カラーの補間
    return _interpolateGradientColor(gradient.colors, gradient.stops, t);
  }

  // ヘルパーメソッド: グラデーションの色を補間
  Color _interpolateGradientColor(
    List<Color> colors,
    List<double>? stops,
    double t,
  ) {
    if (colors.isEmpty) {
      return Color.black;
    }
    if (colors.length == 1) {
      return colors[0];
    }

    // stopsが指定されていない場合は等間隔で配置
    final List<double> effectiveStops;
    if (stops == null || stops.isEmpty) {
      effectiveStops = List<double>.generate(
        colors.length,
        (i) => i / (colors.length - 1),
      );
    } else {
      effectiveStops = stops;
    }

    // tに最も近いstopsのインデックスを見つける
    int startIndex = 0;
    for (int i = 0; i < effectiveStops.length; i++) {
      if (effectiveStops[i] > t) {
        break;
      }
      startIndex = i;
    }

    // 最後のカラーの場合
    if (startIndex >= colors.length - 1) {
      return colors.last;
    }

    // 2つの色の間を補間
    final startColor = colors[startIndex];
    final endColor = colors[startIndex + 1];
    final startStop = effectiveStops[startIndex];
    final endStop = effectiveStops[startIndex + 1];

    // 正規化
    final localT = (endStop > startStop)
        ? ((t - startStop) / (endStop - startStop)).clamp(0.0, 1.0)
        : 0.0;

    // 色を線形補間
    return Color.lerp(startColor, endColor, localT);
  }

  // Colorをimg.ColorRgba8に変換
  img.ColorRgba8 _colorToImgColor(Color color) {
    return img.ColorRgba8(color.red, color.green, color.blue, color.alpha);
  }
}

/// A canvas operation.
class _CanvasOperation {
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
