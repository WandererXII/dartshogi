import 'package:dartshogi/dartshogi.dart';
import 'package:dartshogi/src/history.dart';
import 'package:test/test.dart';

void main() {
  String toPosition(int a) => 'sfen_$a';

  History makeHistory(List<int> positions) {
    var history = History.empty;

    for (final p in positions) {
      history = history.copyWith(
        positions: [
          toPosition(p),
          ...history.positions,
        ],
      );
    }

    return history;
  }

  group('fourfold repetition', () {
    test('empty history', () {
      expect(
        History.empty.fourfoldRepetition,
        isFalse,
      );
    });

    test('addLastLionCapture nullable', () {
      const original = History.empty;

      final withValue = original.addLastLionCapture(const Square(0));
      expect(withValue.lastLionCapture, equals(const Square(0)));

      final cleared = withValue.addLastLionCapture(null);
      expect(cleared.lastLionCapture, isNull);
    });

    test('not 4 same elements', () {
      final history = makeHistory([
        1,
        2,
        3,
        4,
        5,
        2,
        5,
        6,
        16,
        2,
        23,
        55,
      ]);

      expect(
        history.fourfoldRepetition,
        isFalse,
      );
    });

    test('not 4 elements same to the last one', () {
      final history = makeHistory([
        1,
        2,
        3,
        4,
        5,
        2,
        5,
        6,
        23,
        2,
        55,
        2,
        33,
      ]);

      expect(
        history.fourfoldRepetition,
        isFalse,
      );
    });

    test('positive', () {
      final history = makeHistory([
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        2,
        5,
        6,
        3,
        2,
        6,
        2,
      ]);

      expect(
        history.fourfoldRepetition,
        isTrue,
      );
    });
  });

  group('repetition distance', () {
    test('no repetition', () {
      final history = makeHistory([
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
      ]);

      expect(
        history.firstRepetitionDistance,
        isNull,
      );
    });

    test('half', () {
      final history = makeHistory([
        0,
        1,
        2,
        3,
        4,
        5,
        12,
        7,
        8,
        9,
        10,
        11,
        12,
      ]);

      expect(
        history.firstRepetitionDistance,
        equals(3),
      );
    });

    test('last', () {
      final history = makeHistory([
        12,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
      ]);

      expect(
        history.firstRepetitionDistance,
        equals(6),
      );
    });
  });
}