import 'package:dartshogi/dartshogi.dart';
import 'package:test/test.dart';

import '../fixtures/kyotoshogi.dart';

const _kyotoshogiPerfts = [
  ('', 1, 12),
  ('', 2, 137),
  ('', 3, 1636),
  ('', 4, 18268),
  // ('', 5, 225903),
  ('1S3/L2k1/5/1Kl2/2n2 w Psgp 58', 1, 120),
  ('5/2k1l/5/5/pBK2 w Ggtsp 28', 1, 170),
  ('kl3/1n3/G4/5/TSK1P b P', 1, 47),
];

void main() {
  for (final (sfen, depth, res) in _kyotoshogiPerfts) {
    test('kyotoshogi perft: $sfen ($depth): $res', () {
      final pos =
          parseSfen(
            Rule.kyotoshogi,
            sfen.isEmpty ? initialSfen(Rule.kyotoshogi) : sfen,
          ).getOrThrow();
      expect(perft(pos, depth), equals(res));
    });
  }

  test('kyotoshogi checkmate', () {
    final pos =
        parseSfen(Rule.kyotoshogi, 'r1k1N/T1L2/2NBK/5/1S3 w P').getOrThrow();
    expect(
      pos.outcome(),
      equals(const Outcome(result: GameResult.checkmate, winner: Side.sente)),
    );
  });

  test('pawn checkmate', () {
    final pos =
        parseSfen(Rule.kyotoshogi, 'kl3/1n3/G4/5/TSK1P b P').getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('P*5b')!), isTrue);
    expect(
      pos.play(MoveOrDrop.parse('P*5b')!).getOrThrow().outcome()?.result,
      equals(GameResult.checkmate),
    );
  });

  test('last rank', () {
    final pos =
        parseSfen(Rule.kyotoshogi, 'pgkst/R3P/5/5/TSKG1 b P').getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('1b1a+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('5b5a+')!), isTrue);
  });

  test('pieces in dead zone', () {
    final posRes = parseSfen(
      Rule.kyotoshogi,
      'PgksL/5/5/5/pSKGl b',
      strict: false,
    );
    expect(posRes.isSuccess(), isTrue);
    expect(posRes.getOrThrow().validate(strict: true).isSuccess(), isTrue);
  });

  test('promotion in usi', () {
    final pos =
        parseSfen(Rule.kyotoshogi, initialSfen(Rule.kyotoshogi)).getOrThrow();
    // king
    expect(pos.isLegal(MoveOrDrop.parse('3e3d+')!), isFalse);
    expect(pos.isLegal(MoveOrDrop.parse('3e3d')!), isTrue);
    // gold
    expect(pos.isLegal(MoveOrDrop.parse('2e3d+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('2e3d')!), isFalse);
  });

  test('drops', () {
    final pos = parseSfen(Rule.kyotoshogi, '5/5/5/5/k3K b PTGS').getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('T*3a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('S*3a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('G*3a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('P*3a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('L*3a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('B*3a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('N*3a')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('R*3a')!), isTrue);
  });

  test('randomly generated perfts - for consistency', () {
    for (final (sfen, depth, res) in perfts) {
      final pos =
          parseSfen(
            Rule.kyotoshogi,
            sfen.isEmpty ? initialSfen(Rule.kyotoshogi) : sfen,
          ).getOrThrow();
      expect(perft(pos, depth), equals(res));
    }
  });
}
