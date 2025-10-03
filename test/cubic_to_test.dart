import 'dart:io';

import 'package:pure_ui/pure_ui.dart';
import 'package:test/test.dart';

void main() {
  group('CubicTo Tests', () {
    test('Cubic Bézier Curves Test', () async {
      final size = const Size(800, 600);
      await exportImage(
        canvasFunction: (canvas) {
          // Draw white background
          final backgroundPaint = Paint()..color = const Color(0xFFFFFFFF);
          canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

          // Test 1: Simple S-curve
          final sCurvePaint = Paint()
            ..strokeWidth = 3
            ..color = const Color(0xFFFF0000)
            ..style = PaintingStyle.stroke;

          final sCurvePath = Path();
          sCurvePath.moveTo(50, 100);
          sCurvePath.cubicTo(150, 50, 250, 150, 350, 100);
          canvas.drawPath(sCurvePath, sCurvePaint);

          // Test 2: Wave pattern
          final wavePaint = Paint()
            ..strokeWidth = 2
            ..color = const Color(0xFF00FF00)
            ..style = PaintingStyle.stroke;

          final wavePath = Path();
          wavePath.moveTo(50, 200);
          wavePath.cubicTo(150, 150, 200, 250, 300, 200);
          wavePath.cubicTo(400, 150, 450, 250, 550, 200);
          wavePath.cubicTo(650, 150, 700, 250, 750, 200);
          canvas.drawPath(wavePath, wavePaint);

          // Test 3: Spiral-like curve
          final spiralPaint = Paint()
            ..strokeWidth = 2
            ..color = const Color(0xFF0000FF)
            ..style = PaintingStyle.stroke;

          final spiralPath = Path();
          spiralPath.moveTo(400, 300);
          spiralPath.cubicTo(500, 250, 550, 350, 500, 450);
          spiralPath.cubicTo(450, 550, 350, 500, 300, 400);
          spiralPath.cubicTo(250, 300, 350, 250, 400, 300);
          canvas.drawPath(spiralPath, spiralPaint);

          // Test 4: Multiple connected cubic curves forming a complex shape
          final complexPaint = Paint()
            ..strokeWidth = 2
            ..color = const Color(0xFFFF8000)
            ..style = PaintingStyle.stroke;

          final complexPath = Path();
          complexPath.moveTo(100, 400);
          complexPath.cubicTo(200, 350, 300, 450, 400, 400);
          complexPath.cubicTo(500, 350, 600, 400, 700, 350);
          complexPath.cubicTo(750, 300, 700, 250, 600, 300);
          complexPath.cubicTo(500, 350, 400, 300, 300, 350);
          complexPath.cubicTo(200, 400, 100, 350, 100, 400);
          canvas.drawPath(complexPath, complexPaint);

          // Test 5: Cubic curves with different control point distances
          final variedPaint = Paint()
            ..strokeWidth = 1
            ..color = const Color(0xFF8000FF)
            ..style = PaintingStyle.stroke;

          // Close control points (sharp curve)
          final sharpPath = Path();
          sharpPath.moveTo(50, 500);
          sharpPath.cubicTo(60, 490, 70, 510, 80, 500);
          canvas.drawPath(sharpPath, variedPaint);

          // Far control points (gentle curve)
          final gentlePath = Path();
          gentlePath.moveTo(100, 500);
          gentlePath.cubicTo(200, 400, 300, 600, 400, 500);
          canvas.drawPath(gentlePath, variedPaint);

          // Draw control points as small circles for visualization
          final controlPointPaint = Paint()
            ..color = const Color(0xFF000000)
            ..style = PaintingStyle.fill;

          // Control points for S-curve
          canvas.drawCircle(const Offset(150, 50), 3, controlPointPaint);
          canvas.drawCircle(const Offset(250, 150), 3, controlPointPaint);

          // Control points for wave
          canvas.drawCircle(const Offset(150, 150), 2, controlPointPaint);
          canvas.drawCircle(const Offset(200, 250), 2, controlPointPaint);
          canvas.drawCircle(const Offset(400, 150), 2, controlPointPaint);
          canvas.drawCircle(const Offset(450, 250), 2, controlPointPaint);
          canvas.drawCircle(const Offset(650, 150), 2, controlPointPaint);
          canvas.drawCircle(const Offset(700, 250), 2, controlPointPaint);

          // Add labels
          // Note: In a real implementation, you would use TextPainter for text rendering
          // For this test, we'll just draw small rectangles as placeholders for labels
          canvas.drawRect(const Rect.fromLTWH(10, 80, 100, 20),
              Paint()..color = const Color(0xFFE0E0E0));
          canvas.drawRect(const Rect.fromLTWH(10, 180, 100, 20),
              Paint()..color = const Color(0xFFE0E0E0));
          canvas.drawRect(const Rect.fromLTWH(350, 280, 100, 20),
              Paint()..color = const Color(0xFFE0E0E0));
          canvas.drawRect(const Rect.fromLTWH(10, 380, 100, 20),
              Paint()..color = const Color(0xFFE0E0E0));
          canvas.drawRect(const Rect.fromLTWH(10, 480, 100, 20),
              Paint()..color = const Color(0xFFE0E0E0));
        },
        size: size,
        exportFile: File('test_output/cubic_to_test.png'),
      );
    });

    test('CubicTo Edge Cases Test', () async {
      final size = const Size(400, 300);
      await exportImage(
        canvasFunction: (canvas) {
          // Draw white background
          final backgroundPaint = Paint()..color = const Color(0xFFFFFFFF);
          canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

          final paint = Paint()
            ..strokeWidth = 2
            ..color = const Color(0xFF000000)
            ..style = PaintingStyle.stroke;

          // Test 1: Cubic curve with control points at the same position as start/end
          final path1 = Path();
          path1.moveTo(50, 50);
          path1.cubicTo(50, 50, 150, 150, 150, 150); // Straight line
          canvas.drawPath(path1, paint);

          // Test 2: Cubic curve with extreme control points
          final path2 = Path();
          path2.moveTo(50, 100);
          path2.cubicTo(0, 0, 200, 200, 150, 100);
          canvas.drawPath(path2, paint);

          // Test 3: Very small cubic curve
          final path3 = Path();
          path3.moveTo(50, 150);
          path3.cubicTo(51, 149, 52, 151, 53, 150);
          canvas.drawPath(path3, paint);

          // Test 4: Cubic curve forming a loop
          final path4 = Path();
          path4.moveTo(200, 50);
          path4.cubicTo(250, 100, 200, 150, 200, 50);
          canvas.drawPath(path4, paint);

          // Test 5: Multiple cubic curves in sequence
          final path5 = Path();
          path5.moveTo(200, 100);
          path5.cubicTo(220, 80, 240, 120, 260, 100);
          path5.cubicTo(280, 80, 300, 120, 320, 100);
          path5.cubicTo(340, 80, 360, 120, 380, 100);
          canvas.drawPath(path5, paint);
        },
        size: size,
        exportFile: File('test_output/cubic_to_edge_cases.png'),
      );
    });
  });
}
