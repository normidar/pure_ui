import 'package:meta/meta.dart';
import 'package:pure_ui/src/locale.dart';
import 'package:pure_ui/src/size.dart';

/// Signature for [AccessibilityFeatures.onDidChangeAccessibilityFeatures].
typedef AccessibilityFeaturesChangedCallback = void Function();

/// A function that receives a [Locale] as input and returns a bool as output.
///
/// Used by [PlatformDispatcher.onLocaleChanged] to filter locale changes.
typedef LocaleFilter = bool Function(Locale locale);

/// Signature for [PlatformDispatcher.onViewCreated] and
/// [PlatformDispatcher.onViewDisposed] callbacks.
typedef ViewChangeCallback = void Function(Object viewId);

/// A function that takes a [View] as an argument and returns a [RenderView]
/// configured for that view.
typedef ViewConfiguration = ({Size physicalSize, double devicePixelRatio});

/// Signature for [PlatformDispatcher.onViewMetricsChanged] callback.
typedef ViewMetricsChangedCallback = void Function(Object viewId);

/// Signature for callbacks that have no arguments and return no data.
typedef VoidCallback = void Function();

/// Flags for each type of accessibility feature that can be enabled by the platform.
///
/// Used to describe the accessibility features enabled on the platform.
class AccessibilityFeatures {
  /// Creates a representation of the accessibility features enabled on the platform.
  const AccessibilityFeatures({
    this.accessibleNavigation = false,
    this.invertColors = false,
    this.disableAnimations = false,
    this.boldText = false,
    this.reduceMotion = false,
    this.highContrast = false,
    this.onOffSwitchLabels = false,
  });

  /// Create an accessibility features instance with all features disabled.
  static const AccessibilityFeatures empty = AccessibilityFeatures();

  /// Whether to use accessible navigation.
  final bool accessibleNavigation;

  /// Whether to invert the colors of the application.
  final bool invertColors;

  /// Whether to disable animations.
  final bool disableAnimations;

  /// Whether to bold all text.
  final bool boldText;

  /// Whether to reduce motion.
  final bool reduceMotion;

  /// Whether to display high contrast UI.
  final bool highContrast;

  /// Whether to display on/off labels on switch widgets.
  final bool onOffSwitchLabels;

  @override
  int get hashCode => Object.hash(
        accessibleNavigation,
        invertColors,
        disableAnimations,
        boldText,
        reduceMotion,
        highContrast,
        onOffSwitchLabels,
      );

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AccessibilityFeatures &&
        other.accessibleNavigation == accessibleNavigation &&
        other.invertColors == invertColors &&
        other.disableAnimations == disableAnimations &&
        other.boldText == boldText &&
        other.reduceMotion == reduceMotion &&
        other.highContrast == highContrast &&
        other.onOffSwitchLabels == onOffSwitchLabels;
  }

  @override
  String toString() {
    final features = <String>[];
    if (accessibleNavigation) {
      features.add('accessibleNavigation');
    }
    if (invertColors) {
      features.add('invertColors');
    }
    if (disableAnimations) {
      features.add('disableAnimations');
    }
    if (boldText) {
      features.add('boldText');
    }
    if (reduceMotion) {
      features.add('reduceMotion');
    }
    if (highContrast) {
      features.add('highContrast');
    }
    if (onOffSwitchLabels) {
      features.add('onOffSwitchLabels');
    }
    return 'AccessibilityFeatures$features';
  }
}

/// Describes the contrast of a theme or color palette.
enum Brightness {
  /// The color is dark and will require a light text color to achieve readable
  /// contrast.
  dark,

  /// The color is light and will require a dark text color to achieve readable
  /// contrast.
  light,
}

/// A view into which the Flutter framework can render.
class FlutterView {
  /// Creates a new view with the given configuration.
  FlutterView({required this.devicePixelRatio, required this.physicalSize});

  /// The pixel density of the output surface.
  final double devicePixelRatio;

