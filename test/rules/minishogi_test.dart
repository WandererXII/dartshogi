import 'package:dartshogi/dartshogi.dart';
import 'package:result_dart/result_dart.dart';
import 'package:test/test.dart';

import '../fixtures/minishogi.dart';

const _minishogiPerfts = [
  ('', 1, 14),
  ('', 2, 181),
  ('', 3, 2512),
  ('', 4, 35401),
  ('', 5, 533203),
];

void main() {
  for (final (sfen, depth, res) in _minishogiPerfts) {
    test('minishogi perft: $sfen ($depth): $res', () {
      final pos =
          parseSfen(
            Rule.minishogi,
            sfen.isEmpty ? initialSfen(Rule.minishogi) : sfen,
          ).getOrThrow();
      expect(perft(pos, depth), equals(res));
    });
  }

  test('roles outside minishogi', () {
    final r1 = parseSfen(
      Rule.minishogi,
      '2k2/2p2/2l2/2P2/2K2 b - 1',
      strict: true,
    );
    expect(r1, const Failure(SfenException(IllegalSfenCause.board)));
  });

  test('minishogi checkmate', () {
    final pos =
        parseSfen(Rule.minishogi, 'r1s1k/2b1g/5/r1G1B/KPS2 b p').getOrThrow();
    expect(
      pos.outcome(),
      equals(const Outcome(result: GameResult.checkmate, winner: Side.gote)),
    );
  });

  test('randomly generated perfts - for consistency', () {
    for (final (sfen, depth, res) in perfts) {
      final pos =
          parseSfen(
            Rule.minishogi,
            sfen.isEmpty ? initialSfen(Rule.minishogi) : sfen,
          ).getOrThrow();
      expect(perft(pos, depth), equals(res));
    }
  });
}
