part of 'canvas.dart';

extension CanvasTextRendering on Canvas {
  // Method to draw characters (simple bitmap patterns)
  void _drawCharacter(
    img.Image target,
    String char,
    int x,
    int y,
    int width,
    int height,
    img.Color color,
  ) {
    // Use basic character patterns (5x7 pixels)
    final pattern = _getCharacterPattern(char);

    for (int py = 0; py < pattern.length && y + py < target.height; py++) {
      for (int px = 0; px < pattern[py].length && x + px < target.width; px++) {
        if (pattern[py][px] == 1 && x + px >= 0 && y + py >= 0) {
          target.setPixel(x + px, y + py, color);
        }
      }
    }
  }

  // Simple text drawing method
  void _drawSimpleText(
    img.Image target,
    String text,
    Offset offset,
    Color color,
    double fontSize,
  ) {
    final imgColor = img.ColorRgba8(
      color.red,
      color.green,
      color.blue,
      color.alpha,
    );

    // Determine pixel size based on character size
    final charWidth = (fontSize * 0.6).round();
    final charHeight = fontSize.round();

    var x = offset.dx.round();
    var y = offset.dy.round();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '\n') {
        // Line break processing
        x = offset.dx.round();
        y += (charHeight * 1.2).round();
        continue;
      }

      // Draw each character with simple pixel patterns
      _drawCharacter(target, char, x, y, charWidth, charHeight, imgColor);

      x += charWidth;

      // Line break when going off screen
      if (x + charWidth > target.width) {
        x = offset.dx.round();
        y += (charHeight * 1.2).round();
      }
    }
  }

  // Get character patterns (5x7 pixel basic patterns)
  List<List<int>> _getCharacterPattern(String char) {
    return [
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 1, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1],
    ];
  }

  void _renderParagraph(Paragraph paragraph, Offset offset) {
    if (_image == null) return;

    final target = _image.image;
    final text = paragraph.text;

    // Get color and font size from text style
    final textStyle = paragraph.textStyle;
    final color = textStyle.color ?? const Color(0xFF000000);
    final fontSize = textStyle.fontSize ?? 14.0;

    // Basic bitmap font drawing
    _drawSimpleText(target, text, offset, color, fontSize);
  }
}
