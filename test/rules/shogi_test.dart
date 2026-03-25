import 'package:dartshogi/src/core/game_result.dart';
import 'package:dartshogi/src/core/move_drop.dart';
import 'package:dartshogi/src/core/rule.dart';
import 'package:dartshogi/src/core/square.dart';
import 'package:dartshogi/src/debug.dart';
import 'package:dartshogi/src/position/position.dart';
import 'package:dartshogi/src/sfen.dart';
import 'package:test/test.dart';

import '../fixtures/shogi.dart';
import '../fixtures/usi.dart';

// http://www.talkchess.com/forum3/viewtopic.php?f=7&t=71550&start=16
// http://www.talkchess.com/forum3/viewtopic.php?f=7&t=71550
const _random = [
  (
    'gentest-1',
    'l2kg2+R1/4n3+L/p1gpps3/4np3/6P1N/PP+rP2pS1/1pG2P3/4P1G2/LN3KB1+p b SPbslpppp',
    107,
    20080,
  ),
  (
    'gentest-2',
    'l+Rl2+R3/3k1s2+L/p1p1p4/2Ppnp1S1/4n1Pbp/PP2G4/1G3P+n2/Kp2P4/L8 w GSPPPPbgsnp',
    240,
    39392,
  ),
  (
    'gentest-3',
    'l+Rl2g2+R/3k1s2+L/p1p1p4/2Ppnp1S1/4n1Pbp/PP2G4/1G3P+n2/Kp2P4/L8 b SPPPPbgsnp',
    110,
    24582,
  ),
  (
    'gentest-4',
    'l2kgb1+R1/4n3+L/p1gpps3/4np3/6P1N/PPGP2pS1/1p3P3/4P1G2/LN3KB1+p b RSPslpppp',
    158,
    21443,
  ),
  (
    'gentest-5',
    'l8/1r1gk3+L/p1Npp2S1/2Psnpg2/5+r2N/PP1P2pS1/1pG1BP3/4P1G2/LN3KB1+p b SPPlppp',
    109,
    10902,
  ),
  (
    'gentest-6',
    'lr6l/3g1kg2/p2pp2s+P/2Ps1ppp1/8L/P1nP2PR1/1P3PS2/1SGK5/LN3G3 b BNNPPPbpp',
    7,
    755,
  ),
  (
    'gentest-7',
    'lr7/3g1kg2/p2pp2s+L/2Ps1ppp1/9/PP1P1BPS1/5P1PS/1G6+r/LN3KB2 b GNNLPPPnpp',
    184,
    18331,
  ),
  (
    'gentest-8',
    'l+Rl2g2+R/2p+Sks2+L/p3p4/2Ppnp1S1/4n1Pbp/PP2G4/1G3P+n2/Kp2P4/L8 w GSPPPPbnp',
    2,
    326,
  ),
  (
    'gentest-9',
    'l2s5/3kn2R+L/p1gpp+B3/4np3/2+r3P1N/PP1P2pS1/1pG2P3/4P1G2/LN3KB1+p b GLPsspppp',
    165,
    16018,
  ),
  (
    'gentest-11',
    'lr7/3g1kg2/p2pp2s+L/2Psnp1p1/5+rS2/PP1P5/4BPS2/1G2P1G2/LN3KB1L w NNPPPpppp',
    72,
    6928,
  ),
  (
    'gentest-12',
    'lr7/3g1kg2/p2pp2s+L/2Ps1ppp1/9/P2P1BPS1/1P3P3/1G3B3/LN2KG1r1 w NNNLPPPsppp',
    123,
    16661,
  ),
  (
    'gentest-13',
    'l+Rl2+R3/3k1s2+L/p1p1p4/2Ppnp1S1/4n1Pbp/PP2G4/KG3P+n2/1p2P4/Ls7 w GSPPPPbgnp',
    188,
    30364,
  ),
  (
    'gentest-14',
    'lr6l/3g1kg2/p2pp2s+P/2Ps1ppp1/7nL/P2P2PR1/1P3PN2/1SGK2S2/LN3G3 w BNPPPbpp',
    109,
    14585,
  ),
  (
    'gentest-15',
    'l1S6/r3k3+L/p1gppl3/4np+B2/2+r3P1N/PP1P2pS1/1pG2P3/4P1G2/LN3KB1+p b GSPsnpppp',
    163,
    21883,
  ),
  (
    'gentest-16',
    'lr7/3g1kg2/p2pp2sl/2Ps1ppp1/8L/P2P2PR1/1P3PS2/1G7/LN2KG3 b BNNNPPPbsppp',
    145,
    23120,
  ),
  (
    'gentest-17',
    'l8/1r1g1k3/p1Npp1gs+L/2Psnp1p1/5+rS2/PP1P2pS1/1pG1BP3/4P1G1p/LN3KB1L b NPPpp',
    84,
    4399,
  ),
  (
    'gentest-18',
    'lr7/3g1kg2/p2pp2s+L/2Ps1p1p1/5+rp2/PP1P1B1S1/5PP1S/1G2P1G2/LN3KB1L b NNPnpppp',
    86,
    8763,
  ),
  (
    'gentest-18b',
    'l2kgs1+R1/4n+B2+L/p1gpp4/4np3/6P1N/PP+rP2pS1/1pG2P3/4P1G2/LN3KB1+p w SSPlpppp',
    95,
    10625,
  ),
  (
    'gentest-19',
    'l8/1r1gk3+L/p1Npp4/2Psnp+r2/8N/PP1P2pS1/1pG1BP3/4P1G2/LN3KB1+p b GSPPslppp',
    156,
    22669,
  ),
  (
    'gentest-20',
    'lr7/3g1kg2/p2pp2s+L/2Ps1ppp1/9/PP1P1BPS1/5P1P1/1G3B1g1/LN3KN1+r b SNNLPPPpp',
    181,
    12037,
  ),
  ('gentest-21', '7lk/9/8S/9/9/9/9/7L1/8K b P', 85, 639),
];

