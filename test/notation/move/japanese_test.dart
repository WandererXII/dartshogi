import 'package:dartshogi/src/core/move_drop.dart';
import 'package:dartshogi/src/core/rule.dart';
import 'package:dartshogi/src/notation/move/japanese.dart';
import 'package:dartshogi/src/sfen.dart';
import 'package:test/test.dart';

void main() {
  test('basic moves', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    final move = MoveOrDrop.parse('7g7f')!;
    expect(makeJapaneseMoveOrDrop(pos, move), equals('７六歩'));
    expect(
      makeJapaneseMoveOrDrop(
        pos.playUnchecked(move),
        MoveOrDrop.parse('3c3d')!,
      ),
      equals('３四歩'),
    );
  });

  test('correct drop amb resolution', () {
    final pos =
        parseSfen(Rule.shogi, 'k7K/9/9/9/9/9/S8/8g/9 b SPg 1').getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('S*9f')!),
      equals('９六銀打'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('S*5e')!),
      equals('５五銀'),
    );
    final pos2 = pos.playUnchecked(MoveOrDrop.parse('S*9f')!);
    expect(
      makeJapaneseMoveOrDrop(pos2, MoveOrDrop.parse('G*1g')!),
      equals('１七金打'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos2, MoveOrDrop.parse('G*5e')!),
      equals('５五金'),
    );
  });

  test('correct move amb resolution', () {
    final pos =
        parseSfen(Rule.shogi, 'k7K/9/9/9/9/9/2G6/3G5/2G6 b - 1').getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('7g7h')!),
      equals('７八金引'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('6h7h')!),
      equals('７八金寄'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('7i7h')!),
      equals('７八金上'),
    );

    final pos2 =
        parseSfen(Rule.shogi, '3k1K3/9/9/5B3/9/9/9/1B7/9 b - 1').getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos2, MoveOrDrop.parse('4d6f')!),
      equals('６六角引'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos2, MoveOrDrop.parse('8h6f')!),
      equals('６六角上'),
    );

    final pos3 =
        parseSfen(
          Rule.shogi,
          '3k1K3/9/9/3S1S3/9/3S1S3/9/9/9 b - 1',
        ).getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos3, MoveOrDrop.parse('4d5e')!),
      equals('５五銀右引'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos3, MoveOrDrop.parse('4f5e')!),
      equals('５五銀右上'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos3, MoveOrDrop.parse('6d5e')!),
      equals('５五銀左引'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos3, MoveOrDrop.parse('6f5e')!),
      equals('５五銀左上'),
    );

    final pos4 =
        parseSfen(Rule.shogi, '3k1K3/9/9/9/9/3GGG3/9/9/9 b - 1').getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos4, MoveOrDrop.parse('4f5e')!),
      equals('５五金右'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos4, MoveOrDrop.parse('5f5e')!),
      equals('５五金直'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos4, MoveOrDrop.parse('6f5e')!),
      equals('５五金左'),
    );

    final pos5 =
        parseSfen(Rule.shogi, '3k1K3/9/9/9/9/9/3+B+B4/9/9 b - 1').getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos5, MoveOrDrop.parse('6g5f')!),
      equals('５六馬左'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos5, MoveOrDrop.parse('5g5f')!),
      equals('５六馬右'),
    );
  });

  test('correct move amb resolution - gote pov', () {
    final pos =
        parseSfen(Rule.shogi, 'k7K/9/9/9/9/9/2g6/3g5/2g6 w - 1').getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('7g7h')!),
      equals('７八金上'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('6h7h')!),
      equals('７八金寄'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('7i7h')!),
      equals('７八金引'),
    );

    final pos2 =
        parseSfen(Rule.shogi, '3k1K3/9/9/5b3/9/9/9/1b7/9 w - 1').getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos2, MoveOrDrop.parse('4d6f')!),
      equals('６六角上'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos2, MoveOrDrop.parse('8h6f')!),
      equals('６六角引不成'),
    );

    final pos3 =
        parseSfen(
          Rule.shogi,
          '3k1K3/9/9/3s1s3/9/3s1s3/9/9/9 w - 1',
        ).getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos3, MoveOrDrop.parse('4d5e')!),
      equals('５五銀左上'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos3, MoveOrDrop.parse('4f5e')!),
      equals('５五銀左引'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos3, MoveOrDrop.parse('6d5e')!),
      equals('５五銀右上'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos3, MoveOrDrop.parse('6f5e')!),
      equals('５五銀右引'),
    );

    final pos4 =
        parseSfen(Rule.shogi, '3k1K3/9/9/9/9/3ggg3/9/9/9 w - 1').getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos4, MoveOrDrop.parse('4f5g')!),
      equals('５七金左'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos4, MoveOrDrop.parse('5f5g')!),
      equals('５七金直'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos4, MoveOrDrop.parse('6f5g')!),
      equals('５七金右'),
    );

    final pos5 =
        parseSfen(Rule.shogi, '3k1K3/9/9/9/9/9/3+b+b4/9/9 w - 1').getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos5, MoveOrDrop.parse('6g5f')!),
      equals('５六馬右'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos5, MoveOrDrop.parse('5g5f')!),
      equals('５六馬左'),
    );
  });

  test('中 amb resolution', () {
    final pos1 =
        parseSfen(
          Rule.shogi,
          '3k1K3/9/9/9/3+B+B+B3/9/3+B+B+B3/9/9 b - 1',
        ).getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos1, MoveOrDrop.parse('4g5f')!),
      equals('５六馬右行'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos1, MoveOrDrop.parse('5g5f')!),
      equals('５六馬中行'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos1, MoveOrDrop.parse('6g5f')!),
      equals('５六馬左行'),
    );

    final pos2 =
        parseSfen(
          Rule.shogi,
          '3k1K3/9/9/9/9/9/3+B+B+B3/9/9 b - 1',
        ).getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos2, MoveOrDrop.parse('4g5f')!),
      equals('５六馬右'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos2, MoveOrDrop.parse('5g5f')!),
      equals('５六馬中'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos2, MoveOrDrop.parse('6g5f')!),
      equals('５六馬左'),
    );
  });

  test('annanshogi resolution', () {
    final pos1 =
        parseSfen(
          Rule.annanshogi,
          '9/k8/9/9/9/5GGG1/5G1G1/5N1N1/K8 b - 1',
        ).getOrThrow();
    expect(
      makeJapaneseMoveOrDrop(pos1, MoveOrDrop.parse('2f3e')!),
      equals('３五金右上'),
    );
    expect(
      makeJapaneseMoveOrDrop(pos1, MoveOrDrop.parse('2g3e')!),
      equals('３五金右跳'),
    );
  });

  test(
    'illegal moves disambiguation - (https://github.com/WandererXII/lishogi/issues/874)',
    () {
      final pos =
          parseSfen(
            Rule.shogi,
            '5l3/3S3S1/2b6/4GS3/2r1GK1G1/3G1S2G/9/3S3S1/5r3 b - 1',
          ).getOrThrow();
      expect(
        makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('6b5c')!),
        equals('５三銀引不成'),
      );
      expect(
        makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('6b5c+')!),
        equals('５三銀引成'),
      );
      expect(
        makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('2b3c')!),
        equals('３三銀引不成'),
      );
      expect(
        makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('2b3c+')!),
        equals('３三銀引成'),
      );
      expect(
        makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('5d6d')!),
        equals('６四金寄'),
      );
      expect(
        makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('6f5f')!),
        equals('５六金寄'),
      );
      expect(
        makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('6h5g')!),
        equals('５七銀上'),
      );
      expect(
        makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('2h3g')!),
        equals('３七銀上'),
      );
      expect(
        makeJapaneseMoveOrDrop(pos, MoveOrDrop.parse('1f1e')!),
        equals('１五金上'),
      );
    },
  );
}
