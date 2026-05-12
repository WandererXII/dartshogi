import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../../../dartshogi.dart';
import '../../history.dart';

@immutable
abstract class Minishogi extends Position {
  const factory Minishogi({
    required Board board,
    required Hands hands,
    required History history,
    required Side turn,
    required int moveNumber,
    Square? lastDest,
    Square? lastLionCapture,
  }) = _Minishogi;

  const Minishogi._({
    required super.board,
    required super.hands,
    required super.turn,
    required super.history,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  });

  @override
  Rule get rule => Rule.minishogi;

  @useResult
  static Result<Minishogi> fromSetup(Setup s, {bool strict = false}) =>
      Position.fromSetupBase(s, Minishogi.new, strict: strict);

  @override
  SquareSet squareAttackers(Square square, Side attacker, SquareSet occupied) {
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
                goldAttacks(square, defender).intersect(
                  board.byRoles([Role.gold, Role.tokin, Role.promotedsilver]),
                ),
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
              .union(
                kingAttacks(square).intersect(
                  board.byRoles([Role.king, Role.dragon, Role.horse]),
                ),
              ),
        );
  }

  @override
  SquareSet squareSnipers(Square square, Side attacker) {
    final empty = SquareSet.empty;
    return rookAttacks(square, empty)
        .intersect(board.byRoles([Role.rook, Role.dragon]))
        .union(
          bishopAttacks(
            square,
            empty,
          ).intersect(board.byRoles([Role.bishop, Role.horse])),
        )
        .intersect(board.bySide(attacker));
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

class _Minishogi extends Minishogi {
  const _Minishogi({
    required super.board,
    required super.turn,
    required super.hands,
    required super.history,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  }) : super._();

  @override
  Minishogi copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    History? history,
    int? moveNumber,
    Object? lastDest = uniqueObjectInstance,
    Object? lastLionCapture = uniqueObjectInstance,
  }) {
    return Minishogi(
      board: board ?? this.board,
      hands: hands ?? this.hands,
      history: history ?? this.history,
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
