import 'package:meta/meta.dart';

import './game_result.dart';
import './side.dart';

@immutable
class Outcome {
  const Outcome({required this.result, required this.winner});

  final GameResult result;
  final Side? winner;

  @override
  String toString() {
    return 'result: $result, winner: $winner';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Outcome && result == other.result && winner == other.winner);

  @override
  int get hashCode => winner.hashCode;
}
