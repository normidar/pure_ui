import 'package:pure_ui/pure_ui.dart';
import 'package:test/test.dart';

void main() {
  test('dummy test', () {
    expect(true, true);
  });

  group('Color', () {
    test('should create a color from RGB values', () {
      final color = Color.fromRGBO(255, 0, 0, 1.0);
      expect((color.r * 255.0).round(), equals(255));
      expect((color.g * 255.0).round(), equals(0));
      expect((color.b * 255.0).round(), equals(0));
      expect((color.a * 255.0).round(), equals(255));
    });

    test('should create a color from ARGB values', () {
      const color = Color.fromARGB(128, 255, 0, 0);
      expect((color.r * 255.0).round(), equals(255));
      expect((color.g * 255.0).round(), equals(0));
      expect((color.b * 255.0).round(), equals(0));
      expect((color.a * 255.0).round(), equals(128));
    });
  });

  group('Rect', () {
    test('should create a rect from LTRB values', () {
      const rect = Rect.fromLTRB(10, 20, 30, 40);
      expect(rect.left, equals(10));
      expect(rect.top, equals(20));
      expect(rect.right, equals(30));
      expect(rect.bottom, equals(40));
      expect(rect.width, equals(20));
      expect(rect.height, equals(20));
    });

    test('should create a rect from LTWH values', () {
      const rect = Rect.fromLTWH(10, 20, 20, 20);
      expect(rect.left, equals(10));
      expect(rect.top, equals(20));
      expect(rect.right, equals(30));
      expect(rect.bottom, equals(40));
      expect(rect.width, equals(20));
      expect(rect.height, equals(20));
    });
  });

  group('Offset', () {
    test('should create an offset', () {
      const offset = Offset(10, 20);
      expect(offset.dx, equals(10));
      expect(offset.dy, equals(20));
    });

    test('should calculate distance', () {
      const offset = Offset(3, 4);
      expect(offset.distance, equals(5));
    });
  });
}
