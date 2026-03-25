import 'dart:math';

import './file.dart';
import './rank.dart';

/// A square of the shogi board.
///
/// The square is represented with an integer ranging from 0 to 255.
/// Coordination system starts at top right.
/// Assumes POV of sente player - up is smaller rank, down is greater rank, left is smaller file, right is greater file.
extension type const Square._(int value) implements int {
  const Square(this.value) : assert(value >= 0 && value < 256);

  factory Square.fromCoords(File file, Rank rank) => Square(file + rank * 16);

  static Square? parse(String algebraic) {
    if (algebraic.length != 2 && algebraic.length != 3) return null;

    final file = int.tryParse(algebraic.substring(0, algebraic.length - 1));
    if (file == null) return null;

    final fileIdx = file - 1;
    final rank = algebraic.codeUnitAt(algebraic.length - 1) - 'a'.codeUnitAt(0);

    if (fileIdx < 0 || fileIdx >= 16 || rank < 0 || rank >= 16) {
      return null;
    }

    return Square(fileIdx + 16 * rank);
  }

  File get file => File(value & 15);

  Rank get rank => Rank(value >> 4);

  String get name => file.name + rank.name;

  Square? offset(int delta) {
    assert(delta >= -255 && delta <= 255);
    final newSquare = value + delta;
    if (newSquare < 0 || newSquare > 255) {
      return null;
    }
    return Square(newSquare);
  }

  int dist(Square other) {
    final x1 = file.value;
    final x2 = other.file.value;
    final y1 = rank.value;
    final y2 = other.rank.value;
    return max((x1 - x2).abs(), (y1 - y2).abs());
  }
}
