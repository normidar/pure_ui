import 'dart:io';

import 'package:pure_ui/pure_ui.dart' as ui;

void main() async {
  const fontPath = '/Library/Fonts/Arial Unicode.ttf';
  const fontFamily = 'ArialUnicode';
  const text = '君、いいね';
  const outputPath = 'tool/output_japanese.png';

  // Load font.
  ui.FontLoader.load(fontFamily, File(fontPath).readAsBytesSync());

  // Build paragraph.
  final para = (ui.ParagraphBuilder(ui.ParagraphStyle(
    fontFamily: fontFamily,
    fontSize: 64,
  ))
        ..pushStyle(ui.TextStyle(
          fontFamily: fontFamily,
          fontSize: 64,
          color: const ui.Color(0xFF222222),
        ))
        ..addText(text)
        ..pop())
      .build()
    ..layout(const ui.ParagraphConstraints(width: 600));

  print('Paragraph height: ${para.height}');
  print('Longest line:     ${para.longestLine}');

  // Render to canvas.
  const imgW = 700;
  const imgH = 150;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
      recorder, ui.Rect.fromLTWH(0, 0, imgW.toDouble(), imgH.toDouble()));

  // White background.
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, imgW.toDouble(), imgH.toDouble()),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );

  // Draw text centred vertically.
  final dy = (imgH - para.height) / 2;
  canvas.drawParagraph(para, ui.Offset(20, dy));

  // Export to PNG.
  final image = await recorder.endRecording().toImage(imgW, imgH);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    print('ERROR: toByteData returned null');
    exit(1);
  }

  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(byteData.buffer.asUint8List());

  print('Saved to $outputPath');
  image.dispose();
}
