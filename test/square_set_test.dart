import 'package:dartshogi/src/square_set.dart';
import 'package:test/test.dart';

void main() {
  group('SquareSet', () {
    test('full set has all', () {
      for (int square = 0; square < 256; square++) {
        expect(SquareSet.full.has(square), isTrue);
      }
    });

    test('empty set has none', () {
      for (int square = 0; square < 256; square++) {
        expect(SquareSet.empty.has(square), isFalse);
      }
    });

    test('immutable', () {
      final arr = [0xffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0];
      final n = SquareSet.fromList(arr);
      arr[0] = 0;
      arr[2] = 7;
      expect(
        n,
        equals(SquareSet.fromList([0xffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );

      final n2 = SquareSet.fromList(arr);
      expect(n2, isNot(equals(n)));
    });

    test('fromSquare', () {
      for (int square = 0; square < 256; square++) {
        expect(
          SquareSet.empty.withSquare(square),
          equals(SquareSet.fromSquare(square)),
        );
      }
    });

    test('fromSquares', () {
      expect(SquareSet.fromSquares([]), equals(SquareSet.empty));
      expect(
        SquareSet.fromSquares([-1, -2, 256, 257]),
        equals(SquareSet.empty),
      );
      expect(
        SquareSet.fromSquares([128]),
        equals(SquareSet.empty.withSquare(128)),
      );
      expect(
        SquareSet.fromSquares(List.generate(256, (i) => i)),
        equals(SquareSet.full),
      );
    });

    test('fromRank', () {
      expect(
        SquareSet.fromRank(0),
        equals(SquareSet.fromList([0xffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        SquareSet.fromRank(1),
        equals(
          SquareSet.fromList([0xffff0000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]),
        ),
      );
      expect(
        SquareSet.fromRank(2),
        equals(SquareSet.fromList([0x0, 0xffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        SquareSet.fromRank(3),
        equals(
          SquareSet.fromList([0x0, 0xffff0000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]),
        ),
      );
      expect(
        SquareSet.fromRank(4),
        equals(SquareSet.fromList([0x0, 0x0, 0xffff, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        SquareSet.fromRank(5),
        equals(
          SquareSet.fromList([0x0, 0x0, 0xffff0000, 0x0, 0x0, 0x0, 0x0, 0x0]),
        ),
      );
      expect(
        SquareSet.fromRank(6),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0xffff, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        SquareSet.fromRank(7),
        equals(
          SquareSet.fromList([0x0, 0x0, 0x0, 0xffff0000, 0x0, 0x0, 0x0, 0x0]),
        ),
      );
      expect(
        SquareSet.fromRank(8),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0xffff, 0x0, 0x0, 0x0])),
      );
      expect(
        SquareSet.fromRank(9),
        equals(
          SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0xffff0000, 0x0, 0x0, 0x0]),
        ),
      );
      expect(
        SquareSet.fromRank(10),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0xffff, 0x0, 0x0])),
      );
      expect(
        SquareSet.fromRank(11),
        equals(
          SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0xffff0000, 0x0, 0x0]),
        ),
      );
      expect(
        SquareSet.fromRank(12),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffff, 0x0])),
      );
      expect(
        SquareSet.fromRank(13),
        equals(
          SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffff0000, 0x0]),
        ),
      );
      expect(
        SquareSet.fromRank(14),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffff])),
      );
      expect(
        SquareSet.fromRank(15),
        equals(
          SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffff0000]),
        ),
      );
    });

    test('fromFile', () {
      expect(
        SquareSet.fromFile(0),
        equals(
          SquareSet.fromList([
            0x10001,
            0x10001,
            0x10001,
            0x10001,
            0x10001,
            0x10001,
            0x10001,
            0x10001,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(1),
        equals(
          SquareSet.fromList([
            0x20002,
            0x20002,
            0x20002,
            0x20002,
            0x20002,
            0x20002,
            0x20002,
            0x20002,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(2),
        equals(
          SquareSet.fromList([
            0x40004,
            0x40004,
            0x40004,
            0x40004,
            0x40004,
            0x40004,
            0x40004,
            0x40004,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(3),
        equals(
          SquareSet.fromList([
            0x80008,
            0x80008,
            0x80008,
            0x80008,
            0x80008,
            0x80008,
            0x80008,
            0x80008,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(4),
        equals(
          SquareSet.fromList([
            0x100010,
            0x100010,
            0x100010,
            0x100010,
            0x100010,
            0x100010,
            0x100010,
            0x100010,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(5),
        equals(
          SquareSet.fromList([
            0x200020,
            0x200020,
            0x200020,
            0x200020,
            0x200020,
            0x200020,
            0x200020,
            0x200020,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(6),
        equals(
          SquareSet.fromList([
            0x400040,
            0x400040,
            0x400040,
            0x400040,
            0x400040,
            0x400040,
            0x400040,
            0x400040,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(7),
        equals(
          SquareSet.fromList([
            0x800080,
            0x800080,
            0x800080,
            0x800080,
            0x800080,
            0x800080,
            0x800080,
            0x800080,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(8),
        equals(
          SquareSet.fromList([
            0x1000100,
            0x1000100,
            0x1000100,
            0x1000100,
            0x1000100,
            0x1000100,
            0x1000100,
            0x1000100,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(9),
        equals(
          SquareSet.fromList([
            0x2000200,
            0x2000200,
            0x2000200,
            0x2000200,
            0x2000200,
            0x2000200,
            0x2000200,
            0x2000200,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(10),
        equals(
          SquareSet.fromList([
            0x4000400,
            0x4000400,
            0x4000400,
            0x4000400,
            0x4000400,
            0x4000400,
            0x4000400,
            0x4000400,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(11),
        equals(
          SquareSet.fromList([
            0x8000800,
            0x8000800,
            0x8000800,
            0x8000800,
            0x8000800,
            0x8000800,
            0x8000800,
            0x8000800,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(12),
        equals(
          SquareSet.fromList([
            0x10001000,
            0x10001000,
            0x10001000,
            0x10001000,
            0x10001000,
            0x10001000,
            0x10001000,
            0x10001000,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(13),
        equals(
          SquareSet.fromList([
            0x20002000,
            0x20002000,
            0x20002000,
            0x20002000,
            0x20002000,
            0x20002000,
            0x20002000,
            0x20002000,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(14),
        equals(
          SquareSet.fromList([
            0x40004000,
            0x40004000,
            0x40004000,
            0x40004000,
            0x40004000,
            0x40004000,
            0x40004000,
            0x40004000,
          ]),
        ),
      );
      expect(
        SquareSet.fromFile(15),
        equals(
          SquareSet.fromList([
            0x80008000,
            0x80008000,
            0x80008000,
            0x80008000,
            0x80008000,
            0x80008000,
            0x80008000,
            0x80008000,
          ]),
        ),
      );
    });

    test('ranksAbove', () {
      expect(
        SquareSet.ranksAbove(0),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        SquareSet.ranksAbove(1),
        equals(SquareSet.fromList([0xffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
      expect(
        SquareSet.ranksAbove(2),
        equals(
          SquareSet.fromList([0xffffffff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]),
        ),
      );
      expect(
        SquareSet.ranksAbove(3),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffff,
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(4),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(5),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffff,
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(6),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(7),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffff,
            0x0,
            0x0,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(8),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0x0,
            0x0,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(9),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffff,
            0x0,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(10),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0x0,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(11),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffff,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(12),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0x0,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(13),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffff,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(14),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0x0,
          ]),
        ),
      );
      expect(
        SquareSet.ranksAbove(15),
        equals(
          SquareSet.fromList([
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffff,
          ]),
        ),
      );
    });

    test('ranksBelow', () {
      expect(
        SquareSet.ranksBelow(0),
        equals(
          SquareSet.fromList([
            0xffff0000,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(1),
        equals(
          SquareSet.fromList([
            0x0,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(2),
        equals(
          SquareSet.fromList([
            0x0,
            0xffff0000,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(3),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(4),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0xffff0000,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(5),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0x0,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(6),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0x0,
            0xffff0000,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(7),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0x0,
            0x0,
            0xffffffff,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(8),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0x0,
            0x0,
            0xffff0000,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(9),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
            0xffffffff,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(10),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
            0xffff0000,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(11),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
            0xffffffff,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(12),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
            0x0,
            0xffff0000,
            0xffffffff,
          ]),
        ),
      );
      expect(
        SquareSet.ranksBelow(13),
        equals(
          SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffffffff]),
        ),
      );
      expect(
        SquareSet.ranksBelow(14),
        equals(
          SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffff0000]),
        ),
      );
      expect(
        SquareSet.ranksBelow(15),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])),
      );
    });

    test('logical operators', () {
      expect(SquareSet.empty.complement(), equals(SquareSet.full));
      expect(SquareSet.full.complement(), equals(SquareSet.empty));
      expect(SquareSet.full.xor(SquareSet.empty), equals(SquareSet.full));
      expect(SquareSet.full.xor(SquareSet.full), equals(SquareSet.empty));
      expect(SquareSet.full.union(SquareSet.empty), equals(SquareSet.full));
      expect(SquareSet.full.intersect(SquareSet.full), equals(SquareSet.full));
      expect(
        SquareSet.full.intersect(SquareSet.empty),
        equals(SquareSet.empty),
      );

      for (int square = 0; square < 256; square++) {
        expect(
          SquareSet.full.intersect(SquareSet.fromSquare(square)),
          equals(SquareSet.full.withoutSquare(square).xor(SquareSet.full)),
        );
      }
    });

    test('shr256', () {
      final r = SquareSet.fromList([
        0x180,
        0x180,
        0x180,
        0x0,
        0x0,
        0x180,
        0x180,
        0x180,
      ]);
      expect(r.shr256(0), equals(r));
      expect(
        r.shr256(1),
        equals(
          SquareSet.fromList([0xc0, 0xc0, 0xc0, 0x0, 0x0, 0xc0, 0xc0, 0xc0]),
        ),
      );

      final bigS = SquareSet.fromList([
        0x42003c0,
        0x8100810,
        0x4000800,
        0x1000200,
        0x400080,
        0x100020,
        0x8100010,
        0x3c00420,
      ]);
      expect(
        bigS.shr256(32),
        equals(
          SquareSet.fromList([
            0x8100810,
            0x4000800,
            0x1000200,
            0x400080,
            0x100020,
            0x8100010,
            0x3c00420,
            0x0,
          ]),
        ),
      );

      final s = SquareSet.fromList([
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x80000000,
      ]);
      for (int i = 0; i < 256; i++) {
        expect(s.shr256(i), equals(SquareSet.empty.withSquare(255 - i)));
      }
    });

    test('shl256', () {
      final r = SquareSet.fromList([
        0x180,
        0x180,
        0x180,
        0x0,
        0x0,
        0x180,
        0x180,
        0x180,
      ]);
      expect(r.shl256(0), equals(r));
      expect(
        r.shl256(1),
        equals(
          SquareSet.fromList([
            0x300,
            0x300,
            0x300,
            0x0,
            0x0,
            0x300,
            0x300,
            0x300,
          ]),
        ),
      );

      expect(
        SquareSet.fromList([
          0x1,
          0x8000,
          0x10000,
          0x80000000,
          0x0,
          0x0,
          0x0,
          0x80000000,
        ]).shl256(1),
        equals(
          SquareSet.fromList([0x2, 0x10000, 0x20000, 0x0, 0x1, 0x0, 0x0, 0x0]),
        ),
      );

      final bigS = SquareSet.fromList([
        0x42003c0,
        0x8100810,
        0x4000800,
        0x1000200,
        0x400080,
        0x100020,
        0x8100010,
        0x3c00420,
      ]);

      expect(
        bigS.shl256(1),
        equals(
          SquareSet.fromList([
            0x8400780,
            0x10201020,
            0x8001000,
            0x2000400,
            0x800100,
            0x200040,
            0x10200020,
            0x7800840,
          ]),
        ),
      );
      expect(
        bigS.shl256(32),
        equals(
          SquareSet.fromList([
            0x0,
            0x42003c0,
            0x8100810,
            0x4000800,
            0x1000200,
            0x400080,
            0x100020,
            0x8100010,
          ]),
        ),
      );
      expect(bigS.shl256(255), equals(SquareSet.empty));

      final s = SquareSet.fromList([0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);
      for (int i = 0; i < 256; i++) {
        expect(s.shl256(i), equals(SquareSet.empty.withSquare(i)));
      }
    });

    test('rowswap', () {
      expect(SquareSet.full.rowSwap256(), equals(SquareSet.full));
      expect(SquareSet.empty.rowSwap256(), equals(SquareSet.empty));
      expect(
        SquareSet.fromList([
          0xffff,
          0xffff0000,
          0x0,
          0xf000,
          0x0,
          0x0,
          0x0,
          0x0,
        ]).rowSwap256(),
        equals(
          SquareSet.fromList([
            0x0,
            0x0,
            0x0,
            0x0,
            0xf0000000,
            0x0,
            0xffff,
            0xffff0000,
          ]),
        ),
      );
    });

    test('rbit256', () {
      expect(SquareSet.full.rbit256(), equals(SquareSet.full));
      expect(SquareSet.empty.rbit256(), equals(SquareSet.empty));

      final random1 = [
        0xc8866bcd,
        0x1ec29f93,
        0xf5ddebe3,
        0x8f0ada65,
        0x373d2c52,
        0xa6a16ef5,
        0x8d1f9954,
        0x4ab3e8c7,
      ];
      final reversed1 =
          random1.reversed.map((n) {
            final binary = n.toRadixString(2).padLeft(32, '0');
            final reversedBinary = binary.split('').reversed.join('');
            return int.parse(reversedBinary, radix: 2);
          }).toList();
      expect(
        SquareSet.fromList(random1).rbit256(),
        equals(SquareSet.fromList(reversed1)),
      );

      final random2 = [
        0x83b5bee6,
        0x19bf9b6c,
        0x0e6c109c,
        0x6d21e29b,
        0x95cc034c,
        0x5b8e8497,
        0xe2758b39,
        0xfa201e44,
      ];
      final reversed2 =
          random2.reversed.map((n) {
            final binary = n.toRadixString(2).padLeft(32, '0');
            final reversedBinary = binary.split('').reversed.join('');
            return int.parse(reversedBinary, radix: 2);
          }).toList();
      expect(
        SquareSet.fromList(random2).rbit256(),
        equals(SquareSet.fromList(reversed2)),
      );
    });

    test('minus256', () {
      final s1 = SquareSet.fromList([
        0xc8866bcd,
        0x1ec29f93,
        0xf5ddebe3,
        0,
        0,
        0,
        0,
        0,
      ]);
      final s2 = SquareSet.fromList([
        0x83b5bee6,
        0x19bf9b6c,
        0x0e6c109c,
        0,
        0,
        0,
        0,
        0,
      ]);
      final res = SquareSet.fromList([
        0x44d0ace7,
        0x05030427,
        0xe771db47,
        0,
        0,
        0,
        0,
        0,
      ]);
      expect(s1.minus256(s2), equals(res));

      final t1 = SquareSet.fromList([
        0xae7be866,
        0x5c3adbe4,
        0x88f2d2f5,
        0xaf172af7,
        0xe814a99f,
        0x342a0ae6,
        0x84e17eb1,
        0xcde11efa,
      ]);
      final t2 = SquareSet.fromList([
        0x5560d838,
        0xa53e9a7b,
        0xdeafb45d,
        0x9f4b4dc9,
        0x4b3b08a,
        0xec18deef,
        0xb27684b5,
        0xf9bf854f,
      ]);
      final res2 = SquareSet.fromList([
        0x591b102e,
        0xb6fc4169,
        0xaa431e97,
        0x0fcbdd2d,
        0xe360f915,
        0x48112bf7,
        0xd26af9fb,
        0xd42199aa,
      ]);
      expect(t1.minus256(t2), equals(res2));
    });

    test('equals', () {
      expect(
        SquareSet.fromList([3017171219, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]),
        equals(
          SquareSet.fromList([-1277796077, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]),
        ),
      );
    });

    test('size', () {
      var squares = SquareSet.empty;
      expect(squares.size, equals(0));
      expect(squares.isNotEmpty, isFalse);
      expect(squares.isEmpty, isTrue);

      for (int i = 0; i < 256; i++) {
        squares = squares.withSquare(i);
        expect(squares.size, equals(i + 1));
        expect(squares.isEmpty, isFalse);
        expect(squares.isNotEmpty, isTrue);
      }

      for (int i = 255; i >= 0; i--) {
        squares = squares.withoutSquare(i);
        expect(squares.size, equals(i));
      }
    });

    test('with/without many', () {
      expect(
        SquareSet.empty.withMany([0, 1, 2]),
        equals(SquareSet.empty.withSquare(0).withSquare(1).withSquare(2)),
      );
      expect(
        SquareSet.empty.withSquare(0).withSquare(1).withSquare(2).withoutMany([
          0,
          1,
          2,
        ]),
        equals(SquareSet.empty),
      );
      expect(
        SquareSet.full.withoutMany(List.generate(256, (i) => i)),
        equals(SquareSet.empty),
      );
      expect(
        SquareSet.empty.withMany(List.generate(256, (i) => i)),
        equals(SquareSet.full),
      );
    });

    test('first/last', () {
      var squares = SquareSet.empty;
      expect(squares.last(), isNull);

      for (int i = 0; i < 256; i++) {
        squares = squares.withSquare(i);
        expect(squares.first(), equals(0));
        expect(squares.last(), equals(i));
      }

      squares = SquareSet.empty;
      for (int i = 255; i >= 0; i--) {
        squares = squares.withSquare(i);
        expect(squares.first(), equals(i));
        expect(squares.last(), equals(255));
      }
    });

    test('without first', () {
      expect(
        SquareSet.fromList([
          0x08,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x01,
          0x0,
        ]).withoutFirst(),
        equals(SquareSet.fromList([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x01, 0x0])),
      );
      expect(
        SquareSet.fromList([
          0x0,
          0x7,
          0x0,
          0x0,
          0x0,
          0x0,
          0x01,
          0x0,
        ]).withoutFirst(),
        equals(SquareSet.fromList([0x0, 0x6, 0x0, 0x0, 0x0, 0x0, 0x01, 0x0])),
      );
    });

    test('more than one', () {
      expect(
        SquareSet.fromList([0, 0, 0, 0, 0, 0, 0, 0]).moreThanOne(),
        isFalse,
      );

      expect(
        SquareSet.fromList([1, 0, 0, 0, 0, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 1, 0, 0, 0, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 1, 0, 0, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 1, 0, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 0, 1, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 0, 0, 1, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 0, 0, 0, 1, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 0, 0, 0, 0, 1]).moreThanOne(),
        isFalse,
      );

      expect(
        SquareSet.fromList([2, 0, 0, 0, 0, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 4, 0, 0, 0, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 8, 0, 0, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 16, 0, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 0, 2, 0, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 0, 0, 4, 0, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 0, 0, 0, 8, 0]).moreThanOne(),
        isFalse,
      );
      expect(
        SquareSet.fromList([0, 0, 0, 0, 0, 0, 0, 16]).moreThanOne(),
        isFalse,
      );

      expect(
        SquareSet.fromList([1, 0, 0, 0, 1, 0, 0, 0]).moreThanOne(),
        isTrue,
      );
      expect(
        SquareSet.fromList([2, 0, 0, 0, 1, 0, 0, 0]).moreThanOne(),
        isTrue,
      );
      expect(
        SquareSet.fromList([2, 0, 0, 0, 0, 0, 0, 16]).moreThanOne(),
        isTrue,
      );
      expect(
        SquareSet.fromList([7, 0, 0, 0, 0, 0, 0, 1]).moreThanOne(),
        isTrue,
      );
      expect(
        SquareSet.fromList([7, 0, 0, 0, 0, 0, 0, 0]).moreThanOne(),
        isTrue,
      );
      expect(
        SquareSet.fromList([123, 0, 0, 0, 0, 0, 0, 0]).moreThanOne(),
        isTrue,
      );
    });

    test('single square', () {
      expect(
        SquareSet.fromList([
          0x08,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
        ]).isSingleSquare(),
        isTrue,
      );
      expect(
        SquareSet.fromList([
          0x01,
          0x0,
          0x0,
          0x0,
          0x01,
          0x0,
          0x0,
          0x0,
        ]).isSingleSquare(),
        isFalse,
      );
      expect(
        SquareSet.fromList([
          0x07,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
        ]).isSingleSquare(),
        isFalse,
      );
      expect(
        SquareSet.fromList([
          0x01,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
        ]).singleSquare(),
        equals(0),
      );
      expect(
        SquareSet.fromList([
          0x07,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
        ]).singleSquare(),
        isNull,
      );
    });

    test('iterators', () {
      final full = SquareSet.full;
      expect(full.size, equals(256));

      int i = 0;
      for (final s in full.squares) {
        expect(s, equals(i++));
      }

      for (final s in full.squaresReversed) {
        expect(s, equals(--i));
      }
    });
  });
}
