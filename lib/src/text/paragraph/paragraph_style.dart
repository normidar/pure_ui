import 'package:meta/meta.dart';
import 'package:pure_ui/src/enums.dart';
import 'package:pure_ui/src/locale.dart';
import 'package:pure_ui/src/text/font_weight.dart';
import 'package:pure_ui/src/text/text_style.dart';

/// Styles to use for the paragraph as a whole.
@immutable
class ParagraphStyle {
  /// Creates a new ParagraphStyle object.
  const ParagraphStyle({
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
    this.textHeightBehavior,
    this.strutStyle,
    this.ellipsis,
    this.locale,
  });

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The direction in which the text flows.
  final TextDirection? textDirection;

  /// The maximum number of lines for the text to span, wrapping if necessary.
  final int? maxLines;

  /// The name of the font to use when painting the text.
  final String? fontFamily;

  /// The size of glyphs (in logical pixels) to use when painting the text.
  final double? fontSize;

  /// The typeface thickness to use when painting the text (e.g., bold).
  final FontWeight? fontWeight;

  /// The typeface variant to use when drawing the letters (e.g., italics).
  final FontStyle? fontStyle;

  /// The height of a line of text, as a multiple of the font size.
  final double? lineHeight;

  /// How the paragraph should handle the height of text lines.
  final TextHeightBehavior? textHeightBehavior;

  /// How strut height should be handled.
  final StrutStyle? strutStyle;

  /// The string to use when ellipsizing overflowing text.
  final String? ellipsis;

  /// The locale used to select region-specific glyphs.
  final Locale? locale;

  @override
  int get hashCode => Object.hash(
        textAlign,
        textDirection,
        maxLines,
        fontFamily,
        fontSize,
        fontWeight,
        fontStyle,
        lineHeight,
        textHeightBehavior,
        strutStyle,
        ellipsis,
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
    return other is ParagraphStyle &&
        other.textAlign == textAlign &&
        other.textDirection == textDirection &&
        other.maxLines == maxLines &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.fontWeight == fontWeight &&
        other.fontStyle == fontStyle &&
        other.lineHeight == lineHeight &&
        other.textHeightBehavior == textHeightBehavior &&
        other.strutStyle == strutStyle &&
        other.ellipsis == ellipsis &&
        other.locale == locale;
  }

  /// Creates a copy of this paragraph style but with the given fields replaced
  /// with the new values.
  ParagraphStyle copyWith({
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? lineHeight,
    TextHeightBehavior? textHeightBehavior,
    StrutStyle? strutStyle,
    String? ellipsis,
    Locale? locale,
  }) {
    return ParagraphStyle(
      textAlign: textAlign ?? this.textAlign,
      textDirection: textDirection ?? this.textDirection,
      maxLines: maxLines ?? this.maxLines,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      lineHeight: lineHeight ?? this.lineHeight,
      textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
      strutStyle: strutStyle ?? this.strutStyle,
      ellipsis: ellipsis ?? this.ellipsis,
      locale: locale ?? this.locale,
    );
  }
}

/// Defines the strut, which sets the minimum height a line can be.
@immutable
class StrutStyle {
  /// Creates a new StrutStyle object.
  const StrutStyle({
    this.fontFamily,
    this.fontFamilyFallback,
    this.fontSize,
    this.height,
    this.leading,
    this.fontWeight,
    this.fontStyle,
    this.forceStrutHeight,
  });

  /// The name of the font to use when calculating the strut.
  final String? fontFamily;

  /// The ordered list of font family fallbacks to use when calculating the strut.
  final List<String>? fontFamilyFallback;

  /// The size of glyphs to use when calculating the strut.
  final double? fontSize;

  /// The height of the strut, as a multiple of the font size.
  final double? height;

  /// Additional leading to add between lines.
  final double? leading;

  /// The typeface thickness to use when calculating the strut.
  final FontWeight? fontWeight;

  /// The typeface variant to use when calculating the strut.
  final FontStyle? fontStyle;

  /// Whether the strut height should be forced.
  final bool? forceStrutHeight;

  @override
  int get hashCode => Object.hash(
        fontFamily,
        fontFamilyFallback != null ? Object.hashAll(fontFamilyFallback!) : null,
        fontSize,
        height,
        leading,
        fontWeight,
        fontStyle,
        forceStrutHeight,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is StrutStyle &&
        other.fontFamily == fontFamily &&
        _listEquals(other.fontFamilyFallback, fontFamilyFallback) &&
        other.fontSize == fontSize &&
        other.height == height &&
        other.leading == leading &&
        other.fontWeight == fontWeight &&
        other.fontStyle == fontStyle &&
        other.forceStrutHeight == forceStrutHeight;
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

/// Horizontal alignment of text.
enum TextAlign {
  /// Align the text on the left edge of the container.
  left,

  /// Align the text on the right edge of the container.
  right,

  /// Align the text in the center of the container.
  center,

  /// Stretch lines of text that end with a soft line break to fill the width of the container.
  justify,

  /// Align the text on the leading edge of the container.
  start,

  /// Align the text on the trailing edge of the container.
  end,
}

/// How the paragraph should handle the height of text lines.
class TextHeightBehavior {
  /// Creates a new TextHeightBehavior object.
  const TextHeightBehavior({
    this.applyHeightToFirstAscent = true,
    this.applyHeightToLastDescent = true,
    this.leadingDistribution = TextLeadingDistribution.proportional,
  });

  /// Whether to apply additional height to the ascent of the first line.
  final bool applyHeightToFirstAscent;

  /// Whether to apply additional height to the descent of the last line.
  final bool applyHeightToLastDescent;

  /// The distribution of the additional leading space.
  final TextLeadingDistribution leadingDistribution;

  @override
  int get hashCode => Object.hash(
        applyHeightToFirstAscent,
        applyHeightToLastDescent,
        leadingDistribution,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TextHeightBehavior &&
        other.applyHeightToFirstAscent == applyHeightToFirstAscent &&
        other.applyHeightToLastDescent == applyHeightToLastDescent &&
        other.leadingDistribution == leadingDistribution;
  }
}

/// Defines the distribution of the additional leading space.
enum TextLeadingDistribution {
  /// Additional leading space is evenly distributed around the text.
  even,

  /// Additional leading space is proportionally distributed around the text.
  proportional,
}
