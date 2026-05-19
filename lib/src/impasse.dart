import 'dart:math' as math;

import './core/role.dart';
import './core/rule.dart';
import './core/side.dart';
import './handicap.dart';
import './position/position.dart';
import './position/utils.dart';
import './sfen.dart';

const int necessaryEnteredPieces = 10;
const int necessarySenteScore = 28;
const int necessaryGoteScore = 27;

bool isImpasse(Position position) {
  final impassableRules = {Rule.shogi, Rule.annanshogi, Rule.checkshogi};

  if (!impassableRules.contains(position.rule) || position.isCheck()) {
    return false;
  }

  final color = position.turn;

  final ranks = promotionZone(position.rule, color);
  final enteredRoles =
      position.board.pieces
          .where((x) => x.$2.side == color && ranks.has(x.$1))
          .map((x) => x.$2.role)
          .toList();

  final boardPoints = enteredRoles.fold(0, (sum, r) => sum + impasseValueOf(r));

  final handPoints = position.hands
      .side(color)
      .handMap
      .entries
      .fold(0, (sum, e) => sum + impasseValueOf(e.key) * e.value);

  final impassePoints = boardPoints + handPoints;

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
  final initialSfen = position.history.initialSfen;
  final newPosition = parseSfen(Rule.shogi, initialSfen!).getOrThrow();

  if (!Handicap.isHandicap(sfen: initialSfen, rule: position.rule)) {
    return 0;
  }
  final totalPoints =
      newPosition.board.pieces.fold(
        0,
        (sum, entry) => sum + impasseValueOf(entry.$2.role),
      ) +
      newPosition.hands.sente.handMap.entries.fold(
        0,
        (sum, r) => sum + impasseValueOf(r.key) * r.value,
      ) +
      newPosition.hands.gote.handMap.entries.fold(
        0,
        (sum, r) => sum + impasseValueOf(r.key) * r.value,
      );

  return math.max(0, ((necessaryGoteScore * 2) - totalPoints).toInt());
}
