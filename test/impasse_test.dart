import 'package:dartshogi/dartshogi.dart';
import 'package:dartshogi/src/impasse.dart';
import 'package:test/test.dart';

void main() {
  group('IsImpasse', () {
    group('Standard', () {
      group('Not be enough', () {
        test('starting position', () {
          final result = parseSfen(
            Rule.shogi,
            'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
          //
        });
        test('position with less than 10 other pieces in promotion zone', () {
          final result = parseSfen(
            Rule.shogi,
            '2SGS4/+B+RGKG2RB/9/9/7pp/8k/9/9/9 b g2s4n4l16p 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });
        test('position without the king in promotion zone', () {
          final result = parseSfen(
            Rule.shogi,
            '2SGS4/+B+RG1G2RB/3G5/9/7pp/8k/9/9/4K4 b - 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });
        test('position without enough value', () {
          final result = parseSfen(
            Rule.shogi,
            '9/1G2K2G1/PPPPPPPPP/9/9/7ss/7sk/9/9 w 2r2b2gs4n4l9p 2',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });
        test('one move away', () {
          final result = parseSfen(
            Rule.shogi,
            '2SGS4/+B1GKGLLRB/3G5/9/1+R5pp/8k/9/9/9 b - 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            final move1 = MoveOrDrop.parse('8e8b')!;
            final resultAfterMove1 = position.play(move1);
            final positionAfterMove1 = resultAfterMove1.getOrThrow();
            expect(isImpasse(positionAfterMove1), false);
            expect(positionAfterMove1.outcome(), null);
          }
        });
        test('opponent prevents impasse', () {
          final result = parseSfen(
            Rule.shogi,
            '2SGS4/+B1GKGLLRB/3G5/9/1+R5pp/8k/6b2/9/9 b - 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            final move1 = MoveOrDrop.parse('8e8b')!;
            final move2 = MoveOrDrop.parse('3g2f')!;
            final resultAfterMove1 = position.play(move1);
            final resultAfterMove2 = resultAfterMove1.getOrThrow().play(move2);

            final positionAfterMove2 = resultAfterMove2.getOrThrow();
            expect(isImpasse(positionAfterMove2), false);
            expect(positionAfterMove2.outcome(), null);
          }
        });
        test('26 points for gote', () {
          final result = parseSfen(
            Rule.shogi,
            '9/9/9/9/9/9/3r1lllg/+P+P1+bkssgg/K+P4ssg w r 2',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });
        test('21 points for gote (uwate) plus 1 piece handicap', () {
          final result = parseSfen(
            Rule.shogi,
            '9/9/9/9/9/9/3p1lllg/+P+P2kssgr/K+P4ssg w r 2',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow().copyWith(
              history: result.getOrThrow().history.copyWith(
                initialSfen:
                    'lnsgkgsnl/7b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
              ),
            );
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });
        test(
          '17 points for gote (uwate) and pieces in opponent hand - not missing',
          () {
            final result = parseSfen(
              Rule.shogi,
              '9/9/9/9/9/9/3p1lllg/+P+P2kssgg/K+P4ssg w r 2',
            );
            if (result.isSuccess()) {
              final position = result.getOrThrow().copyWith(
                history: result.getOrThrow().history.copyWith(
                  initialSfen:
                      'lnsgkgsnl/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RB 1',
                ),
              );
              expect(isImpasse(position), false);
              expect(position.outcome(), null);
            }
          },
        );
        test('27 points for sente', () {
          final result = parseSfen(
            Rule.shogi,
            'G3+R3S/GG5SS/GLPBKBPLS/9/9/7+p+p/7+pk/7+p+p/9 b - 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });
      });
      group('Be enough', () {
        test('all pieces on the board', () {
          final result = parseSfen(
            Rule.shogi,
            '2SGS4/+B+RGKGLLRB/3G5/9/7pp/8k/9/9/9 b - 1',
          );
          if (result.isSuccess()) {
            final pos = result.getOrThrow();
            expect(isImpasse(pos), true);
            expect(pos.outcome()!.winner, Side.sente);
          }
        });

        test('some from hand', () {
          final result = parseSfen(
            Rule.shogi,
            'G8/4K4/PPPPPPPPP/9/9/7ss/7sk/9/9 b 2R2B 1',
          );
          if (result.isSuccess()) {
            final pos = result.getOrThrow();
            expect(isImpasse(pos), true);
            expect(pos.outcome()!.winner, Side.sente);
          }
        });
        test('after moves', () {
          final result = parseSfen(
            Rule.shogi,
            '2SGS4/+B1GKGLLRB/3G5/9/1+R5pp/8k/9/9/9 b - 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            final move1 = MoveOrDrop.parse('8e8b')!;
            final move2 = MoveOrDrop.parse('2e2f')!;
            final resultAfterMove1 = position.play(move1);
            final resultAfterMove2 = resultAfterMove1.getOrThrow().play(move2);
            final posAfterMove2 = resultAfterMove2.getOrThrow();
            expect(isImpasse(posAfterMove2), true);
            expect(posAfterMove2.outcome()!.winner, Side.sente);
          }
        });

        test('27 points for gote', () {
          final result = parseSfen(
            Rule.shogi,
            '9/9/9/9/9/9/3r1llll/+P+P1+bkssgg/K+P3ssgg w r 2',
          );
          if (result.isSuccess()) {
            final pos = result.getOrThrow();
            expect(isImpasse(pos), true);
            expect(pos.outcome()!.winner, Side.gote);
          }
        });

        test('17 points for gote (uwate), but 2 piece handicap', () {
          final result = parseSfen(
            Rule.shogi,
            '9/9/9/9/9/9/3p1lllg/+P+P2kssgg/K+P4ssg w r 2',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow().copyWith(
              history: result.getOrThrow().history.copyWith(
                initialSfen:
                    'lnsgkgsnl/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
              ),
            );
            expect(isImpasse(position), true);
            expect(position.outcome()!.winner, Side.gote);
          }
        });

        test('28 points for sente', () {
          final result = parseSfen(
            Rule.shogi,
            'G3+R3S/GG2P2SS/GLPBKBPLS/9/9/7+p+p/7+pk/7+p+p/9 b - 1',
          );
          if (result.isSuccess()) {
            final pos = result.getOrThrow();
            expect(isImpasse(pos), true);
            expect(pos.outcome()!.winner, Side.sente);
          }
        });
      });
    });
    group('Annanshogi', () {
      group('Yes', () {
        test('starting position', () {
          final result = parseSfen(
            Rule.annanshogi,
            '2SGS4/+B+RGKGLLRB/3G5/9/7pp/8k/9/9/9 b - 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), true);
            expect(position.outcome()!.winner, Side.sente);
          }
        });
        test('some from hand', () {
          final result = parseSfen(
            Rule.annanshogi,
            'G8/4K4/PPPPPPPPP/9/9/7ss/7sk/9/9 b 2R2B 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), true);
            expect(position.outcome()!.winner, Side.sente);
          }
        });

        test('17 points for gote (uwate), but annanshogi handicap', () {
          final result = parseSfen(
            Rule.annanshogi,
            '9/9/9/9/9/9/3p1lllg/+P+P2kssgg/K+P4ssg w r 2',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow().copyWith(
              history: result.getOrThrow().history.copyWith(
                initialSfen:
                    'lnsgkgsnl/9/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
              ),
            );
            expect(isImpasse(position), true);
            expect(position.outcome()!.winner, Side.gote);
          }
        });
      });
      group('No', () {
        test('position with less than 10 other pieces in promotion zone', () {
          final result = parseSfen(
            Rule.annanshogi,
            '2SGS4/+B+RGKG2RB/9/9/7pp/8k/9/9/9 b g2s4n4l16p 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });

        test('position without the king in promotion zone', () {
          final result = parseSfen(
            Rule.annanshogi,
            '2SGS4/+B+RG1G2RB/3G5/9/7pp/8k/9/9/4K4 b - 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });

        test('position without enough value', () {
          final result = parseSfen(
            Rule.annanshogi,
            '9/1G2K2G1/PPPPPPPPP/9/9/7ss/7sk/9/9 w 2r2b2gs4n4l9p 2',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });

        test('17 points for gote (uwate), but standard handicap', () {
          final result = parseSfen(
            Rule.annanshogi,
            '9/9/9/9/9/9/3p1lllg/+P+P2kssgg/K+P4ssg w r 2',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow().copyWith(
              history: result.getOrThrow().history.copyWith(
                initialSfen:
                    'lnsgkgsnl/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
              ),
            );
            expect(isImpasse(position), false);
            expect(position.outcome(), null);
          }
        });
      });
    });
    group('Checkshogi', () {
      group('Yes', () {
        test('all pieces on the board', () {
          final result = parseSfen(
            Rule.checkshogi,
            '2SGS4/+B+RGKGLLRB/3G5/9/7pp/8k/9/9/9 b - 1',
          );
          if (result.isSuccess()) {
            final position = result.getOrThrow();
            expect(isImpasse(position), true);
            expect(position.outcome()!.winner, Side.sente);
          }
        });
      });
    });
  });
}
