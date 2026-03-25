import 'package:dartshogi/src/core/move_drop.dart';
import 'package:dartshogi/src/core/rule.dart';
import 'package:dartshogi/src/notation/move/kitao_kawasaki.dart';
import 'package:dartshogi/src/sfen.dart';
import 'package:test/test.dart';

void main() {
  test('basic moves', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    final move = MoveOrDrop.parse('7g7f')!;
    expect(makeKitaoKawasakiMoveOrDrop(pos, move), equals('歩-76'));
    expect(
      makeKitaoKawasakiMoveOrDrop(
        pos.playUnchecked(move),
        MoveOrDrop.parse('3c3d')!,
      ),
      equals('歩-34'),
    );
  });

  test('amb moves', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    final move = MoveOrDrop.parse('6i5h')!;
    expect(makeKitaoKawasakiMoveOrDrop(pos, move), equals('金(69)-58'));
  });
}
