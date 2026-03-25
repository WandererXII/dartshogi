import './core/rule.dart';

class Handicap {
  final Rule rule;
  final String sfen;
  final String japaneseName;
  final String englishName;

  const Handicap({
    required this.rule,
    required this.sfen,
    required this.japaneseName,
    required this.englishName,
  });

  static List<Handicap> findAll({
    Rule? rule,
    String? sfen,
    String? japaneseName,
    String? englishName,
  }) {
    return values.where((h) {
      if (rule != null && h.rule != rule) return false;
      if (sfen != null && !_compareSfens(h.sfen, sfen)) return false;
      if (japaneseName != null && h.japaneseName != japaneseName) return false;
      if (englishName != null && h.englishName != englishName) return false;
      return true;
    }).toList();
  }

  static Handicap? find({
    Rule? rule,
    String? sfen,
    String? japaneseName,
    String? englishName,
  }) {
    return findAll(
      rule: rule,
      sfen: sfen,
      japaneseName: japaneseName,
      englishName: englishName,
    ).firstOrNull;
  }

  static bool isHandicap({
    Rule? rule,
    String? sfen,
    String? japaneseName,
    String? englishName,
  }) {
    return find(
          rule: rule,
          sfen: sfen,
          japaneseName: japaneseName,
          englishName: englishName,
        ) !=
        null;
  }

  static bool _compareSfens(String a, String b) {
    final aSplit = a.split(' ');
    final bSplit = b.split(' ');

    if (aSplit.length < 2 || bSplit.length < 2) return false;
    final aHands = aSplit.length > 2 ? aSplit[2] : '-';
    final bHands = bSplit.length > 2 ? bSplit[2] : '-';

    return aSplit[0] == bSplit[0] && aSplit[1] == bSplit[1] && aHands == bHands;
  }

  static const List<({String sfen, String japaneseName, String englishName})>
  _standardHandicaps = [
    (
      sfen: 'lnsgkgsn1/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '香落ち',
      englishName: 'Lance',
    ),
    (
      sfen: '1nsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '右香落ち',
      englishName: 'Right Lance',
    ),
    (
      sfen: '1nsgkgsn1/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '両香落ち',
      englishName: 'Both Lance',
    ),
    (
      sfen: 'lnsgkgsnl/1r7/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '角落ち',
      englishName: 'Bishop',
    ),
    (
      sfen: 'lnsgkgsnl/7b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '飛車落ち',
      englishName: 'Rook',
    ),
    (
      sfen: 'lnsgkgsn1/7b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '飛香落ち',
      englishName: 'Rook-Lance',
    ),
    (
      sfen: 'lnsgkgsnl/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '二枚落ち',
      englishName: '2-piece',
    ),
    (
      sfen: '1nsgkgsnl/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '三枚落ち',
      englishName: '3-piece',
    ),
    (
      sfen: '1nsgkgsn1/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '四枚落ち',
      englishName: '4-piece',
    ),
    (
      sfen: '2sgkgsn1/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '五枚落ち',
      englishName: '5-piece',
    ),
    (
      sfen: '2sgkgs2/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '六枚落ち',
      englishName: '6-piece',
    ),
    (
      sfen: '3gkgs2/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '七枚落ち',
      englishName: '7-piece',
    ),
    (
      sfen: '3gkg3/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '八枚落ち',
      englishName: '8-piece',
    ),
    (
      sfen: '4kg3/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '九枚落ち',
      englishName: '9-piece',
    ),
    (
      sfen: '4k4/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '十枚落ち',
      englishName: '10-piece',
    ),
    (
      sfen: '4k4/9/9/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w 3p 1',
      japaneseName: '歩三兵',
      englishName: '3 Pawns',
    ),
    (
      sfen: '4k4/9/9/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '裸玉',
      englishName: 'Naked King',
    ),
    (
      sfen: 'ln2k2nl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: 'トンボ＋桂香',
      englishName: 'Dragonfly + NL',
    ),
    (
      sfen: 'l3k3l/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: 'トンボ＋香',
      englishName: 'Dragonfly + L',
    ),
    (
      sfen: '4k4/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: 'トンボ',
      englishName: 'Dragonfly',
    ),
    (
      sfen: 'lnsgkgsnl/1r5b1/p1ppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '太閤将棋',
      englishName: 'Taiko',
    ),
    (
      sfen: 'lnsgkgsn1/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w L 1',
      japaneseName: '香得',
      englishName: 'Lance Gained',
    ),
    (
      sfen: '1nsgkgsn1/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w 2L 1',
      japaneseName: '両香得',
      englishName: 'Two Lance Gained',
    ),
    (
      sfen: 'lnsgkgsnl/1r7/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w B 1',
      japaneseName: '角得',
      englishName: 'Bishop Gained',
    ),
    (
      sfen: 'lnsgkgsnl/7b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w R 1',
      japaneseName: '飛車得',
      englishName: 'Rook Gained',
    ),
    (
      sfen: 'lnsgkgsn1/7b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RL 1',
      japaneseName: '飛香得',
      englishName: 'Rook-Lance Gained',
    ),
    (
      sfen: 'lnsgkgsnl/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RB 1',
      japaneseName: '二枚得',
      englishName: '2-piece Gained',
    ),
    (
      sfen: '1nsgkgsnl/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RBL 1',
      japaneseName: '三枚得',
      englishName: '3-piece Gained',
    ),
    (
      sfen: '1nsgkgsn1/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RB2L 1',
      japaneseName: '四枚得',
      englishName: '4-piece Gained',
    ),
    (
      sfen: '2sgkgsn1/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RBN2L 1',
      japaneseName: '五枚得',
      englishName: '5-piece Gained',
    ),
    (
      sfen: '2sgkgs2/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RB2N2L 1',
      japaneseName: '六枚得',
      englishName: '6-piece Gained',
    ),
    (
      sfen: '3gkgs2/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RBS2N2L 1',
      japaneseName: '七枚得',
      englishName: '7-piece Gained',
    ),
    (
      sfen: '3gkg3/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RB2S2N2L 1',
      japaneseName: '八枚得',
      englishName: '8-piece Gained',
    ),
    (
      sfen: '4kg3/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RBG2S2N2L 1',
      japaneseName: '九枚得',
      englishName: '9-piece Gained',
    ),
  ];

