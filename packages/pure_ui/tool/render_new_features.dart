// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'package:pure_ui/pure_ui.dart' as ui;

Future<void> saveImage(
    ui.Picture picture, int w, int h, String path) async {
  final image = await picture.toImage(w, h);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  await File(path).writeAsBytes(bytes!.buffer.asUint8List());
  print('Saved $path');
}

Future<void> main() async {
  await Directory('tool/renders').create(recursive: true);

  // ── 1. drawArc – pie slices ───────────────────────────────────────────────
  {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec, const ui.Rect.fromLTWH(0, 0, 300, 100));

    // background
    c.drawColor(const ui.Color(0xFFEEEEEE), ui.BlendMode.srcOver);

    // Red pie slice (90°, useCenter=true)
    c.drawArc(
      const ui.Rect.fromLTWH(10, 10, 80, 80),
      0,
      math.pi / 2,
      true,
      ui.Paint()
        ..color = const ui.Color(0xFFFF0000)
        ..style = ui.PaintingStyle.fill,
    );

    // Blue chord (180°, useCenter=false)
    c.drawArc(
      const ui.Rect.fromLTWH(110, 10, 80, 80),
      0,
      math.pi,
      false,
      ui.Paint()
        ..color = const ui.Color(0xFF0000FF)
        ..style = ui.PaintingStyle.fill,
    );

    // Green full circle stroke
    c.drawArc(
      const ui.Rect.fromLTWH(210, 10, 80, 80),
      0,
      math.pi * 2,
      false,
      ui.Paint()
        ..color = const ui.Color(0xFF00AA00)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    await saveImage(rec.endRecording(), 300, 100, 'tool/renders/01_arc.png');
  }

  // ── 2. drawRRect ──────────────────────────────────────────────────────────
  {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec, const ui.Rect.fromLTWH(0, 0, 300, 110));
    c.drawColor(const ui.Color(0xFFEEEEEE), ui.BlendMode.srcOver);

    // Small radius fill
    c.drawRRect(
      ui.RRect.fromRectXY(const ui.Rect.fromLTWH(10, 10, 80, 90), 8, 8),
      ui.Paint()
        ..color = const ui.Color(0xFFFF8800)
        ..style = ui.PaintingStyle.fill,
    );

    // Large radius fill
    c.drawRRect(
      ui.RRect.fromRectXY(const ui.Rect.fromLTWH(110, 10, 80, 90), 25, 25),
      ui.Paint()
        ..color = const ui.Color(0xFF880088)
        ..style = ui.PaintingStyle.fill,
    );

    // Stroke only
    c.drawRRect(
      ui.RRect.fromRectXY(const ui.Rect.fromLTWH(210, 10, 80, 90), 15, 15),
      ui.Paint()
        ..color = const ui.Color(0xFF0055FF)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    await saveImage(rec.endRecording(), 300, 110, 'tool/renders/02_rrect.png');
  }

  // ── 3. drawDRRect (ring/donut) ────────────────────────────────────────────
  {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec, const ui.Rect.fromLTWH(0, 0, 300, 110));
    c.drawColor(const ui.Color(0xFFEEEEEE), ui.BlendMode.srcOver);

    // Yellow ring
    c.drawDRRect(
      ui.RRect.fromRectXY(const ui.Rect.fromLTWH(10, 10, 90, 90), 8, 8),
      ui.RRect.fromRectXY(const ui.Rect.fromLTWH(30, 30, 50, 50), 8, 8),
      ui.Paint()
        ..color = const ui.Color(0xFFFFDD00)
        ..style = ui.PaintingStyle.fill,
    );

    // Cyan ring stroke
    c.drawDRRect(
      ui.RRect.fromRectXY(const ui.Rect.fromLTWH(120, 10, 90, 90), 8, 8),
      ui.RRect.fromRectXY(const ui.Rect.fromLTWH(140, 30, 50, 50), 8, 8),
      ui.Paint()
        ..color = const ui.Color(0xFF00AAAA)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    await saveImage(rec.endRecording(), 300, 110, 'tool/renders/03_drrect.png');
  }

  // ── 4. drawImageNine ──────────────────────────────────────────────────────
  {
    // Build a 9x9 test image: red border (1px), blue interior
    final srcRec = ui.PictureRecorder();
    final srcC = ui.Canvas(srcRec, const ui.Rect.fromLTWH(0, 0, 9, 9));
    srcC.drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.srcOver); // red bg
    srcC.drawRect(
      const ui.Rect.fromLTWH(1, 1, 7, 7),
      ui.Paint()
        ..color = const ui.Color(0xFF0000FF)
        ..style = ui.PaintingStyle.fill,
    );
    final srcImage = srcRec.endRecording().toImageSync(9, 9);

    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec, const ui.Rect.fromLTWH(0, 0, 300, 110));
    c.drawColor(const ui.Color(0xFFEEEEEE), ui.BlendMode.srcOver);

    // Draw the 9x9 source image stretched to 280x90
    c.drawImageNine(
      srcImage,
      const ui.Rect.fromLTWH(1, 1, 7, 7), // center slice
      const ui.Rect.fromLTWH(10, 10, 280, 90), // destination
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    srcImage.dispose();
    await saveImage(rec.endRecording(), 300, 110, 'tool/renders/04_imagenine.png');
  }

  // ── 5. Path.addOval / addArc / addRRect via drawPath ─────────────────────
  {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec, const ui.Rect.fromLTWH(0, 0, 300, 110));
    c.drawColor(const ui.Color(0xFFEEEEEE), ui.BlendMode.srcOver);

    // addOval
    c.drawPath(
      ui.Path()..addOval(const ui.Rect.fromLTWH(10, 10, 80, 90)),
      ui.Paint()
        ..color = const ui.Color(0xFFAA0000)
        ..style = ui.PaintingStyle.fill,
    );

    // addArc (partial fill)
    c.drawPath(
      ui.Path()..addArc(const ui.Rect.fromLTWH(110, 10, 80, 90), 0, math.pi),
      ui.Paint()
        ..color = const ui.Color(0xFF006600)
        ..style = ui.PaintingStyle.fill,
    );

    // addRRect
    c.drawPath(
      ui.Path()
        ..addRRect(ui.RRect.fromRectXY(
            const ui.Rect.fromLTWH(210, 10, 80, 90), 15, 15)),
      ui.Paint()
        ..color = const ui.Color(0xFF000088)
        ..style = ui.PaintingStyle.fill,
    );

    await saveImage(rec.endRecording(), 300, 110, 'tool/renders/05_path_shapes.png');
  }

  print('\nAll renders complete → tool/renders/');
}
