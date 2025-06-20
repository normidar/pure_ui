import 'package:meta/meta.dart';

/// An immutable 32 bit color value in ARGB format.
@immutable
class Color {
  /// Creates a color from the lower 32 bits of an integer.
  ///
  /// The bits are interpreted as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  const Color(this.value);

  /// Creates a color from the given [r], [g], [b], and [a] values.
  ///
  /// The [r], [g], and [b] values are typically between 0 and 255.
  /// The [a] value is typically between 0 and 255, representing opacity.
  const Color.fromARGB(int a, int r, int g, int b)
    : value =
          (((a & 0xff) << 24) |
              ((r & 0xff) << 16) |
              ((g & 0xff) << 8) |
              ((b & 0xff) << 0)) &
          0xFFFFFFFF;

  /// Creates a color from the given [r], [g], and [b] values.
  ///
  /// The [r], [g], and [b] values are typically between 0 and 255.
  /// The opacity is set to 255 (fully opaque).
  const Color.fromRGB(int r, int g, int b) : this.fromARGB(255, r, g, b);

  /// Creates a color from the given [r], [g], [b], and [a] values.
  ///
  /// The [r], [g], [b], and [a] values are typically between 0 and 255.
  const Color.fromRGBA(int r, int g, int b, int a) : this.fromARGB(a, r, g, b);

  /// Black color.
  static const Color black = Color(0xFF000000);

  /// White color.
  static const Color white = Color(0xFFFFFFFF);

  /// Transparent color.
  static const Color transparent = Color(0x00000000);

  /// The value stored in this color, as a 32-bit integer.
  final int value;

  /// The alpha channel of this color in an 8-bit value.
  int get alpha => (0xff000000 & value) >> 24;

  /// The blue channel of this color in an 8-bit value.
  int get blue => (0x000000ff & value) >> 0;

  /// The green channel of this color in an 8-bit value.
  int get green => (0x0000ff00 & value) >> 8;

  @override
  int get hashCode => value.hashCode;

  /// The red channel of this color in an 8-bit value.
  int get red => (0x00ff0000 & value) >> 16;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Color && other.value == value;
  }

  @override
  String toString() => 'Color(0x${value.toRadixString(16).padLeft(8, '0')})';

  /// Returns a new color that matches this color with the alpha channel
  /// replaced with the given value.
  Color withAlpha(int a) => Color.fromARGB(a, red, green, blue);

  /// Returns a new color that matches this color with the blue channel
  /// replaced with the given value.
  Color withBlue(int b) => Color.fromARGB(alpha, red, green, b);

  /// Returns a new color that matches this color with the green channel
  /// replaced with the given value.
  Color withGreen(int g) => Color.fromARGB(alpha, red, g, blue);

  /// Returns a new color that matches this color with the opacity set to the
  /// given value.
  Color withOpacity(double opacity) {
    return withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
  }

  /// Returns a new color that matches this color with the red channel
  /// replaced with the given value.
  Color withRed(int r) => Color.fromARGB(alpha, r, green, blue);

  /// Linearly interpolate between two colors.
  factory Color.lerp(Color a, Color b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    final alphaA = a.alpha;
    final redA = a.red;
    final greenA = a.green;
    final blueA = a.blue;

    final alphaB = b.alpha;
    final redB = b.red;
    final greenB = b.green;
    final blueB = b.blue;

    return Color.fromARGB(
      _lerpInt(alphaA, alphaB, t),
      _lerpInt(redA, redB, t),
      _lerpInt(greenA, greenB, t),
      _lerpInt(blueA, blueB, t),
    );
  }

  static int _lerpInt(int a, int b, double t) {
    return (a + (b - a) * t).round().clamp(0, 255);
  }
}
