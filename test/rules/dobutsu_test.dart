import 'package:dartshogi/dartshogi.dart';
import 'package:test/test.dart';

import '../fixtures/dobutsu.dart';

const _dobutsuPerfts = [
  ('', 1, 4),
  ('', 2, 17),
  ('', 3, 123),
  ('', 4, 976),
  ('', 5, 8122),
  ('', 6, 71677),
];

void main() {
  for (final (sfen, depth, res) in _dobutsuPerfts) {
    test('dobutsu perft: $sfen ($depth): $res', () {
      final pos =
          parseSfen(
            Rule.dobutsu,
            sfen.isEmpty ? initialSfen(Rule.dobutsu) : sfen,
          ).getOrThrow();
      expect(perft(pos, depth), res);
    });
  }

  test('pieces in hand', () {
    final pos = parseSfen(Rule.dobutsu, '3/1k1/3/1K1 b Pp 1').getOrThrow();
    expect(pos.hands.count, 2);
  });

  test('moving into check and being captured', () {
    final pos = parseSfen(Rule.dobutsu, '3/1k1/3/1K1 b - 1').getOrThrow();
    expect(perft(pos, 1), equals(5));
    expect(pos.isLegal(MoveOrDrop.parse('2d2c')!), isTrue);

    final pos2 = pos.play(MoveOrDrop.parse('2d2c')!).getOrThrow();
    expect(perft(pos2, 1), equals(8));
    expect(pos2.isLegal(MoveOrDrop.parse('2b2c')!), isTrue);

    final posNotMiss = pos2.play(MoveOrDrop.parse('2b2c')!).getOrThrow();
    final posMiss = pos2.play(MoveOrDrop.parse('2b1b')!).getOrThrow();
    expect(posNotMiss.isEnd(), isTrue);
    expect(posNotMiss.outcome()?.result, equals(GameResult.kingsLost));
    expect(posNotMiss.outcome()?.winner, equals(Side.gote));
    expect(posMiss.isEnd(), isFalse);
    expect(perft(posMiss, 1), equals(8));
  });

  group('try rule', () {
    test('basic', () {
      final pos = parseSfen(Rule.dobutsu, 'k2/2K/3/3 b - 1').getOrThrow();
      expect(perft(pos, 1), equals(5));
      expect(pos.isLegal(MoveOrDrop.parse('1b1a')!), isTrue);

      final pos2 = pos.play(MoveOrDrop.parse('1b1a')!).getOrThrow();
      expect(pos2.isEnd(), isTrue);
      expect(pos2.outcome()?.result, equals(GameResult.tryRule));
      expect(pos2.outcome()?.winner, equals(Side.sente));
    });

    final posBase =
        parseSfen(
          Rule.dobutsu,
          '1r1/bpK/k2/3 b -',
        ).getOrThrow().play(MoveOrDrop.parse('1b1a')!).getOrThrow();

    test('in check', () {
      expect(posBase.isEnd(), isFalse);
    });

    test('in check #2 - opponent safe try rule', () {
      final pos2 = posBase.play(MoveOrDrop.parse('3c3d')!).getOrThrow();
      expect(pos2.isEnd(), isTrue);
      expect(pos2.outcome()?.result, equals(GameResult.tryRule));
      expect(pos2.outcome()?.winner, equals(Side.gote));
    });

    test('in check #2 - random unrelated move', () {
      expect(
        posBase.play(MoveOrDrop.parse('2b2c')!).getOrThrow().isEnd(),
        isFalse,
      );
    });
    test('in check #3 - clearing check', () {
      final pos3 = posBase.play(MoveOrDrop.parse('2a3a')!).getOrThrow();
      expect(pos3.isEnd(), isTrue);
      expect(pos3.outcome()?.result, equals(GameResult.tryRule));
      expect(pos3.outcome()?.winner, equals(Side.sente));
    });

    test('try rule - draw', () {
      final pos =
          parseSfen(Rule.dobutsu, '1K1/1r1/1R1/1k1 w BPbp 40').getOrThrow();
      expect(pos.validate(strict: true).isSuccess(), isTrue);
      expect(pos.isLegal(MoveOrDrop.parse('2b2c')!), isTrue);

      final pos2 = pos.play(MoveOrDrop.parse('2b2c')!).getOrThrow();

      expect(pos2.isEnd(), isTrue);
      expect(pos2.outcome()?.result, equals(GameResult.draw));
      expect(pos2.outcome()?.winner, isNull);
    });
  });

  test('force promoting', () {
    final pos = parseSfen(Rule.dobutsu, '3/BRP/2k/K2 b P').getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('1b1a')!), isFalse);
    expect(pos.isLegal(MoveOrDrop.parse('1b1a+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('3b2a+')!), isFalse);
  });

  test('drops', () {
    final pos = parseSfen(Rule.dobutsu, 'rkr/b1b/1P1/BKR b P').getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('P*2b')!), isTrue);
    expect(pos.play(MoveOrDrop.parse('P*2b')!).getOrThrow().isEnd(), isFalse);
  });

  test('valid in opposite check', () {
    final posB = parseSfen(Rule.dobutsu, 'r2/2k/PKb/B2 b Pr').getOrThrow();
    final posW = parseSfen(Rule.dobutsu, 'r2/2k/PKb/B2 w Pr').getOrThrow();
    expect(posB.validate(strict: true).isSuccess(), isTrue);
    expect(posW.validate(strict: true).isSuccess(), isTrue);
  });

  test('double pawn', () {
    final pos = parseSfen(Rule.dobutsu, 'rkb/2P/2P/BKR b - 1').getOrThrow();
    expect(pos.validate(strict: true).isSuccess(), isTrue);

    final posPre = parseSfen(Rule.dobutsu, 'rkb/3/2P/BKR b P 1').getOrThrow();
    expect(posPre.isLegal(MoveOrDrop.parse('P*1b')!), isTrue);
  });

  test('randomly generated perfts - for consistency', () {
    for (final (sfen, depth, res) in perfts) {
      final pos =
          parseSfen(
            Rule.dobutsu,
            sfen.isEmpty ? initialSfen(Rule.dobutsu) : sfen,
          ).getOrThrow();
      expect(perft(pos, depth), equals(res));
    }
  });
}
