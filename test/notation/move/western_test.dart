import 'package:dartshogi/dartshogi.dart';
import 'package:dartshogi/src/notation/move/western.dart';
import 'package:test/test.dart';

void main() {
  test('basic moves', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    final move = MoveOrDrop.parse('7g7f')!;
    expect(makeWesternMoveOrDrop(pos, move), equals('P-76'));
    expect(
      makeWesternMoveOrDrop(pos.playUnchecked(move), MoveOrDrop.parse('3c3d')!),
      equals('P-34'),
    );
  });

  test('amb moves', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    final move = MoveOrDrop.parse('6i5h')!;
    expect(makeWesternMoveOrDrop(pos, move), equals('G69-58'));
  });

  test('minishogi move', () {
    final pos =
        parseSfen(Rule.minishogi, initialSfen(Rule.minishogi)).getOrThrow();
    final move = MoveOrDrop.parse('4e4d')!;
    expect(makeWesternMoveOrDrop(pos, move), equals('G-44'));
  });
}
