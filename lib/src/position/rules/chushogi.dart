import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../../../dartshogi.dart';

@immutable
abstract class Chushogi extends Position {
  const factory Chushogi({
    required Board board,
    required Hands hands,
    required Side turn,
    required int moveNumber,
    Square? lastDest,
    Square? lastLionCapture,
  }) = _Chushogi;

  const Chushogi._({
    required super.board,
    required super.hands,
    required super.turn,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  });

  @override
  Rule get rule => Rule.chushogi;

  @useResult
  static Result<Chushogi> fromSetup(Setup s, {bool strict = false}) =>
      Position.fromSetupBase(s, Chushogi.new, strict: strict);

  @override
  PositionValidation get validation => const PositionValidation(
        doublePawn: false,
        oppositeCheck: false,
        unpromotedForcedPromotion: false,
        maxNumberOfRoyalPieces: 2,
      );

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

  @override
  SquareSet kingsOf(Side side) =>
      board.byRoles([Role.king, Role.prince]).intersect(board.bySide(side));
}

class _Chushogi extends Chushogi {
  const _Chushogi({
    required super.board,
    required super.turn,
    required super.hands,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  }) : super._();

  @override
  Chushogi copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    int? moveNumber,
    Object? lastDest = uniqueObjectInstance,
    Object? lastLionCapture = uniqueObjectInstance,
  }) {
    return Chushogi(
      board: board ?? this.board,
      hands: hands ?? this.hands,
      turn: turn ?? this.turn,
      moveNumber: moveNumber ?? this.moveNumber,
      lastDest: lastDest == uniqueObjectInstance ? this.lastDest : lastDest as Square?,
      lastLionCapture: lastLionCapture == uniqueObjectInstance
          ? this.lastLionCapture
          : lastLionCapture as Square?,
    );
  }
}
