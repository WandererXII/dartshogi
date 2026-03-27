import 'package:dartshogi/dartshogi.dart';
import 'package:test/test.dart';

import '../fixtures/chushogi.dart';

const _chushogiPerfts = [
  ('', 1, 36),
  ('', 2, 1296),
  ('11k/12/12/12/12/4r7/12/12/9n2/4+o7/12/6B4K b 8j', 1, 7),
  ('11k/12/12/12/12/4r7/12/12/9n2/4+o7/12/6B4K b -', 1, 8),
];

const _soloPiecePerfts = [
  ('12/12/12/12/12/12/5N6/12/12/12/12/12 b', 1, 24 + 8 * 8), // solo lion
  ('12/12/12/12/12/12/5+O6/12/12/12/12/12 b', 1, 24 + 8 * 8), // solo +lion
  ('12/12/12/12/12/12/5+H6/12/12/12/12/12 b', 1, 41), // solo falcon
  ('12/12/12/12/12/12/5+D6/12/12/12/12/12 b', 1, 40), // solo eagle
  ('12/12/12/12/7g4/6n5/5N6/12/12/12/12/12 b - 1', 1, 24 + 8 * 8),
  ('12/12/12/12/4B2l4/4S7/5N6/7n4/12/12/12/12 b - 1', 1, 98),
];

