import 'package:meta/meta.dart';
import 'package:pure_ui/src/color.dart';
import 'package:pure_ui/src/offset.dart';
import 'package:pure_ui/src/paint.dart';
import 'package:pure_ui/src/text/font_weight.dart';
import 'package:pure_ui/src/text/text_decoration.dart';
import 'package:pure_ui/src/locale.dart';

/// The font style to use when painting the text.
enum FontStyle {
  /// Use the normal, upright version of the font.
  normal,

  /// Use the italic version of the font.
  italic,
}

/// A drop shadow for text.
class Shadow {
  /// Creates a shadow with the given color, offset, and blur radius.
  const Shadow({
    this.color = const Color(0xFF000000),
    this.offset = Offset.zero,
    this.blurRadius = 0.0,
  });

  /// The color of the shadow.
  final Color color;

  /// The displacement of the shadow from the text.
  final Offset offset;

  /// The standard deviation of the Gaussian blur applied to the shadow.
  final double blurRadius;

  @override
  int get hashCode => Object.hash(color, offset, blurRadius);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Shadow &&
        other.color == color &&
        other.offset == offset &&
        other.blurRadius == blurRadius;
  }
}

/// The common baseline that should be aligned between this text span and its
/// parent text span, or, for the root text spans, with the line box.
enum TextBaseline {
  /// The alphabetic baseline is typically used for alphabetic characters such
  /// as Latin, Greek, and similar.
  alphabetic,

  /// The ideographic baseline is used for ideographic characters such as CJK.
  ideographic,
}

/// The strategy to use when the text doesn't fit into the available space.
enum TextOverflow {
  /// Clip the overflowing text to fix its container.
  clip,

  /// Fade the overflowing text to transparent.
  fade,

  /// Use an ellipsis to indicate that the text has overflowed.
  ellipsis,

  /// Render overflowing text outside of its container.
  visible,
}

/// An immutable style describing how to format and paint text.
@immutable
class TextStyle {
  /// Creates a text style.
  const TextStyle({
    this.color,
    this.backgroundColor,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.height,
    this.foreground,
    this.background,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
    this.fontFamilyFallback,
    this.shadows,
    this.overflow,
    this.locale,
  }) : assert(
         foreground == null || color == null,
         'Cannot provide both a color and a foreground',
       ),
       assert(
         background == null || backgroundColor == null,
         'Cannot provide both a backgroundColor and a background',
       );

  /// The color to use when painting the text.
  final Color? color;

  /// The background color for the text.
  final Color? backgroundColor;

  /// The size of glyphs (in logical pixels) to use when painting the text.
  final double? fontSize;

  /// The typeface thickness to use when painting the text.
  final FontWeight? fontWeight;

  /// The font style to use when painting the text.
  final FontStyle? fontStyle;

  /// The amount of space to add between each letter.
  final double? letterSpacing;

  /// The amount of space to add at each sequence of white-space.
  final double? wordSpacing;

  /// The common baseline that should be aligned between this text span and its
  /// parent text span, or, for the root text spans, with the line box.
  final TextBaseline? textBaseline;

  /// The height of this text span, as a multiple of the font size.
  final double? height;

  /// The paint to use as the foreground when painting the text.
  final Paint? foreground;

  /// The paint to use as the background when painting the text.
  final Paint? background;

  /// The decorations to paint near the text.
  final TextDecoration? decoration;

  /// The color in which to paint the text decorations.
  final Color? decorationColor;

  /// The style in which to paint the text decorations.
  final TextDecorationStyle? decorationStyle;

  /// The thickness of the decoration stroke as a multiplier of the thickness
  /// defined by the font.
  final double? decorationThickness;

  /// The name of the font to use when painting the text.
  final String? fontFamily;

  /// The ordered list of fallback font family names.
  final List<String>? fontFamilyFallback;

  /// A list of shadows to paint beneath the text.
  final List<Shadow>? shadows;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// The locale used to select region-specific glyphs.
  final Locale? locale;

  @override
  int get hashCode => Object.hash(
    color,
    backgroundColor,
    fontSize,
    fontWeight,
    fontStyle,
    letterSpacing,
    wordSpacing,
    textBaseline,
    height,
    foreground,
    background,
    decoration,
    decorationColor,
    decorationStyle,
    decorationThickness,
    fontFamily,
    fontFamilyFallback != null ? Object.hashAll(fontFamilyFallback!) : null,
    shadows != null ? Object.hashAll(shadows!) : null,
    overflow,
    locale,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TextStyle &&
        other.color == color &&
        other.backgroundColor == backgroundColor &&
        other.fontSize == fontSize &&
        other.fontWeight == fontWeight &&
        other.fontStyle == fontStyle &&
        other.letterSpacing == letterSpacing &&
        other.wordSpacing == wordSpacing &&
        other.textBaseline == textBaseline &&
        other.height == height &&
        other.foreground == foreground &&
        other.background == background &&
        other.decoration == decoration &&
        other.decorationColor == decorationColor &&
        other.decorationStyle == decorationStyle &&
        other.decorationThickness == decorationThickness &&
        other.fontFamily == fontFamily &&
        _listEquals(other.fontFamilyFallback, fontFamilyFallback) &&
        _listEquals(other.shadows, shadows) &&
        other.overflow == overflow &&
        other.locale == locale;
  }

  /// Creates a copy of this text style replacing the given fields.
  TextStyle copyWith({
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Paint? foreground,
    Paint? background,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    List<Shadow>? shadows,
    TextOverflow? overflow,
    Locale? locale,
  }) {
    return TextStyle(
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      textBaseline: textBaseline ?? this.textBaseline,
      height: height ?? this.height,
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
      decoration: decoration ?? this.decoration,
      decorationColor: decorationColor ?? this.decorationColor,
      decorationStyle: decorationStyle ?? this.decorationStyle,
      decorationThickness: decorationThickness ?? this.decorationThickness,
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      shadows: shadows ?? this.shadows,
      overflow: overflow ?? this.overflow,
      locale: locale ?? this.locale,
    );
  }

  /// Merges this style with another style.
  ///
  /// The values in the given style override the values in this style.
  TextStyle merge(TextStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      color: other.color,
      backgroundColor: other.backgroundColor,
      fontSize: other.fontSize,
      fontWeight: other.fontWeight,
      fontStyle: other.fontStyle,
      letterSpacing: other.letterSpacing,
      wordSpacing: other.wordSpacing,
      textBaseline: other.textBaseline,
      height: other.height,
      foreground: other.foreground,
      background: other.background,
      decoration: other.decoration,
      decorationColor: other.decorationColor,
      decorationStyle: other.decorationStyle,
      decorationThickness: other.decorationThickness,
      fontFamily: other.fontFamily,
      fontFamilyFallback: other.fontFamilyFallback,
      shadows: other.shadows,
      overflow: other.overflow,
      locale: other.locale,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
