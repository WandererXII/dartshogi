import 'package:dartshogi/src/core/rule.dart';
import 'package:dartshogi/src/core/side.dart';
import 'package:dartshogi/src/handicap.dart';
import 'package:dartshogi/src/sfen.dart';
import 'package:test/test.dart';

void main() {
  test('proper count', () {
    expect(Handicap.findAll(rule: Rule.shogi).length, 34);
    expect(Handicap.findAll(rule: Rule.minishogi).length, 5);
    expect(Handicap.findAll(rule: Rule.chushogi).length, 3);
    expect(Handicap.findAll(rule: Rule.annanshogi).length, 15);
    expect(Handicap.findAll(rule: Rule.kyotoshogi).length, 7);
    expect(Handicap.findAll(rule: Rule.checkshogi).length, 34);
  });

  test('only one field', () {
    expect(Handicap.find(rule: Rule.shogi), isNotNull);
    expect(Handicap.find(sfen: 'asdsafds'), isNull);

    expect(
      Handicap.find(
        sfen: '1nsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      )?.englishName,
      'Right Lance',
    );

    expect(
      Handicap.find(
        sfen: '1nsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w -',
      )?.englishName,
      'Right Lance',
    );

    expect(
      Handicap.find(
        sfen: '1nsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w',
      )?.englishName,
      'Right Lance',
    );

    expect(
      Handicap.find(
        sfen: '1nsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL ',
      )?.englishName,
      isNull,
    );

    expect(
      Handicap.find(
        sfen: '1nsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL',
      )?.englishName,
      isNull,
    );

    expect(Handicap.find(sfen: '1nsgkgsnl/1r5b1/ppppppppp'), isNull);
  });

  test('multiple fields', () {
    expect(Handicap.find(rule: Rule.shogi, japaneseName: '角落ち'), isNotNull);

    expect(Handicap.find(rule: Rule.shogi, englishName: '角落ち'), isNull);
  });

  test('parse validly', () {
    for (final h in Handicap.values) {
      expect(parseSfen(h.rule, h.sfen, strict: true).isSuccess(), true);
      expect(
        parseSfen(h.rule, h.sfen, strict: true).getOrThrow().turn,
        Side.gote,
      );
    }
  });

  test('default not handicap', () {
    for (final r in Rule.values) {
      expect(Handicap.isHandicap(sfen: initialSfen(r)), false);
    }
  });
}
