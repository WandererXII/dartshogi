import 'dart:typed_data';
import './models.dart';

/// A finite set of all squares on a board.
///
/// All the squares are represented by 8 32-bit integers, where each bit
/// corresponds to a square, using a little-endian rank-file mapping.
/// See also [Square].
///
/// The set operations are implemented as bitwise operations on the integer.

extension type const SquareSet(Uint32List value) {
  SquareSet._internal(Uint32List dRows) : value = dRows;

  factory SquareSet.fromList(List<int> dRows) {
    final list = Uint32List(8);
    for (int i = 0; i < 8; i++) {
      list[i] = _toUint32(dRows[i]);
    }
    return SquareSet._internal(list);
  }

  /// Creates a [SquareSet] with a single [Square].
  factory SquareSet.fromSquare(int square) {
    if (square >= 256 || square < 0) return SquareSet.empty;
    final newRows = List<int>.filled(8, 0);
    final index = square >>> 5;
    newRows[index] = 1 << (square - index * 32);
    return SquareSet.fromList(newRows);
  }

  /// Creates a [SquareSet] from several [Square]s.
  factory SquareSet.fromSquares(List<int> squares) {
    final newRows = List<int>.filled(8, 0);
    for (final square in squares) {
      if (square < 256 && square >= 0) {
        final index = square >>> 5;
        newRows[index] = newRows[index] | (1 << (square - index * 32));
      }
    }
    return SquareSet.fromList(newRows);
  }

  /// Create a [SquareSet] containing all squares of the given rank.
  factory SquareSet.fromRank(int rank) {
    return SquareSet.fromList([0xffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])
        .shl256(16 * rank);
  }

  /// Create a [SquareSet] containing all squares of the given file.
  factory SquareSet.fromFile(int file) {
    final val = 0x10001 << file;
    return SquareSet.fromList([val, val, val, val, val, val, val, val]);
  }

  /// Create a [SquareSet] containing all ranks from [rank] above.
  static SquareSet ranksAbove(int rank) {
    return SquareSet.full.shr256(16 * (16 - rank));
  }

  /// Create a [SquareSet] containing all ranks from [rank] below.
  static SquareSet ranksBelow(int rank) {
    return SquareSet.full.shl256(16 * (rank + 1));
  }

  static final empty = SquareSet.fromList([0, 0, 0, 0, 0, 0, 0, 0]);
  static final full = SquareSet.fromList([
    0xffffffff,
    0xffffffff,
    0xffffffff,
    0xffffffff,
    0xffffffff,
    0xffffffff,
    0xffffffff,
    0xffffffff,
  ]);
  static final diagonal = SquareSet.fromList([
    0x20001,
    0x80004,
    0x200010,
    0x800040,
    0x2000100,
    0x8000400,
    0x20001000,
    0x80004000,
  ]);
  static final antidiagonal = SquareSet.fromList([
    0x40008000,
    0x10002000,
    0x4000800,
    0x1000200,
    0x400080,
    0x100020,
    0x40008,
    0x10002
  ]);

  /// Bitwise right shift
  SquareSet shr256(int shift) {
    if (shift >= 256) return SquareSet.empty;
    if (shift > 0) {
      final newRows = List<int>.filled(8, 0);
      final cutoff = shift >>> 5;
      final shift1 = shift & 0x1f;
      final shift2 = 32 - shift1;

      for (int i = 0; i < 8 - cutoff; i++) {
        newRows[i] = value[i + cutoff] >>> shift1;
        if (shift2 < 32 && i + cutoff + 1 < 8) {
          newRows[i] ^= value[i + cutoff + 1] << shift2;
        }
      }
      return SquareSet.fromList(newRows);
    }
    return this;
  }

  /// Bitwise left shift
  SquareSet shl256(int shift) {
    if (shift >= 256) return SquareSet.empty;
    if (shift > 0) {
      final newRows = List<int>.filled(8, 0);
      final cutoff = shift >> 5;
      final shift1 = shift & 0x1f;
      final shift2 = 32 - shift1;

      for (int i = cutoff; i < 8; i++) {
        newRows[i] = value[i - cutoff] << shift1;
        if (shift2 < 32 && i - cutoff - 1 >= 0) {
          newRows[i] ^= value[i - cutoff - 1] >>> shift2;
        }
      }
      return SquareSet.fromList(newRows);
    }
    return this;
  }

  /// Returns a new [SquareSet] with a bitwise XOR of this set and [other].
  SquareSet xor(SquareSet other) => SquareSet.fromList([
        value[0] ^ other.value[0],
        value[1] ^ other.value[1],
        value[2] ^ other.value[2],
        value[3] ^ other.value[3],
        value[4] ^ other.value[4],
        value[5] ^ other.value[5],
        value[6] ^ other.value[6],
        value[7] ^ other.value[7],
      ]);
  SquareSet operator ^(SquareSet other) => xor(other);

