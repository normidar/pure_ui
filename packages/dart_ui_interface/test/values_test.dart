import 'package:dart_ui_interface/dart_ui_interface.dart';
import 'package:test/test.dart';

void main() {
  group('value types preserve const', () {
    test('Offset.zero is a compile-time constant and identical', () {
      const a = Offset.zero;
      const b = Offset(0, 0);
      expect(identical(a, b), isTrue);
    });

    test('Color const construction', () {
      const c = Color(0xFF112233);
      expect(c.alpha, 0xFF);
      expect(c.red, 0x11);
      expect(c.green, 0x22);
      expect(c.blue, 0x33);
      expect(c.value, 0xFF112233);
    });

    test('Rect geometry', () {
      const r = Rect.fromLTWH(10, 20, 30, 40);
      expect(r.width, 30);
      expect(r.height, 40);
      expect(r.center, const Offset(25, 40));
    });

    test('RRect zero is const', () {
      const rr = RRect.zero;
      expect(rr.width, 0);
      expect(rr.tlRadiusX, 0);
    });

    test('Offset arithmetic and equality', () {
      expect(const Offset(1, 2) + const Offset(3, 4), const Offset(4, 6));
      expect(const Offset(2, 4) / 2, const Offset(1, 2));
      expect(const Offset(1, 1), equals(const Offset(1, 1)));
    });

    test('Color.lerp clamps and interpolates', () {
      final c =
          Color.lerp(const Color(0xFF000000), const Color(0xFFFFFFFF), 0.5);
      expect(c!.red, closeTo(128, 1));
    });
  });

  group('top-level functions', () {
    test('lerpDouble', () {
      expect(lerpDouble(0, 10, 0.5), 5.0);
      expect(lerpDouble(null, null, 0.5), isNull);
    });

    test('clampDouble', () {
      expect(clampDouble(5, 0, 10), 5);
      expect(clampDouble(-1, 0, 10), 0);
      expect(clampDouble(11, 0, 10), 10);
    });
  });
}
