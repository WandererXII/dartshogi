import './file.dart';
import './rank.dart';

/// A square of the shogi board.
///
/// The square is represented with an integer ranging from 0 to 255.
/// Coordination system starts at top right - square 0
/// Assumes POV of sente player - up is smaller rank, down is greater rank, left is smaller file, right is greater file
///
/// See also:
/// - [File]
/// - [Rank]
/// - [SquareSet] for the manipulation of sets of squares.
extension type const Square._(int value) implements int {
  /// Gets the board [Square] from a square index between 0 and 255.
  const Square(this.value) : assert(value >= 0 && value < 256);

  /// Gets a [Square] from its file and rank.
  factory Square.fromCoords(File file, Rank rank) => Square(file + rank * 16);

  /// Parses a square name in algebraic notation.
  ///
  /// Returns either a [Square] or `null` if the algebraic notation is invalid.
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

  /// The file of the square on the board.
  File get file => File(value & 15);

  /// The rank of the square on the board.
  Rank get rank => Rank(value >> 4);

  /// Unique identifier of the square, using pure algebraic notation.
  String get name => file.name + rank.name;

  /// Returns the square offset by [delta].
  ///
  /// Returns `null` if the resulting square is out of bounds.
  Square? offset(int delta) {
    assert(delta >= -255 && delta <= 255);
    final newSquare = value + delta;
    if (newSquare < 0 || newSquare > 255) {
      return null;
    }
    return Square(newSquare);
  }

  /// Return the bitwise XOR of the numeric square representation.
  Square xor(Square other) => Square(value ^ other.value);
}
