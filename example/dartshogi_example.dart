import 'package:dartshogi/dartshogi.dart';

void main() {
  // Parse sfen and create a valid shogi position
  final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();

  // Generate all legal moves
  assert(pos.allMoveDests().length == 40);

  // Parse usi
  final move = MoveOrDrop.parse('7g7f')!;

  assert(pos.isLegal(move));

  // Play moves
  final pos2 = pos.play(move).getOrThrow();

  // Detect game end conditions
  assert(pos2.outcome() == null);
}