void main() {
  test('test promotions', () {
    final initial = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    final pos = parseSfen(Rule.shogi, '4k4/9/7S1/1+PG3NS1/9/9/9/9/4K3L b - 1').getOrThrow();

    expect(initial.isLegal(const NormalMove(from: Square(20), to: Square(29), promotion: true)),
        isFalse); // promoting outside promotion zone
    expect(pos.isLegal(MoveOrDrop.parse('8d8c+')!), isFalse); // promoting tokin
    expect(pos.isLegal(MoveOrDrop.parse('7d7c+')!), isFalse); // promoting gold
    expect(pos.isLegal(MoveOrDrop.parse('1i1a')!), isFalse); // not promoting lance on last rank
    expect(pos.isLegal(MoveOrDrop.parse('1i1a+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('3d2b')!),
        isFalse); // not promoting knight on second last rank
    expect(pos.isLegal(MoveOrDrop.parse('3d2b+')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('2c1d+')!),
        isTrue); // promoting while leaving the promotion zone
    expect(pos.isLegal(MoveOrDrop.parse('2c1d')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('2d1c+')!),
        isTrue); // promoting while entering the promotion zone
    expect(pos.isLegal(MoveOrDrop.parse('2d1c')!), isTrue);
  });

  // http://www.talkchess.com/forum3/viewtopic.php?t=60445
  test('starting perft', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    expect(perft(pos, 0), equals(1));
    expect(perft(pos, 1), equals(30));
    expect(perft(pos, 2), equals(900));
    expect(perft(pos, 3), equals(25470));
    // expect(perft(pos, 4), equals(719731));
    // expect(perft(pos, 5), equals(19861490));
  });

  test('blockers perft', () {
    final posLance = parseSfen(Rule.shogi, '4k4/4g4/9/4L4/9/9/9/4K4/9 w - 1').getOrThrow();
    final posRook = parseSfen(Rule.shogi, '4k4/4g4/9/4R4/9/9/9/4K4/9 w - 1').getOrThrow();
    expect(perft(posLance, 1), equals(5));
    expect(perft(posRook, 1), equals(5));
  });

  test('capturing', () {
    final pos = parseSfen(Rule.shogi, '4k4/9/3g5/3K5/9/9/9/9/9 b - 1').getOrThrow();
    final pos2 = pos.play(MoveOrDrop.parse('6d6c')!).getOrThrow();
    final pos3 = pos2.play(MoveOrDrop.parse('5a4a')!).getOrThrow();
    expect(pos3.isLegal(MoveOrDrop.parse('G*5e')!), isTrue);
  });

  test('promotion', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    expect(makeSfen(pos.play(MoveOrDrop.parse('1i1h')!).getOrThrow()),
        equals('lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5RL/LNSGKGSN1 w - 2'));

    final pos2 = parseSfen(
      Rule.shogi,
      'lnsgkgsn1/1r5b1/pppppp1p1/6p2/8L/9/PPPPPPPP1/1B5R1/LNSGKGSN1 b LPp 9',
    ).getOrThrow();
    expect(
      makeSfen(pos2.playUnchecked(MoveOrDrop.parse('1e1a')!)),
      equals('lnsgkgsn+L/1r5b1/pppppp1p1/6p2/9/9/PPPPPPPP1/1B5R1/LNSGKGSN1 w LPp 10'),
    );
    expect(
      makeSfen(pos2.play(MoveOrDrop.parse('1e1a+')!).getOrThrow()),
      equals('lnsgkgsn+L/1r5b1/pppppp1p1/6p2/9/9/PPPPPPPP1/1B5R1/LNSGKGSN1 w LPp 10'),
    );
  });

  for (final (name, sfen, d1, d2) in _random) {
    test('random perft: $name: $sfen', () {
      final pos = parseSfen(Rule.shogi, sfen).getOrThrow();
      expect(perft(pos, 1), equals(d1));
      expect(perft(pos, 2), equals(d2));
    });
  }

  test('pawn checkmate legality', () {
    final pos = parseSfen(Rule.shogi, '3rkr3/9/8p/4N4/1B7/9/1SG6/1KS6/9 b LPp 1').getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('L*5b')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('P*5b')!), isFalse);

    // Single king
    final skPos = parseSfen(Rule.shogi, '3rkr3/9/8p/4N4/1B7/9/1SG6/2S6/9 b LPp 1').getOrThrow();
    expect(skPos.isLegal(MoveOrDrop.parse('L*5b')!), isTrue);
    expect(skPos.isLegal(MoveOrDrop.parse('P*5b')!), isFalse);
  });

  test('multiple checkers', () {
    final pos = parseSfen(Rule.shogi, '9/9/2B3B2/9/4k4/9/2B3B2/9/8K w').getOrThrow();
    expect(pos.isLegal(MoveOrDrop.parse('5e5d')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('5e5f')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('5e4e')!), isTrue);
    expect(pos.isLegal(MoveOrDrop.parse('5e6e')!), isTrue);
  });

  const insufficientMaterial = [
    ('lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1', false),
    ('9/4k4/9/9/9/9/9/4K4/9 b - 1', true),
    ('9/4k4/9/9/9/9/2G6/4K4/9 b - 1', false),
  ];

  for (final (sfen, insufficient) in insufficientMaterial) {
    test('insufficient material: $sfen', () {
      final pos = parseSfen(Rule.shogi, sfen).getOrThrow();
      expect(pos.outcome()?.result == GameResult.draw, equals(insufficient));
    });
  }

  test('prod 500 usi', () {
    for (final usis in usiFixture) {
      Position pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
      for (final usi in usis.split(' ')) {
        final md = MoveOrDrop.parse(usi)!;
        expect(pos.isLegal(md), isTrue);
        pos = pos.playUnchecked(md);
      }
    }
  });

  test('randomly generated perfts - for consistency', () {
    for (final (sfen, depth, res) in perfts) {
      final pos = parseSfen(Rule.shogi, sfen).getOrThrow();
      expect(perft(pos, depth), equals(res));
    }
  });
}
