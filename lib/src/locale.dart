import 'package:meta/meta.dart';

/// A locale represents a specific geographical, political, or cultural region.
///
/// This is used to specify the language, script, and country of a specific locale.
@immutable
class Locale {
  /// Creates a new locale object.
  const Locale(this.languageCode, [this.countryCode]);

  /// The primary language subtag for the locale.
  final String languageCode;

  /// The country/region subtag for the locale.
  final String? countryCode;

  @override
  int get hashCode => Object.hash(languageCode, countryCode);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Locale &&
        other.languageCode == languageCode &&
        other.countryCode == countryCode;
  }

  @override
  String toString() {
    if (countryCode == null) {
      return languageCode;
    }
    return '${languageCode}_$countryCode';
  }
}
