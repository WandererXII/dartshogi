import 'dart:math' as math;
import '../dartshogi.dart';

const int necessaryEnteredPieces = 10;
const int necessarySenteScore = 28;
const int necessaryGoteScore = 27;

bool isImpasse(Position position) {
  if (position.rule != Rule.shogi || position.isCheck()) {
    return false;
  }

  final color = position.turn;

  final ranks = promotionZone(position.rule, position.turn);

  final enteredRoles =
      position.board.pieces
          .where((x) => x.$2.side == color && ranks.has(x.$1.rank))
          .map((x) => x.$2.role)
          .toList();

  final impassePoints =
      enteredRoles.fold(0, (sum, r) => sum + impasseValueOf(r)) +
      position.hands
          .side(color)
          .handMap
          .keys
          .fold(0, (sum, r) => sum + impasseValueOf(r));

  return enteredRoles.length > necessaryEnteredPieces &&
      enteredRoles.contains(Role.king) &&
      impassePoints >=
          (color == Side.sente
              ? necessarySenteScore
              : necessaryGoteScore - missingImpassePoints(position));
}

int impasseValueOf(Role role) {
  switch (role) {
    case Role.bishop:
    case Role.rook:
    case Role.horse:
    case Role.dragon:
      return 5;

    case Role.king:
      return 0;

    default:
      return 1;
  }
}

int missingImpassePoints(Position position) {
  final positionSfen = makeSfen(position);
  if (!Handicap.isHandicap(rule: position.rule, sfen: positionSfen)) {
    return 0;
  }

  final totalPoints =
      position.board.pieces.fold(
        0,
        (sum, entry) => sum + impasseValueOf(entry.$2.role),
      ) +
      position.hands.sente.handMap.keys.fold(
        0,
        (sum, r) => sum + impasseValueOf(r),
      ) +
      position.hands.gote.handMap.keys.fold(
        0,
        (sum, r) => sum + impasseValueOf(r),
      );

  return math.max(0, ((necessaryGoteScore * 2) - totalPoints).toInt());
}
