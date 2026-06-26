// Text APIs for the backend-switching architecture (plan §4.3 text slice).
//
// Style objects (TextStyle / ParagraphStyle / StrutStyle / Shadow / ...) carry
// no engine resources — they are concrete data classes here, just like the
// value types in `values.dart`. Resource-holding types (ParagraphBuilder,
// Paragraph) are abstract and dispatch through `UiBackend`.
//
// The surface intentionally targets the documented pure_ui featureset (TTF
// rendering, multi-style spans, decorations, shadows, alignment, maxLines,
// ellipsis). Advanced concerns (Locale, FontFeature, FontVariation,
// placeholders, getBoxesForRange, glyph queries) are out of scope here; users
// who need them can drop down to the concrete backend.

import 'dart:typed_data';

import 'backend.dart';
import 'values.dart';

/// Whether to use the italic type variation of glyphs in the font.
enum FontStyle {
  normal,
  italic,
}

/// The thickness of the glyphs used to draw the text. Mirrors dart:ui's
/// `FontWeight` which is itself a (non-enum) class wrapping nine fixed weights.
class FontWeight {
  const FontWeight._(this.index, this.value);

  /// 0..8 ordinal matching dart:ui.
  final int index;

  /// Numeric weight (100..900).
  final int value;

  static const FontWeight w100 = FontWeight._(0, 100);
  static const FontWeight w200 = FontWeight._(1, 200);
  static const FontWeight w300 = FontWeight._(2, 300);
  static const FontWeight w400 = FontWeight._(3, 400);
  static const FontWeight w500 = FontWeight._(4, 500);
  static const FontWeight w600 = FontWeight._(5, 600);
  static const FontWeight w700 = FontWeight._(6, 700);
  static const FontWeight w800 = FontWeight._(7, 800);
  static const FontWeight w900 = FontWeight._(8, 900);

  static const FontWeight normal = w400;
  static const FontWeight bold = w700;

  static const List<FontWeight> values = <FontWeight>[
    w100, w200, w300, w400, w500, w600, w700, w800, w900,
  ];

  @override
  bool operator ==(Object other) =>
      other is FontWeight && other.index == index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => 'FontWeight.w$value';
}

/// Horizontal alignment within a paragraph.
enum TextAlign { left, right, center, justify, start, end }

/// Writing direction.
enum TextDirection { rtl, ltr }

/// Baseline used to align glyphs vertically.
enum TextBaseline { alphabetic, ideographic }

/// Style used to paint a [TextDecoration].
enum TextDecorationStyle { solid, double, dotted, dashed, wavy }

/// How extra line-height leading is distributed.
enum TextLeadingDistribution { proportional, even }

/// A bitmask describing decorations drawn near text (underline / overline /
/// line-through). Behaves like dart:ui's class.
class TextDecoration {
  const TextDecoration._(this._mask);

  factory TextDecoration.combine(List<TextDecoration> decorations) {
    var mask = 0;
    for (final d in decorations) {
      mask |= d._mask;
    }
    return TextDecoration._(mask);
  }

  final int _mask;

  /// Bitmask backing this decoration; the value mirrors dart:ui's encoding so
  /// adapters can reconstitute the engine type cheaply.
  int get mask => _mask;

  bool contains(TextDecoration other) => (_mask | other._mask) == _mask;

  static const TextDecoration none = TextDecoration._(0x0);
  static const TextDecoration underline = TextDecoration._(0x1);
  static const TextDecoration overline = TextDecoration._(0x2);
  static const TextDecoration lineThrough = TextDecoration._(0x4);

  @override
  bool operator ==(Object other) =>
      other is TextDecoration && other._mask == _mask;

  @override
  int get hashCode => _mask;

  @override
  String toString() {
    if (_mask == 0) return 'TextDecoration.none';
    final parts = <String>[];
    if (_mask & 0x1 != 0) parts.add('underline');
    if (_mask & 0x2 != 0) parts.add('overline');
    if (_mask & 0x4 != 0) parts.add('lineThrough');
    return parts.length == 1
        ? 'TextDecoration.${parts.first}'
        : 'TextDecoration.combine([${parts.join(', ')}])';
  }
}

/// A shadow cast by a box or text.
class Shadow {
  const Shadow({
    this.color = const Color(0xFF000000),
    this.offset = Offset.zero,
    this.blurRadius = 0.0,
  });

  final Color color;
  final Offset offset;
  final double blurRadius;

  @override
  bool operator ==(Object other) =>
      other is Shadow &&
      other.color == color &&
      other.offset == offset &&
      other.blurRadius == blurRadius;

  @override
  int get hashCode => Object.hash(color, offset, blurRadius);

  @override
  String toString() =>
      'Shadow($color, $offset, ${blurRadius.toStringAsFixed(1)})';
}

