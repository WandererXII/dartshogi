import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import './core/piece.dart';
import './core/square.dart';
import './position/position.dart';

IMap<Square, ISet<Square>> makeLegalMoves(Position pos) {
  final Map<Square, ISet<Square>> result = {};
  for (final entry in pos.allMoveDests().entries) {
    final dests = entry.value.squares;
    if (dests.isNotEmpty) {
      final from = entry.key;
      final destSet = dests.toSet();
      result[from] = ISet(destSet);
    }
  }
  return IMap(result);
}

IMap<Piece, ISet<Square>> makeLegalDrops(Position pos) {
  final Map<Piece, ISet<Square>> result = {};
  for (final entry in pos.allDropDests().entries) {
    final dests = entry.value.squares;
    if (dests.isNotEmpty) {
      final from = entry.key;
      final destSet = dests.toSet();
      result[from] = ISet(destSet);
    }
  }
  return IMap(result);
}

// Unique object to use as a sentinel value in copyWith methods.
const uniqueObjectInstance = Object();
