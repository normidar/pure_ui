// Value-type and enum conversions between the interface layer and pure_ui.
//
// pure_ui defines its own structurally-identical value types and enums (it
// mirrors dart:ui), so the conversions here are mechanical. They are the only
// boundary cost on the pure_ui path.

import 'package:dart_ui_interface/dart_ui_interface.dart' as i;
import 'package:pure_ui/pure_ui.dart' as p;

// --- value types ---

p.Offset offsetToPure(i.Offset o) => p.Offset(o.dx, o.dy);
i.Offset offsetFromPure(p.Offset o) => i.Offset(o.dx, o.dy);

p.Size sizeToPure(i.Size s) => p.Size(s.width, s.height);
i.Size sizeFromPure(p.Size s) => i.Size(s.width, s.height);

p.Rect rectToPure(i.Rect r) =>
    p.Rect.fromLTRB(r.left, r.top, r.right, r.bottom);
i.Rect rectFromPure(p.Rect r) =>
    i.Rect.fromLTRB(r.left, r.top, r.right, r.bottom);

p.Radius radiusToPure(i.Radius r) => p.Radius.elliptical(r.x, r.y);

p.RRect rrectToPure(i.RRect r) => p.RRect.fromLTRBAndCorners(
      r.left,
      r.top,
      r.right,
      r.bottom,
      topLeft: radiusToPure(r.tlRadius),
      topRight: radiusToPure(r.trRadius),
      bottomRight: radiusToPure(r.brRadius),
      bottomLeft: radiusToPure(r.blRadius),
    );

p.Color colorToPure(i.Color c) =>
    p.Color.from(alpha: c.a, red: c.r, green: c.g, blue: c.b);
i.Color colorFromPure(p.Color c) =>
    i.Color.from(alpha: c.a, red: c.r, green: c.g, blue: c.b);

// --- enums (explicit, never index-based) ---

p.PaintingStyle paintingStyleToPure(i.PaintingStyle v) {
  switch (v) {
    case i.PaintingStyle.fill:
      return p.PaintingStyle.fill;
    case i.PaintingStyle.stroke:
      return p.PaintingStyle.stroke;
  }
}

i.PaintingStyle paintingStyleFromPure(p.PaintingStyle v) {
  switch (v) {
    case p.PaintingStyle.fill:
      return i.PaintingStyle.fill;
    case p.PaintingStyle.stroke:
      return i.PaintingStyle.stroke;
  }
}

p.StrokeCap strokeCapToPure(i.StrokeCap v) {
  switch (v) {
    case i.StrokeCap.butt:
      return p.StrokeCap.butt;
    case i.StrokeCap.round:
      return p.StrokeCap.round;
    case i.StrokeCap.square:
      return p.StrokeCap.square;
  }
}

i.StrokeCap strokeCapFromPure(p.StrokeCap v) {
  switch (v) {
    case p.StrokeCap.butt:
      return i.StrokeCap.butt;
    case p.StrokeCap.round:
      return i.StrokeCap.round;
    case p.StrokeCap.square:
      return i.StrokeCap.square;
  }
}

p.StrokeJoin strokeJoinToPure(i.StrokeJoin v) {
  switch (v) {
    case i.StrokeJoin.miter:
      return p.StrokeJoin.miter;
    case i.StrokeJoin.round:
      return p.StrokeJoin.round;
    case i.StrokeJoin.bevel:
      return p.StrokeJoin.bevel;
  }
}

i.StrokeJoin strokeJoinFromPure(p.StrokeJoin v) {
  switch (v) {
    case p.StrokeJoin.miter:
      return i.StrokeJoin.miter;
    case p.StrokeJoin.round:
      return i.StrokeJoin.round;
    case p.StrokeJoin.bevel:
      return i.StrokeJoin.bevel;
  }
}

p.FilterQuality filterQualityToPure(i.FilterQuality v) {
  switch (v) {
    case i.FilterQuality.none:
      return p.FilterQuality.none;
    case i.FilterQuality.low:
      return p.FilterQuality.low;
    case i.FilterQuality.medium:
      return p.FilterQuality.medium;
    case i.FilterQuality.high:
      return p.FilterQuality.high;
  }
}

