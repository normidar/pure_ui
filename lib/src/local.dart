/// An identifier used to select a user's language and formatting preferences.
///
/// This represents a Unicode Language Identifier(i.e. without Locale extensions),
/// except variants are not supported.
///
/// Locales are canonicalized according to the "preferred value" entries in the
/// IANA Language Subtag Registry. For example, [Local('he')] and [Local('iw')]
/// are equal and both have the languageCode `he`, because `iw` is a deprecated
/// language subtag that was replaced by the subtag `he`.
class Local {
  /// Creates a new Local object. The first argument is the primary language subtag,
  /// the second is the region (also referred to as 'country') subtag.
  const Local(String languageCode, [String? countryCode])
    : _languageCode = languageCode,
      _countryCode = countryCode,
      _scriptCode = null;

  /// Creates a new Local object.
  ///
  /// The [languageCode] is required.
  /// The [scriptCode] is the script subtag (for example, 'Latn', 'Cyrl').
  /// The [countryCode] is the region subtag.
  const Local.fromSubtags({
    String languageCode = 'und',
    String? scriptCode,
    String? countryCode,
  }) : _languageCode = languageCode,
       _countryCode = countryCode,
       _scriptCode = scriptCode;

  final String _languageCode;
  final String? _countryCode;
  final String? _scriptCode;

  /// The region subtag for the locale.
  String? get countryCode => _countryCode;

  @override
  int get hashCode => Object.hash(languageCode, countryCode, scriptCode);

  /// The primary language subtag for the locale.
  String get languageCode => _languageCode;

  /// The script subtag for the locale.
  String? get scriptCode => _scriptCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Local) {
      return false;
    }
    return languageCode == other.languageCode &&
        countryCode == other.countryCode &&
        scriptCode == other.scriptCode;
  }

  /// Returns a syntactically valid Unicode BCP47 Locale Identifier.
  String toLanguageTag() {
    final subtags = <String>[languageCode];
    if (scriptCode != null) {
      subtags.add(scriptCode!);
    }
    if (countryCode != null) {
      subtags.add(countryCode!);
    }
    return subtags.join('-');
  }

  @override
  String toString() {
    if (countryCode == null && scriptCode == null) {
      return languageCode;
    }
    if (scriptCode == null) {
      return '${languageCode}_$countryCode';
    }
    if (countryCode == null) {
      return '${languageCode}_$scriptCode';
    }
    return '${languageCode}_${scriptCode}_$countryCode';
  }
}
