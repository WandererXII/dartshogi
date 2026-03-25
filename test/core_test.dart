import 'package:dartshogi/src/core/file.dart';
import 'package:dartshogi/src/core/move_drop.dart';
import 'package:dartshogi/src/core/rank.dart';
import 'package:dartshogi/src/core/role.dart';
import 'package:dartshogi/src/core/square.dart';
import 'package:test/test.dart';

void main() {
  group('File', () {
    test('equals', () {
      expect(File.file1, 0);
    });
    test('File.values', () {
      expect(File.values.length, 16);
    });

    test('offset', () {
      expect(File.file1.offset(1), File.file2);
      expect(File.file16.offset(-1), File.file15);
      expect(File.file16.offset(1), null);
    });
  });

  group('Rank', () {
    test('Rank.values', () {
      expect(Rank.values.length, 16);
    });

    test('offset', () {
      expect(Rank.rankA.offset(1), Rank.rankB);
      expect(Rank.rankP.offset(-1), Rank.rankO);
      expect(Rank.rankP.offset(1), null);
    });
  });

  group('Square', () {
    test('fromCoords', () {
      expect(Square.fromCoords(const File(0), const Rank(0)), Square.parse('1a'));
      expect(Square.fromCoords(const File(2), const Rank(5)), Square.parse('3f'));
      expect(Square.fromCoords(const File(15), const Rank(15)), Square.parse('16p'));
    });

    test('parse', () {
      expect(Square.parse('1a'), const Square(0));
      expect(Square.parse('16a'), const Square(15));
      expect(Square.parse('1b'), const Square(16));
      expect(Square.parse('1c'), const Square(32));
      expect(Square.parse('3c'), const Square(34));
      expect(Square.parse('16o'), const Square(239));
      expect(Square.parse('1p'), const Square(240));
      expect(Square.parse('16p'), const Square(255));
      expect(Square.parse('1q'), isNull);
      expect(Square.parse('17a'), isNull);
      expect(Square.parse('0c'), isNull);
    });

    test('offset', () {
      expect(Square.parse('1a')!.offset(16), Square.parse('1b'));
      expect(Square.parse('16p')!.offset(-16), Square.parse('16o'));
      expect(Square.parse('1a')!.offset(-1), null);
      expect(Square.parse('16p')!.offset(1), null);
    });

    test('name', () {
      expect(Square.parse('1a')!.name, '1a');
      expect(Square.parse('16p')!.name, '16p');
    });
  });

  group('Move', () {
    test('parse', () {
      expect(
          MoveOrDrop.parse('1a1b'), NormalMove(from: Square.parse('1a')!, to: Square.parse('1b')!));
      expect(MoveOrDrop.parse('7g7f+'),
          NormalMove(from: Square.parse('7g')!, to: Square.parse('7f')!, promotion: true));
      expect(MoveOrDrop.parse('P*3c'), DropMove(role: Role.pawn, to: Square.parse('3c')!));
    });

    test('usi', () {
      expect(DropMove(role: Role.bishop, to: Square.parse('3c')!).usi, 'B*3c');
      expect(NormalMove(from: Square.parse('7g')!, to: Square.parse('7f')!).usi, '7g7f');
      expect(NormalMove(from: Square.parse('7g')!, to: Square.parse('7f')!, promotion: true).usi,
          '7g7f+');
      expect(
          NormalMove(
                  from: Square.parse('7g')!,
                  midStep: Square.parse('7f'),
                  to: Square.parse('7g')!,
                  promotion: true)
              .usi,
          '7g7f7g+');
    });
  });
}
