// Value-type and enum conversions between the interface layer and dart:ui.
//
// Requires the Flutter SDK (for `dart:ui`). Conversions mirror those in
// pure_ui_adapter but target engine types. Enums are mapped with explicit
// switches (plan §4.2) — never by index.

import 'dart:ui' as ui;

import 'package:dart_ui_interface/dart_ui_interface.dart' as i;

// --- value types ---

ui.Offset offsetToUi(i.Offset o) => ui.Offset(o.dx, o.dy);
i.Offset offsetFromUi(ui.Offset o) => i.Offset(o.dx, o.dy);

ui.Size sizeToUi(i.Size s) => ui.Size(s.width, s.height);
i.Size sizeFromUi(ui.Size s) => i.Size(s.width, s.height);

ui.Rect rectToUi(i.Rect r) =>
    ui.Rect.fromLTRB(r.left, r.top, r.right, r.bottom);
i.Rect rectFromUi(ui.Rect r) =>
    i.Rect.fromLTRB(r.left, r.top, r.right, r.bottom);

ui.Radius radiusToUi(i.Radius r) => ui.Radius.elliptical(r.x, r.y);

ui.RRect rrectToUi(i.RRect r) => ui.RRect.fromLTRBAndCorners(
  r.left,
  r.top,
  r.right,
  r.bottom,
  topLeft: radiusToUi(r.tlRadius),
  topRight: radiusToUi(r.trRadius),
  bottomRight: radiusToUi(r.brRadius),
  bottomLeft: radiusToUi(r.blRadius),
);

ui.Color colorToUi(i.Color c) =>
    ui.Color.from(alpha: c.a, red: c.r, green: c.g, blue: c.b);
i.Color colorFromUi(ui.Color c) =>
    i.Color.from(alpha: c.a, red: c.r, green: c.g, blue: c.b);

// --- enums ---

ui.PaintingStyle paintingStyleToUi(i.PaintingStyle v) {
  switch (v) {
    case i.PaintingStyle.fill:
      return ui.PaintingStyle.fill;
    case i.PaintingStyle.stroke:
      return ui.PaintingStyle.stroke;
  }
}

i.PaintingStyle paintingStyleFromUi(ui.PaintingStyle v) {
  switch (v) {
    case ui.PaintingStyle.fill:
      return i.PaintingStyle.fill;
    case ui.PaintingStyle.stroke:
      return i.PaintingStyle.stroke;
  }
}

ui.StrokeCap strokeCapToUi(i.StrokeCap v) {
  switch (v) {
    case i.StrokeCap.butt:
      return ui.StrokeCap.butt;
    case i.StrokeCap.round:
      return ui.StrokeCap.round;
    case i.StrokeCap.square:
      return ui.StrokeCap.square;
  }
}

i.StrokeCap strokeCapFromUi(ui.StrokeCap v) {
  switch (v) {
    case ui.StrokeCap.butt:
      return i.StrokeCap.butt;
    case ui.StrokeCap.round:
      return i.StrokeCap.round;
    case ui.StrokeCap.square:
      return i.StrokeCap.square;
  }
}

ui.StrokeJoin strokeJoinToUi(i.StrokeJoin v) {
  switch (v) {
    case i.StrokeJoin.miter:
      return ui.StrokeJoin.miter;
    case i.StrokeJoin.round:
      return ui.StrokeJoin.round;
    case i.StrokeJoin.bevel:
      return ui.StrokeJoin.bevel;
  }
}

i.StrokeJoin strokeJoinFromUi(ui.StrokeJoin v) {
  switch (v) {
    case ui.StrokeJoin.miter:
      return i.StrokeJoin.miter;
    case ui.StrokeJoin.round:
      return i.StrokeJoin.round;
    case ui.StrokeJoin.bevel:
      return i.StrokeJoin.bevel;
  }
}

ui.FilterQuality filterQualityToUi(i.FilterQuality v) {
  switch (v) {
    case i.FilterQuality.none:
      return ui.FilterQuality.none;
    case i.FilterQuality.low:
      return ui.FilterQuality.low;
    case i.FilterQuality.medium:
      return ui.FilterQuality.medium;
    case i.FilterQuality.high:
      return ui.FilterQuality.high;
  }
}

i.FilterQuality filterQualityFromUi(ui.FilterQuality v) {
  switch (v) {
    case ui.FilterQuality.none:
      return i.FilterQuality.none;
    case ui.FilterQuality.low:
      return i.FilterQuality.low;
    case ui.FilterQuality.medium:
      return i.FilterQuality.medium;
    case ui.FilterQuality.high:
      return i.FilterQuality.high;
  }
}

