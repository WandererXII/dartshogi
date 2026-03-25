import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../../board.dart';
import '../../core/piece.dart';
import '../../core/rule.dart';
import '../../core/setup.dart';
import '../../core/side.dart';
import '../../core/square.dart';
import '../../hands.dart';
import '../../square_set.dart';
import '../../utils.dart';
import '../position.dart';
import './shogi.dart';

@immutable
abstract class Annanshogi extends Position {
  const factory Annanshogi({
    required Board board,
    required Hands hands,
    required Side turn,
    required int moveNumber,
    Square? lastDest,
    Square? lastLionCapture,
  }) = _Annanshogi;

  const Annanshogi._({
    required super.board,
    required super.hands,
    required super.turn,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  });

  @override
  Rule get rule => Rule.annanshogi;

  @useResult
  static Result<Annanshogi> fromSetup(Setup s, {bool strict = false}) =>
      Position.fromSetupBase(s, Annanshogi.new, strict: strict);

  @override
  PositionValidation get validation => const PositionValidation(
        doublePawn: false,
        oppositeCheck: true,
        unpromotedForcedPromotion: true,
        maxNumberOfRoyalPieces: 1,
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
}

class _Annanshogi extends Annanshogi {
  const _Annanshogi({
    required super.board,
    required super.turn,
    required super.hands,
    required super.moveNumber,
    super.lastDest,
    super.lastLionCapture,
  }) : super._();

  @override
  Annanshogi copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    int? moveNumber,
    Object? lastDest = uniqueObjectInstance,
    Object? lastLionCapture = uniqueObjectInstance,
  }) {
    return Annanshogi(
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
