import 'package:dartshogi/dartshogi.dart';
import 'package:test/test.dart';

void main() {
  String toPosition(int a) => 'sfen_$a';

  History makeHistory(List<int> positions) {
    var history = History.empty;

    for (final p in positions) {
      history = history.addPosition(toPosition(p));
    }

    return history;
  }

  group('fourfold repetition', () {
    test('empty history', () {
      expect(History.empty.fourfoldRepetition, isFalse);
    });

    test('addLastLionCapture nullable', () {
      const original = History.empty;

      final withValue = original.copyWith(lastLionCapture: const Square(0));
      expect(withValue.lastLionCapture, equals(const Square(0)));

      final cleared = withValue.copyWith(lastLionCapture: null);
      expect(cleared.lastLionCapture, isNull);
    });

    test('not 4 same elements', () {
      final history = makeHistory([1, 2, 3, 4, 5, 2, 5, 6, 16, 2, 23, 55]);

      expect(history.fourfoldRepetition, isFalse);
    });

    test('not 4 elements same to the last one', () {
      final history = makeHistory([1, 2, 3, 4, 5, 2, 5, 6, 23, 2, 55, 2, 33]);

      expect(history.fourfoldRepetition, isFalse);
    });

    test('positive', () {
      final history = makeHistory([1, 2, 3, 4, 5, 6, 7, 2, 5, 6, 3, 2, 6, 2]);

      expect(history.fourfoldRepetition, isTrue);
    });
  });

  group('repetition distance', () {
    test('no repetition', () {
      final history = makeHistory([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

      expect(history.firstRepetitionDistance, isNull);
    });

    test('half', () {
      final history = makeHistory([0, 1, 2, 3, 4, 5, 12, 7, 8, 9, 10, 11, 12]);

      expect(history.firstRepetitionDistance, equals(3));
    });

    test('last', () {
      final history = makeHistory([12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

      expect(history.firstRepetitionDistance, equals(6));
    });
  });

  group('played repetition', () {
    for (final turn in ['b', 'w']) {
      test(
        'counts first occurrence when playing from empty history ($turn)',
        () {
          var pos =
              parseSfen(
                Rule.shogi,
                '4k3p/9/9/9/9/9/9/P8/4K4 $turn - 37',
                strict: true,
              ).getOrThrow();
          expect(pos.history.positions, isEmpty);
          expect(pos.history.initialSfen, isNull);
          final cycle =
              turn == 'b'
                  ? ['5i6i', '5a6a', '6i5i', '6a5a']
                  : ['5a6a', '5i6i', '6a5a', '6i5i'];
          for (var ply = 1; ply <= 13; ply++) {
            pos =
                pos.play(MoveOrDrop.parse(cycle[(ply - 1) % 4])!).getOrThrow();
            expect(
              pos.history.fourfoldRepetition,
              ply >= 12,
              reason: 'ply $ply',
            );
            expect(
              pos.history.firstRepetitionDistance,
              ply < 4 ? isNull : equals(2 * (ply ~/ 4)),
            );
            expect(pos.history.positions.last, makeSfen(pos));
          }
          pos =
              pos
                  .play(MoveOrDrop.parse(turn == 'b' ? '5a4a' : '5i4i')!)
                  .getOrThrow();
          expect(pos.history.fourfoldRepetition, isFalse);
          expect(pos.history.firstRepetitionDistance, isNull);
          expect(pos.moveNumber, 51);
        },
      );
    }

    test(
      'independently parsed positions have no inferred starting history',
      () {
        for (final moveNumber in [1, 37, 400]) {
          final pos =
              parseSfen(
                Rule.shogi,
                '4k3p/9/9/9/9/9/9/P8/4K4 b - $moveNumber',
              ).getOrThrow();
          expect(pos.history.positions, isEmpty);
          expect(pos.history.initialSfen, isNull);
          final next = pos.play(MoveOrDrop.parse('5i6i')!).getOrThrow();
          expect(next.history.positions, [makeSfen(pos), makeSfen(next)]);
          expect(next.history.initialSfen, isNull);
        }
      },
    );

    test('old repeated position does not match newest unique key', () {
      var history = History.empty;
      for (final key in [
        'a',
        'b',
        'c',
        'b',
        'a',
        'b',
        'c',
        'b',
        'a',
        'b',
        'c',
        'b',
        'a',
        'z',
      ]) {
        history = history.addPosition(key);
      }
      expect(history.fourfoldRepetition, isFalse);
      expect(history.firstRepetitionDistance, isNull);
    });

    test('identity retains side, hands and Chu anti-recapture state', () {
      for (final different in ['board w - 2', 'board b P 2', 'board b 5e 2']) {
        final history = History.empty
            .addPosition('board b - 1')
            .addPosition('other w - 2')
            .addPosition(different);
        expect(history.firstRepetitionDistance, isNull);
      }
      final history = History.empty
          .addPosition('board b - 1')
          .addPosition('other w - 2')
          .addPosition('board b - 3');
      expect(history.firstRepetitionDistance, 1);
      expect(
        history
            .copyWith(consecutiveAttacks: const ConsecutiveAttacks(1, 0))
            .perpetualCheckAttacker,
        Side.sente,
      );
    });

    test('setup preserves explicitly supplied history', () {
      final pos = parseSfen(Rule.shogi, 'startpos').getOrThrow();
      final setup = Setup(
        board: pos.board,
        hands: pos.hands,
        turn: pos.turn,
        history: pos.history
            .copyWith(initialSfen: makeSfen(pos))
            .addPosition(makeSfen(pos)),
        moveNumber: pos.moveNumber,
      );
      expect(
        setupPosition(Rule.shogi, setup).getOrThrow().history,
        setup.history,
      );
    });

    test('direct constructor records preceding and resulting positions', () {
      final parsed = parseSfen(Rule.shogi, 'startpos').getOrThrow();
      final pos = Shogi(
        board: parsed.board,
        hands: parsed.hands,
        turn: parsed.turn,
        history: History.empty,
        moveNumber: 1,
      );
      final next = pos.play(MoveOrDrop.parse('7g7f')!).getOrThrow();
      expect(next.history.positions, [makeSfen(pos), makeSfen(next)]);
      expect(next.history.initialSfen, isNull);
    });

    test('Chu history records updated and cleared anti-recapture square', () {
      final pos =
          parseSfen(
            Rule.chushogi,
            '12/12/12/12/12/4r7/12/12/5o3n1n/4N6P/12/6B5 w - 1',
          ).getOrThrow();
      final capture = pos.play(MoveOrDrop.parse('7i8j+')!).getOrThrow();
      expect(capture.history.lastLionCapture, Square.parse('8j'));
      expect(capture.history.positions.last, makeSfen(capture));
      expect(capture.history.positions.last.split(' ')[2], '8j');
      final next = capture.play(MoveOrDrop.parse('6l7k')!).getOrThrow();
      expect(next.history.lastLionCapture, isNull);
      expect(next.history.positions.last, makeSfen(next));
      expect(next.history.positions.last.split(' ')[2], '-');
    });

    test('drop records resulting state', () {
      final pos =
          parseSfen(
            Rule.shogi,
            '4k3p/9/9/9/9/9/9/P8/4K4 b P 1',
            strict: true,
          ).getOrThrow();
      final next = pos.play(MoveOrDrop.parse('P*4e')!).getOrThrow();
      expect(next.history.positions, [makeSfen(pos), makeSfen(next)]);
      expect(next.history.initialSfen, isNull);
    });
  });

  group('scalashogi history lifecycle', () {
    test(
      'Chu lion passes repeat after six plies, including first position',
      () {
        var pos =
            parseSfen(
              Rule.chushogi,
              'k11/12/6n5/12/12/12/12/12/12/5N6/12/11K b - 1',
            ).getOrThrow();
        for (var ply = 1; ply <= 6; ply++) {
          pos =
              pos
                  .play(MoveOrDrop.parse(ply.isOdd ? '7j7i7j' : '6c6d6c')!)
                  .getOrThrow();
          expect(pos.history.fourfoldRepetition, ply == 6);
          expect(pos.history.positions.length, ply + 1);
        }
        expect(pos.history.firstRepetitionDistance, 3);
        expect(pos.history.initialSfen, isNull);
      },
    );

    for (final (rule, cycle, plies) in [
      (Rule.minishogi, ['4e4d', '2a2b', '4d4e', '2b2a'], 12),
      (Rule.kyotoshogi, ['4e3d+', '2a3b+', '3d4e+', '3b2a+'], 8),
    ]) {
      test('$rule repetition matches scalashogi played cycles', () {
        var pos = parseSfen(rule, 'startpos').getOrThrow();
        for (var ply = 1; ply <= plies; ply++) {
          pos = pos.play(MoveOrDrop.parse(cycle[(ply - 1) % 4])!).getOrThrow();
          expect(
            rule == Rule.kyotoshogi
                ? pos.history.threefoldRepetition
                : pos.history.fourfoldRepetition,
            ply == plies,
          );
          expect(pos.history.positions.length, ply + 1);
        }
      });
    }

    test('Chu irreversible moves discard prior repetition entries', () {
      const cases = [
        ('k11/12/12/12/12/12/6P5/12/12/12/12/11K b - 1', '6g6f'),
        ('k11/12/12/12/12/12/6L5/12/12/12/12/11K b - 1', '6g6f'),
        ('k11/12/12/12/6P5/12/12/12/12/12/12/11K b - 1', '6e6d+'),
        ('k11/12/12/12/12/6p5/6R5/12/12/12/12/11K b - 1', '6g6f'),
        ('k11/12/12/12/12/6p5/6N5/12/12/12/12/11K b - 1', '6g6f6g'),
      ];
      for (final (sfen, usi) in cases) {
        for (final hasHistory in [false, true]) {
          var pos = parseSfen(Rule.chushogi, sfen).getOrThrow();
          var history = pos.history.copyWith(initialSfen: sfen);
          if (hasHistory) history = history.addPosition('old');
          pos = pos.copyWith(history: history);
          final next = pos.play(MoveOrDrop.parse(usi)!).getOrThrow();
          expect(next.history.positions, [makeSfen(next)], reason: usi);
          expect(next.history.firstRepetitionDistance, isNull);
          expect(next.history.initialSfen, sfen);
          expect(next.history.lastMoveOrDrop?.usi, usi);
        }
      }
    });

    test('existing history is extended once without reseeding', () {
      var pos = parseSfen(Rule.shogi, 'startpos').getOrThrow();
      pos = pos.copyWith(
        history: pos.history.copyWith(initialSfen: 'caller').addPosition('old'),
      );
      final next = pos.play(MoveOrDrop.parse('7g7f')!).getOrThrow();
      expect(next.history.positions, ['old', makeSfen(next)]);
      expect(next.history.initialSfen, 'caller');
    });

    test('checks increment mover counter and quiet moves reset only mover', () {
      var pos =
          parseSfen(
            Rule.shogi,
            '4k4/5R3/9/9/9/9/9/P8/4K4 b - 1',
            strict: true,
          ).getOrThrow();
      const cycle = ['4b5b', '5a4a', '5b4b', '4a5a'];
      for (var ply = 1; ply <= 12; ply++) {
        pos = pos.play(MoveOrDrop.parse(cycle[(ply - 1) % 4])!).getOrThrow();
        expect(
          pos.history.consecutiveAttacks,
          ConsecutiveAttacks((ply + 1) ~/ 2, 0),
        );
      }
      expect(pos.history.fourfoldRepetition, isTrue);
      expect(pos.history.firstRepetitionDistance, 6);
      expect(pos.history.perpetualCheckAttacker, Side.sente);
      pos = pos.play(MoveOrDrop.parse('4b3b')!).getOrThrow();
      expect(pos.history.consecutiveAttacks, ConsecutiveAttacks.empty);
    });

    test('checking drops update counters and preserve opponent count', () {
      var pos =
          parseSfen(
            Rule.shogi,
            '4k4/9/9/9/9/9/9/P8/4K4 b R 1',
            strict: true,
          ).getOrThrow();
      pos = pos.copyWith(
        history: pos.history.copyWith(
          consecutiveAttacks: const ConsecutiveAttacks(2, 4),
        ),
      );
      final next = pos.play(MoveOrDrop.parse('R*5b')!).getOrThrow();
      expect(next.history.consecutiveAttacks, const ConsecutiveAttacks(3, 4));
      expect(next.history.positions, [makeSfen(pos), makeSfen(next)]);
    });

    test('Dobutsu and checkshogi never accumulate perpetual attacks', () {
      for (final (rule, sfen, usi) in [
        (Rule.checkshogi, '4k4/5R3/9/9/9/9/9/P8/4K4 b - 1', '4b5b'),
        (Rule.dobutsu, '2k/1R1/3/K2 b - 1', '2b1b'),
      ]) {
        var pos = parseSfen(rule, sfen).getOrThrow();
        pos = pos.copyWith(
          history: pos.history.copyWith(
            consecutiveAttacks: const ConsecutiveAttacks(2, 4),
          ),
        );
        final next = pos.play(MoveOrDrop.parse(usi)!).getOrThrow();
        expect(next.isCheck(), isTrue);
        expect(next.history.consecutiveAttacks, const ConsecutiveAttacks(0, 4));
      }
    });

    test('Chu chasing counts attacks on nonroyal pieces', () {
      final pos =
          parseSfen(
            Rule.chushogi,
            'k11/12/12/6p5/12/12/6R5/12/12/12/12/11K b - 1',
          ).getOrThrow();
      final next = pos.play(MoveOrDrop.parse('6g6f')!).getOrThrow();
      expect(next.isCheck(), isFalse);
      expect(next.history.consecutiveAttacks, const ConsecutiveAttacks(1, 0));
      expect(next.history.positions, [makeSfen(pos), makeSfen(next)]);
    });
  });

  group('equality', () {
    test('two histories are equal', () {
      expect(History.empty, History.empty);
      expect(History.empty.addPosition('a'), History.empty.addPosition('a'));
    });
  });
}
