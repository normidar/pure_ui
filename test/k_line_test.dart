import 'dart:io';

import 'package:pure_ui/pure_ui.dart';
import 'package:test/test.dart';

void main() {
  group('K Line Tests', () {
    test('K Line Test', () async {
      final size = const Size(250, 1000);
      await exportImage(
        canvasFunction: (canvas) {
          final backgroundPaint = Paint()..color = const Color(0xFFFFFFFF);
          canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
          final paint = Paint()
            ..strokeWidth = size.width / 7
            ..color = const Color(0xFFFF0000);
          canvas.drawRect(
              Rect.fromLTRB(
                0,
                size.height / 4,
                size.width,
                size.height / 4 * 3,
              ),
              paint);
          canvas.drawLine(Offset(size.width / 2, 0),
              Offset(size.width / 2, size.height), paint);
        },
        size: size,
        exportFile: File('test_output/k_line.png'),
      );
    });
  });
}
