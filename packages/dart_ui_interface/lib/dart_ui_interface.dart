/// Backend-agnostic contract layer for the `dart:ui` / `pure_ui` switching
/// architecture.
///
/// This package defines:
/// * concrete value types ([Offset], [Size], [Rect], [RRect], [Radius],
///   [Color]) with their `const` constructors preserved;
/// * shared enums;
/// * the [UiBackend] contract plus its global / zone-scoped selection;
/// * public abstract resource types ([Paint], [Path], [Canvas], [Picture],
///   [PictureRecorder], [Image]) that dispatch construction to the current
///   backend.
///
/// It has no Flutter dependency.
library dart_ui_interface;

export 'src/backend.dart';
export 'src/enums.dart';
export 'src/functions.dart';
export 'src/painting.dart';
export 'src/shaders.dart';
export 'src/text.dart';
export 'src/values.dart';