/// A laid-out, immutable line metric snapshot.
class LineMetrics {
  const LineMetrics({
    required this.hardBreak,
    required this.ascent,
    required this.descent,
    required this.unscaledAscent,
    required this.height,
    required this.width,
    required this.left,
    required this.baseline,
    required this.lineNumber,
  });

  final bool hardBreak;
  final double ascent;
  final double descent;
  final double unscaledAscent;
  final double height;
  final double width;
  final double left;
  final double baseline;
  final int lineNumber;

  @override
  bool operator ==(Object other) =>
      other is LineMetrics &&
      other.hardBreak == hardBreak &&
      other.ascent == ascent &&
      other.descent == descent &&
      other.unscaledAscent == unscaledAscent &&
      other.height == height &&
      other.width == width &&
      other.left == left &&
      other.baseline == baseline &&
      other.lineNumber == lineNumber;

  @override
  int get hashCode => Object.hash(hardBreak, ascent, descent, unscaledAscent,
      height, width, left, baseline, lineNumber);
}

/// Layout constraints handed to [Paragraph.layout].
class ParagraphConstraints {
  const ParagraphConstraints({required this.width});

  final double width;

  @override
  bool operator ==(Object other) =>
      other is ParagraphConstraints && other.width == width;

  @override
  int get hashCode => width.hashCode;

  @override
  String toString() => 'ParagraphConstraints(width: $width)';
}

/// Style applied to a span of text inside a [ParagraphBuilder].
///
/// This is a concrete data class — adapters read these fields to construct
/// their backend-native equivalent at `pushStyle` time.
class TextStyle {
  const TextStyle({
    this.color,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontWeight,
    this.fontStyle,
    this.textBaseline,
    this.fontFamily,
    this.fontFamilyFallback,
    this.fontSize,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.leadingDistribution,
    this.shadows,
  });

  final Color? color;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextBaseline? textBaseline;
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final double? fontSize;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final TextLeadingDistribution? leadingDistribution;
  final List<Shadow>? shadows;

  @override
  String toString() => 'TextStyle(font: $fontFamily/$fontSize, color: $color)';
}

/// Paragraph-level layout / default-span style.
class ParagraphStyle {
  const ParagraphStyle({
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.fontFamily,
    this.fontSize,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.strutStyle,
    this.ellipsis,
    this.leadingDistribution,
  });

  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final String? fontFamily;
  final double? fontSize;
  final double? height;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final StrutStyle? strutStyle;
  final String? ellipsis;
  final TextLeadingDistribution? leadingDistribution;

  @override
  String toString() => 'ParagraphStyle(align: $textAlign, maxLines: $maxLines)';
}

/// Strut style — minimum line-box metrics independent of span content.
class StrutStyle {
  const StrutStyle({
    this.fontFamily,
    this.fontFamilyFallback,
    this.fontSize,
    this.height,
    this.leadingDistribution,
    this.leading,
    this.fontWeight,
    this.fontStyle,
    this.forceStrutHeight,
  });

  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final double? fontSize;
  final double? height;
  final TextLeadingDistribution? leadingDistribution;
  final double? leading;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final bool? forceStrutHeight;
}

/// A paragraph of laid-out text, ready to be painted.
abstract class Paragraph {
  double get width;
  double get height;
  double get longestLine;
  double get minIntrinsicWidth;
  double get maxIntrinsicWidth;
  double get alphabeticBaseline;
  double get ideographicBaseline;
  bool get didExceedMaxLines;
  int get numberOfLines;
  bool get debugDisposed;

  void layout(ParagraphConstraints constraints);
  List<LineMetrics> computeLineMetrics();
  void dispose();
}

/// Builder for [Paragraph]: push/pop styles and add text spans.
abstract class ParagraphBuilder {
  factory ParagraphBuilder(ParagraphStyle style) =>
      UiBackend.instance.createParagraphBuilder(style);

  void pushStyle(TextStyle style);
  void pop();
  void addText(String text);
  Paragraph build();
}

/// Registry for font files used in pure-Dart text rendering.
///
/// Implementations are backend-specific. The pure_ui backend stores TTF bytes
/// in an in-memory registry that the rasterizer consults at draw time. The
/// dart:ui backend delegates to `loadFontFromList`. Both return a Future so
/// code is portable.
class FontLoader {
  FontLoader._();

  /// Registers a font with the active [UiBackend].
  ///
  /// `family` is the family name that span styles reference. `bytes` is a TTF
  /// (or OTF where supported). `weight`/`style` distinguish variants of the
  /// same family.
  static Future<void> load(
    String family,
    Uint8List bytes, {
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
  }) =>
      UiBackend.instance
          .loadFont(family, bytes, weight: weight, style: style);
}
