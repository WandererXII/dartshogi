import 'package:dartshogi/dartshogi.dart';
import 'package:test/test.dart';

void main() {
  test('all numeric squares round-trip', () {
    for (var value = 0; value < 256; value++) {
      final notation = makeNumberSquare(Square(value));
      expect(parseNumberSquare(notation), value, reason: notation);
    }
  });

  test('numeric squares decode digit and letter coordinates', () {
    for (final entry
        in {
          '11': 0,
          '76': 86,
          '99': 136,
          'a1': 9,
          '1a': 144,
          'bb': 170,
          'cc': 187,
          'g9': 143,
          '9g': 248,
          'gg': 255,
        }.entries) {
      expect(parseNumberSquare(entry.key), entry.value, reason: entry.key);
    }
  });

  test('numeric squares reject invalid coordinates and lengths', () {
    for (final character in '0:;<=>?@hHzAG'.split('')) {
      expect(parseNumberSquare('${character}1'), isNull, reason: character);
      expect(parseNumberSquare('1$character'), isNull, reason: character);
    }
    for (final notation in ['', '1', '111', 'a11', ' 11', '11 ', '１１']) {
      expect(parseNumberSquare(notation), isNull, reason: notation);
    }
  });

  test('all Japanese squares round-trip in full and half width', () {
    for (var value = 0; value < 256; value++) {
      final square = Square(value);
      for (final notation in [
        makeJapaneseSquare(square),
        makeJapaneseSquareHalf(square),
      ]) {
        expect(parseJapaneseSquare(notation), value, reason: notation);
      }
    }
  });

  test('Japanese squares reject invalid files and ranks', () {
    for (final notation in [
      '0一',
      '０一',
      '17一',
      '１７一',
      'x一',
      'ｘ一',
      '1〇',
      '１〇',
      '1十七',
      '１十七',
    ]) {
      expect(parseJapaneseSquare(notation), isNull, reason: notation);
    }
  });

  test('kanji number conversion', () {
    for (final entry
        in {1: '一', 10: '十', 16: '十六', 20: '二十', 99: '九十九'}.entries) {
      expect(numberToKanji(entry.key), entry.value);
      expect(kanjiToNumber(entry.value), entry.key);
    }
  });

  test('kanji number bounds', () {
    expect(numberToKanji(0), isEmpty);
    expect(numberToKanji(-1), isEmpty);
    expect(numberToKanji(100), '九十九');
    expect(kanjiToNumber(''), 0);
  });
}
