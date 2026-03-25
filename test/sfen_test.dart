import 'package:dartshogi/src/board.dart';
import 'package:dartshogi/src/core/exceptions.dart';
import 'package:dartshogi/src/core/rule.dart';
import 'package:dartshogi/src/core/side.dart';
import 'package:dartshogi/src/core/square.dart';
import 'package:dartshogi/src/hands.dart';
import 'package:dartshogi/src/sfen.dart';
import 'package:result_dart/result_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final rule in Rule.values) {
    test('rules - parse sfen and back: $rule', () {
      final pos = parseSfen(rule, initialSfen(rule)).getOrThrow();
      expect(makeSfen(pos), equals(initialSfen(rule)));
    });
  }

  test('make board sfen', () {
    expect(makeBoardSfen(Rule.shogi, Board.empty), equals('9/9/9/9/9/9/9/9/9'));
  });

  test('parse initial sfen', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi), strict: true).getOrThrow();
    expect(pos.hands, equals(Hands.empty));
    expect(pos.turn, equals(Side.sente));
    expect(pos.moveNumber, equals(1));
  });

  test('partial sfen', () {
    final partialSfen = initialSfen(Rule.shogi).split(' ')[0];
    final pos = parseSfen(Rule.shogi, partialSfen, strict: true).getOrThrow();
    final remadePartialSfen = makeSfen(pos).split(' ')[0];
    expect(remadePartialSfen, equals(partialSfen));
    expect(pos.hands, equals(Hands.empty));
    expect(pos.turn, equals(Side.sente));
    expect(pos.moveNumber, equals(1));
    expect(
      () => parseSfen(Rule.shogi, 'lnsgkgsnl/9/9/9/9/9/9/9/LNSGKGSNL b - ', strict: true),
      returnsNormally,
    );
  });

  test('invalid sfen', () {
    expect(
      parseSfen(
        Rule.shogi,
        'lnsgkgsnl/1r5b1/ppppppppp/9/9/8P/PPPPPPP1P/1B5R1/LNSGKGSNL b - 1',
        strict: true,
      ),
      const Failure(PositionSetupException(IllegalSetupCause.doublePawns)),
    );
  });

  const validSfens = [
    'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b RG4P2b2s3p 143',
    'lnsgkgsnl/1r5b1/9/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
    'lnsgkgsnl/1r5b1/p+pppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
    '+lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5+R1/+L+N+SGKGSNL b - 1',
    '8l/1l+R2P3/p2pBG1pp/kps1p4/Nn1P2G2/P1P1P2PP/1PS6/1KSG3+r1/LN2+p3L w Sbgn3p 124',
    'lnsgkgsnl/9/9/9/9/9/9/9/LNSGKGSNL b - 10',
    '  lnsgkgsnl/9/9/9/9/9/9/9/LNSGKGSNL b - 10',
    'lnsgkgsnl/9/9/9/9/9/9/9/LNSGKGSNL b - 10  ',
    'lnsgkgsnl/9/9/9/9/9/9/9/LNSGKGSNL b 15p 10',
    'lnsgkgsnl/9/9/9/9/9/9/9/LNSGKGSNL b 10p 10',
    'lnsgkgsnl/9/9/9/9/9/9/9/LNSGKGSNL b 15R10P10p 10',
  ];

  for (final sfen in validSfens) {
    test('parse and make sfen: $sfen', () {
      final pos = parseSfen(Rule.shogi, sfen, strict: true).getOrThrow();
      expect(makeSfen(pos), equals(sfen.trim()));
    });
  }

  test('minishogi sfen', () {
    final pos = parseSfen(Rule.minishogi, 'rbsgk/4p/5/P4/KGSBR b - 1', strict: true).getOrThrow();
    expect(makeBoardSfen(Rule.minishogi, pos.board), equals('rbsgk/4p/5/P4/KGSBR'));
    expect(makeSfen(pos), equals(initialSfen(Rule.minishogi)));
  });

  test('chushogi sfen', () {
    final pos = parseSfen(
      Rule.chushogi,
      'lfcsgekgscfl/a1b1txot1b1a/mvrhdqndhrvm/pppppppppppp/3i4i3/12/12/3I4I3/PPPPPPPPPPPP/MVRHDNQDHRVM/A1B1TOXT1B1A/LFCSGKEGSCFL b 5e 1',
      strict: true,
    ).getOrThrow();
    expect(pos.lastLionCapture, equals(Square.parse('5e')));

    final pos2 = parseSfen(
      Rule.chushogi,
      '+l+f+c+s+g+ek+g+s+c+f+l/+a1+b1+t+x+o+t1+b1+a/+m+v+r+h+dqn+d+h+r+v+m/+p+p+p+p+p+p+p+p+p+p+p+p/3+i4+i3/12/12/3+I4+I3/+P+P+P+P+P+P+P+P+P+P+P+P/+M+V+R+H+DNQ+D+H+R+V+M/+A1+B1+T+O+X+T1+B1+A/+L+F+C+S+GK+E+G+S+C+F+L b - 1',
      strict: true,
    ).getOrThrow();
    expect(
      makeSfen(pos2),
      equals(
        '+l+f+c+s+g+ek+g+s+c+f+l/+a1+b1+t+x+o+t1+b1+a/+m+v+r+h+dqn+d+h+r+v+m/+p+p+p+p+p+p+p+p+p+p+p+p/3+i4+i3/12/12/3+I4+I3/+P+P+P+P+P+P+P+P+P+P+P+P/+M+V+R+H+DNQ+D+H+R+V+M/+A1+B1+T+O+X+T1+B1+A/+L+F+C+S+GK+E+G+S+C+F+L b - 1',
      ),
    );

    expect(
        parseSfen(
          Rule.chushogi,
          '12/12/7k3p/12/7K4/12/12/9+E2/12/3X8/12/12 b',
          strict: true,
        ),
        isA<Success>());
    expect(
        parseSfen(
          Rule.chushogi,
          '12/12/7k3p/12/7K4/12/12/9K2/12/3X3+E4/12/12 b',
          strict: true,
        ),
        const Failure(PositionSetupException(IllegalSetupCause.kings)));
  });

  test('kyotoshogi fairy-stockfish', () {
    expect(
      parseSfen(Rule.kyotoshogi, 'p+nks+l/5/5/5/+LSK+NP b -', strict: true),
      isA<Success>(),
    );
    final pos2Fairy =
        parseSfen(Rule.kyotoshogi, '+L1L2/+S1S1k/5/+N1N1K/+P1P2 b PNLS', strict: true).getOrThrow();
    final pos2Lishogi =
        parseSfen(Rule.kyotoshogi, 'T1L2/B1S1k/5/G1N1K/R1P2 b TGSP 1', strict: true).getOrThrow();
    expect(makeSfen(pos2Fairy), equals(makeSfen(pos2Lishogi)));
  });

  test('dobutsu fairy-stockfish', () {
    final posFairy = parseSfen(Rule.dobutsu, 'gle/1c1/1C+C/ELG b CEG 1', strict: true).getOrThrow();
    final posLishogi =
        parseSfen(Rule.dobutsu, 'rkb/1p1/1P+P/BKR b RBP 1', strict: true).getOrThrow();
    expect(makeSfen(posFairy), equals(makeSfen(posLishogi)));
  });
}
