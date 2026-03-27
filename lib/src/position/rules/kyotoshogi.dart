import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../../attacks.dart';
import '../../board.dart';
import '../../core/move_drop.dart';
import '../../core/piece.dart';
import '../../core/role.dart';
import '../../core/rule.dart';
import '../../core/setup.dart';
import '../../core/side.dart';
import '../../core/square.dart';
import '../../hands.dart';
import '../../square_set.dart';
import '../../utils.dart';
import '../position.dart';
import '../utils.dart';
import './shogi.dart';

@immutable
abstract class Kyotoshogi extends Position {
  const factory Kyotoshogi({
    required Board board,
    required Hands hands,
    required Side turn,
    required int moveNumber,
    Square? lastDest,
    Square? lastLionCapture,
  }) = _Kyotoshogi;

  const Kyotoshogi._({
    required super.board,
    required super.hands,
    required super.turn,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  });

  @override
  Rule get rule => Rule.kyotoshogi;

  @useResult
  static Result<Kyotoshogi> fromSetup(Setup s, {bool strict = false}) =>
      Position.fromSetupBase(s, Kyotoshogi.new, strict: strict);

  @override
  PositionValidation get validation => const PositionValidation(
    doublePawn: false,
    oppositeCheck: true,
    unpromotedForcedPromotion: false,
    maxNumberOfRoyalPieces: 1,
  );

  @override
  SquareSet squareAttackers(Square square, Side attacker, SquareSet occupied) {
    final defender = attacker.opposite;
    return board
        .bySide(attacker)
        .intersect(
          rookAttacks(square, occupied)
              .intersect(board.byRole(Role.rook))
              .union(
                bishopAttacks(
                  square,
                  occupied,
                ).intersect(board.byRole(Role.bishop)),
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
                goldAttacks(
                  square,
                  defender,
                ).intersect(board.byRoles([Role.gold, Role.tokin])),
              )
              .union(
                silverAttacks(
                  square,
                  defender,
                ).intersect(board.byRole(Role.silver)),
              )
              .union(
                pawnAttacks(
                  square,
                  defender,
                ).intersect(board.byRole(Role.pawn)),
              )
              .union(kingAttacks(square).intersect(board.byRole(Role.king))),
        );
  }

  @override
  SquareSet squareSnipers(Square square, Side attacker) {
    final empty = SquareSet.empty;
    return rookAttacks(square, empty)
        .intersect(board.byRole(Role.rook))
        .union(
          bishopAttacks(square, empty).intersect(board.byRole(Role.bishop)),
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

  @override
  SquareSet moveDests(Square square, [Context? ctx]) {
    return standardMoveDests(this, square, ctx);
  }

  @override
  SquareSet dropDests(Piece piece, [Context? ctx]) {
    ctx ??= makeCtx();
    if (piece.side != ctx.side) return SquareSet.empty;

    var mask = board.occupied.complement();

    if (ctx.king != null && ctx.checkers.isNotEmpty) {
      final checker = ctx.checkers.singleSquare();
      if (checker == null) return SquareSet.empty;
      mask = mask.intersect(between(checker, ctx.king!));
    }

    return mask.intersect(fullSquareSet(rule));
  }

  @override
  bool isLegal(MoveOrDrop md, [Context? ctx]) {
    if (md is DropMove) {
      final side = ctx?.side ?? turn;

      final roleInHand =
          !handRoles(rule).contains(md.role)
              ? unpromote(rule, md.role)
              : md.role;
      if (roleInHand == null ||
          !handRoles(rule).contains(roleInHand) ||
          (hands.side(side).countOf(roleInHand)) <= 0) {
        return false;
      }

      return dropDests(Piece(side: turn, role: md.role), ctx).has(md.to);
    } else {
      return super.isLegal(md, ctx);
    }
  }
}

class _Kyotoshogi extends Kyotoshogi {
  const _Kyotoshogi({
    required super.board,
    required super.turn,
    required super.hands,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  }) : super._();

  @override
  Kyotoshogi copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    int? moveNumber,
    Object? lastDest = uniqueObjectInstance,
    Object? lastLionCapture = uniqueObjectInstance,
  }) {
    return Kyotoshogi(
      board: board ?? this.board,
      hands: hands ?? this.hands,
      turn: turn ?? this.turn,
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
