import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../../attacks.dart';
import '../../board.dart';
import '../../core/game_result.dart';
import '../../core/move_drop.dart';
import '../../core/piece.dart';
import '../../core/role.dart';
import '../../core/rule.dart';
import '../../core/setup.dart';
import '../../core/side.dart';
import '../../core/square.dart';
import '../../hands.dart';
import '../../history.dart';
import '../../square_set.dart';
import '../../utils.dart';
import '../position.dart';
import '../utils.dart';

@immutable
abstract class Shogi extends Position {
  const factory Shogi({
    required Board board,
    required Hands hands,
    required Side turn,
    required int moveNumber,
    required History history,
    Square? lastDest,
    Square? lastLionCapture,
  }) = _Shogi;

  const Shogi._({
    required super.board,
    required super.hands,
    required super.turn,
    required super.moveNumber,
    required super.history,
    super.lastDest,
    super.lastLionCapture,
  });

  @override
  Rule get rule => Rule.shogi;

  @useResult
  static Result<Shogi> fromSetup(Setup s, {bool strict = false}) =>
      Position.fromSetupBase(s, Shogi.new, strict: strict);

  @override
  SquareSet squareAttackers(Square square, Side attacker, SquareSet occupied) {
    return standardSquareAttackers(square, attacker, board, occupied);
  }

  @override
  SquareSet squareSnipers(Square square, Side attacker) {
    return standardSquareSnipers(square, attacker, board);
  }

  @override
  SquareSet moveDests(Square square, [Context? ctx]) {
    return standardMoveDests(this, square, ctx);
  }

  @override
  SquareSet dropDests(Piece piece, [Context? ctx]) {
    return standardDropDests(this, piece, ctx);
  }
}

class _Shogi extends Shogi {
  const _Shogi({
    required super.board,
    required super.turn,
    required super.hands,
    required super.moveNumber,
    required super.history,
    super.lastDest,
    super.lastLionCapture,
  }) : super._();

  @override
  Shogi copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    History? history,
    int? moveNumber,
    Object? lastDest = uniqueObjectInstance,
    Object? lastLionCapture = uniqueObjectInstance,
  }) {
    return Shogi(
      board: board ?? this.board,
      hands: hands ?? this.hands,
      turn: turn ?? this.turn,
      history: history?? this.history,
      moveNumber: moveNumber ?? this.moveNumber,
      lastDest:
          lastDest == uniqueObjectInstance
              ? this.lastDest
              : lastDest as Square?,
      lastLionCapture:
          lastLionCapture == uniqueObjectInstance
              ? this.lastLionCapture
              : lastLionCapture as Square?,
    );
  }
}

SquareSet standardSquareAttackers(
  Square square,
  Side attacker,
  Board board,
  SquareSet occupied,
) {
  final defender = attacker.opposite;
  return board
      .bySide(attacker)
      .intersect(
        rookAttacks(square, occupied)
            .intersect(board.byRoles([Role.rook, Role.dragon]))
            .union(
              bishopAttacks(
                square,
                occupied,
              ).intersect(board.byRoles([Role.bishop, Role.horse])),
            )
            .union(
              lanceAttacks(
                square,
                defender,
                occupied,
              ).intersect(board.byRole(Role.lance)),
            )
            .union(
              knightAttacks(
                square,
                defender,
              ).intersect(board.byRole(Role.knight)),
            )
            .union(
              silverAttacks(
                square,
                defender,
              ).intersect(board.byRole(Role.silver)),
            )
            .union(
              goldAttacks(square, defender).intersect(
                board.byRoles([
                  Role.gold,
                  Role.tokin,
                  Role.promotedlance,
                  Role.promotedknight,
                  Role.promotedsilver,
                ]),
              ),
            )
            .union(
              pawnAttacks(square, defender).intersect(board.byRole(Role.pawn)),
            )
            .union(
              kingAttacks(
                square,
              ).intersect(board.byRoles([Role.king, Role.dragon, Role.horse])),
            ),
      );
}

