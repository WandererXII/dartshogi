import 'package:meta/meta.dart';

import '../board.dart';
import '../hands.dart';
import '../history.dart';
import './side.dart';

@immutable
class Setup {
  const Setup({
    required this.board,
    required this.hands,
    required this.turn,
    required this.history,
    required this.moveNumber,
  });

  final Board board;
  final Hands hands;
  final History history;
  final Side turn;
  final int moveNumber;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setup &&
          board == other.board &&
          hands == other.hands &&
          turn == other.turn &&
          history == other.history &&
          moveNumber == other.moveNumber);

  @override
  int get hashCode => Object.hash(board, hands, turn, history, moveNumber);
}