i.FilterQuality filterQualityFromPure(p.FilterQuality v) {
  switch (v) {
    case p.FilterQuality.none:
      return i.FilterQuality.none;
    case p.FilterQuality.low:
      return i.FilterQuality.low;
    case p.FilterQuality.medium:
      return i.FilterQuality.medium;
    case p.FilterQuality.high:
      return i.FilterQuality.high;
  }
}

p.BlendMode blendModeToPure(i.BlendMode v) {
  switch (v) {
    case i.BlendMode.clear:
      return p.BlendMode.clear;
    case i.BlendMode.src:
      return p.BlendMode.src;
    case i.BlendMode.dst:
      return p.BlendMode.dst;
    case i.BlendMode.srcOver:
      return p.BlendMode.srcOver;
    case i.BlendMode.dstOver:
      return p.BlendMode.dstOver;
    case i.BlendMode.srcIn:
      return p.BlendMode.srcIn;
    case i.BlendMode.dstIn:
      return p.BlendMode.dstIn;
    case i.BlendMode.srcOut:
      return p.BlendMode.srcOut;
    case i.BlendMode.dstOut:
      return p.BlendMode.dstOut;
    case i.BlendMode.srcATop:
      return p.BlendMode.srcATop;
    case i.BlendMode.dstATop:
      return p.BlendMode.dstATop;
    case i.BlendMode.xor:
      return p.BlendMode.xor;
    case i.BlendMode.plus:
      return p.BlendMode.plus;
    case i.BlendMode.modulate:
      return p.BlendMode.modulate;
    case i.BlendMode.screen:
      return p.BlendMode.screen;
    case i.BlendMode.overlay:
      return p.BlendMode.overlay;
    case i.BlendMode.darken:
      return p.BlendMode.darken;
    case i.BlendMode.lighten:
      return p.BlendMode.lighten;
    case i.BlendMode.colorDodge:
      return p.BlendMode.colorDodge;
    case i.BlendMode.colorBurn:
      return p.BlendMode.colorBurn;
    case i.BlendMode.hardLight:
      return p.BlendMode.hardLight;
    case i.BlendMode.softLight:
      return p.BlendMode.softLight;
    case i.BlendMode.difference:
      return p.BlendMode.difference;
    case i.BlendMode.exclusion:
      return p.BlendMode.exclusion;
    case i.BlendMode.multiply:
      return p.BlendMode.multiply;
    case i.BlendMode.hue:
      return p.BlendMode.hue;
    case i.BlendMode.saturation:
      return p.BlendMode.saturation;
    case i.BlendMode.color:
      return p.BlendMode.color;
    case i.BlendMode.luminosity:
      return p.BlendMode.luminosity;
  }
}

p.ClipOp clipOpToPure(i.ClipOp v) {
  switch (v) {
    case i.ClipOp.difference:
      return p.ClipOp.difference;
    case i.ClipOp.intersect:
      return p.ClipOp.intersect;
  }
}

p.PathFillType pathFillTypeToPure(i.PathFillType v) {
  switch (v) {
    case i.PathFillType.nonZero:
      return p.PathFillType.nonZero;
    case i.PathFillType.evenOdd:
      return p.PathFillType.evenOdd;
  }
}

i.PathFillType pathFillTypeFromPure(p.PathFillType v) {
  switch (v) {
    case p.PathFillType.nonZero:
      return i.PathFillType.nonZero;
    case p.PathFillType.evenOdd:
      return i.PathFillType.evenOdd;
  }
}

p.PointMode pointModeToPure(i.PointMode v) {
  switch (v) {
    case i.PointMode.points:
      return p.PointMode.points;
    case i.PointMode.lines:
      return p.PointMode.lines;
    case i.PointMode.polygon:
      return p.PointMode.polygon;
  }
}

p.ImageByteFormat imageByteFormatToPure(i.ImageByteFormat v) {
  switch (v) {
    case i.ImageByteFormat.rawRgba:
      return p.ImageByteFormat.rawRgba;
    case i.ImageByteFormat.rawStraightRgba:
      return p.ImageByteFormat.rawStraightRgba;
    case i.ImageByteFormat.rawUnmodified:
      return p.ImageByteFormat.rawUnmodified;
    case i.ImageByteFormat.png:
      return p.ImageByteFormat.png;
    case i.ImageByteFormat.rawExtendedRgba128:
      return p.ImageByteFormat.rawExtendedRgba128;
  }
}