SquareSet standardSquareSnipers(Square square, Side attacker, Board board) {
  final empty = SquareSet.empty;
  return rookAttacks(square, empty)
      .intersect(board.byRoles([Role.rook, Role.dragon]))
      .union(
        bishopAttacks(
          square,
          empty,
        ).intersect(board.byRoles([Role.bishop, Role.horse])),
      )
      .union(
        lanceAttacks(
          square,
          attacker.opposite,
          empty,
        ).intersect(board.byRole(Role.lance)),
      )
      .intersect(board.bySide(attacker));
}

SquareSet standardMoveDests(Position pos, Square square, [Context? ctx]) {
  ctx ??= pos.makeCtx();
  final piece = pos.board.pieceAt(square);
  if (piece == null || piece.side != ctx.side) return SquareSet.empty;

  var pseudo = attacks(
    piece,
    square,
    pos.board.occupied,
  ).intersect(fullSquareSet(pos.rule)).diff(pos.board.bySide(ctx.side));

  final king = ctx.king;
  if (king != null) {
    if (piece.role == Role.king) {
      // The king cannot step onto an attacked square.
      final occ = pos.board.occupied.withoutSquare(square);
      for (final to in pseudo.squares) {
        if (pos.squareAttackers(to, ctx.side.opposite, occ).isNotEmpty) {
          pseudo = pseudo.withoutSquare(to);
        }
      }
    } else {
      if (ctx.checkers.isNotEmpty) {
        // In check: must either block or capture the (single) checker.
        final checker = ctx.checkers.singleSquare();
        if (checker == null) return SquareSet.empty;
        pseudo = pseudo.intersect(between(checker, king).withSquare(checker));
      }

      // A pinned piece may only move along the pin ray.
      if (ctx.blockers.has(square)) {
        pseudo = pseudo.intersect(ray(square, king));
      }
    }
  }

  return pseudo;
}

SquareSet standardDropDests(Position pos, Piece piece, [Context? ctx]) {
  ctx ??= pos.makeCtx();
  if (piece.side != ctx.side) return SquareSet.empty;

  final role = piece.role;
  final dims = dimensions(pos.rule);

  // Start with all empty squares.
  var mask = pos.board.occupied.complement();

  // Remove backranks where the piece could never move again.
  if (role == Role.pawn || role == Role.lance) {
    mask = mask.diff(
      SquareSet.fromRank(ctx.side == Side.sente ? 0 : dims.ranks - 1),
    );
  } else if (role == Role.knight) {
    mask = mask.diff(
      ctx.side == Side.sente
          ? SquareSet.ranksAbove(2)
          : SquareSet.ranksBelow(dims.ranks - 3),
    );
  }

  final king = ctx.king;
  if (king != null && ctx.checkers.isNotEmpty) {
    final checker = ctx.checkers.singleSquare();
    if (checker == null) return SquareSet.empty;
    mask = mask.intersect(between(checker, king));
  }

  if (role == Role.pawn) {
    final pawns = pos.board
        .byRole(Role.pawn)
        .intersect(pos.board.bySide(ctx.side));
    for (final pawn in pawns.squares) {
      mask = mask.diff(SquareSet.fromFile(pawn.file));
    }

    final enemyKing = pos.kingsOf(ctx.side.opposite).singleSquare();
    if (enemyKing != null) {
      final kingFront = enemyKing.offset(ctx.side == Side.sente ? 16 : -16);
      if (kingFront != null && mask.has(kingFront)) {
        final child = pos.playUnchecked(
          DropMove(role: Role.pawn, to: kingFront),
        );
        if (child.outcome()?.result == GameResult.checkmate) {
          mask = mask.withoutSquare(kingFront);
        }
      }
    }
  }

  return mask.intersect(fullSquareSet(pos.rule));
}
