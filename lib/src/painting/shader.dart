import 'package:meta/meta.dart';
import 'package:pure_ui/pure_ui.dart' show Paint;

/// Abstract class for shader objects that can be used with [Paint].
@immutable
abstract class Shader {
  /// Creates a new Shader.
  const Shader();

  /// Whether this shader is implemented on this platform.
  bool get isAvailable => true;

  /// Disposes of the resources used by this shader.
  void dispose() {
    // Currently, the underlying image library doesn't require explicit disposal
    // This method is added for API compatibility and future use
  }
}
