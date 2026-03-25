import 'package:dartshogi/src/core/move_drop.dart';
import 'package:dartshogi/src/core/rule.dart';
import 'package:dartshogi/src/core/square.dart';
import 'package:dartshogi/src/notation/move/yorozuya.dart';
import 'package:dartshogi/src/notation/utils.dart';
import 'package:dartshogi/src/sfen.dart';
import 'package:test/test.dart';

void main() {
  test('basic moves', () {
    final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();
    final move = MoveOrDrop.parse('7g7f')!;
    expect(makeYorozuyaMoveOrDrop(pos, move), equals('午六歩'));
    expect(
      makeYorozuyaMoveOrDrop(
        pos.playUnchecked(move),
        MoveOrDrop.parse('3c3d')!,
      ),
      equals('寅四歩'),
    );
  });

  test('jp conversion', () {
    expect(
      convertJapaneseToYorozuya(makeJapaneseSquare(Square.parse('1l')!)),
      equals('子十二'),
    );
    expect(
      convertJapaneseToYorozuya(makeJapaneseSquare(Square.parse('12a')!)),
      equals('亥一'),
    );
    expect(convertJapaneseToYorozuya('6三・6二獅'), equals('巳三・巳二獅'));
    expect(convertJapaneseToYorozuya('4三龍'), equals('卯三龍'));
    expect(convertJapaneseToYorozuya('4三龍不成'), equals('卯三龍'));
    expect(convertJapaneseToYorozuya('4三龍成'), equals('卯三龍ナル'));
    expect(convertJapaneseToYorozuya('4三龍'), equals('卯三龍'));
    expect(convertJapaneseToYorozuya('1一馬'), equals('子一馬'));
    expect(convertJapaneseToYorozuya('12十二角'), equals('亥十二角'));
    expect(convertJapaneseToYorozuya('5五金'), equals('辰五金'));
    expect(convertJapaneseToYorozuya('7七香'), equals('午七香'));
    expect(convertJapaneseToYorozuya('10十飛'), equals('酉十飛'));
    expect(convertJapaneseToYorozuya('3二玉'), equals('寅二玉'));
    expect(convertJapaneseToYorozuya('9八銀'), equals('申八銀'));
    expect(convertJapaneseToYorozuya('2六桂'), equals('丑六桂'));
    expect(convertJapaneseToYorozuya('6四歩'), equals('巳四歩'));
    expect(convertJapaneseToYorozuya('11九王'), equals('戌九王'));
    expect(convertJapaneseToYorozuya('8三兵'), equals('未三兵'));
    expect(convertJapaneseToYorozuya('1十二香'), equals('子十二香'));
    expect(convertJapaneseToYorozuya('12一飛'), equals('亥一飛'));
    expect(convertJapaneseToYorozuya('5二歩'), equals('辰二歩'));
    expect(convertJapaneseToYorozuya('10七金'), equals('酉七金'));
    expect(convertJapaneseToYorozuya('3三銀'), equals('寅三銀'));
    expect(convertJapaneseToYorozuya('9九王'), equals('申九王'));
    expect(convertJapaneseToYorozuya('５六金寄'), equals('辰六金寄'));
  });
}