  /// Returns a new [SquareSet] with the squares that are in either this set or [other].
  SquareSet union(SquareSet other) => SquareSet.fromList([
        value[0] | other.value[0],
        value[1] | other.value[1],
        value[2] | other.value[2],
        value[3] | other.value[3],
        value[4] | other.value[4],
        value[5] | other.value[5],
        value[6] | other.value[6],
        value[7] | other.value[7],
      ]);
  SquareSet operator |(SquareSet other) => union(other);

  /// Returns a new [SquareSet] with the squares that are in both this set and [other].
  SquareSet intersect(SquareSet other) => SquareSet.fromList([
        value[0] & other.value[0],
        value[1] & other.value[1],
        value[2] & other.value[2],
        value[3] & other.value[3],
        value[4] & other.value[4],
        value[5] & other.value[5],
        value[6] & other.value[6],
        value[7] & other.value[7],
      ]);
  SquareSet operator &(SquareSet other) => intersect(other);

  /// Returns a new [SquareSet] with the [other] squares removed from this set.
  SquareSet minus256(SquareSet other) {
    int c = 0;
    final newRows = List<int>.from(value);

    for (int i = 0; i < 8; i++) {
      final otherWithC = _toUint32(other.value[i] + c);
      newRows[i] = _toUint32(newRows[i] - otherWithC);
      c = ((newRows[i] & otherWithC & 1) +
              (otherWithC >>> 1) +
              (newRows[i] >>> 1)) >>>
          31;
    }
    return SquareSet.fromList(newRows);
  }

  SquareSet operator -(SquareSet other) => minus256(other);

  /// Returns the set complement of this set.
  SquareSet complement() {
    return SquareSet.fromList([
      ~value[0],
      ~value[1],
      ~value[2],
      ~value[3],
      ~value[4],
      ~value[5],
      ~value[6],
      ~value[7],
    ]);
  }

  /// Returns the set difference of this set and [other].
  SquareSet diff(SquareSet other) {
    return SquareSet.fromList([
      value[0] & ~other.value[0],
      value[1] & ~other.value[1],
      value[2] & ~other.value[2],
      value[3] & ~other.value[3],
      value[4] & ~other.value[4],
      value[5] & ~other.value[5],
      value[6] & ~other.value[6],
      value[7] & ~other.value[7],
    ]);
  }

  /// Flips the set vertically.
  SquareSet rowSwap256() {
    return SquareSet.fromList([
      _rowSwap32(value[7]),
      _rowSwap32(value[6]),
      _rowSwap32(value[5]),
      _rowSwap32(value[4]),
      _rowSwap32(value[3]),
      _rowSwap32(value[2]),
      _rowSwap32(value[1]),
      _rowSwap32(value[0]),
    ]);
  }

  /// Flips the set horizontally.
  SquareSet rbit256() {
    return SquareSet.fromList([
      _rbit32(value[7]),
      _rbit32(value[6]),
      _rbit32(value[5]),
      _rbit32(value[4]),
      _rbit32(value[3]),
      _rbit32(value[2]),
      _rbit32(value[1]),
      _rbit32(value[0]),
    ]);
  }

  /// Returns the number of squares in the set.
  int get size {
    int count = 0;
    for (int i = 0; i < 8; i++) {
      count += _popcnt32(value[i]);
    }
    return count;
  }

  /// Returns true if the set is empty.
  bool get isEmpty {
    for (int i = 0; i < 8; i++) {
      if (value[i] != 0) return false;
    }
    return true;
  }

  /// Returns true if the set is not empty.
  bool get isNotEmpty {
    for (int i = 0; i < 8; i++) {
      if (value[i] != 0) return true;
    }
    return false;
  }

  /// Returns the first square in the set, or null if the set is empty.
  Square? first() {
    for (int i = 0; i < 8; i++) {
      if (value[i] != 0) {
        return Square((i + 1) * 32 - 1 - _clz32(value[i] & -value[i]));
      }
    }
    return null;
  }

  /// Returns the last square in the set, or null if the set is empty.
  Square? last() {
    for (int i = 7; i >= 0; i--) {
      if (value[i] != 0) {
        return Square((i + 1) * 32 - 1 - _clz32(value[i]));
      }
    }
    return null;
  }

  /// Returns the squares in the set as an iterable.
  Iterable<Square> get squares => _iterateSquares();

  /// Returns the squares in the set as an iterable in reverse order.
  Iterable<Square> get squaresReversed => _iterateSquaresReversed();

  /// Returns true if the set contains more than one square.
  bool moreThanOne() {
    final occ = <int>[];
    for (int i = 0; i < 8; i++) {
      if (value[i] != 0) occ.add(value[i]);
    }
    if (occ.length > 1) return true;
    return occ.any((r) => (r & (r - 1)) != 0);
  }

  /// Returns square if it is single, otherwise returns null.
  int? singleSquare() {
    return moreThanOne() ? null : last();
  }

  bool isSingleSquare() {
    return isNotEmpty && !moreThanOne();
  }

  /// Returns true if the [SquareSet] contains the given [square].
  bool has(int square) {
    if (square >= 256 || square < 0) return false;
    final index = square >>> 5;
    return (value[index] & (1 << (square - 32 * index))) != 0;
  }

