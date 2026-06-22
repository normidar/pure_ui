/// Adapts the pure-Dart `pure_ui` implementation to the [UiBackend] contract.
///
/// Provides [PureUiBackend], the default backend for non-Flutter environments.
/// No Flutter dependency.
library pure_ui_adapter;

export 'package:dart_ui_interface/dart_ui_interface.dart';

export 'src/backend.dart'
    show
        PureUiBackend,
        PureUiPaint,
        PureUiPath,
        PureUiCanvas,
        PureUiPicture,
        PureUiPictureRecorder,
        PureUiImage;
