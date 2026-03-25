import 'package:meta/meta.dart';

import '../board.dart';
import '../hands.dart';
import './side.dart';
import './square.dart';

@immutable
class Setup {
  const Setup({
    required this.board,
    required this.hands,
    required this.turn,
    this.lastDest,
    this.lastLionCapture,
    required this.moveNumber,
  });

  final Board board;
  final Hands hands;
  final Side turn;
  final Square? lastDest;
  final Square? lastLionCapture;
  final int moveNumber;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setup &&
          board == other.board &&
          hands == other.hands &&
          turn == other.turn &&
          lastDest == other.lastDest &&
          lastLionCapture == other.lastLionCapture &&
          moveNumber == other.moveNumber);

  @override
  int get hashCode => Object.hash(board, hands, turn, lastDest, lastLionCapture, moveNumber);
}
