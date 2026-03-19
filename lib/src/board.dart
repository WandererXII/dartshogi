import 'package:meta/meta.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import './square_set.dart';
import './models.dart';

/// A board represented by several square sets for each piece.
@immutable
class Board {
  const Board({
    required this.occupied,
    required this.sente,
    required this.gote,
    required this.roles,
  });

  /// All occupied squares.
  final SquareSet occupied;

  /// All squares occupied by sente pieces.
  final SquareSet sente;

  /// All squares occupied by gote pieces.
  final SquareSet gote;

  /// Map of all roles and squares they occupy.
  final IMap<Role, SquareSet> roles;

  /// Empty board.
  static final empty = Board(
    occupied: SquareSet.empty,
    sente: SquareSet.empty,
    gote: SquareSet.empty,
    roles: const IMap.empty(),
  );

  /// An iterable of each [Piece] associated to its [Square].
  Iterable<(Square, Piece)> get pieces sync* {
    for (final square in occupied.squares) {
      yield (square, pieceAt(square)!);
    }
  }

  /// Gets the number of pieces of each [Role] for the given [Side].
  IMap<Role, int> materialCount(Side side) => IMap.fromEntries(
      Role.values.map((role) => MapEntry(role, piecesOf(side, role).size)));

  /// A [SquareSet] of all the pieces matching this [Side] and [Role].
  SquareSet piecesOf(Side side, Role role) {
    return bySide(side) & byRole(role);
  }

  /// Gets all squares occupied by [Side].
  SquareSet bySide(Side side) => side == Side.sente ? sente : gote;

  /// Gets all squares occupied by [Role].
  SquareSet byRole(Role role) {
    return roles[role] ?? SquareSet.empty;
  }

  /// Gets all squares occupied by [Piece].
  SquareSet byPiece(Piece piece) {
    return bySide(piece.color) & byRole(piece.role);
  }

  /// Gets the [Side] at this [Square], if any.
  Side? sideAt(Square square) {
    if (bySide(Side.sente).has(square)) {
      return Side.sente;
    } else if (bySide(Side.gote).has(square)) {
      return Side.gote;
    } else {
      return null;
    }
  }

  /// Gets the [Role] at this [Square], if any.
  Role? roleAt(Square square) {
    if (!occupied.has(square)) return null;

    for (final entry in roles.entries) {
      if (entry.value.has(square)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Gets the [Piece] at this [Square], if any.
  Piece? pieceAt(Square square) {
    final side = sideAt(square);
    if (side == null) {
      return null;
    }
    final role = roleAt(square)!;
    return Piece(color: side, role: role);
  }

  /// Finds the unique king [Square] of the given [Side], if any.
  Square? kingOf(Side side) {
    return byPiece(Piece(color: side, role: Role.king)).singleSquare();
  }

  /// Puts a [Piece] on a [Square] overriding the existing one, if any.
  @useResult
  Board setPieceAt(Square square, Piece piece) {
    final removed = removePieceAt(square);
    return removed.copyWith(
      occupied: removed.occupied.withSquare(square),
      sente:
          piece.color == Side.sente ? removed.sente.withSquare(square) : null,
      gote: piece.color == Side.gote ? removed.gote.withSquare(square) : null,
      roles: removed.roles.update(
        piece.role,
        (sqs) => sqs.withSquare(square),
        ifAbsent: () => SquareSet.empty.withSquare(square),
      ),
    );
  }

  /// Removes the [Piece] at this [Square] if it exists.
  @useResult
  Board removePieceAt(Square square) {
    final piece = pieceAt(square);
    return piece != null
        ? copyWith(
            occupied: occupied.withoutSquare(square),
            sente:
                piece.color == Side.sente ? sente.withoutSquare(square) : null,
            gote: piece.color == Side.gote ? gote.withoutSquare(square) : null,
            roles: roles.update(
              piece.role,
              (sqs) => sqs.withoutSquare(square),
              ifRemove: (_, sqs) => sqs.isEmpty,
            ),
          )
        : this;
  }

  /// Returns a copy of this board with some fields updated.
  @useResult
  Board copyWith({
    SquareSet? occupied,
    SquareSet? sente,
    SquareSet? gote,
    IMap<Role, SquareSet>? roles,
  }) {
    return Board(
      occupied: occupied ?? this.occupied,
      sente: sente ?? this.sente,
      gote: gote ?? this.gote,
      roles: roles ?? this.roles,
    );
  }

  // @override
  // String toString() => sfen;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Board &&
            other.occupied.equals(occupied) &&
            other.sente.equals(sente) &&
            other.gote.equals(gote) &&
            other.roles == roles;
  }

  @override
  int get hashCode => Object.hash(occupied, sente, gote, roles);
}
