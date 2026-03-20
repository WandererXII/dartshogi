import './core/square.dart';
import './square_set.dart';
import './core/piece.dart';
import './core/role.dart';
import './core/side.dart';

/// Gets squares attacked or defended by a king on [Square].
SquareSet kingAttacks(Square square) {
  return _neighbors[square];
}

/// Gets squares attacked or defended by a knight on [Square].
SquareSet knightAttacks(Square square, Side side) {
  if (side == Side.sente) {
    return _computeRange(square, [-31, -33]);
  } else {
    return _computeRange(square, [31, 33]);
  }
}

SquareSet silverAttacks(Square square, Side side) {
  if (side == Side.sente) {
    return _neighbors[square]
        .withoutMany([square + 16, square - 1, square + 1]);
  } else {
    return _neighbors[square]
        .withoutMany([square - 16, square - 1, square + 1]);
  }
}

SquareSet goldAttacks(Square square, Side side) {
  if (side == Side.sente) {
    return _neighbors[square].withoutMany([square + 17, square + 15]);
  } else {
    return _neighbors[square].withoutMany([square - 17, square - 15]);
  }
}

SquareSet pawnAttacks(Square square, Side side) {
  if (side == Side.sente) {
    return SquareSet.fromSquare(square - 16);
  } else {
    return SquareSet.fromSquare(square + 16);
  }
}

SquareSet bishopAttacks(Square square, SquareSet occupied) {
  final bit = SquareSet.fromSquare(square);
  return _hyperbola(bit, _diagRange[square], occupied)
      .xor(_hyperbola(bit, _antiDiagRange[square], occupied));
}

SquareSet rookAttacks(Square square, SquareSet occupied) {
  return _fileAttacks(square, occupied).xor(_rankAttacks(square, occupied));
}

SquareSet lanceAttacks(Square square, Side side, SquareSet occupied) {
  if (side == Side.sente) {
    return _fileAttacks(square, occupied).intersect(_forwRanks[square.rank]);
  } else {
    return _fileAttacks(square, occupied).intersect(_backRanks[square.rank]);
  }
}

SquareSet horseAttacks(Square square, SquareSet occupied) {
  return bishopAttacks(square, occupied).union(kingAttacks(square));
}

SquareSet dragonAttacks(Square square, SquareSet occupied) {
  return rookAttacks(square, occupied).union(kingAttacks(square));
}

// Chushogi pieces

SquareSet goBetweenAttacks(Square square) {
  return SquareSet.fromSquares([square - 16, square + 16]);
}

SquareSet chariotAttacks(Square square, SquareSet occupied) {
  return _fileAttacks(square, occupied);
}

SquareSet sideMoverAttacks(Square square, SquareSet occupied) {
  return _rankAttacks(square, occupied)
      .union(SquareSet.fromSquares([square - 16, square + 16]));
}

SquareSet verticalMoverAttacks(Square square, SquareSet occupied) {
  return _fileAttacks(square, occupied).union(_computeRange(square, [-1, 1]));
}

SquareSet copperAttacks(Square square, Side side) {
  if (side == Side.sente) {
    return _neighbors[square]
        .withoutMany([square + 17, square + 15, square + 1, square - 1]);
  } else {
    return _neighbors[square]
        .withoutMany([square - 17, square - 15, square - 1, square + 1]);
  }
}

SquareSet leopardAttacks(Square square) {
  return _neighbors[square].withoutMany([square + 1, square - 1]);
}

SquareSet tigerAttacks(Square square, Side side) {
  if (side == Side.sente) {
    return _neighbors[square].withoutSquare(square - 16);
  } else {
    return _neighbors[square].withoutSquare(square + 16);
  }
}

SquareSet elephantAttacks(Square square, Side side) {
  return tigerAttacks(square, side.opposite);
}

SquareSet kirinAttacks(Square square) {
  return _neighbors[square]
      .withoutMany([square + 1, square - 1, square + 16, square - 16]).union(
          _computeRange(square, [32, -32, -2, 2]));
}

SquareSet phoenixAttacks(Square square) {
  return _neighbors[square]
      .withoutMany([square - 15, square - 17, square + 15, square + 17]).union(
          _computeRange(square, [30, 34, -30, -34]));
}

SquareSet queenAttacks(Square square, SquareSet occupied) {
  return rookAttacks(square, occupied).union(bishopAttacks(square, occupied));
}

SquareSet stagAttacks(Square square, SquareSet occupied) {
  return _fileAttacks(square, occupied).union(_neighbors[square]);
}

SquareSet oxAttacks(Square square, SquareSet occupied) {
  return _fileAttacks(square, occupied).union(bishopAttacks(square, occupied));
}

