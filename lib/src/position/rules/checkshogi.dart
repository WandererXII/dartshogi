import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../../board.dart';
import '../../core/game_result.dart';
import '../../core/outcome.dart';
import '../../core/piece.dart';
import '../../core/rule.dart';
import '../../core/setup.dart';
import '../../core/side.dart';
import '../../core/square.dart';
import '../../hands.dart';
import '../../history.dart';
import '../../square_set.dart';
import '../../utils.dart';
import '../position.dart';
import './shogi.dart';

@immutable
abstract class Checkshogi extends Position {
  const factory Checkshogi({
    required Board board,
    required Hands hands,
    required Side turn,
    required History history,
    required int moveNumber,
  }) = _Checkshogi;

  const Checkshogi._({
    required super.board,
    required super.hands,
    required super.turn,
    required super.history,
    required super.moveNumber,
  });

  @override
  Rule get rule => Rule.checkshogi;

  @useResult
  static Result<Checkshogi> fromSetup(Setup s, {bool strict = false}) =>
      Position.fromSetupBase(s, Checkshogi.new, strict: strict);

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
  Outcome? outcome([Context? ctx]) {
    ctx ??= makeCtx();

    if (ctx.checkers.isNotEmpty) {
      return Outcome(result: GameResult.check, winner: ctx.side.opposite);
    } else {
      return super.outcome();
    }
  }
}

class _Checkshogi extends Checkshogi {
  const _Checkshogi({
    required super.board,
    required super.turn,
    required super.history,
    required super.hands,
    required super.moveNumber,
  }) : super._();

  @override
  Checkshogi copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    History? history,
    int? moveNumber,
  }) {
    return Checkshogi(
      board: board ?? this.board,
      hands: hands ?? this.hands,
      turn: turn ?? this.turn,
      history: history ?? this.history,
      moveNumber: moveNumber ?? this.moveNumber,
    );
  }
}