ui.BlendMode blendModeToUi(i.BlendMode v) {
  switch (v) {
    case i.BlendMode.clear:
      return ui.BlendMode.clear;
    case i.BlendMode.src:
      return ui.BlendMode.src;
    case i.BlendMode.dst:
      return ui.BlendMode.dst;
    case i.BlendMode.srcOver:
      return ui.BlendMode.srcOver;
    case i.BlendMode.dstOver:
      return ui.BlendMode.dstOver;
    case i.BlendMode.srcIn:
      return ui.BlendMode.srcIn;
    case i.BlendMode.dstIn:
      return ui.BlendMode.dstIn;
    case i.BlendMode.srcOut:
      return ui.BlendMode.srcOut;
    case i.BlendMode.dstOut:
      return ui.BlendMode.dstOut;
    case i.BlendMode.srcATop:
      return ui.BlendMode.srcATop;
    case i.BlendMode.dstATop:
      return ui.BlendMode.dstATop;
    case i.BlendMode.xor:
      return ui.BlendMode.xor;
    case i.BlendMode.plus:
      return ui.BlendMode.plus;
    case i.BlendMode.modulate:
      return ui.BlendMode.modulate;
    case i.BlendMode.screen:
      return ui.BlendMode.screen;
    case i.BlendMode.overlay:
      return ui.BlendMode.overlay;
    case i.BlendMode.darken:
      return ui.BlendMode.darken;
    case i.BlendMode.lighten:
      return ui.BlendMode.lighten;
    case i.BlendMode.colorDodge:
      return ui.BlendMode.colorDodge;
    case i.BlendMode.colorBurn:
      return ui.BlendMode.colorBurn;
    case i.BlendMode.hardLight:
      return ui.BlendMode.hardLight;
    case i.BlendMode.softLight:
      return ui.BlendMode.softLight;
    case i.BlendMode.difference:
      return ui.BlendMode.difference;
    case i.BlendMode.exclusion:
      return ui.BlendMode.exclusion;
    case i.BlendMode.multiply:
      return ui.BlendMode.multiply;
    case i.BlendMode.hue:
      return ui.BlendMode.hue;
    case i.BlendMode.saturation:
      return ui.BlendMode.saturation;
    case i.BlendMode.color:
      return ui.BlendMode.color;
    case i.BlendMode.luminosity:
      return ui.BlendMode.luminosity;
  }
}

i.BlendMode blendModeFromUi(ui.BlendMode v) {
  switch (v) {
    case ui.BlendMode.clear:
      return i.BlendMode.clear;
    case ui.BlendMode.src:
      return i.BlendMode.src;
    case ui.BlendMode.dst:
      return i.BlendMode.dst;
    case ui.BlendMode.srcOver:
      return i.BlendMode.srcOver;
    case ui.BlendMode.dstOver:
      return i.BlendMode.dstOver;
    case ui.BlendMode.srcIn:
      return i.BlendMode.srcIn;
    case ui.BlendMode.dstIn:
      return i.BlendMode.dstIn;
    case ui.BlendMode.srcOut:
      return i.BlendMode.srcOut;
    case ui.BlendMode.dstOut:
      return i.BlendMode.dstOut;
    case ui.BlendMode.srcATop:
      return i.BlendMode.srcATop;
    case ui.BlendMode.dstATop:
      return i.BlendMode.dstATop;
    case ui.BlendMode.xor:
      return i.BlendMode.xor;
    case ui.BlendMode.plus:
      return i.BlendMode.plus;
    case ui.BlendMode.modulate:
      return i.BlendMode.modulate;
    case ui.BlendMode.screen:
      return i.BlendMode.screen;
    case ui.BlendMode.overlay:
      return i.BlendMode.overlay;
    case ui.BlendMode.darken:
      return i.BlendMode.darken;
    case ui.BlendMode.lighten:
      return i.BlendMode.lighten;
    case ui.BlendMode.colorDodge:
      return i.BlendMode.colorDodge;
    case ui.BlendMode.colorBurn:
      return i.BlendMode.colorBurn;
    case ui.BlendMode.hardLight:
      return i.BlendMode.hardLight;
    case ui.BlendMode.softLight:
      return i.BlendMode.softLight;
    case ui.BlendMode.difference:
      return i.BlendMode.difference;
    case ui.BlendMode.exclusion:
      return i.BlendMode.exclusion;
    case ui.BlendMode.multiply:
      return i.BlendMode.multiply;
    case ui.BlendMode.hue:
      return i.BlendMode.hue;
    case ui.BlendMode.saturation:
      return i.BlendMode.saturation;
    case ui.BlendMode.color:
      return i.BlendMode.color;
    case ui.BlendMode.luminosity:
      return i.BlendMode.luminosity;
  }
}