  static List<Handicap> _fromStandard(Rule rule) =>
      _standardHandicaps
          .map(
            (h) => Handicap(
              rule: rule,
              sfen: h.sfen,
              japaneseName: h.japaneseName,
              englishName: h.englishName,
            ),
          )
          .toList();

  static final List<Handicap> values = [
    ..._fromStandard(Rule.shogi),
    // minishogi
    const Handicap(
      rule: Rule.minishogi,
      sfen: 'r1sgk/4p/5/P4/KGSBR w - 1',
      japaneseName: '角落ち',
      englishName: 'Bishop',
    ),
    const Handicap(
      rule: Rule.minishogi,
      sfen: '1bsgk/4p/5/P4/KGSBR w - 1',
      japaneseName: '飛車落ち',
      englishName: 'Rook',
    ),
    const Handicap(
      rule: Rule.minishogi,
      sfen: '2sgk/4p/5/P4/KGSBR w - 1',
      japaneseName: '二枚落ち',
      englishName: '2-piece',
    ),
    const Handicap(
      rule: Rule.minishogi,
      sfen: '3gk/4p/5/P4/KGSBR w - 1',
      japaneseName: '三枚落ち',
      englishName: '3-piece',
    ),
    const Handicap(
      rule: Rule.minishogi,
      sfen: '4k/4p/5/P4/KGSBR w - 1',
      japaneseName: '四枚落ち',
      englishName: '4-piece',
    ),
    // chushogi
    const Handicap(
      rule: Rule.chushogi,
      sfen:
          'lfcsgekgscfl/a1b1txxt1b1a/mvrhdqndhrvm/pppppppppppp/3i4i3/12/12/3I4I3/PPPPPPPPPPPP/MVRHDNQDHRVM/A1B1T+O+OT1B1A/LFCSGKEGSCFL w - 1',
      japaneseName: '3枚獅子',
      englishName: '3-piece lion',
    ),
    const Handicap(
      rule: Rule.chushogi,
      sfen:
          'lfcsgekgscfl/a1b1txot1b1a/mvrhdqndhrvm/pppppppppppp/3i4i3/12/12/3I4I3/PPPPPPPPPPPP/MVRHDNQDHRVM/A1B1T+OXT1B1A/LFCSGKEGSCFL w - 1',
      japaneseName: '2枚獅子',
      englishName: '2-lions',
    ),
    const Handicap(
      rule: Rule.chushogi,
      sfen:
          'lfcsgekgscfl/a1b1txot1b1a/mvrhdqndhrvm/pppppppppppp/3i4i3/12/12/3I4I3/PPPPPPPPPPPP/MVRHDNQDHRVM/A1B1TOXT1B1A/LFCSGK+EGSCFL w - 1',
      japaneseName: '2枚王',
      englishName: '2-kings',
    ),
    // annanshogi
    const Handicap(
      rule: Rule.annanshogi,
      sfen:
          'lnsgkgsn1/1r5b1/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '香落ち',
      englishName: 'Lance',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen:
          '1nsgkgsnl/1r5b1/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '右香落ち',
      englishName: 'Right Lance',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen:
          'lnsgkgsnl/1r7/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '角落ち',
      englishName: 'Bishop',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen:
          'lnsgkgsnl/7b1/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '飛車落ち',
      englishName: 'Rook',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen:
          'lnsgkgsn1/7b1/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '飛香落ち',
      englishName: 'Rook-Lance',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen:
          'lnsgkgsnl/9/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '二枚落ち',
      englishName: '2-piece',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen:
          '1nsgkgsn1/9/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '四枚落ち',
      englishName: '4-piece',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen: '2sgkgs2/9/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '六枚落ち',
      englishName: '6-piece',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen: '3gkg3/9/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '八枚落ち',
      englishName: '8-piece',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen: '4k4/9/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '十枚落ち',
      englishName: '10-piece',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen: '4k4/9/9/9/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w 3p 1',
      japaneseName: '歩三兵',
      englishName: '3 Pawns',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen: '4k4/9/9/9/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: '裸玉',
      englishName: 'Naked King',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen:
          'ln2k2nl/1r5b1/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: 'トンボ＋桂香',
      englishName: 'Dragonfly + NL',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen:
          'l3k3l/1r5b1/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: 'トンボ＋香',
      englishName: 'Dragonfly + L',
    ),
    const Handicap(
      rule: Rule.annanshogi,
      sfen: '4k4/1r5b1/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL w - 1',
      japaneseName: 'トンボ',
      englishName: 'Dragonfly',
    ),
    // kyotoshogi
    const Handicap(
      rule: Rule.kyotoshogi,
      sfen: 'pgks1/5/5/5/TSKGP w - 1',
      japaneseName: 'と落ち',
      englishName: 'Tokin',
    ),
    const Handicap(
      rule: Rule.kyotoshogi,
      sfen: 'pgk1t/5/5/5/TSKGP w - 1',
      japaneseName: '銀落ち',
      englishName: 'Silver',
    ),
    const Handicap(
      rule: Rule.kyotoshogi,
      sfen: '1gkst/5/5/5/TSKGP w - 1',
      japaneseName: '歩落ち',
      englishName: 'Pawn',
    ),
    const Handicap(
      rule: Rule.kyotoshogi,
      sfen: 'p1kst/5/5/5/TSKGP w - 1',
      japaneseName: '金落ち',
      englishName: 'Gold',
    ),
    const Handicap(
      rule: Rule.kyotoshogi,
      sfen: '1gks1/5/5/5/TSKGP w - 1',
      japaneseName: '二枚落ち',
      englishName: '2-piece',
    ),
    const Handicap(
      rule: Rule.kyotoshogi,
      sfen: '1gk2/5/5/5/TSKGP w - 1',
      japaneseName: '三枚落ち',
      englishName: '3-piece',
    ),
    const Handicap(
      rule: Rule.kyotoshogi,
      sfen: '2k2/5/5/5/TSKGP w - 1',
      japaneseName: '裸玉',
      englishName: 'Naked King',
    ),
    // checkshogi
    ..._fromStandard(Rule.checkshogi),
    // dobutsu
    const Handicap(
      rule: Rule.dobutsu,
      sfen: 'rkb/3/1P1/BKR w - 1',
      japaneseName: 'ひよこ落ち',
      englishName: 'Chick',
    ),
  ];
}
