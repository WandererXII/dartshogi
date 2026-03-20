import 'package:dartshogi/src/core/role.dart';
import 'package:dartshogi/src/hands.dart';
import 'package:test/test.dart';

void main() {
  group('Hand', () {
    test('empty', () {
      expect(Hand.empty.isEmpty, isTrue);
      expect(Hand.empty.nonEmpty, isFalse);
      expect(Hand.empty.count, 0);
    });

    test('capture', () {
      final hand = Hand.empty.capture(Role.pawn);
      expect(hand.countOf(Role.pawn), 1);
      expect(hand.count, 1);

      final hand2 = Hand.empty.capture(Role.pawn).capture(Role.pawn);
      expect(hand2.countOf(Role.pawn), 2);
    });

    test('immutable', () {
      const original = Hand.empty;
      final updated = original.capture(Role.pawn);
      expect(original.countOf(Role.pawn), 0);
      expect(updated.countOf(Role.pawn), 1);
    });

    test('drop', () {
      final hand = Hand.empty.capture(Role.pawn).drop(Role.pawn);
      expect(hand.countOf(Role.pawn), 0);
      expect(hand.isEmpty, isTrue);

      // key removed when reaching zero
      final hand2 = Hand.empty.capture(Role.pawn).drop(Role.pawn);
      expect(hand2.handMap.containsKey(Role.pawn), isFalse);
    });

    test('set', () {
      final hand = Hand.empty.set(Role.pawn, 3);
      expect(hand.countOf(Role.pawn), 3);

      // setting to zero removes the key
      final hand2 = Hand.empty.capture(Role.pawn).set(Role.pawn, 0);
      expect(hand2.handMap.containsKey(Role.pawn), isFalse);
      expect(hand2.isEmpty, isTrue);

      final hand3 = Hand.empty.set(Role.pawn, -1);
      expect(hand3.handMap.containsKey(Role.pawn), isFalse);

      final hand4 =
          Hand.empty.capture(Role.pawn).capture(Role.pawn).set(Role.pawn, 1);
      expect(hand4.countOf(Role.pawn), 1);
    });

    group('combine', () {
      test('merges two non-overlapping hands', () {
        final a = Hand.empty.capture(Role.pawn);
        final b = Hand.empty.capture(Role.rook);
        final combined = a.combine(b);
        expect(combined.countOf(Role.pawn), 1);
        expect(combined.countOf(Role.rook), 1);
        expect(combined.count, 2);
      });

      test('sums counts for overlapping roles', () {
        final a = Hand.empty.capture(Role.pawn).capture(Role.pawn);
        final b = Hand.empty.capture(Role.pawn);
        expect(a.combine(b).countOf(Role.pawn), 3);
      });

      test('combining with empty returns equivalent hand', () {
        final hand = Hand.empty.capture(Role.pawn);
        expect(hand.combine(Hand.empty), hand);
      });

      test('combining two empty hands returns empty hand', () {
        expect(Hand.empty.combine(Hand.empty), Hand.empty);
      });
    });

    group('equality', () {
      test('two hands with same pieces are equal', () {
        final a = Hand.empty.capture(Role.pawn);
        final b = Hand.empty.capture(Role.pawn);
        expect(a, b);
      });

      test('two hands with different pieces are not equal', () {
        final a = Hand.empty.capture(Role.pawn);
        final b = Hand.empty.capture(Role.rook);
        expect(a, isNot(b));
      });

      test('hashCode matches for equal hands', () {
        final a = Hand.empty.capture(Role.pawn);
        final b = Hand.empty.capture(Role.pawn);
        expect(a.hashCode, b.hashCode);
      });
    });
  });

  group('Hands', () {
    test('empty', () {
      expect(Hands.empty.isEmpty, isTrue);
      expect(Hands.empty.nonEmpty, isFalse);
      expect(Hands.empty.count, 0);
    });

    group('combine', () {
      test('combines both sides independently', () {
        final a = Hands(
          sente: Hand.empty.capture(Role.pawn),
          gote: Hand.empty.capture(Role.rook),
        );
        final b = Hands(
          sente: Hand.empty.capture(Role.pawn),
          gote: Hand.empty.capture(Role.rook),
        );
        final combined = a.combine(b);
        expect(combined.sente.countOf(Role.pawn), 2);
        expect(combined.gote.countOf(Role.rook), 2);
      });

      test('combining with empty returns equivalent hands', () {
        final hands = Hands(
          sente: Hand.empty.capture(Role.pawn),
          gote: Hand.empty,
        );
        expect(hands.combine(Hands.empty), hands);
      });
    });

    test('count', () {
      final hands = Hands(
        sente: Hand.empty.capture(Role.pawn).capture(Role.pawn),
        gote: Hand.empty.capture(Role.rook),
      );
      expect(hands.count, 3);
    });

    group('equality', () {
      test('equal when both sides match', () {
        final a = Hands(
          sente: Hand.empty.capture(Role.pawn),
          gote: Hand.empty,
        );
        final b = Hands(
          sente: Hand.empty.capture(Role.pawn),
          gote: Hand.empty,
        );
        expect(a, b);
      });

      test('not equal when sides differ', () {
        final a = Hands(sente: Hand.empty.capture(Role.pawn), gote: Hand.empty);
        final b = Hands(sente: Hand.empty, gote: Hand.empty.capture(Role.pawn));
        expect(a, isNot(b));
      });

      test('hashCode matches for equal hands', () {
        final a = Hands(sente: Hand.empty.capture(Role.pawn), gote: Hand.empty);
        final b = Hands(sente: Hand.empty.capture(Role.pawn), gote: Hand.empty);
        expect(a.hashCode, b.hashCode);
      });
    });
  });
}