ui.ClipOp clipOpToUi(i.ClipOp v) {
  switch (v) {
    case i.ClipOp.difference:
      return ui.ClipOp.difference;
    case i.ClipOp.intersect:
      return ui.ClipOp.intersect;
  }
}

ui.PathFillType pathFillTypeToUi(i.PathFillType v) {
  switch (v) {
    case i.PathFillType.nonZero:
      return ui.PathFillType.nonZero;
    case i.PathFillType.evenOdd:
      return ui.PathFillType.evenOdd;
  }
}

i.PathFillType pathFillTypeFromUi(ui.PathFillType v) {
  switch (v) {
    case ui.PathFillType.nonZero:
      return i.PathFillType.nonZero;
    case ui.PathFillType.evenOdd:
      return i.PathFillType.evenOdd;
  }
}

ui.PointMode pointModeToUi(i.PointMode v) {
  switch (v) {
    case i.PointMode.points:
      return ui.PointMode.points;
    case i.PointMode.lines:
      return ui.PointMode.lines;
    case i.PointMode.polygon:
      return ui.PointMode.polygon;
  }
}

ui.PixelFormat pixelFormatToUi(i.PixelFormat v) {
  switch (v) {
    case i.PixelFormat.rgba8888:
      return ui.PixelFormat.rgba8888;
    case i.PixelFormat.bgra8888:
      return ui.PixelFormat.bgra8888;
    case i.PixelFormat.rgbaFloat32:
      return ui.PixelFormat.rgbaFloat32;
  }
}

ui.ImageByteFormat imageByteFormatToUi(i.ImageByteFormat v) {
  switch (v) {
    case i.ImageByteFormat.rawRgba:
      return ui.ImageByteFormat.rawRgba;
    case i.ImageByteFormat.rawStraightRgba:
      return ui.ImageByteFormat.rawStraightRgba;
    case i.ImageByteFormat.rawUnmodified:
      return ui.ImageByteFormat.rawUnmodified;
    case i.ImageByteFormat.png:
      return ui.ImageByteFormat.png;
    case i.ImageByteFormat.rawExtendedRgba128:
      return ui.ImageByteFormat.rawExtendedRgba128;
  }
}

ui.TileMode tileModeToUi(i.TileMode v) {
  switch (v) {
    case i.TileMode.clamp:
      return ui.TileMode.clamp;
    case i.TileMode.repeated:
      return ui.TileMode.repeated;
    case i.TileMode.mirror:
      return ui.TileMode.mirror;
    case i.TileMode.decal:
      return ui.TileMode.decal;
  }
}

ui.VertexMode vertexModeToUi(i.VertexMode v) {
  switch (v) {
    case i.VertexMode.triangles:
      return ui.VertexMode.triangles;
    case i.VertexMode.triangleStrip:
      return ui.VertexMode.triangleStrip;
    case i.VertexMode.triangleFan:
      return ui.VertexMode.triangleFan;
  }
}

ui.BlurStyle blurStyleToUi(i.BlurStyle v) {
  switch (v) {
    case i.BlurStyle.normal:
      return ui.BlurStyle.normal;
    case i.BlurStyle.solid:
      return ui.BlurStyle.solid;
    case i.BlurStyle.outer:
      return ui.BlurStyle.outer;
    case i.BlurStyle.inner:
      return ui.BlurStyle.inner;
  }
}

// --- text enums ---

ui.TextAlign textAlignToUi(i.TextAlign v) {
  switch (v) {
    case i.TextAlign.left:
      return ui.TextAlign.left;
    case i.TextAlign.right:
      return ui.TextAlign.right;
    case i.TextAlign.center:
      return ui.TextAlign.center;
    case i.TextAlign.justify:
      return ui.TextAlign.justify;
    case i.TextAlign.start:
      return ui.TextAlign.start;
    case i.TextAlign.end:
      return ui.TextAlign.end;
  }
}

ui.TextDirection textDirectionToUi(i.TextDirection v) {
  switch (v) {
    case i.TextDirection.ltr:
      return ui.TextDirection.ltr;
    case i.TextDirection.rtl:
      return ui.TextDirection.rtl;
  }
}

ui.TextBaseline textBaselineToUi(i.TextBaseline v) {
  switch (v) {
    case i.TextBaseline.alphabetic:
      return ui.TextBaseline.alphabetic;
    case i.TextBaseline.ideographic:
      return ui.TextBaseline.ideographic;
  }
}

