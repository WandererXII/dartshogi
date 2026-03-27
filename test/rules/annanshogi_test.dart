import 'package:dartshogi/dartshogi.dart';
import 'package:test/test.dart';

import '../fixtures/annanshogi.dart';

void main() {
  final annanPerfts = <(String, int, int)>[
    ('', 1, 28),
    ('', 2, 784),
    (
      '4k3S/r1l1gs3/n+N1s5/L+P4G1+B/1Pp1p1Rb1/4PNpN1/3+pPGPP1/6G1P/1p1K2S1+l w - 1',
      1,
      35,
    ),
    (
      'P1G+N3s1/lp7/2+N+Pp+P1+L+P/1sB1kP3/N1pl1s3/g6p1/+p1B2+p+p+l+p/1+s+r+n4R/1g1pK1+p2 b G3P 167',
      1,
      2,
    ),
    (
      '1n2g1g2/l2k1p3/p1p1psb1l/r4Ppp1/1p6p/P2p1PPpP/L3+n1S1L/1BKN2GS1/r1G4N1 b 2Psp 83',
      1,
      7,
    ),
    (
      'Pn2g4/+S2ps3l/4p1p1+P/sPpg1Pk2/lS1rr2pp/p2GnnPP1/LB+p4+nL/2B2K2+p/1p1GP2+p1 b - 129',
      1,
      46,
    ),
    ('9/1k7/9/4b4/4p4/5N3/6K2/9/9 b - 1', 1, 6),
  ];

  test('annanshogi perft', () {
    for (final (sfen, depth, res) in annanPerfts) {
      final pos =
          parseSfen(
            Rule.annanshogi,
            sfen.isEmpty ? initialSfen(Rule.annanshogi) : sfen,
          ).getOrThrow();
      expect(perft(pos, depth), equals(res));
    }
  });

  test('pieces in dead zone', () {
    final posRes = parseSfen(
      Rule.annanshogi,
      'lPsgkgLnP/1r5b1/p1ppp1p1p/1p5pp/9/1P3P1P1/P1PP1P2P/1B5n1/lNSGKGpNL b',
    );
    expect(posRes.isSuccess(), isTrue);
  });

  test('only friendly pieces give you moves', () {
    final pos =
        parseSfen(Rule.annanshogi, '9/9/9/4P4/4r4/9/9/9/K7k b').getOrThrow();
    expect(pos.moveDests(Square.parse('5d')!).size, equals(1));

    final pos2 =
        parseSfen(
          Rule.annanshogi,
          '4k3S/r1l1gs3/n+N1s5/L+P4G1+B/1Pp1p1Rb1/4PNpN1/3+pPGPP1/6G1P/1p1K2S1+l w',
        ).getOrThrow();
    expect(perft(pos2, 1), equals(35));
  });

  test('do not allow capturing move givers that prevent check', () {
    final pos =
        parseSfen(
          Rule.annanshogi,
          '2k5N/3p2+P1G/1+P+P1s2+P+L/1pg1bS3/6Bp1/6G1P/1K1SL+pP2/+ln+pRG1+p1+p/1+lP1+p2R1 b SN2Pnp 205',
        ).getOrThrow();
    expect(
      pos.moveDests(Square.parse('4d')!).has(Square.parse('5c')!),
      isFalse,
    );
  });

  test('checkmate', () {
    final pos =
        parseSfen(
          Rule.annanshogi,
          '4k4/4+R4/9/4L4/9/+B8/9/7GS/7GK w - 1',
        ).getOrThrow();
    final pos2 =
        parseSfen(
          Rule.annanshogi,
          '4k4/9/9/4P4/4L4/4N4/4GP3/3P1L3/3L1S3 w - 1',
        ).getOrThrow();

    expect(
      pos.outcome(),
      equals(const Outcome(result: GameResult.checkmate, winner: Side.sente)),
    );
    expect(
      pos2.outcome(),
      equals(const Outcome(result: GameResult.checkmate, winner: Side.sente)),
    );
  });

  test('drop', () {
    final pos =
        parseSfen(
          Rule.annanshogi,
          '5k3/9/9/9/5P3/5L3/9/9/5K3 w p 1',
        ).getOrThrow();
    expect(
      pos
          .dropDests(const Piece(role: Role.pawn, side: Side.gote))
          .has(Square.parse('4c')!),
      isTrue,
    );
    expect(pos.isLegal(MoveOrDrop.parse('P*4c')!), isTrue);

    final pos2 =
        parseSfen(Rule.annanshogi, '4k4/9/4G4/9/9/9/9/9/9 b P 1').getOrThrow();
    expect(
      pos2
          .dropDests(const Piece(role: Role.pawn, side: Side.sente))
          .has(Square.parse('5b')!),
      isFalse,
    );
    expect(pos2.isLegal(MoveOrDrop.parse('P*5b')!), isFalse);

    final pos3 =
        parseSfen(
          Rule.annanshogi,
          '9/9/9/k8/g8/G8/K8/9/9 b NLP 1',
        ).getOrThrow();
    expect(
      pos3
          .dropDests(const Piece(role: Role.pawn, side: Side.sente))
          .intersect(SquareSet.fromRank(0))
          .equals(
            SquareSet.fromRank(0).intersect(fullSquareSet(Rule.annanshogi)),
          ),
      isTrue,
    );
    expect(
      pos3
          .dropDests(const Piece(role: Role.lance, side: Side.sente))
          .intersect(SquareSet.fromRank(0))
          .equals(
            SquareSet.fromRank(0).intersect(fullSquareSet(Rule.annanshogi)),
          ),
      isTrue,
    );
    expect(
      pos3
          .dropDests(const Piece(role: Role.knight, side: Side.sente))
          .intersect(SquareSet.fromRank(0))
          .equals(
            SquareSet.fromRank(0).intersect(fullSquareSet(Rule.annanshogi)),
          ),
      isTrue,
    );
    expect(
      pos3
          .dropDests(const Piece(role: Role.knight, side: Side.sente))
          .intersect(SquareSet.fromRank(1))
          .equals(
            SquareSet.fromRank(1).intersect(fullSquareSet(Rule.annanshogi)),
          ),
      isTrue,
    );
    expect(pos3.isLegal(MoveOrDrop.parse('P*5a')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('L*5a')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('N*5a')!), isTrue);
    expect(pos3.isLegal(MoveOrDrop.parse('N*5b')!), isTrue);

    final pos4 =
        parseSfen(
          Rule.annanshogi,
          '9/9/9/9/9/k8/n1PPPPPP1/N2G2B2/K8 b 3P 1',
        ).getOrThrow();
    expect(
      pos4
          .dropDests(const Piece(role: Role.pawn, side: Side.sente))
          .has(Square.parse('8e')!),
      isTrue,
    );
    expect(
      pos4
          .dropDests(const Piece(role: Role.pawn, side: Side.sente))
          .has(Square.parse('5e')!),
      isFalse,
    );
    expect(
      pos4.dropDests(const Piece(role: Role.pawn, side: Side.sente)).size,
      equals(23),
    );
    expect(pos4.isLegal(MoveOrDrop.parse('P*5a')!), isFalse);
    expect(pos4.isLegal(MoveOrDrop.parse('P*1a')!), isTrue);
    expect(pos4.moveDests(Square.parse('6g')!).size, equals(3));
    expect(pos4.isLegal(MoveOrDrop.parse('6g5f')!), isTrue);
  });

  test('promotions', () {
    final pos =
        parseSfen(
          Rule.annanshogi,
          '9/3PL4/2P5N/k6N1/g8/G8/K8/9/5L3 b - 1',
        ).getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('6b6a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('6b6a+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('5b5a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('5b5a+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('2d3b')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('2d3b+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('1c2a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('1c2a+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('4i4a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('4i4a+')!), isTrue);
  });

  test('capture attacker move giver', () {
    final pos =
        parseSfen(
          Rule.annanshogi,
          '5k3/9/9/7b1/5P3/5L3/9/9/5K3 w - 1',
        ).getOrThrow();
    expect(pos.moveDests(Square.parse('2d')!).has(Square.parse('4f')!), isTrue);

    final posS =
        parseSfen(
          Rule.annanshogi,
          '5k3/9/9/5l3/5p3/9/2B6/9/5K3 b - 1',
        ).getOrThrow();
    expect(posS.isLegal(MoveOrDrop.parse('7g4d')!), isTrue);
    expect(perft(posS, 1), equals(5));

    // 2 checkers
    final pos2 =
        parseSfen(
          Rule.annanshogi,
          'P1G+N3s1/lp7/2+N+Pp+P1+L+P/1sB1kP3/N1pl1s3/g6p1/+p1B2+p+p+l+p/1+s+r+n4R/1g1pK1+p2 b G3P 167',
        ).getOrThrow();
    expect(perft(pos2, 1), equals(2));
    expect(pos2.isLegal(MoveOrDrop.parse('1h6h')!), isTrue);
    expect(pos2.isLegal(MoveOrDrop.parse('7g6h')!), isTrue);

    final pos3 =
        parseSfen(
          Rule.annanshogi,
          '8k/9/3l5/9/9/9/9/2G+n2+p2/3pK4 b - 1',
        ).getOrThrow();
    expect(perft(pos3, 1), equals(1));

    final pos4 =
        parseSfen(
          Rule.annanshogi,
          '8k/9/3ll4/9/9/9/4+R4/2G+p2+p2/3pK4 b',
        ).getOrThrow();
    expect(perft(pos4, 1), equals(1));

    final pos5 =
        parseSfen(
          Rule.annanshogi,
          '9/9/2B3B2/9/4k4/9/2B3B2/9/8K w',
        ).getOrThrow();
    expect(pos5.isLegal(MoveOrDrop.parse('5e5d')!), isTrue);
    expect(pos5.isLegal(MoveOrDrop.parse('5e5f')!), isTrue);
    expect(pos5.isLegal(MoveOrDrop.parse('5e4e')!), isTrue);
    expect(pos5.isLegal(MoveOrDrop.parse('5e6e')!), isTrue);
  });

  test('capture attacker move giver - with king', () {
    final pos =
        parseSfen(
          Rule.annanshogi,
          '9/7Pk/7+R1/9/9/9/9/9/8K w - 1',
        ).getOrThrow();
    expect(pos.moveDests(Square.parse('1b')!).has(Square.parse('2c')!), isTrue);

    final pos2 =
        parseSfen(Rule.annanshogi, '9/8k/9/9/9/9/9/p+r7/K8 b - 1').getOrThrow();
    expect(
      pos2.moveDests(Square.parse('9i')!).has(Square.parse('8h')!),
      isTrue,
    );
  });

  test('do not allow discovering check by capturing move giver', () {
    final pos =
        parseSfen(Rule.annanshogi, '3k5/9/9/3p5/3bG4/9/9/6K2/9 b').getOrThrow();
    expect(
      pos.moveDests(Square.parse('5e')!).has(Square.parse('6d')!),
      isFalse,
    );
    expect(perft(pos, 1), equals(13));

    final pos2 =
        parseSfen(
          Rule.annanshogi,
          '6k2/p8/9/3Bs4/3R5/9/9/6K2/9 w',
        ).getOrThrow();
    expect(
      pos2.moveDests(Square.parse('5d')!).has(Square.parse('6e')!),
      isFalse,
    );
    expect(perft(pos2, 1), equals(10));
  });

  test('allow moving/capturing square behind attacker with king', () {
    final pos =
        parseSfen(
          Rule.annanshogi,
          '5K3/9/9/9/3B5/4k4/9/9/9 w - 1',
        ).getOrThrow();
    expect(pos.moveDests(Square.parse('5f')!).has(Square.parse('6f')!), isTrue);
    expect(perft(pos, 1), equals(7));

    final pos2 =
        parseSfen(
          Rule.annanshogi,
          '5K3/9/9/9/3B5/3Bk4/9/9/9 w - 1',
        ).getOrThrow();
    expect(
      pos2.moveDests(Square.parse('5f')!).has(Square.parse('6f')!),
      isTrue,
    );
  });

  test('proper parse', () {
    final pos1 = parseSfen(
      Rule.annanshogi,
      '9/4kP3/5+R3/2B6/9/9/9/9/8K w - 1',
      strict: true,
    );
    expect(pos1.isSuccess(), isTrue);

    final pos2 = parseSfen(
      Rule.annanshogi,
      '3P1PNL1/7N1/5P3/9/4p4/6k2/9/3K5/6nsl b',
      strict: true,
    );
    pos2.getOrThrow();
    expect(pos2.isSuccess(), isTrue);
  });

  test('randomly generated perfts - for consistency', () {
    for (final (sfen, depth, res) in perfts) {
      final pos =
          parseSfen(
            Rule.annanshogi,
            sfen.isEmpty ? initialSfen(Rule.annanshogi) : sfen,
          ).getOrThrow();
      expect(pos.isEnd(), isFalse);
      expect(perft(pos, depth), equals(res));
    }
  });
}
