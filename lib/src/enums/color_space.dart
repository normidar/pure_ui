/// The color space describes the colors that are available to an [Image].
///
/// This value can help decide which [ImageByteFormat] to use with
/// [Image.toByteData]. Images that are in the [extendedSRGB] color space
/// should use something like [ImageByteFormat.rawExtendedRgba128] so that
/// colors outside of the sRGB gamut aren't lost.
///
/// This is also the result of [Image.colorSpace].
///
/// See also: https://en.wikipedia.org/wiki/Color_space
enum ColorSpace {
  /// The sRGB color space.
  ///
  /// You may know this as the standard color space for the web or the color
  /// space of non-wide-gamut Flutter apps.
  ///
  /// See also: https://en.wikipedia.org/wiki/SRGB
  sRGB,

  /// A color space that is backwards compatible with sRGB but can represent
  /// colors outside of that gamut with values outside of [0..1]. In order to
  /// see the extended values an [ImageByteFormat] like
  /// [ImageByteFormat.rawExtendedRgba128] must be used.
  extendedSRGB,

  /// The Display P3 color space.
  ///
  /// This is a wide gamut color space that has broad hardware support. It's
  /// supported in cases like using Impeller on iOS. When used on a platform
  /// that doesn't support Display P3, the colors will be clamped to sRGB.
  ///
  /// See also: https://en.wikipedia.org/wiki/DCI-P3
  displayP3,
}