SquareSet boarAttacks(Square square, SquareSet occupied) {
  return _rankAttacks(square, occupied).union(bishopAttacks(square, occupied));
}

SquareSet whaleAttacks(Square square, Side side, SquareSet occupied) {
  if (side == Side.sente) {
    return _fileAttacks(square, occupied).union(
        bishopAttacks(square, occupied).intersect(_backRanks[square.rank]));
  } else {
    return _fileAttacks(square, occupied).union(
        bishopAttacks(square, occupied).intersect(_forwRanks[square.rank]));
  }
}

SquareSet whiteHorseAttacks(Square square, Side side, SquareSet occupied) {
  return whaleAttacks(square, side.opposite, occupied);
}

SquareSet falconLionAttacks(Square square, Side side) {
  if (side == Side.sente) {
    return SquareSet.fromSquares([square - 16, square - 32]);
  } else {
    return SquareSet.fromSquares([square + 16, square + 32]);
  }
}

SquareSet falconAttacks(Square square, Side side, SquareSet occupied) {
  if (side == Side.sente) {
    return bishopAttacks(square, occupied)
        .union(_rankAttacks(square, occupied))
        .union(
            _fileAttacks(square, occupied).intersect(_backRanks[square.rank]))
        .union(falconLionAttacks(square, side));
  } else {
    return bishopAttacks(square, occupied)
        .union(_rankAttacks(square, occupied))
        .union(
            _fileAttacks(square, occupied).intersect(_forwRanks[square.rank]))
        .union(falconLionAttacks(square, side));
  }
}

SquareSet eagleLionAttacks(Square square, Side side) {
  if (side == Side.sente) {
    return _computeRange(square, [-15, -17, -30, -34]);
  } else {
    return _computeRange(square, [15, 17, 30, 34]);
  }
}

SquareSet eagleAttacks(Square square, Side side, SquareSet occupied) {
  if (side == Side.sente) {
    return rookAttacks(square, occupied)
        .union(
            bishopAttacks(square, occupied).intersect(_backRanks[square.rank]))
        .union(eagleLionAttacks(square, side));
  } else {
    return rookAttacks(square, occupied)
        .union(
            bishopAttacks(square, occupied).intersect(_forwRanks[square.rank]))
        .union(eagleLionAttacks(square, side));
  }
}

SquareSet lionAttacks(Square square) {
  return _neighbors[square].union(_computeRange(square,
      [-34, -33, -32, -31, -30, -18, -14, -2, 2, 14, 18, 30, 31, 32, 33, 34]));
}

/// Gets squares attacked or defended by a `piece` on `square`, given
/// `occupied` squares.
SquareSet attacks(Piece piece, Square square, SquareSet occupied) {
  switch (piece.role) {
    case Role.pawn:
      return pawnAttacks(square, piece.side);
    case Role.lance:
      return lanceAttacks(square, piece.side, occupied);
    case Role.knight:
      return knightAttacks(square, piece.side);
    case Role.silver:
      return silverAttacks(square, piece.side);
    case Role.promotedpawn:
    case Role.tokin:
    case Role.promotedlance:
    case Role.promotedknight:
    case Role.promotedsilver:
    case Role.gold:
      return goldAttacks(square, piece.side);
    case Role.bishop:
    case Role.bishoppromoted:
      return bishopAttacks(square, occupied);
    case Role.rook:
    case Role.rookpromoted:
      return rookAttacks(square, occupied);
    case Role.horse:
    case Role.horsepromoted:
      return horseAttacks(square, occupied);
    case Role.dragon:
    case Role.dragonpromoted:
      return dragonAttacks(square, occupied);
    case Role.tiger:
      return tigerAttacks(square, piece.side);
    case Role.copper:
      return copperAttacks(square, piece.side);
    case Role.elephant:
    case Role.elephantpromoted:
      return elephantAttacks(square, piece.side);
    case Role.leopard:
      return leopardAttacks(square);
    case Role.ox:
      return oxAttacks(square, occupied);
    case Role.stag:
      return stagAttacks(square, occupied);
    case Role.boar:
      return boarAttacks(square, occupied);
    case Role.gobetween:
      return goBetweenAttacks(square);
    case Role.falcon:
      return falconAttacks(square, piece.side, occupied);
    case Role.kirin:
      return kirinAttacks(square);
    case Role.lion:
    case Role.lionpromoted:
      return lionAttacks(square);
    case Role.phoenix:
      return phoenixAttacks(square);
    case Role.queen:
    case Role.queenpromoted:
      return queenAttacks(square, occupied);
    case Role.chariot:
      return chariotAttacks(square, occupied);
    case Role.sidemover:
    case Role.sidemoverpromoted:
      return sideMoverAttacks(square, occupied);
    case Role.eagle:
      return eagleAttacks(square, piece.side, occupied);
    case Role.verticalmover:
    case Role.verticalmoverpromoted:
      return verticalMoverAttacks(square, occupied);
    case Role.whale:
      return whaleAttacks(square, piece.side, occupied);
    case Role.whitehorse:
      return whiteHorseAttacks(square, piece.side, occupied);
    case Role.prince:
    case Role.king:
      return kingAttacks(square);
  }
}

