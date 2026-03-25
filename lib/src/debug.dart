import './core/move_drop.dart';
import './position/position.dart';
import './position/utils.dart';

// const _lionPowerRoles = [Role.lion, Role.lionpromoted, Role.eagle, Role.falcon];

/// Counts legal move paths of a given length.
///
/// Computing perft numbers is useful for comparing, testing and debugging move
/// generation correctness and performance.
///
/// Set [ignoreEnd] to true to skip the [Position.isEnd] check, which is useful
/// for testing positions that are technically over but still have moves.
int perft(
  Position pos,
  int depth, {
  bool shouldLog = false,
  bool ignoreEnd = false,
}) {
  if (depth < 1) return 1;
  if (!ignoreEnd && pos.isEnd()) return 0;

  final logs = <String>[];
  int nodes = 0;

  for (final entry in pos.allMoveDests().entries) {
    final from = entry.key;
    final dests = entry.value;
    final piece = pos.board.pieceAt(from)!;

    for (final to in dests.squares) {
      // Determine whether this move can/must promote.
      final List<bool> promotions;
      if (pieceCanPromote(pos.rule, piece, from, to, pos.board.pieceAt(to))) {
        if (pieceForcePromote(pos.rule, piece, to)) {
          promotions = [true];
        } else {
          promotions = [true, false];
        }
      } else {
        promotions = [false];
      }

      for (final promotion in promotions) {
        final move = NormalMove(from: from, to: to, promotion: promotion);
        final child = pos.playUnchecked(move);
        final children = perft(child, depth - 1, ignoreEnd: ignoreEnd);
        if (shouldLog) logs.add('${move.usi} $children');
        nodes += children;
      }

      // Chushogi: lion-power pieces can make a two-step move.
      // if (_lionPowerRoles.contains(piece.role)) {
      //   final secondDests = secondLionStepDests(pos as Chushogi, from, to);
      //   for (final mid in secondDests.squares) {
      //     final move = NormalMove(from: from, to: to, midStep: mid);
      //     final child = pos.clone()..play(move);
      //     final children = perft(child, depth - 1, ignoreEnd: ignoreEnd);
      //     if (shouldLog) logs.add('${move.usi} $children');
      //     nodes += children;
      //   }
      // }
    }
  }

  for (final entry in pos.allDropDests().entries) {
    final piece = entry.key;
    final dests = entry.value;

    // In some variants a piece dropped onto the board can itself be promoted.
    final promotions =
        promotableOnDrop(pos.rule, piece) ? [false, true] : [false];

    for (final prom in promotions) {
      final role = prom ? promote(pos.rule, piece.role)! : piece.role;
      for (final to in dests.squares) {
        final drop = DropMove(role: role, to: to);
        final child = pos.playUnchecked(drop);
        final children = perft(child, depth - 1, ignoreEnd: ignoreEnd);
        if (shouldLog) logs.add('${drop.usi} $children');
        nodes += children;
      }
    }
  }

  if (shouldLog) print(logs.join('\n'));
  return nodes;
}
