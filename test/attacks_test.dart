import 'package:dartshogi/src/core/side.dart';
import 'package:dartshogi/src/core/role.dart';
import 'package:dartshogi/src/core/piece.dart';
import 'package:dartshogi/src/core/square.dart';
import 'package:dartshogi/src/square_set.dart';
import 'package:dartshogi/src/attacks.dart';
import 'package:test/test.dart';

void main() {
  Square s(int v) => Square(v);
  group('Attacks', () {
    test('ray', () {
      expect(ray(s(0), s(240)), equals(SquareSet.fromFile(0)));
      expect(ray(s(240), s(0)), equals(SquareSet.fromFile(0)));
      expect(ray(s(0), s(15)), equals(SquareSet.fromRank(0)));
      expect(ray(s(15), s(0)), equals(SquareSet.fromRank(0)));
      expect(
        ray(s(0), s(255)),
        equals(SquareSet.fromList([
          0x20001,
          0x80004,
          0x200010,
          0x800040,
          0x2000100,
          0x8000400,
          0x20001000,
          0x80004000,
        ])),
      );
      expect(
        ray(s(255), s(0)),
        equals(SquareSet.fromList([
          0x20001,
          0x80004,
          0x200010,
          0x800040,
          0x2000100,
          0x8000400,
          0x20001000,
          0x80004000,
        ])),
      );
    });

    test('between', () {
      expect(between(s(42), s(42)), equals(SquareSet.empty));
      expect(between(s(0), s(3)).squares.toList(), equals([1, 2]));
      expect(between(s(3), s(0)).squares.toList(), equals([1, 2]));
      expect(between(s(0), s(34)).squares.toList(), equals([17]));
      expect(between(s(34), s(0)).squares.toList(), equals([17]));
      expect(between(s(208), s(240)).squares.toList(), equals([224]));
      expect(between(s(240), s(208)).squares.toList(), equals([224]));
    });

    test('lance attacks', () {
      expect(
        lanceAttacks(s(0), Side.sente, SquareSet.empty),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        lanceAttacks(s(1), Side.sente, SquareSet.empty),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        lanceAttacks(s(14), Side.sente, SquareSet.empty),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        lanceAttacks(s(15), Side.sente, SquareSet.empty),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        lanceAttacks(s(42), Side.sente, SquareSet.empty),
        equals(
            SquareSet.fromList([0x4000400, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        lanceAttacks(s(240), Side.sente, SquareSet.empty),
        equals(SquareSet.fromList([
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x1
        ])),
      );
      expect(
        lanceAttacks(s(241), Side.sente, SquareSet.empty),
        equals(SquareSet.fromList([
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x2
        ])),
      );
      expect(
        lanceAttacks(s(254), Side.sente, SquareSet.empty),
        equals(SquareSet.fromList([
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x4000
        ])),
      );
      expect(
        lanceAttacks(s(255), Side.sente, SquareSet.empty),
        equals(SquareSet.fromList([
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x8000
        ])),
      );

      expect(
        lanceAttacks(s(0), Side.gote, SquareSet.empty),
        equals(SquareSet.fromList([
          0x10000,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001
        ])),
      );
      expect(
        lanceAttacks(s(1), Side.gote, SquareSet.empty),
        equals(SquareSet.fromList([
          0x20000,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002
        ])),
      );
      expect(
        lanceAttacks(s(14), Side.gote, SquareSet.empty),
        equals(SquareSet.fromList([
          0x40000000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000
        ])),
      );
      expect(
        lanceAttacks(s(15), Side.gote, SquareSet.empty),
        equals(SquareSet.fromList([
          0x80000000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000
        ])),
      );
      expect(
        lanceAttacks(s(42), Side.gote, SquareSet.empty),
        equals(SquareSet.fromList([
          0x0,
          0x4000000,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400
        ])),
      );
      expect(
        lanceAttacks(s(240), Side.gote, SquareSet.empty),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        lanceAttacks(s(241), Side.gote, SquareSet.empty),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        lanceAttacks(s(254), Side.gote, SquareSet.empty),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        lanceAttacks(s(255), Side.gote, SquareSet.empty),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );

      expect(
        lanceAttacks(s(42), Side.sente,
            SquareSet.fromList([0x4000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
        equals(
            SquareSet.fromList([0x4000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        lanceAttacks(s(42), Side.sente,
            SquareSet.fromList([0x400, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
        equals(
            SquareSet.fromList([0x4000400, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
    });

    test('knight attacks', () {
      expect(
        knightAttacks(s(0), Side.sente),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(1), Side.sente),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(14), Side.sente),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(15), Side.sente),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(42), Side.sente),
        equals(SquareSet.fromList([0xa00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(240), Side.sente),
        equals(
            SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x20000, 0x0])),
      );
      expect(
        knightAttacks(s(241), Side.sente),
        equals(
            SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x50000, 0x0])),
      );
      expect(
        knightAttacks(s(254), Side.sente),
        equals(SquareSet.fromList(
            [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xa0000000, 0x0])),
      );
      expect(
        knightAttacks(s(255), Side.sente),
        equals(SquareSet.fromList(
            [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x40000000, 0x0])),
      );

      expect(
        knightAttacks(s(0), Side.gote),
        equals(SquareSet.fromList([0x0, 0x2, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(1), Side.gote),
        equals(SquareSet.fromList([0x0, 0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(14), Side.gote),
        equals(SquareSet.fromList([0x0, 0xa000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(15), Side.gote),
        equals(SquareSet.fromList([0x0, 0x4000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(42), Side.gote),
        equals(SquareSet.fromList([0x0, 0x0, 0xa00, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(240), Side.gote),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(241), Side.gote),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(254), Side.gote),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        knightAttacks(s(255), Side.gote),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
    });

    test('silver attacks', () {
      expect(
        silverAttacks(s(0), Side.sente),
        equals(
            SquareSet.fromList([0x20000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(1), Side.sente),
        equals(
            SquareSet.fromList([0x50000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(14), Side.sente),
        equals(SquareSet.fromList(
            [0xa0000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(15), Side.sente),
        equals(SquareSet.fromList(
            [0x40000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(42), Side.sente),
        equals(SquareSet.fromList(
            [0xe000000, 0xa000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(240), Side.sente),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x3])),
      );
      expect(
        silverAttacks(s(241), Side.sente),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x7])),
      );
      expect(
        silverAttacks(s(254), Side.sente),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xe000])),
      );
      expect(
        silverAttacks(s(255), Side.sente),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xc000])),
      );

      expect(
        silverAttacks(s(0), Side.gote),
        equals(
            SquareSet.fromList([0x30000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(1), Side.gote),
        equals(
            SquareSet.fromList([0x70000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(14), Side.gote),
        equals(SquareSet.fromList(
            [0xe0000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(15), Side.gote),
        equals(SquareSet.fromList(
            [0xc0000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(42), Side.gote),
        equals(SquareSet.fromList(
            [0xa000000, 0xe000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        silverAttacks(s(240), Side.gote),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2])),
      );
      expect(
        silverAttacks(s(241), Side.gote),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x5])),
      );
      expect(
        silverAttacks(s(254), Side.gote),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xa000])),
      );
      expect(
        silverAttacks(s(255), Side.gote),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x4000])),
      );
    });

    test('gold attacks', () {
      expect(
        goldAttacks(s(0), Side.sente),
        equals(
            SquareSet.fromList([0x10002, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(1), Side.sente),
        equals(
            SquareSet.fromList([0x20005, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(14), Side.sente),
        equals(SquareSet.fromList(
            [0x4000a000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(15), Side.sente),
        equals(SquareSet.fromList(
            [0x80004000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(42), Side.sente),
        equals(SquareSet.fromList(
            [0xe000000, 0x4000a00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(240), Side.sente),
        equals(
            SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x20003])),
      );
      expect(
        goldAttacks(s(241), Side.sente),
        equals(
            SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x50007])),
      );
      expect(
        goldAttacks(s(254), Side.sente),
        equals(SquareSet.fromList(
            [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xa000e000])),
      );
      expect(
        goldAttacks(s(255), Side.sente),
        equals(SquareSet.fromList(
            [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x4000c000])),
      );

      expect(
        goldAttacks(s(0), Side.gote),
        equals(
            SquareSet.fromList([0x30002, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(1), Side.gote),
        equals(
            SquareSet.fromList([0x70005, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(14), Side.gote),
        equals(SquareSet.fromList(
            [0xe000a000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(15), Side.gote),
        equals(SquareSet.fromList(
            [0xc0004000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(42), Side.gote),
        equals(SquareSet.fromList(
            [0x4000000, 0xe000a00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        goldAttacks(s(240), Side.gote),
        equals(
            SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x20001])),
      );
      expect(
        goldAttacks(s(241), Side.gote),
        equals(
            SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x50002])),
      );
      expect(
        goldAttacks(s(254), Side.gote),
        equals(SquareSet.fromList(
            [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xa0004000])),
      );
      expect(
        goldAttacks(s(255), Side.gote),
        equals(SquareSet.fromList(
            [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x40008000])),
      );
    });

    test('rook attacks', () {
      expect(
        rookAttacks(s(0), SquareSet.empty),
        equals(SquareSet.fromList([
          0x1fffe,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001
        ])),
      );
      expect(
        rookAttacks(s(1), SquareSet.empty),
        equals(SquareSet.fromList([
          0x2fffd,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002
        ])),
      );
      expect(
        rookAttacks(s(14), SquareSet.empty),
        equals(SquareSet.fromList([
          0x4000bfff,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000
        ])),
      );
      expect(
        rookAttacks(s(15), SquareSet.empty),
        equals(SquareSet.fromList([
          0x80007fff,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000
        ])),
      );
      expect(
        rookAttacks(s(42), SquareSet.empty),
        equals(SquareSet.fromList([
          0x4000400,
          0x400fbff,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400
        ])),
      );
      expect(
        rookAttacks(s(240), SquareSet.empty),
        equals(SquareSet.fromList([
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0xfffe0001
        ])),
      );
      expect(
        rookAttacks(s(241), SquareSet.empty),
        equals(SquareSet.fromList([
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0xfffd0002
        ])),
      );
      expect(
        rookAttacks(s(254), SquareSet.empty),
        equals(SquareSet.fromList([
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0xbfff4000
        ])),
      );
      expect(
        rookAttacks(s(255), SquareSet.empty),
        equals(SquareSet.fromList([
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x7fff8000
        ])),
      );

      expect(
        rookAttacks(
            s(42),
            SquareSet.fromList(
                [0xa000000, 0xa000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
        equals(SquareSet.fromList([
          0x4000400,
          0x400fbff,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400
        ])),
      );
      expect(
        rookAttacks(
            s(42),
            SquareSet.fromList(
                [0x4000000, 0x4000a00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
        equals(SquareSet.fromList(
            [0x4000000, 0x4000a00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        rookAttacks(s(42),
            SquareSet.fromList([0x0, 0x4000a00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
        equals(SquareSet.fromList(
            [0x4000400, 0x4000a00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
    });

    test('bishop attacks', () {
      expect(
        bishopAttacks(s(0), SquareSet.empty),
        equals(SquareSet.fromList([
          0x20000,
          0x80004,
          0x200010,
          0x800040,
          0x2000100,
          0x8000400,
          0x20001000,
          0x80004000
        ])),
      );
      expect(
        bishopAttacks(s(1), SquareSet.empty),
        equals(SquareSet.fromList([
          0x50000,
          0x100008,
          0x400020,
          0x1000080,
          0x4000200,
          0x10000800,
          0x40002000,
          0x8000
        ])),
      );
      expect(
        bishopAttacks(s(14), SquareSet.empty),
        equals(SquareSet.fromList([
          0xa0000000,
          0x8001000,
          0x2000400,
          0x800100,
          0x200040,
          0x80010,
          0x20004,
          0x1
        ])),
      );
      expect(
        bishopAttacks(s(15), SquareSet.empty),
        equals(SquareSet.fromList([
          0x40000000,
          0x10002000,
          0x4000800,
          0x1000200,
          0x400080,
          0x100020,
          0x40008,
          0x10002
        ])),
      );
      expect(
        bishopAttacks(s(42), SquareSet.empty),
        equals(SquareSet.fromList([
          0xa001100,
          0xa000000,
          0x20801100,
          0x80204040,
          0x80010,
          0x20004,
          0x1,
          0x0
        ])),
      );
      expect(
        bishopAttacks(s(240), SquareSet.empty),
        equals(SquareSet.fromList([
          0x40008000,
          0x10002000,
          0x4000800,
          0x1000200,
          0x400080,
          0x100020,
          0x40008,
          0x2
        ])),
      );
      expect(
        bishopAttacks(s(241), SquareSet.empty),
        equals(SquareSet.fromList([
          0x80000000,
          0x20004000,
          0x8001000,
          0x2000400,
          0x800100,
          0x200040,
          0x80010,
          0x5
        ])),
      );
      expect(
        bishopAttacks(s(254), SquareSet.empty),
        equals(SquareSet.fromList([
          0x10000,
          0x40002,
          0x100008,
          0x400020,
          0x1000080,
          0x4000200,
          0x10000800,
          0xa000
        ])),
      );
      expect(
        bishopAttacks(s(255), SquareSet.empty),
        equals(SquareSet.fromList([
          0x20001,
          0x80004,
          0x200010,
          0x800040,
          0x2000100,
          0x8000400,
          0x20001000,
          0x4000
        ])),
      );

      expect(
        bishopAttacks(
            s(42),
            SquareSet.fromList(
                [0x4000000, 0x4000a00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
        equals(SquareSet.fromList([
          0xa001100,
          0xa000000,
          0x20801100,
          0x80204040,
          0x80010,
          0x20004,
          0x1,
          0x0
        ])),
      );
      expect(
        bishopAttacks(
            s(42),
            SquareSet.fromList(
                [0xa000000, 0xa000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
        equals(SquareSet.fromList(
            [0xa000000, 0xa000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        bishopAttacks(
            s(42),
            SquareSet.fromList(
                [0x8000000, 0xa000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
        equals(SquareSet.fromList(
            [0xa000100, 0xa000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
    });

    test('king attacks', () {
      expect(
          kingAttacks(s(0)),
          equals(SquareSet.fromList(
              [0x30002, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])));
      expect(
          kingAttacks(s(1)),
          equals(SquareSet.fromList(
              [0x70005, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])));
      expect(
          kingAttacks(s(14)),
          equals(SquareSet.fromList(
              [0xe000a000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])));
      expect(
          kingAttacks(s(15)),
          equals(SquareSet.fromList(
              [0xc0004000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])));
      expect(
          kingAttacks(s(42)),
          equals(SquareSet.fromList(
              [0xe000000, 0xe000a00, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])));
      expect(
          kingAttacks(s(240)),
          equals(SquareSet.fromList(
              [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x20003])));
      expect(
          kingAttacks(s(241)),
          equals(SquareSet.fromList(
              [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x50007])));
      expect(
          kingAttacks(s(254)),
          equals(SquareSet.fromList(
              [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xa000e000])));
      expect(
          kingAttacks(s(255)),
          equals(SquareSet.fromList(
              [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x4000c000])));
    });

    test('dragon attacks', () {
      expect(
        dragonAttacks(s(0), SquareSet.empty),
        equals(SquareSet.fromList([
          0x3fffe,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001
        ])),
      );
      expect(
        dragonAttacks(s(1), SquareSet.empty),
        equals(SquareSet.fromList([
          0x7fffd,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002
        ])),
      );
      expect(
        dragonAttacks(s(14), SquareSet.empty),
        equals(SquareSet.fromList([
          0xe000bfff,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000
        ])),
      );
      expect(
        dragonAttacks(s(15), SquareSet.empty),
        equals(SquareSet.fromList([
          0xc0007fff,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000
        ])),
      );
      expect(
        dragonAttacks(s(42), SquareSet.empty),
        equals(SquareSet.fromList([
          0xe000400,
          0xe00fbff,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400,
          0x4000400
        ])),
      );
      expect(
        dragonAttacks(s(240), SquareSet.empty),
        equals(SquareSet.fromList([
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0x10001,
          0xfffe0003
        ])),
      );
      expect(
        dragonAttacks(s(241), SquareSet.empty),
        equals(SquareSet.fromList([
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0x20002,
          0xfffd0007
        ])),
      );
      expect(
        dragonAttacks(s(254), SquareSet.empty),
        equals(SquareSet.fromList([
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0x40004000,
          0xbfffe000
        ])),
      );
      expect(
        dragonAttacks(s(255), SquareSet.empty),
        equals(SquareSet.fromList([
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x80008000,
          0x7fffc000
        ])),
      );
    });

    test('horse attacks', () {
      expect(
        horseAttacks(s(0), SquareSet.empty),
        equals(SquareSet.fromList([
          0x30002,
          0x80004,
          0x200010,
          0x800040,
          0x2000100,
          0x8000400,
          0x20001000,
          0x80004000
        ])),
      );
      expect(
        horseAttacks(s(1), SquareSet.empty),
        equals(SquareSet.fromList([
          0x70005,
          0x100008,
          0x400020,
          0x1000080,
          0x4000200,
          0x10000800,
          0x40002000,
          0x8000
        ])),
      );
      expect(
        horseAttacks(s(14), SquareSet.empty),
        equals(SquareSet.fromList([
          0xe000a000,
          0x8001000,
          0x2000400,
          0x800100,
          0x200040,
          0x80010,
          0x20004,
          0x1
        ])),
      );
      expect(
        horseAttacks(s(15), SquareSet.empty),
        equals(SquareSet.fromList([
          0xc0004000,
          0x10002000,
          0x4000800,
          0x1000200,
          0x400080,
          0x100020,
          0x40008,
          0x10002
        ])),
      );
      expect(
        horseAttacks(s(42), SquareSet.empty),
        equals(SquareSet.fromList([
          0xe001100,
          0xe000a00,
          0x20801100,
          0x80204040,
          0x80010,
          0x20004,
          0x1,
          0x0
        ])),
      );
      expect(
        horseAttacks(s(240), SquareSet.empty),
        equals(SquareSet.fromList([
          0x40008000,
          0x10002000,
          0x4000800,
          0x1000200,
          0x400080,
          0x100020,
          0x40008,
          0x20003
        ])),
      );
      expect(
        horseAttacks(s(241), SquareSet.empty),
        equals(SquareSet.fromList([
          0x80000000,
          0x20004000,
          0x8001000,
          0x2000400,
          0x800100,
          0x200040,
          0x80010,
          0x50007
        ])),
      );
      expect(
        horseAttacks(s(254), SquareSet.empty),
        equals(SquareSet.fromList([
          0x10000,
          0x40002,
          0x100008,
          0x400020,
          0x1000080,
          0x4000200,
          0x10000800,
          0xa000e000
        ])),
      );
      expect(
        horseAttacks(s(255), SquareSet.empty),
        equals(SquareSet.fromList([
          0x20001,
          0x80004,
          0x200010,
          0x800040,
          0x2000100,
          0x8000400,
          0x20001000,
          0x4000c000
        ])),
      );
    });

    test('chushogi pieces', () {
      expect(
        attacks(const Piece(role: Role.leopard, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x1c000000, 0x1c000000, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.copper, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x1c000000, 0x8000000, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.elephant, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x1c000000, 0x14001400, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.chariot, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x8000800,
          0x8000800,
          0x8000000,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800
        ])),
      );
      expect(
        attacks(const Piece(role: Role.tiger, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x14000000, 0x1c001400, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.phoenix, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x8002200, 0x8001400, 0x2200, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.kirin, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x14000800, 0x14002200, 0x800, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.sidemover, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x8000000, 0x800f7ff, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.verticalmover, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x8000800,
          0x8000800,
          0x8001400,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800
        ])),
      );
      expect(
        attacks(const Piece(role: Role.queen, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x49008880,
          0x1c002a00,
          0x1c00f7ff,
          0x49002a00,
          0x8408880,
          0x8100820,
          0x8040808,
          0x8010802
        ])),
      );
      expect(
        attacks(const Piece(role: Role.lion, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x3e003e00, 0x3e003600, 0x3e00, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.gobetween, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x8000000, 0x8000000, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.promotedpawn, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x1c000000, 0x8001400, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.ox, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x49008880,
          0x1c002a00,
          0x1c000000,
          0x49002a00,
          0x8408880,
          0x8100820,
          0x8040808,
          0x8010802
        ])),
      );
      expect(
        attacks(const Piece(role: Role.stag, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x8000800,
          0x1c000800,
          0x1c001400,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800
        ])),
      );
      expect(
        attacks(const Piece(role: Role.boar, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x41008080,
          0x14002200,
          0x1400f7ff,
          0x41002200,
          0x408080,
          0x100020,
          0x40008,
          0x10002
        ])),
      );
      expect(
        attacks(const Piece(role: Role.falcon, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x41008080,
          0x1c002a00,
          0x1c00f7ff,
          0x49002a00,
          0x8408880,
          0x8100820,
          0x8040808,
          0x8010802
        ])),
      );
      expect(
        attacks(const Piece(role: Role.prince, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x1c000000, 0x1c001400, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.eagle, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x8000800,
          0x1c002a00,
          0x1c00f7ff,
          0x49002a00,
          0x8408880,
          0x8100820,
          0x8040808,
          0x8010802
        ])),
      );
      expect(
        attacks(const Piece(role: Role.whale, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x8000800,
          0x8000800,
          0x1c000000,
          0x49002a00,
          0x8408880,
          0x8100820,
          0x8040808,
          0x8010802
        ])),
      );
      expect(
        attacks(const Piece(role: Role.whitehorse, side: Side.sente), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x49008880,
          0x1c002a00,
          0x8000000,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800
        ])),
      );

      // Gote tests
      expect(
        attacks(const Piece(role: Role.copper, side: Side.gote), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x8000000, 0x1c000000, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.elephant, side: Side.gote), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x14000000, 0x1c001400, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.tiger, side: Side.gote), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x1c000000, 0x14001400, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.promotedpawn, side: Side.gote), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList(
            [0x0, 0x8000000, 0x1c001400, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        attacks(const Piece(role: Role.falcon, side: Side.gote), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x49008880,
          0x1c002a00,
          0x1c00f7ff,
          0x41002a00,
          0x408080,
          0x100020,
          0x40008,
          0x10002
        ])),
      );
      expect(
        attacks(const Piece(role: Role.eagle, side: Side.gote), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x49008880,
          0x1c002a00,
          0x1c00f7ff,
          0x8002a00,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800
        ])),
      );
      expect(
        attacks(const Piece(role: Role.whale, side: Side.gote), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x49008880,
          0x1c002a00,
          0x8000000,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800,
          0x8000800
        ])),
      );
      expect(
        attacks(const Piece(role: Role.whitehorse, side: Side.gote), s(75),
            SquareSet.empty),
        equals(SquareSet.fromList([
          0x8000800,
          0x8000800,
          0x1c000000,
          0x49002a00,
          0x8408880,
          0x8100820,
          0x8040808,
          0x8010802
        ])),
      );
    });
  });
}
