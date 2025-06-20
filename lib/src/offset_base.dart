import 'package:meta/meta.dart';
import 'package:pure_ui/pure_ui.dart' show Offset;
import 'package:pure_ui/src/offset.dart' show Offset;
import 'package:pure_ui/src/size.dart' show Size;

/// Base class for [Size] and [Offset], which are both ways to describe a
/// distance as a two-dimensional axis-aligned vector.
@immutable
abstract class OffsetBase {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const OffsetBase();

  /// The horizontal component of this vector.
  double get dx;

  /// The vertical component of this vector.
  double get dy;

  /// Less-than operator. Compares an [OffsetBase] to another [OffsetBase], and
  /// returns true if both the horizontal and vertical values of the left-hand-side
  /// operand are smaller than the horizontal and vertical values of the right-hand-side
  /// operand respectively. Returns false otherwise.
  bool operator <(OffsetBase other) => dx < other.dx && dy < other.dy;

  /// Less-than-or-equal-to operator. Compares an [OffsetBase] to another [OffsetBase],
  /// and returns true if both the horizontal and vertical values of the left-hand-side
  /// operand are smaller than or equal to the horizontal and vertical values of the
  /// right-hand-side operand respectively. Returns false otherwise.
  bool operator <=(OffsetBase other) => dx <= other.dx && dy <= other.dy;

  /// Greater-than operator. Compares an [OffsetBase] to another [OffsetBase],
  /// and returns true if both the horizontal and vertical values of the left-hand-side
  /// operand are bigger than the horizontal and vertical values of the right-hand-side
  /// operand respectively. Returns false otherwise.
  bool operator >(OffsetBase other) => dx > other.dx && dy > other.dy;

  /// Greater-than-or-equal-to operator. Compares an [OffsetBase] to another [OffsetBase],
  /// and returns true if both the horizontal and vertical values of the left-hand-side
  /// operand are bigger than or equal to the horizontal and vertical values of the
  /// right-hand-side operand respectively. Returns false otherwise.
  bool operator >=(OffsetBase other) => dx >= other.dx && dy >= other.dy;
}