  /// Returns true if the square set has any square in the [other] square set.
  bool isIntersected(SquareSet other) => intersect(other).isNotEmpty;

  /// Returns true if the square set is disjoint from the [other] square set.
  bool isDisjoint(SquareSet other) => intersect(other).isEmpty;

  /// Returns a new [SquareSet] with the given [square] added.
  SquareSet withSquare(int square) {
    if (square >= 256 || square < 0) return this;
    final index = square >>> 5;
    final newDRows = List<int>.from(value);
    newDRows[index] = newDRows[index] | (1 << (square - index * 32));
    return SquareSet.fromList(newDRows);
  }

  /// Returns a new [SquareSet] with all the given [squares] added.
  SquareSet withMany(List<int> squares) {
    final newDRows = List<int>.from(value);
    for (final square in squares) {
      if (square < 256 && square >= 0) {
        final index = square >>> 5;
        newDRows[index] = newDRows[index] | (1 << (square - index * 32));
      }
    }
    return SquareSet.fromList(newDRows);
  }

  /// Returns a new [SquareSet] with the given [square] removed.
  SquareSet without(int square) {
    if (square >= 256 || square < 0) return this;
    final index = square >>> 5;
    final newDRows = List<int>.from(value);
    newDRows[index] = newDRows[index] & ~(1 << (square - index * 32));
    return SquareSet.fromList(newDRows);
  }

  SquareSet withoutMany(List<int> squares) {
    final newDRows = List<int>.from(value);
    for (final square in squares) {
      if (square < 256 && square >= 0) {
        final index = square >>> 5;
        newDRows[index] = newDRows[index] & ~(1 << (square - index * 32));
      }
    }
    return SquareSet.fromList(newDRows);
  }

  /// Returns a new [SquareSet] with its first [Square] removed.
  SquareSet withoutFirst() {
    final newDRows = List<int>.from(value);
    for (int i = 0; i < 8; i++) {
      if (value[i] != 0) {
        newDRows[i] = newDRows[i] & (newDRows[i] - 1);
        return SquareSet.fromList(newDRows);
      }
    }
    return this;
  }

  /// Returns the hexadecimal string representation of the bitboard value.
  String hex() {
    final parts = <String>[];
    for (int i = 0; i < 8; i++) {
      parts.add('0x${value[i].toRadixString(16)}');
    }
    return parts.join(', ');
  }

  String visual() {
    final buffer = StringBuffer();
    for (int y = 0; y < 8; y++) {
      for (int x = 15; x >= 0; x--) {
        final sq = 32 * y + x;
        buffer.write(has(sq) ? ' 1' : ' 0');
        if (sq % 16 == 0) buffer.write('\n');
      }
      for (int x = 31; x >= 16; x--) {
        final sq = 32 * y + x;
        buffer.write(has(sq) ? ' 1' : ' 0');
        if (sq % 16 == 0) buffer.write('\n');
      }
    }
    return buffer.toString();
  }

  Iterable<Square> _iterateSquares() sync* {
    for (var i = 0; i < value.length; i++) {
      int tmp = value[i];
      while (tmp != 0) {
        final idx = 31 - _clz32(tmp & -tmp);
        tmp ^= 1 << idx;
        yield Square((i << 5) + idx);
      }
    }
  }

  Iterable<Square> _iterateSquaresReversed() sync* {
    for (var i = 7; i >= 0; i--) {
      int tmp = value[i];
      while (tmp != 0) {
        final idx = 31 - _clz32(tmp);
        tmp ^= 1 << idx;
        yield Square((i << 5) + idx);
      }
    }
  }

  bool equals(SquareSet other) {
    if (value.length != other.value.length) return false;
    for (var i = 0; i < value.length; i++) {
      if (value[i] != other.value[i]) return false;
    }
    return true;
  }
}

int _popcnt32(int np) {
  int n = np;
  n = n - ((n >>> 1) & 0x55555555);
  n = (n & 0x33333333) + ((n >>> 2) & 0x33333333);
  n = _toUint32(((n + (n >>> 4)) & 0x0f0f0f0f) * 0x01010101);
  return n >>> 24;
}

int _bswap32(int np) {
  int n = np;
  n = ((n >>> 8) & 0x00ff00ff) | _toUint32((n & 0x00ff00ff) << 8);
  return _rowSwap32(n);
}

int _rowSwap32(int n) {
  return ((n >>> 16) & 0xffff) | _toUint32((n & 0xffff) << 16);
}

int _rbit32(int np) {
  int n = np;
  n = ((n >>> 1) & 0x55555555) | _toUint32((n & 0x55555555) << 1);
  n = ((n >>> 2) & 0x33333333) | _toUint32((n & 0x33333333) << 2);
  n = ((n >>> 4) & 0x0f0f0f0f) | _toUint32((n & 0x0f0f0f0f) << 4);
  return _bswap32(n);
}

int _clz32(int n) {
  final int val = _toUint32(n);
  if (val == 0) return 32;
  return 32 - val.bitLength;
}

int _toUint32(int n) => n.toUnsigned(32);
