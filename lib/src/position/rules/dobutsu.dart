import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../../attacks.dart';
import '../../board.dart';
import '../../core/game_result.dart';
import '../../core/outcome.dart';
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

@immutable
abstract class Dobutsu extends Position {
  const factory Dobutsu({
    required Board board,
    required Hands hands,
    required Side turn,
    required int moveNumber,
    Square? lastDest,
    Square? lastLionCapture,
  }) = _Dobutsu;

  const Dobutsu._({
    required super.board,
    required super.hands,
    required super.turn,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  });

  @override
  Rule get rule => Rule.dobutsu;

  @useResult
  static Result<Dobutsu> fromSetup(Setup s, {bool strict = false}) =>
      Position.fromSetupBase(s, Dobutsu.new, strict: strict);

  @override
  PositionValidation get validation => const PositionValidation(
    doublePawn: false,
    oppositeCheck: false,
    unpromotedForcedPromotion: false,
    maxNumberOfRoyalPieces: 1,
  );

  @override
  SquareSet squareAttackers(Square square, Side attacker, SquareSet occupied) {
    final defender = attacker.opposite;
    return board
        .bySide(attacker)
        .intersect(
          _limitedAttacks(Piece(role: Role.rook, side: attacker), square)
              .intersect(board.byRole(Role.rook))
              .union(
                _limitedAttacks(
                  Piece(role: Role.bishop, side: attacker),
                  square,
                ).intersect(board.byRole(Role.bishop)),
              )
              .union(
                goldAttacks(
                  square,
                  defender,
                ).intersect(board.byRole(Role.tokin)),
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
  SquareSet squareSnipers(Square square, Side attacker) => SquareSet.empty;

  @override
  SquareSet moveDests(Square square, [Context? ctx]) {
    ctx ??= makeCtx();

    final piece = board.pieceAt(square);
    if (piece == null || piece.side != ctx.side) return SquareSet.empty;

    var pseudo = _limitedAttacks(piece, square).intersect(fullSquareSet(rule));
    pseudo = pseudo.diff(board.bySide(ctx.side));

    return pseudo.intersect(fullSquareSet(rule));
  }

  @override
  SquareSet dropDests(Piece piece, [Context? ctx]) {
    ctx ??= makeCtx();

    if (piece.side != ctx.side) return SquareSet.empty;
    return board.occupied.complement().intersect(fullSquareSet(rule));
  }

  @override
  Outcome? outcome([Context? ctx]) {
    ctx ??= makeCtx();

    if (kingsOf(ctx.side).isEmpty) {
      return Outcome(result: GameResult.kingsLost, winner: ctx.side.opposite);
    }

    bool isTryRule(Side side) {
      final king = kingsOf(side).singleSquare();
      return king != null &&
          promotionZone(rule, side).has(king) &&
          !isCheck(side);
    }

    final senteTryRule = isTryRule(Side.sente);
    final goteTryRule = isTryRule(Side.gote);

    if (senteTryRule && goteTryRule) {
      return const Outcome(result: GameResult.draw, winner: null);
    }
    if (senteTryRule) {
      return const Outcome(result: GameResult.tryRule, winner: Side.sente);
    }
    if (goteTryRule) {
      return const Outcome(result: GameResult.tryRule, winner: Side.gote);
    }
    if (!hasDests()) {
      return Outcome(result: GameResult.stalemate, winner: ctx.side.opposite);
    }

    return null;
  }
}

SquareSet _limitedAttacks(Piece piece, Square square) => switch (piece.role) {
  Role.bishop => kingAttacks(
    square,
  ).withoutMany([square - 16, square + 16, square - 1, square + 1]),
  Role.rook => kingAttacks(
    square,
  ).withoutMany([square - 15, square - 17, square + 15, square + 17]),
  _ => attacks(piece, square, SquareSet.empty),
};

class _Dobutsu extends Dobutsu {
  const _Dobutsu({
    required super.board,
    required super.turn,
    required super.hands,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  }) : super._();

  @override
  Dobutsu copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    int? moveNumber,
    Object? lastDest = uniqueObjectInstance,
    Object? lastLionCapture = uniqueObjectInstance,
  }) {
    return Dobutsu(
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
