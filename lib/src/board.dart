import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

import './core/piece.dart';
import './core/role.dart';
import './core/side.dart';
import './core/square.dart';
import './square_set.dart';

@immutable
class Board {
  const Board({
    required this.occupied,
    required this.sente,
    required this.gote,
    required this.roles,
  });

  final SquareSet occupied;

  final SquareSet sente;

  final SquareSet gote;

  final IMap<Role, SquareSet> roles;

  static final empty = Board(
    occupied: SquareSet.empty,
    sente: SquareSet.empty,
    gote: SquareSet.empty,
    roles: const IMapConst({}),
  );

  Iterable<(Square, Piece)> get pieces sync* {
    for (final square in occupied.squares) {
      yield (square, pieceAt(square)!);
    }
  }

  IMap<Role, int> materialCount(Side side) =>
      IMap.fromEntries(Role.values.map((role) => MapEntry(role, piecesOf(side, role).size)));

  SquareSet piecesOf(Side side, Role role) {
    return bySide(side) & byRole(role);
  }

  SquareSet bySide(Side side) => side == Side.sente ? sente : gote;

  SquareSet byRole(Role role) {
    return roles[role] ?? SquareSet.empty;
  }

  SquareSet byRoles(List<Role> roleList) {
    return roleList.fold<SquareSet>(
        SquareSet.empty, (v, e) => v.union(roles[e] ?? SquareSet.empty));
  }

  SquareSet byPiece(Piece piece) {
    return bySide(piece.side) & byRole(piece.role);
  }

  Side? sideAt(Square square) {
    if (bySide(Side.sente).has(square)) {
      return Side.sente;
    } else if (bySide(Side.gote).has(square)) {
      return Side.gote;
    } else {
      return null;
    }
  }

  Role? roleAt(Square square) {
    if (!occupied.has(square)) return null;

    for (final entry in roles.entries) {
      if (entry.value.has(square)) {
        return entry.key;
      }
    }
    return null;
  }

  Piece? pieceAt(Square square) {
    final side = sideAt(square);
    if (side == null) return null;
    final role = roleAt(square)!;
    return Piece(side: side, role: role);
  }

  Square? kingOf(Side side) {
    return byPiece(Piece(side: side, role: Role.king)).singleSquare();
  }

  Set<Role> presentRoles() {
    return roles.entries.where((e) => e.value.isNotEmpty).map((e) => e.key).toSet();
  }

  @useResult
  Board setPieceAt(Square square, Piece piece) {
    final removed = removePieceAt(square);
    return Board(
      occupied: removed.occupied.withSquare(square),
      sente: piece.side == Side.sente ? removed.sente.withSquare(square) : removed.sente,
      gote: piece.side == Side.gote ? removed.gote.withSquare(square) : removed.gote,
      roles: removed.roles.update(
        piece.role,
        (sqs) => sqs.withSquare(square),
        ifAbsent: () => SquareSet.empty.withSquare(square),
      ),
    );
  }

  @useResult
  Board removePieceAt(Square square) {
    final piece = pieceAt(square);
    if (piece == null) return this;
    return Board(
      occupied: occupied.withoutSquare(square),
      sente: piece.side == Side.sente ? sente.withoutSquare(square) : sente,
      gote: piece.side == Side.gote ? gote.withoutSquare(square) : gote,
      roles: roles.update(
        piece.role,
        (sqs) => sqs.withoutSquare(square),
        ifRemove: (_, sqs) => sqs.isEmpty,
      ),
    );
  }

  // Helper to ensure we don't store empty squares.
  static IMap<Role, SquareSet> _clean(IMap<Role, SquareSet> map) =>
      map.removeWhere((_, sqs) => sqs.isEmpty);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Board &&
            other.occupied.equals(occupied) &&
            other.sente.equals(sente) &&
            other.gote.equals(gote) &&
            _clean(other.roles) == _clean(roles);
  }

  @override
  int get hashCode => Object.hash(occupied, sente, gote, _clean(roles));
}