ui.TextDecorationStyle textDecorationStyleToUi(i.TextDecorationStyle v) {
  switch (v) {
    case i.TextDecorationStyle.solid:
      return ui.TextDecorationStyle.solid;
    case i.TextDecorationStyle.double:
      return ui.TextDecorationStyle.double;
    case i.TextDecorationStyle.dotted:
      return ui.TextDecorationStyle.dotted;
    case i.TextDecorationStyle.dashed:
      return ui.TextDecorationStyle.dashed;
    case i.TextDecorationStyle.wavy:
      return ui.TextDecorationStyle.wavy;
  }
}

ui.TextLeadingDistribution textLeadingDistributionToUi(
    i.TextLeadingDistribution v) {
  switch (v) {
    case i.TextLeadingDistribution.proportional:
      return ui.TextLeadingDistribution.proportional;
    case i.TextLeadingDistribution.even:
      return ui.TextLeadingDistribution.even;
  }
}

ui.FontStyle fontStyleToUi(i.FontStyle v) {
  switch (v) {
    case i.FontStyle.normal:
      return ui.FontStyle.normal;
    case i.FontStyle.italic:
      return ui.FontStyle.italic;
  }
}

ui.FontWeight fontWeightToUi(i.FontWeight v) =>
    ui.FontWeight.values[v.index];

ui.TextDecoration textDecorationToUi(i.TextDecoration v) {
  // Reconstruct dart:ui's decoration by ORing the named primitives, since the
  // bitmask encoding matches.
  final mask = v.mask;
  final parts = <ui.TextDecoration>[];
  if (mask & 0x1 != 0) parts.add(ui.TextDecoration.underline);
  if (mask & 0x2 != 0) parts.add(ui.TextDecoration.overline);
  if (mask & 0x4 != 0) parts.add(ui.TextDecoration.lineThrough);
  if (parts.isEmpty) return ui.TextDecoration.none;
  if (parts.length == 1) return parts.first;
  return ui.TextDecoration.combine(parts);
}

ui.Shadow shadowToUi(i.Shadow s) => ui.Shadow(
      color: colorToUi(s.color),
      offset: offsetToUi(s.offset),
      blurRadius: s.blurRadius,
    );

ui.ParagraphStyle paragraphStyleToUi(i.ParagraphStyle s) => ui.ParagraphStyle(
      textAlign: s.textAlign == null ? null : textAlignToUi(s.textAlign!),
      textDirection: s.textDirection == null
          ? null
          : textDirectionToUi(s.textDirection!),
      maxLines: s.maxLines,
      fontFamily: s.fontFamily,
      fontSize: s.fontSize,
      height: s.height,
      fontWeight: s.fontWeight == null ? null : fontWeightToUi(s.fontWeight!),
      fontStyle: s.fontStyle == null ? null : fontStyleToUi(s.fontStyle!),
      ellipsis: s.ellipsis,
    );

ui.TextStyle textStyleToUi(i.TextStyle s) => ui.TextStyle(
      color: s.color == null ? null : colorToUi(s.color!),
      decoration:
          s.decoration == null ? null : textDecorationToUi(s.decoration!),
      decorationColor:
          s.decorationColor == null ? null : colorToUi(s.decorationColor!),
      decorationStyle: s.decorationStyle == null
          ? null
          : textDecorationStyleToUi(s.decorationStyle!),
      decorationThickness: s.decorationThickness,
      fontWeight: s.fontWeight == null ? null : fontWeightToUi(s.fontWeight!),
      fontStyle: s.fontStyle == null ? null : fontStyleToUi(s.fontStyle!),
      textBaseline:
          s.textBaseline == null ? null : textBaselineToUi(s.textBaseline!),
      fontFamily: s.fontFamily,
      fontFamilyFallback: s.fontFamilyFallback,
      fontSize: s.fontSize,
      letterSpacing: s.letterSpacing,
      wordSpacing: s.wordSpacing,
      height: s.height,
      leadingDistribution: s.leadingDistribution == null
          ? null
          : textLeadingDistributionToUi(s.leadingDistribution!),
      shadows: s.shadows?.map(shadowToUi).toList(),
    );

i.LineMetrics lineMetricsFromUi(ui.LineMetrics m) => i.LineMetrics(
      hardBreak: m.hardBreak,
      ascent: m.ascent,
      descent: m.descent,
      unscaledAscent: m.unscaledAscent,
      height: m.height,
      width: m.width,
      left: m.left,
      baseline: m.baseline,
      lineNumber: m.lineNumber,
    );
