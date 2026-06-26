import 'package:pure_ui/pure_ui.dart' as pure;
import 'package:pure_ui_adapter/pure_ui_adapter.dart';
import 'package:test/test.dart';

/// A trivial backend used only to observe which backend `instance` resolves to.
class _FakeBackend implements UiBackend {
  @override
  String get name => 'fake';
  @override
  bool supports(BackendFeature feature) => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
      'fake backend has no real implementation; only `name` is observed');
}

void main() {
  group('backend selection (§3.2)', () {
    test('global instance is used by default', () {
      UiBackend.instance = const PureUiBackend();
      expect(UiBackend.instance.name, 'pure_ui');
      expect(Paint(), isA<PureUiPaint>());
    });

    test('runWith overrides the global for its dynamic extent', () {
      UiBackend.instance = const PureUiBackend();
      final fake = _FakeBackend();
      UiBackend.runWith(fake, () {
        expect(UiBackend.instance.name, 'fake');
      });
      // Restored outside the zone.
      expect(UiBackend.instance.name, 'pure_ui');
    });

    test('runWith nests', () {
      UiBackend.instance = const PureUiBackend();
      final fake = _FakeBackend();
      UiBackend.runWith(fake, () {
        expect(UiBackend.instance.name, 'fake');
        UiBackend.runWith(const PureUiBackend(), () {
          expect(UiBackend.instance.name, 'pure_ui');
        });
        expect(UiBackend.instance.name, 'fake');
      });
    });
  });

  group('pure_ui drop-in regression (§6.0)', () {
    test('using pure_ui directly needs no backend and stays independent', () {
      // The standalone pure_ui API must keep working with import-swap only.
      // It never touches UiBackend, so it works even with no backend wired.
      final recorder = pure.PictureRecorder();
      final canvas =
          pure.Canvas(recorder, const pure.Rect.fromLTWH(0, 0, 4, 4));
      canvas.drawRect(
        const pure.Rect.fromLTWH(0, 0, 4, 4),
        pure.Paint()..color = const pure.Color(0xFF00FF00),
      );
      final picture = recorder.endRecording();
      expect(picture.debugDisposed, isFalse);
      picture.dispose();
    });
  });
}
