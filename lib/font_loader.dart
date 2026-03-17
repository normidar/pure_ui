// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of dart.ui;

/// Registry for font files used in pure Dart text rendering.
///
/// Since pure_ui runs outside of Flutter, there is no system font registry.
/// Use [FontLoader] to register TTF/OTF font files by family name before
/// rendering text with [ParagraphBuilder].
///
/// Example:
/// ```dart
/// // Register from raw bytes
/// final bytes = File('/path/to/Roboto-Regular.ttf').readAsBytesSync();
/// FontLoader.load('Roboto', bytes);
///
/// // Register from a file path
/// FontLoader.loadFromFile('Roboto', '/path/to/Roboto-Bold.ttf',
///   weight: FontWeight.bold);
///
/// // Then use in paragraph building
/// final builder = ParagraphBuilder(ParagraphStyle(fontFamily: 'Roboto'));
/// builder.addText('Hello');
/// ```
class FontLoader {
  FontLoader._();

  static final Map<String, Map<_FontKey, Uint8List>> _registry = {};

  /// Registers a font from raw bytes.
  ///
  /// [family] is the font family name used in [TextStyle.fontFamily] and
  /// [ParagraphStyle.fontFamily].
  ///
  /// [bytes] must be a valid TTF or OTF font file.
  ///
  /// Use [weight] and [style] to register multiple variants of the same family.
  static void load(
    String family,
    Uint8List bytes, {
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
  }) {
    _registry.putIfAbsent(family, () => {})[_FontKey(weight, style)] = bytes;
  }

  /// Registers a font from a file path.
  ///
  /// Reads the file synchronously. Throws if the file does not exist or is
  /// not a valid font file.
  static void loadFromFile(
    String family,
    String filePath, {
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
  }) {
    final bytes = File(filePath).readAsBytesSync();
    load(family, bytes, weight: weight, style: style);
  }

  /// Returns the font bytes for the given family, weight, and style.
  ///
  /// Returns null if no matching font is registered.
  /// Falls back to the normal weight/style variant if the exact match is not
  /// found.
  static Uint8List? getFont(
    String family, {
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
  }) {
    final familyFonts = _registry[family];
    if (familyFonts == null) return null;
    return familyFonts[_FontKey(weight, style)] ??
        familyFonts[_FontKey(FontWeight.normal, FontStyle.normal)];
  }

  /// Whether any font variant is registered for the given family name.
  static bool hasFamily(String family) => _registry.containsKey(family);

  /// Returns all registered font family names.
  static Set<String> get families => _registry.keys.toSet();

  /// Removes all registered fonts.
  static void clear() => _registry.clear();
}

/// Key for looking up a font variant by weight and style.
class _FontKey {
  final FontWeight weight;
  final FontStyle style;

  const _FontKey(this.weight, this.style);

  @override
  bool operator ==(Object other) =>
      other is _FontKey && other.weight == weight && other.style == style;

  @override
  int get hashCode => Object.hash(weight, style);
}
