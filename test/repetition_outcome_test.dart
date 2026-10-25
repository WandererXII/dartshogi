import 'package:dartshogi/dartshogi.dart';
import 'package:test/test.dart';

Position repeated(Position pos, {ConsecutiveAttacks? attacks, int times = 4}) {
  var history = History.empty;
  for (var i = 0; i < times; i++) {
    history = history.addPosition(makeSfen(pos));
    if (i < times - 1) history = history.addPosition('other');
  }
  return pos.copyWith(history: history.copyWith(consecutiveAttacks: attacks));
}

void main() {
  group('standard repetition outcome', () {
    for (final turn in ['b', 'w']) {
      test('quiet cycle ends at fourth occurrence ($turn)', () {
        var pos =
            parseSfen(
              Rule.shogi,
              '4k3p/9/9/9/9/9/9/P8/4K4 $turn - 37',
              strict: true,
            ).getOrThrow();
        final cycle =
            turn == 'b'
                ? ['5i6i', '5a6a', '6i5i', '6a5a']
                : ['5a6a', '5i6i', '6a5a', '6i5i'];
        for (var ply = 0; ply < 12; ply++) {
          expect(pos.outcome(), isNull);
          expect(pos.isEnd(), isFalse);
          pos = pos.play(MoveOrDrop.parse(cycle[ply % 4])!).getOrThrow();
        }
        expect(pos.history.fourfoldRepetition, isTrue);
        expect(pos.outcome()?.result, GameResult.repetition);
        expect(pos.outcome()?.winner, isNull);
        expect(pos.isEnd(), isTrue);
      });
    }

    for (final (sfen, cycle, attacker) in [
      (
        '4k4/5R3/9/9/9/9/9/P8/4K4 b - 1',
        ['4b5b', '5a4a', '5b4b', '4a5a'],
        Side.sente,
      ),
      (
        '4k4/8p/9/9/9/9/9/3r5/4K4 w - 1',
        ['6h5h', '5i6i', '5h6h', '6i5i'],
        Side.gote,
      ),
    ]) {
      test('continuous checker $attacker loses on either turn', () {
        var pos = parseSfen(Rule.shogi, sfen, strict: true).getOrThrow();
        for (var ply = 0; ply < 13; ply++) {
          if (ply < 12) {
            expect(pos.outcome(), isNull);
          } else {
            expect(pos.history.perpetualCheckAttacker, attacker);
            expect(pos.outcome()?.result, GameResult.perpetualCheck);
            expect(pos.outcome()?.winner, attacker.opposite);
            expect(pos.isEnd(), isTrue);
          }
          pos = pos.play(MoveOrDrop.parse(cycle[ply % 4])!).getOrThrow();
        }
        expect(pos.outcome()?.result, GameResult.perpetualCheck);
        expect(pos.outcome()?.winner, attacker.opposite);
      });
    }

    test('isolated history supplies repetition result', () {
      final pos = repeated(parseSfen(Rule.shogi, 'startpos').getOrThrow());
      expect(pos.outcome()?.result, GameResult.repetition);
      expect(pos.outcome()?.winner, isNull);
      expect(pos.isEnd(pos.makeCtx()), isTrue);
    });

    test('interrupted checking sequence draws', () {
      final pos = repeated(
        parseSfen(Rule.shogi, 'startpos').getOrThrow(),
        attacks: const ConsecutiveAttacks(2, 0),
      );
      expect(pos.history.firstRepetitionDistance, 3);
      expect(pos.outcome()?.result, GameResult.repetition);
      expect(pos.outcome()?.winner, isNull);
    });

    for (final (sfen, result, winner) in [
      ('k8/1G7/1R7/9/9/9/9/9/4K4 w - 1', GameResult.checkmate, Side.sente),
      ('k8/2R6/1R7/9/9/9/9/9/4K4 w - 1', GameResult.stalemate, Side.sente),
      (
        '2SGS4/+B+RGKGLLRB/3G5/9/7pp/8k/9/9/9 b - 1',
        GameResult.impasse27,
        Side.sente,
      ),
    ]) {
      test('$result retains priority over repetition', () {
        final pos = parseSfen(Rule.shogi, sfen).getOrThrow();
        final expected = Outcome(result: result, winner: winner);
        expect(pos.outcome(), expected);
        expect(repeated(pos).outcome(), expected);
      });
    }

    test('repetition precedes insufficient material', () {
      final pos =
          parseSfen(Rule.shogi, '4k4/9/9/9/9/9/9/9/4K4 b - 1').getOrThrow();
      expect(pos.outcome()?.result, GameResult.draw);
      expect(repeated(pos).outcome()?.result, GameResult.repetition);
    });
  });

  group('scalashogi variant adjudication', () {
    for (final rule in Rule.values) {
      final threshold = rule == Rule.kyotoshogi || rule == Rule.dobutsu ? 3 : 4;
      test('$rule threshold and quiet winner', () {
        final pos = parseSfen(rule, 'startpos').getOrThrow();
        expect(repeated(pos, times: threshold - 1).outcome(), isNull);
        final end = repeated(pos, times: threshold);
        expect(
          end.outcome(),
          Outcome(
            result: GameResult.repetition,
            winner: rule == Rule.minishogi ? Side.gote : null,
          ),
        );
        expect(end.isEnd(), isTrue);
      });
      for (final attacker in Side.values) {
        test('$rule continuous attacker $attacker', () {
          final pos = parseSfen(rule, 'startpos').getOrThrow();
          final end = repeated(
            pos,
            times: threshold,
            attacks:
                attacker == Side.sente
                    ? const ConsecutiveAttacks(10, 0)
                    : const ConsecutiveAttacks(0, 10),
          );
          expect(
            end.outcome(),
            Outcome(
              result:
                  threshold == 3
                      ? GameResult.repetition
                      : GameResult.perpetualCheck,
              winner: threshold == 3 ? null : attacker.opposite,
            ),
          );
        });
      }
    }

    for (final (initial, winner) in [
      (null, Side.gote),
      ('invalid', Side.gote),
      ('rbsgk/4p/5/P4/KGSBR b - 1', Side.gote),
      ('rbsgk/4p/5/P4/KGSBR w - 1', Side.sente),
      ('board ? - 1', Side.gote),
    ]) {
      test('Minishogi initial SFEN $initial', () {
        final pos = repeated(
          parseSfen(Rule.minishogi, 'startpos').getOrThrow(),
        );
        final end = pos.copyWith(
          history: pos.history.copyWith(initialSfen: initial),
        );
        expect(
          end.outcome(),
          Outcome(result: GameResult.repetition, winner: winner),
        );
      });
    }

    for (final (rule, sfen, cycle, plies, winner) in [
      (
        Rule.minishogi,
        'startpos',
        ['4e4d', '2a2b', '4d4e', '2b2a'],
        12,
        Side.gote,
      ),
      (
        Rule.kyotoshogi,
        'startpos',
        ['4e3d+', '2a3b+', '3d4e+', '3b2a+'],
        8,
        null,
      ),
      (
        Rule.chushogi,
        'k11/12/6n5/12/12/12/12/12/12/5N6/12/11K b - 1',
        ['7j7i7j', '6c6d6c'],
        6,
        null,
      ),
      (
        Rule.dobutsu,
        '1k1/3/3/1K1 b - 1',
        ['2d3d', '2a3a', '3d2d', '3a2a'],
        8,
        null,
      ),
    ]) {
      test('$rule legal repetition cycle', () {
        var pos = parseSfen(rule, sfen).getOrThrow();
        for (var ply = 0; ply < plies; ply++) {
          expect(pos.outcome(), isNull);
          pos =
              pos
                  .play(MoveOrDrop.parse(cycle[ply % cycle.length])!)
                  .getOrThrow();
        }
        expect(
          pos.outcome(),
          Outcome(result: GameResult.repetition, winner: winner),
        );
      });
    }

    test('Chu continuous attacks on a pawn lose without checking the king', () {
      var pos =
          parseSfen(
            Rule.chushogi,
            'k11/12/12/6p5/12/12/6R5/12/12/12/12/11K b - 1',
          ).getOrThrow();
      const cycle = ['6g6f', '12a11a', '6f6g', '11a12a'];
      for (var ply = 0; ply < 12; ply++) {
        expect(pos.outcome(), isNull);
        pos = pos.play(MoveOrDrop.parse(cycle[ply % 4])!).getOrThrow();
        expect(pos.isCheck(), isFalse);
      }
      expect(pos.history.perpetualCheckAttacker, Side.sente);
      expect(
        pos.outcome(),
        const Outcome(result: GameResult.perpetualCheck, winner: Side.gote),
      );
    });

    for (final (rule, sfen, result, winner) in [
      (
        Rule.checkshogi,
        '4k4/4R4/9/9/9/9/9/P8/4K4 w - 1',
        GameResult.check,
        Side.sente,
      ),
      (Rule.dobutsu, 'k1K/3/3/3 b - 1', GameResult.tryRule, Side.sente),
      (Rule.dobutsu, 'k2/3/3/3 b - 1', GameResult.kingsLost, Side.gote),
      (
        Rule.chushogi,
        'k11/12/12/12/12/12/12/12/12/12/12/10RK w - 1',
        GameResult.bareKing,
        Side.sente,
      ),
    ]) {
      test('$rule $result precedes repetition', () {
        final pos = parseSfen(rule, sfen).getOrThrow();
        final expected = Outcome(result: result, winner: winner);
        expect(pos.outcome(), expected);
        expect(repeated(pos).outcome(), expected);
      });
    }
  });
}
