import 'package:meta/meta.dart';
import 'package:pure_ui/src/canvas/canvas.dart';
import 'package:pure_ui/src/offset.dart';
import 'package:pure_ui/src/rect.dart';
import 'package:pure_ui/src/text/paragraph/paragraph_style.dart';
import 'package:pure_ui/src/text/text_style.dart';

/// A paragraph of text.
@immutable
class Paragraph {
  /// The text of the paragraph.
  final String text;

  // ignore: unused_field
  final ParagraphStyle _paragraphStyle;

  final TextStyle _textStyle;

  /// Creates a new paragraph object.
  const Paragraph(this.text, this._paragraphStyle, this._textStyle);

  /// The alphabetic baseline of the paragraph.
  double get alphabeticBaseline => _computeAlphabeticBaseline();

  /// The height that the paragraph occupies.
  double get height => _computeHeight();

  /// The maximum width of the paragraph.
  double get maxIntrinsicWidth => _computeMaxIntrinsicWidth();

  /// The text style of the paragraph.
  TextStyle get textStyle => _textStyle;

  /// Releases resources held by this paragraph.
  void dispose() {
    // In a real implementation, this would free native resources
    // For this pure implementation, it's a placeholder
  }

  /// Returns the smallest rectangle that completely contains the given range of text.
  Rect getBoxesForRange(int start, int end) {
    // In a real implementation, this would compute accurate text boxes
    // For this pure implementation, we'll provide a simplified approximation
    if (start < 0 || end > text.length || start >= end) {
      return Rect.zero;
    }

    final charWidth = _approximateCharWidth();
    final lineHeight = _approximateLineHeight();

    // Count newlines up to start to determine y position
    var linesBeforeStart = 0;
    for (var i = 0; i < start; i++) {
      if (text[i] == '\n') linesBeforeStart++;
    }

    // Count characters on the same line as start
    var charsOnStartLine = 0;
    final lastNewlineBeforeStart = text.lastIndexOf('\n', start - 1);
    if (lastNewlineBeforeStart == -1) {
      charsOnStartLine = start;
    } else {
      charsOnStartLine = start - lastNewlineBeforeStart - 1;
    }

    // Approximate the position
    final x = charsOnStartLine * charWidth;
    final y = linesBeforeStart * lineHeight;

    // For simplicity, assume all characters are on the same line
    final width = (end - start) * charWidth;

    return Rect.fromLTWH(x, y, width, lineHeight);
  }

  /// Lays out the paragraph with the given constraints.
  void layout(ParagraphConstraints constraints) {
    // In a real implementation, this would perform text layout
    // For this pure implementation, it's a placeholder
  }

  /// Paints the paragraph at the given offset on the canvas.
  void paint(Canvas canvas, Offset offset) {
    // In a real implementation, this would render the paragraph on the canvas
    // For this pure implementation, the method is a placeholder
  }

  double _approximateCharWidth() {
    final fontSize = _textStyle.fontSize ?? 14.0;
    return fontSize * 0.6; // Approximate character width
  }

  double _approximateLineHeight() {
    final fontSize = _textStyle.fontSize ?? 14.0;
    final lineHeight = _textStyle.height ?? 1.0;
    return fontSize * lineHeight;
  }

  double _computeAlphabeticBaseline() {
    // In a real implementation, this would compute the alphabetic baseline
    // For this pure implementation, use a simple approximation (75% of line height)
    final fontSize = _textStyle.fontSize ?? 14.0;
    return fontSize * 0.75;
  }

  double _computeHeight() {
    // In a real implementation, this would compute based on text layout
    final lineCount = text.split('\n').length;
    final fontSize = _textStyle.fontSize ?? 14.0;
    final lineHeight = _textStyle.height ?? 1.0;
    return lineCount * fontSize * lineHeight;
  }

  double _computeMaxIntrinsicWidth() {
    // In a real implementation, this would compute the maximum width
    // For this pure implementation, use a simple approximation
    final lines = text.split('\n');
    double maxWidth = 0.0;
    for (final line in lines) {
      final width = line.length * _approximateCharWidth();
      if (width > maxWidth) {
        maxWidth = width;
      }
    }
    return maxWidth;
  }
}

/// A builder for creating paragraph objects.
class ParagraphBuilder {
  final ParagraphStyle _paragraphStyle;

  TextStyle _textStyle;
  final StringBuffer _buffer;
  final List<TextSpan> _spans = <TextSpan>[];

  /// Creates a new paragraph builder.
  ParagraphBuilder(this._paragraphStyle)
      : _textStyle = const TextStyle(),
        _buffer = StringBuffer();

  /// Adds the given text to the paragraph.
  void addText(String text) {
    _buffer.write(text);
    _spans.add(TextSpan(text, _textStyle));
  }

  /// Builds the paragraph.
  Paragraph build() {
    return Paragraph(_buffer.toString(), _paragraphStyle, _textStyle);
  }

  /// Ends the effect of the most recent call to [pushStyle].
  void pop() {
    // In a real implementation, this would restore the previous style
    // For this pure implementation, it's a no-op
  }

  /// Applies the given style to the added text until [pop] is called.
  void pushStyle(TextStyle style) {
    _textStyle = _textStyle.merge(style);
  }
}

/// Constraints for paragraph layout.
@immutable
class ParagraphConstraints {
  /// The width the paragraph should use.
  final double width;

  /// Creates constraints for paragraph layout.
  const ParagraphConstraints({required this.width});

  @override
  int get hashCode => width.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ParagraphConstraints && other.width == width;
  }

  @override
  String toString() => 'ParagraphConstraints(width: $width)';
}

/// A span of text with a single style.
@immutable
class TextSpan {
  /// The text contained in the span.
  final String text;

  /// The style to apply to the text.
  final TextStyle style;

  /// Creates a new text span.
  const TextSpan(this.text, this.style);
}