  /// The size of the output surface in physical pixels.
  final Size physicalSize;

  /// The size of the output surface in logical pixels.
  Size get logicalSize {
    return Size(
      physicalSize.width / devicePixelRatio,
      physicalSize.height / devicePixelRatio,
    );
  }

  /// The number of device pixels for each logical pixel.
  double get platformDisplayPixelRatio => devicePixelRatio;
}

/// The glue between the Flutter engine and the framework.
///
/// This is the pure Dart implementation, designed to work without Flutter engine.
class PlatformDispatcher {
  /// Creates a new platform dispatcher.
  PlatformDispatcher._();

  /// The singleton instance of this class.
  static final PlatformDispatcher instance = PlatformDispatcher._();

  /// Called when the platform's locale information changes.
  VoidCallback? onLocaleChanged;

  /// Called when the system's text scale factor changes.
  VoidCallback? onTextScaleFactorChanged;

  /// Called when the platform brightness changes.
  VoidCallback? onPlatformBrightnessChanged;

  /// Called when the platform's UTC time zone offset changes.
  VoidCallback? onSystemFontFamilyChanged;

  /// A callback that is invoked when the platform registers a view.
  ViewChangeCallback? onViewCreated;

  /// A callback that is invoked when a view is disposed.
  ViewChangeCallback? onViewDisposed;

  /// A callback that is invoked when the system changes the metrics of a view.
  ViewMetricsChangedCallback? onViewMetricsChanged;

  /// The view currently attached to this dispatcher.
  final Map<Object, FlutterView> _views = <Object, FlutterView>{};

  int _nextViewId = 0;

  /// Called when the system accessibility features change.
  AccessibilityFeaturesChangedCallback? onAccessibilityFeaturesChanged;

  /// The accessibility features currently enabled by the system.
  AccessibilityFeatures get accessibilityFeatures =>
      const AccessibilityFeatures();

  /// The setting indicating whether time should be shown in 24-hour format.
  bool get alwaysUse24HourFormat => false;

  /// Returns the default route name.
  String get defaultRouteName => '/';

  /// Whether the user has requested animations be disabled or reduced.
  bool get disableAnimations => accessibilityFeatures.disableAnimations;

  /// Provides the primary view associated with this platform dispatcher.
  FlutterView? get implicitView {
    if (_views.isEmpty) {
      return null;
    }
    return _views.values.first;
  }

  /// The current system locale obtained from the host platform.
  Locale get locale => locales.first;

  /// The list of locales supported by this device.
  List<Locale> get locales => const <Locale>[Locale('en', 'US')];

  /// The current brightness mode of the host platform.
  Brightness get platformBrightness => Brightness.light;

  /// The current text scale factor.
  double get textScaleFactor => 1;

  /// The complete list of views available to this dispatcher.
  Iterable<FlutterView> get views => _views.values;

  /// Adds a view to this platform dispatcher with the given configuration.
  @visibleForTesting
  FlutterView addView({
    required Size physicalSize,
    required double devicePixelRatio,
  }) {
    final viewId = _nextViewId++;
    final view = FlutterView(
      devicePixelRatio: devicePixelRatio,
      physicalSize: physicalSize,
    );
    _views[viewId] = view;
    onViewCreated?.call(viewId);
    return view;
  }

  /// Removes a view from this platform dispatcher.
  @visibleForTesting
  void removeView(Object viewId) {
    if (_views.containsKey(viewId)) {
      _views.remove(viewId);
      onViewDisposed?.call(viewId);
    }
  }

  /// Requests that, when the application is next restarted, the application
  /// start with the given configuration.
  void setInitialSettings({
    Locale? locale,
    List<Locale>? locales,
    double? textScaleFactor,
    Brightness? platformBrightness,
    bool? alwaysUse24HourFormat,
    AccessibilityFeatures? accessibilityFeatures,
  }) {
    // No-op in pure implementation
  }
}
