import 'package:dartshogi/dartshogi.dart';
import 'package:test/test.dart';

void main() {
  test('basic moves', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    final move = MoveOrDrop.parse('7g7f')!;
    expect(makeWesternEngineMoveOrDrop(pos, move), equals('P-7f'));
    expect(
      makeWesternEngineMoveOrDrop(
        pos.playUnchecked(move),
        MoveOrDrop.parse('3c3d')!,
      ),
      equals('P-3d'),
    );
  });

  test('amb moves', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    final move = MoveOrDrop.parse('6i5h')!;
    expect(makeWesternEngineMoveOrDrop(pos, move), equals('G6i-5h'));
  });
}