/// Gets all squares of the rank, file or diagonal with the two squares
/// `a` and `b`, or an empty set if they are not aligned.
SquareSet ray(Square a, Square b) {
  final other = SquareSet.fromSquare(b);
  if (_rankRange[a].isIntersected(other)) {
    return _rankRange[a].withSquare(a);
  }
  if (_antiDiagRange[a].isIntersected(other)) {
    return _antiDiagRange[a].withSquare(a);
  }
  if (_diagRange[a].isIntersected(other)) {
    return _diagRange[a].withSquare(a);
  }
  if (_fileRange[a].isIntersected(other)) {
    return _fileRange[a].withSquare(a);
  }
  return SquareSet.empty;
}

/// Gets all squares between `a` and `b` (bounds not included), or an empty set
/// if they are not on the same rank, file or diagonal.
SquareSet between(Square a, Square b) {
  return ray(a, b)
      .intersect(SquareSet.full.shl256(a).xor(SquareSet.full.shl256(b)))
      .withoutFirst();
}

SquareSet _computeRange(Square square, List<int> deltas) {
  final file = square.file;
  final dests = deltas
      .map((delta) => square + delta)
      .where((sq) => sq >= 0 && sq < 256 && (file - Square(sq).file).abs() <= 2)
      .toList();
  return SquareSet.fromSquares(dests);
}

List<SquareSet> _tabulateSquares(SquareSet Function(Square) f) {
  final table = <SquareSet>[];
  for (int square = 0; square < 256; square++) {
    table.add(f(Square(square)));
  }
  return table;
}

List<SquareSet> _tabulateRanks(SquareSet Function(int) f) {
  final table = <SquareSet>[];
  for (int rank = 0; rank < 16; rank++) {
    table.add(f(rank));
  }
  return table;
}

final _forwRanks = _tabulateRanks((rank) => SquareSet.ranksAbove(rank));
final _backRanks = _tabulateRanks((rank) => SquareSet.ranksBelow(rank));

final _neighbors = _tabulateSquares(
    (sq) => _computeRange(sq, [-17, -16, -15, -1, 1, 15, 16, 17]));

final _fileRange =
    _tabulateSquares((sq) => SquareSet.fromFile(sq.file).withoutSquare(sq));

final _rankRange =
    _tabulateSquares((sq) => SquareSet.fromRank(sq.rank).withoutSquare(sq));

final _diagRange = _tabulateSquares((sq) {
  final diag = SquareSet.fromList([
    0x20001,
    0x80004,
    0x200010,
    0x800040,
    0x2000100,
    0x8000400,
    0x20001000,
    0x80004000,
  ]);
  final shift = 16 * (sq.rank - sq.file);
  return (shift >= 0 ? diag.shl256(shift) : diag.shr256(-shift))
      .withoutSquare(sq);
});
final _antiDiagRange = _tabulateSquares((sq) {
  final diag = SquareSet.fromList([
    0x40008000,
    0x10002000,
    0x4000800,
    0x1000200,
    0x400080,
    0x100020,
    0x40008,
    0x10002,
  ]);
  final shift = 16 * (sq.rank + sq.file - 15);
  return (shift >= 0 ? diag.shl256(shift) : diag.shr256(-shift))
      .withoutSquare(sq);
});

SquareSet _hyperbola(SquareSet bit, SquareSet range, SquareSet occupied) {
  var forward = occupied.intersect(range);
  var reverse = forward.rowSwap256(); // Assumes no more than 1 bit per rank

  forward = forward.minus256(bit);
  reverse = reverse.minus256(bit.rowSwap256());
  return forward.xor(reverse.rowSwap256()).intersect(range);
}

SquareSet _fileAttacks(Square square, SquareSet occupied) {
  return _hyperbola(SquareSet.fromSquare(square), _fileRange[square], occupied);
}

SquareSet _rankAttacks(Square square, SquareSet occupied) {
  final range = _rankRange[square];
  var forward = occupied.intersect(range);
  var reverse = forward.rbit256();
  forward = forward.minus256(SquareSet.fromSquare(square));
  reverse = reverse.minus256(SquareSet.fromSquare(255 - square));

  return forward.xor(reverse.rbit256()).intersect(range);
}