void main() {
  test('valid promotions', () {
    final pos =
        parseSfen(
          Rule.chushogi,
          '10p1/2I1pP2p1LL/1Rp1PB2LL2/12/7L4/1p10/12/12/11k/12/11K/12 b - 1',
        ).getOrThrow();
    // capture inside prom zone
    expect(pos.isLegal(MoveOrDrop.parse('7c8b+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('7c8b')!), isTrue);
    // inside prom zone
    expect(pos.isLegal(MoveOrDrop.parse('7c6b+')!), isFalse);
    expect(pos.isLegal(MoveOrDrop.parse('7c6b')!), isTrue);
    // pawn last rank
    expect(pos.isLegal(MoveOrDrop.parse('7b7a+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('7b7a')!), isTrue);
    // entering prom zone
    expect(pos.isLegal(MoveOrDrop.parse('5e5c+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('5e5c')!), isTrue);
    // capture leaving prom zone
    expect(pos.isLegal(MoveOrDrop.parse('11c11f+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('11c11f')!), isTrue);
  });

  test('lion moves', () {
    final pos =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/12/6+O5/12/12/12/12/12/12 b',
        ).getOrThrow();
    expect(pos.moveDests(Square.parse('6f')!).size, equals(24));
    // 1 step, 0 dist move
    expect(pos.isLegal(MoveOrDrop.parse('6f6f')!), isFalse);
    // 1 step, 1 dist move
    expect(pos.isLegal(MoveOrDrop.parse('6f5e')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('6f7g')!), isTrue);
    // 1 step, 2 dist move
    expect(pos.isLegal(MoveOrDrop.parse('6f7d')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('6f4h')!), isTrue);
    // 2 step, back to start
    expect(pos.isLegal(MoveOrDrop.parse('6f6g6f')!), isTrue);
    // 2 step
    expect(pos.isLegal(MoveOrDrop.parse('6f5e6d')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('6f7g8h')!), isTrue);

    final pos2 =
        parseSfen(
          Rule.chushogi,
          '3l8/11p/10p1/3n5+D2/2i1f7/3N5G2/9+H2/2t2P1i4/2p3+D5/2+H9/12/12 b',
        ).getOrThrow();
    // jumps
    expect(pos2.isLegal(MoveOrDrop.parse('3g3e')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('3g3f')!), isFalse);
    expect(pos2.isLegal(MoveOrDrop.parse('6i4g')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('6i8g')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('6i7h')!), isFalse);
    // captures
    expect(pos2.isLegal(MoveOrDrop.parse('6i5h')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('6i5h6i')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('6i5h4g')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('3d2c')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('3d1b')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('3d2c1b')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('3d1b2c')!), isFalse);
    expect(pos2.isLegal(MoveOrDrop.parse('10j10i')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('10j10h')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('10j10i10h')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('10j10h10i')!), isFalse);
    // lions
    expect(pos2.isLegal(MoveOrDrop.parse('9f10e')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('9f8e')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('9f9d')!), isFalse);
    expect(pos2.isLegal(MoveOrDrop.parse('9f10e9d')!), isFalse);
    expect(pos2.isLegal(MoveOrDrop.parse('9f8e9d')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('9f9e9d')!), isFalse);

    final pos3 =
        parseSfen(
          Rule.chushogi,
          '11l/6l5/5Nn5/11n/9N2/12/1N10/9n2/1n7N2/4r7/4nN6/4r7 b',
        ).getOrThrow();
    expect(pos3.isLegal(MoveOrDrop.parse('7c6c')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('7c6b6c')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('3e1d')!), isFalse);
    expect(pos3.isLegal(MoveOrDrop.parse('3e2e1d')!), isFalse);
    expect(pos3.isLegal(MoveOrDrop.parse('3i3h')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('3i3h3g')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('3i2h3h')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('7k8k')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('7k8j8k')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('7k8l8k')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('7k8k8j')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('7k8k8l')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('7k7j8k')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('11g11i')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('11g11h11i')!), isTrue);

    final pos4 =
        parseSfen(
          Rule.chushogi,
          '11k/12/12/10bm/9N2/12/5n6/6N5/5r6/12/9K2/12 b',
        ).getOrThrow();
    expect(
      pos4
          .play(MoveOrDrop.parse('6h7g')!)
          .getOrThrow()
          .isLegal(MoveOrDrop.parse('2d3e')!),
      isTrue,
    );

    final pos5 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/12/12/12/12/4+ho3n2/4N7/12/6B5 w',
        ).getOrThrow();

    final pos5Alt = pos5.play(MoveOrDrop.parse('8i8j8i')!).getOrThrow();
    expect(pos5Alt.isLegal(MoveOrDrop.parse('6l3i')!), isFalse);

    final pos5Alt2 = pos5.play(MoveOrDrop.parse('8i8j')!).getOrThrow();
    expect(pos5Alt2.isLegal(MoveOrDrop.parse('6l3i')!), isFalse);

    final pos5Alt3 = pos5.play(MoveOrDrop.parse('7i8j+')!).getOrThrow();
    expect(pos5Alt3.isLegal(MoveOrDrop.parse('6l3i')!), isFalse);
    expect(pos5Alt3.isLegal(MoveOrDrop.parse('6l8j')!), isTrue);
  });

  test('wiki lion moves and more', () {
    final pos =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/7g4/6n5/5N6/12/12/12/12/12 b',
        ).getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('7g6f')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('7g6f5e')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('7g6f6e')!), isTrue);

    final pos2 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/4B2l4/4S7/5N6/7n4/12/12/12/12 b',
        ).getOrThrow();
    final pos2opp =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/4B2l4/4S7/5N6/7n4/12/12/12/12 w',
        ).getOrThrow();
    expect(pos2.isLegal(MoveOrDrop.parse('7g5h')!), isFalse);
    expect(pos2.isLegal(MoveOrDrop.parse('7g5e')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('8e5h')!), isTrue);
    expect(pos2opp.isLegal(MoveOrDrop.parse('5h7g')!), isFalse);
    expect(pos2opp.isLegal(MoveOrDrop.parse('5h5j')!), isTrue);

    final pos3 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/3n8/12/5N6/5P6/7b4/12/12/12 b',
        ).getOrThrow();
    final pos3opp =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/3n8/12/5N6/5P6/7b4/12/12/12 w',
        ).getOrThrow();
    expect(pos3.isLegal(MoveOrDrop.parse('7g9e')!), isFalse);
    expect(pos3.isLegal(MoveOrDrop.parse('7g5i')!), isTrue);
    expect(pos3opp.isLegal(MoveOrDrop.parse('9e7g')!), isFalse);
    expect(pos3opp.isLegal(MoveOrDrop.parse('9e10e')!), isTrue);
    expect(pos3opp.isLegal(MoveOrDrop.parse('5i7g')!), isTrue);

    final pos4 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/3n1H6/3sp7/5N6/5P6/1k5b4/12/12/12 b',
        ).getOrThrow();
    expect(pos4.isLegal(MoveOrDrop.parse('7g9e')!), isTrue);
    expect(pos4.isLegal(MoveOrDrop.parse('7g8f9e')!), isFalse);

    final pos5 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/12/4N7/4p7/4n7/12/12/12/12 b',
        ).getOrThrow();
    expect(pos5.isLegal(MoveOrDrop.parse('8f8g')!), isTrue);
    expect(pos5.isLegal(MoveOrDrop.parse('8f8h')!), isFalse);
    expect(pos5.isLegal(MoveOrDrop.parse('8f8g8h')!), isFalse);

    final pos6 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/6+o1r3/4gi6/6N5/7s4/8n3/12/12/12 b',
        ).getOrThrow();
    expect(pos6.isLegal(MoveOrDrop.parse('6g4i')!), isFalse);
    expect(pos6.isLegal(MoveOrDrop.parse('6g5h4i')!), isTrue);
    expect(pos6.isLegal(MoveOrDrop.parse('6g6e')!), isFalse);
    expect(pos6.isLegal(MoveOrDrop.parse('6g7f6e')!), isFalse);
    expect(pos6.isLegal(MoveOrDrop.parse('6g6f6e')!), isFalse);
    expect(pos6.isLegal(MoveOrDrop.parse('6g7f')!), isTrue);
    expect(pos6.isLegal(MoveOrDrop.parse('6g7f8f')!), isTrue);

    final pos7 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/12/4r7/12/12/5o3n1n/4N6P/12/6B5 w - 1',
        ).getOrThrow();

    final pos7Alt = pos7.play(MoveOrDrop.parse('8f8j')!).getOrThrow();
    expect(pos7Alt.isLegal(MoveOrDrop.parse('6l8j')!), isTrue);
    expect(pos7Alt.isLegal(MoveOrDrop.parse('6l3i')!), isFalse);

    final pos7Alt2 = pos7.play(MoveOrDrop.parse('7i8j+')!).getOrThrow();
    expect(pos7Alt2.lastLionCapture, equals(Square.parse('8j')));
    expect(pos7Alt2.isLegal(MoveOrDrop.parse('6l8j')!), isTrue);
    expect(pos7Alt2.isLegal(MoveOrDrop.parse('6l3i')!), isFalse);

    final pos7Alt3 = pos7.play(MoveOrDrop.parse('7i8j')!).getOrThrow();
    expect(pos7Alt3.isLegal(MoveOrDrop.parse('6l8j')!), isTrue);
    expect(pos7Alt3.isLegal(MoveOrDrop.parse('6l3i')!), isFalse);

    final pos7Alt4 = pos7.play(MoveOrDrop.parse('3i4i3i')!).getOrThrow();
    expect(pos7Alt4.isLegal(MoveOrDrop.parse('6l3i')!), isTrue);
    expect(pos7Alt4.isLegal(MoveOrDrop.parse('1j1i')!), isTrue);

    final pos8 =
        parseSfen(
          Rule.chushogi,
          '12/12/3l8/12/3b4+o3/6n5/4N7/6R5/7K4/12/12/12 b - 1',
        ).getOrThrow();
    expect(pos8.isLegal(MoveOrDrop.parse('8g6f')!), isFalse);
  });

  test('falcon/eagle second move', () {
    final pos =
        parseSfen(
          Rule.chushogi,
          'k11/12/12/12/6n5/6P5/12/5+h6/12/5N6/12/11K b',
        ).getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('6f6e')!), isTrue);

    final posAlt = pos.play(MoveOrDrop.parse('6f6e')!).getOrThrow();
    expect(posAlt.isLegal(MoveOrDrop.parse('7h7i')!), isTrue);
    expect(posAlt.isLegal(MoveOrDrop.parse('7h7i7j')!), isFalse);
    final dests = makeSecondLionMoves(
      posAlt,
      Square.parse('7h')!,
      Square.parse('7i')!,
    ).get(Square.parse('7i')!);
    expect(dests != null && !dests.contains(Square.parse('7j')), isTrue);

    final pos2 =
        parseSfen(
          Rule.chushogi,
          'k11/12/12/12/6n5/6P5/12/7+d4/12/5N6/12/11K b',
        ).getOrThrow().play(MoveOrDrop.parse('6f6e')!).getOrThrow();

    expect(pos2.isLegal(MoveOrDrop.parse('5h6i')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('5h6i7j')!), isFalse);
    final dests2 = makeSecondLionMoves(
      pos2,
      Square.parse('5h')!,
      Square.parse('6i')!,
    ).get(Square.parse('6i')!);
    expect(
      dests2 != null &&
          !dests2.contains(Square.parse('7j')) &&
          dests2.isNotEmpty,
      isTrue,
    );
  });

  test('bare king', () {
    final pos =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/6k5/4g7/4G7/6K5/12/12/12/12 b - 1',
        ).getOrThrow();
    expect(pos.outcome(), isNull);

    final posPlay1 = pos.play(MoveOrDrop.parse('8g8f')!).getOrThrow();
    expect(posPlay1.outcome()?.result, equals(GameResult.bareKing));
    expect(posPlay1.outcome()?.winner, equals(Side.sente));

    final pos2 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/3I2k5/12/12/5+pK5/12/12/12/12 b - 1',
        ).getOrThrow();
    expect(pos2.outcome(), isNull);

    final pos2Play1 = pos2.play(MoveOrDrop.parse('6h7h')!).getOrThrow();
    expect(pos2Play1.outcome(), isNull);

    final pos2Play2 = pos2Play1.play(MoveOrDrop.parse('6e7d')!).getOrThrow();
    expect(pos2Play2.outcome(), isNull);

    final pos2Play3 = pos2Play2.play(MoveOrDrop.parse('9e9d+')!).getOrThrow();
    expect(pos2Play3.outcome()?.result, equals(GameResult.bareKing));

    final pos3 =
        parseSfen(
          Rule.chushogi,
          '1P3PP3P1/12/12/12/6k5/12/12/6K5/12/12/12/l10l b - 1',
        ).getOrThrow();
    expect(pos3.outcome()?.result, equals(GameResult.draw));

    final pos4 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/6k5/5g6/4G7/6K5/12/12/12/12 b - 1',
        ).getOrThrow();
    expect(pos4.outcome(), isNull);

    final pos4Play1 = pos4.play(MoveOrDrop.parse('8g7f')!).getOrThrow();
    expect(pos4Play1.outcome(), isNull);

    final pos4Play2 = pos4Play1.play(MoveOrDrop.parse('6e7f')!).getOrThrow();
    final pos4Play2Alt = pos4Play1.play(MoveOrDrop.parse('6e6d')!).getOrThrow();

    expect(pos4Play2.outcome()?.result, equals(GameResult.draw));
    expect(pos4Play2Alt.outcome()?.result, equals(GameResult.bareKing));

    final pos5 =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/6k5/5K6/12/4G7/12/12/12/12 w - 1',
        ).getOrThrow();
    expect(pos5.outcome(), isNull);

    final pos6 = pos5.copyWith(turn: pos5.turn.opposite);
    expect(pos6.outcome(), isNull);
  });

  test('chushogi perft', () {
    for (final (sfen, depth, res) in _chushogiPerfts) {
      final pos =
          parseSfen(
            Rule.chushogi,
            sfen.isEmpty ? initialSfen(Rule.chushogi) : sfen,
          ).getOrThrow();
      expect(perft(pos, depth), equals(res));
    }
  });

  test('chushogi solo piece perft', () {
    for (final (sfen, depth, res) in _soloPiecePerfts) {
      final pos =
          parseSfen(
            Rule.chushogi,
            sfen.isEmpty ? initialSfen(Rule.chushogi) : sfen,
          ).getOrThrow();
      expect(perft(pos, depth, ignoreEnd: true), equals(res));
    }
  });

  test('randomly generated perfts - for consistency', () {
    for (final (sfen, depth, res) in perfts) {
      final pos =
          parseSfen(
            Rule.chushogi,
            sfen.isEmpty ? initialSfen(Rule.chushogi) : sfen,
          ).getOrThrow();
      expect(pos.isEnd(), isFalse);
      expect(perft(pos, depth), equals(res));
    }
  });

  test('valid in opposite check', () {
    final posB =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/12/6k5/5K6/12/12/12/12/12 b - 1',
        ).getOrThrow();
    final posW =
        parseSfen(
          Rule.chushogi,
          '12/12/12/12/12/6k5/5K6/12/12/12/12/12 w - 1',
        ).getOrThrow();
    expect(posB.validate(strict: true).isSuccess(), isTrue);
    expect(posW.validate(strict: true).isSuccess(), isTrue);
  });
}
