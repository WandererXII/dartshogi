import 'package:dartshogi/dartshogi.dart';
import 'package:test/test.dart';

void main() {
  test('starting perft', () {
    final pos =
        parseSfen(Rule.checkshogi, initialSfen(Rule.checkshogi)).getOrThrow();
    expect(perft(pos, 0), equals(1));
    expect(perft(pos, 1), equals(30));
    expect(perft(pos, 2), equals(900));
    expect(perft(pos, 3), equals(25470));
    // expect(perft(pos, 4), equals(719408));
    // expect(perft(pos, 5), equals(19839626));
  });

  test('check win', () {
    final pos =
        parseSfen(
          Rule.checkshogi,
          '9/3gk4/9/2b6/9/6B2/9/4KG3/9 b - 1',
          strict: false,
        ).getOrThrow();
    expect(pos.isCheck(), isFalse);
    expect(pos.isEnd(), isFalse);

    final posChecked = pos.play(MoveOrDrop.parse('3f2e')!).getOrThrow();
    expect(posChecked.isCheck(), isTrue);
    expect(posChecked.isEnd(), isTrue);
    expect(posChecked.outcome()?.result, equals(GameResult.check));
    expect(posChecked.outcome()?.winner, equals(Side.sente));

    final pos2 =
        parseSfen(
          Rule.checkshogi,
          '9/3gk4/9/2b6/9/6B2/9/4KG3/9 w - 1',
          strict: false,
        ).getOrThrow();
    expect(pos2.isCheck(), isFalse);
    expect(pos2.isEnd(), isFalse);

    final pos2Checked = pos2.play(MoveOrDrop.parse('7d8e')!).getOrThrow();
    expect(pos2Checked.isCheck(), isTrue);
    expect(pos2Checked.isEnd(), isTrue);
    expect(pos2Checked.outcome()?.result, equals(GameResult.check));
    expect(pos2Checked.outcome()?.winner, equals(Side.gote));
  });

  test('pawn drop checkmate', () {
    final pos =
        parseSfen(
          Rule.checkshogi,
          '3rkr3/9/8p/4N4/1B7/9/1SG6/1KS6/9 b LPp',
          strict: false,
        ).getOrThrow();
    expect(pos.isCheck(), isFalse);
    expect(pos.isEnd(), isFalse);
    final md = MoveOrDrop.parse('P*5b')!;
    expect(pos.isLegal(md), isTrue);
    final md2 = MoveOrDrop.parse('L*5b')!;
    expect(pos.isLegal(md2), isTrue);

    final posChecked = pos.play(md2).getOrThrow();
    expect(posChecked.isCheck(), isTrue);
    expect(posChecked.isEnd(), isTrue);
    expect(posChecked.outcome()?.result, equals(GameResult.check));
    expect(posChecked.outcome()?.winner, equals(Side.sente));
  });

  test('pawn drop check', () {
    final pos =
        parseSfen(
          Rule.checkshogi,
          '3rk4/9/8p/4N4/1B7/9/1SG6/1KS6/9 b LPp 1',
        ).getOrThrow();
    expect(pos.isCheck(), isFalse);
    expect(pos.isEnd(), isFalse);
    final md = MoveOrDrop.parse('P*5b')!;
    expect(pos.isLegal(md), isTrue);

    final posChecked = pos.play(md).getOrThrow();
    expect(posChecked.isCheck(), isTrue);
    expect(posChecked.isEnd(), isTrue);
    expect(posChecked.outcome()?.result, equals(GameResult.check));
    expect(posChecked.outcome()?.winner, equals(Side.sente));
  });
}
