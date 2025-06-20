import 'package:meta/meta.dart';

/// The weight of the font.
///
/// The values correspond to the CSS font-weight values.
@immutable
class FontWeight {
  const FontWeight._(this.value);

  /// Thin, the least thick
  static const FontWeight w100 = FontWeight._(100);

  /// Extra-light
  static const FontWeight w200 = FontWeight._(200);

  /// Light
  static const FontWeight w300 = FontWeight._(300);

  /// Normal / regular / plain
  static const FontWeight w400 = FontWeight._(400);

  /// Medium
  static const FontWeight w500 = FontWeight._(500);

  /// Semi-bold
  static const FontWeight w600 = FontWeight._(600);

  /// Bold
  static const FontWeight w700 = FontWeight._(700);

  /// Extra-bold
  static const FontWeight w800 = FontWeight._(800);

  /// Black, the most thick
  static const FontWeight w900 = FontWeight._(900);

  /// The default font weight.
  static const FontWeight normal = w400;

  /// A commonly used font weight that is heavier than normal.
  static const FontWeight bold = w700;

  /// The numerical value of the font weight.
  final int value;

  /// List of all available font weights, from lightest to boldest.
  static const List<FontWeight> values = <FontWeight>[
    w100,
    w200,
    w300,
    w400,
    w500,
    w600,
    w700,
    w800,
    w900,
  ];

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is FontWeight && other.value == value;
  }

  @override
  String toString() {
    return const <int, String>{
          100: 'FontWeight.w100',
          200: 'FontWeight.w200',
          300: 'FontWeight.w300',
          400: 'FontWeight.w400',
          500: 'FontWeight.w500',
          600: 'FontWeight.w600',
          700: 'FontWeight.w700',
          800: 'FontWeight.w800',
          900: 'FontWeight.w900',
        }[value] ??
        'FontWeight($value)';
  }

  /// Linearly interpolates between two font weights.
  ///
  /// Rather than using fractional font weights, the interpolation is clamped to
  /// the next higher and next lower font weight value.
  static FontWeight lerp(FontWeight a, FontWeight b, double t) {
    final aValue = a.value;
    final bValue = b.value;
    return FontWeight._((aValue + (bValue - aValue) * t).round().clamp(1, 999));
  }
}
