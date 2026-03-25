import '../../dartshogi.dart';

SquareSet aimingAt(Position pos, SquareSet pieces, int to) {
  SquareSet ambs = SquareSet.empty;
  for (final p in pieces.squares) {
    if (pos.illegalMoveDests(p).has(to)) ambs = ambs.withSquare(p);
  }
  return ambs;
}

String Function(Role) roleToWestern(Rule rule) {
  if (rule == Rule.dobutsu) return doubutsuRoleToWestern;
  return (role) => switch (role) {
    Role.pawn => 'P',
    Role.lance => 'L',
    Role.knight => 'N',
    Role.silver => 'S',
    Role.gold => 'G',
    Role.bishop => 'B',
    Role.rook => 'R',
    Role.tokin => rule == Rule.kyotoshogi ? 'T' : '+P',
    Role.promotedpawn => '+P',
    Role.promotedlance => '+L',
    Role.promotedknight => '+N',
    Role.promotedsilver => '+S',
    Role.horse => rule == Rule.chushogi ? 'H' : '+B',
    Role.dragon => rule == Rule.chushogi ? 'D' : '+R',
    Role.king => 'K',
    Role.leopard => 'FL',
    Role.copper => 'C',
    Role.elephant => 'DE',
    Role.chariot => 'RC',
    Role.tiger => 'BT',
    Role.kirin => 'Kr',
    Role.phoenix => 'Ph',
    Role.sidemover => 'SM',
    Role.verticalmover => 'VM',
    Role.lion => 'Ln',
    Role.queen => 'FK',
    Role.gobetween => 'GB',
    Role.whitehorse => '+L',
    Role.bishoppromoted => '+FL',
    Role.sidemoverpromoted => '+C',
    Role.verticalmoverpromoted => '+S',
    Role.rookpromoted => '+G',
    Role.prince => '+DE',
    Role.whale => '+RC',
    Role.horsepromoted => '+B',
    Role.stag => '+BT',
    Role.lionpromoted => '+Kr',
    Role.queenpromoted => '+Ph',
    Role.boar => '+SM',
    Role.ox => '+VM',
    Role.falcon => '+H',
    Role.eagle => '+D',
    Role.dragonpromoted => '+R',
    Role.elephantpromoted => '+GB',
  };
}

String doubutsuRoleToWestern(Role role) => switch (role) {
  Role.pawn => 'C',
  Role.bishop => 'E',
  Role.rook => 'G',
  Role.tokin => 'H',
  Role.king => 'L',
  _ => '',
};

List<Role> Function(Role) roleKanjiDuplicates(Rule rule) {
  if (rule == Rule.chushogi) {
    return (role) {
      const groups = [
        [Role.gold, Role.promotedpawn],
        [Role.elephant, Role.elephantpromoted],
        [Role.sidemover, Role.sidemoverpromoted],
        [Role.verticalmover, Role.verticalmoverpromoted],
        [Role.horse, Role.horsepromoted],
        [Role.dragon, Role.dragonpromoted],
        [Role.lion, Role.lionpromoted],
        [Role.queen, Role.queenpromoted],
      ];
      for (final rs in groups) {
        if (rs.contains(role)) return rs.where((r) => r != role).toList();
      }
      return [];
    };
  }
  return (_) => [];
}

String Function(Role) roleToKanji(Rule rule) {
  if (rule == Rule.dobutsu) return doubutsuRoleToKanji;
  return (role) => switch (role) {
    Role.pawn => '歩',
    Role.lance => '香',
    Role.knight => '桂',
    Role.silver => '銀',
    Role.gold => '金',
    Role.bishop => '角',
    Role.rook => '飛',
    Role.tokin => 'と',
    Role.promotedpawn => '金',
    Role.promotedlance => '成香',
    Role.promotedknight => '成桂',
    Role.promotedsilver => '成銀',
    Role.horse || Role.horsepromoted => '馬',
    Role.dragon || Role.dragonpromoted => '龍',
    Role.king => '玉',
    Role.leopard => '豹',
    Role.copper => '銅',
    Role.elephant || Role.elephantpromoted => '象',
    Role.chariot => '反',
    Role.tiger => '虎',
    Role.kirin => '麒',
    Role.phoenix => '鳳',
    Role.sidemover || Role.sidemoverpromoted => '横',
    Role.verticalmover || Role.verticalmoverpromoted => '竪',
    Role.lion || Role.lionpromoted => '獅',
    Role.queen || Role.queenpromoted => '奔',
    Role.gobetween => '仲',
    Role.whitehorse => '駒',
    Role.bishoppromoted => '小角',
    Role.rookpromoted => '金飛車',
    Role.prince => '太',
    Role.whale => '鯨',
    Role.stag => '鹿',
    Role.boar => '猪',
    Role.ox => '牛',
    Role.falcon => '鷹',
    Role.eagle => '鷲',
  };
}

String doubutsuRoleToKanji(Role role) => switch (role) {
  Role.pawn => 'ひよこ',
  Role.bishop => 'ぞう',
  Role.rook => 'きりん',
  Role.tokin => 'にわとり',
  Role.king => 'ライオン',
  _ => '',
};

String Function(Role) roleToBoardKanji(Rule rule) {
  if (rule == Rule.dobutsu) return doubutsuRoleToBoardKanji;
  return (role) => switch (role) {
    Role.promotedlance => '杏',
    Role.promotedknight => '圭',
    Role.promotedsilver => '全',
    Role.bishoppromoted => '成角',
    Role.rookpromoted => '成飛',
    Role.queenpromoted => '成奔',
    Role.verticalmoverpromoted => '成竪',
    Role.sidemoverpromoted => '成横',
    Role.elephantpromoted => '成象',
    Role.lionpromoted => '成獅',
    Role.horsepromoted => '成馬',
    Role.dragonpromoted => '成龍',
    Role.promotedpawn => '成歩',
    _ => roleToKanji(rule)(role),
  };
}

String doubutsuRoleToBoardKanji(Role role) => switch (role) {
  Role.pawn => 'ひ',
  Role.bishop => 'ぞ',
  Role.rook => 'き',
  Role.tokin => 'に',
  Role.king => 'ラ',
  _ => '',
};

String Function(Role) roleToFullKanji(Rule rule) {
  if (rule == Rule.dobutsu) return doubutsuRoleToKanji;
  return (role) => switch (role) {
    Role.pawn => '歩兵',
    Role.lance => '香車',
    Role.knight => '桂馬',
    Role.silver => '銀将',
    Role.gold => '金将',
    Role.bishop => '角行',
    Role.rook => '飛車',
    Role.tokin => 'と金',
    Role.promotedpawn => '金将',
    Role.promotedlance => '成香',
    Role.promotedknight => '成桂',
    Role.promotedsilver => '成銀',
    Role.horse || Role.horsepromoted => '龍馬',
    Role.dragon || Role.dragonpromoted => '龍王',
    Role.king => '玉将',
    Role.leopard => '猛豹',
    Role.copper => '銅将',
    Role.elephant || Role.elephantpromoted => '醉象',
    Role.chariot => '反車',
    Role.tiger => '盲虎',
    Role.kirin => '麒麟',
    Role.phoenix => '鳳凰',
    Role.sidemover || Role.sidemoverpromoted => '横行',
    Role.verticalmover || Role.verticalmoverpromoted => '竪行',
    Role.lion || Role.lionpromoted => '獅子',
    Role.queen || Role.queenpromoted => '奔王',
    Role.gobetween => '仲人',
    Role.whitehorse => '白駒',
    Role.bishoppromoted => '小角',
    Role.rookpromoted => '金飛車',
    Role.prince => '太子',
    Role.whale => '鯨鯢',
    Role.stag => '飛鹿',
    Role.boar => '奔猪',
    Role.ox => '飛牛',
    Role.falcon => '角鷹',
    Role.eagle => '飛鷲',
  };
}

List<Role> kanjiToRole(String str) => switch (str) {
  '歩' || '歩兵' || 'ひ' => [Role.pawn],
  '香' || '香車' => [Role.lance],
  '桂' || '桂馬' => [Role.knight],
  '銀' || '銀将' => [Role.silver],
  '金' || '金将' => [Role.gold, Role.promotedpawn],
  '成歩' => [Role.promotedpawn],
  '角' || '角行' || 'ぞ' => [Role.bishop],
  '飛' || '飛車' || 'き' => [Role.rook],
  'と' || 'と金' || 'に' => [Role.tokin, Role.promotedpawn],
  '杏' || '仝' || '成香' => [Role.promotedlance],
  '圭' || '今' || '成桂' => [Role.promotedknight],
  '全' || '成銀' => [Role.promotedsilver],
  '馬' || '龍馬' || '竜馬' => [Role.horse, Role.horsepromoted],
  '成馬' => [Role.horsepromoted],
  '龍' || '龍王' || '竜' || '竜王' => [Role.dragon, Role.dragonpromoted],
  '成龍' || '成竜' => [Role.dragonpromoted],
  '玉' || '王' || '王将' || '玉将' || 'ラ' => [Role.king],
  '豹' || '猛豹' => [Role.leopard],
  '銅' || '銅将' => [Role.copper],
  '象' || '醉象' => [Role.elephant, Role.elephantpromoted],
  '成象' => [Role.elephantpromoted],
  '反' || '反車' => [Role.chariot],
  '虎' || '盲虎' => [Role.tiger],
  '麒' || '麒麟' => [Role.kirin],
  '鳳' || '鳳凰' => [Role.phoenix],
  '横' || '横行' => [Role.sidemover, Role.sidemoverpromoted],
  '成横' => [Role.sidemoverpromoted],
  '竪' || '竪行' => [Role.verticalmover, Role.verticalmoverpromoted],
  '成竪' => [Role.verticalmoverpromoted],
  '獅' || '師' || '獅子' => [Role.lion, Role.lionpromoted],
  '成獅' || '成師' => [Role.lionpromoted],
  '奔' || '奔王' => [Role.queen, Role.queenpromoted],
  '成奔' => [Role.queenpromoted],
  '仲' || '仲人' => [Role.gobetween],
  '駒' || '白駒' => [Role.whitehorse],
  '小角' || '成角' => [Role.bishoppromoted],
  '金飛車' || '金飛' || '成飛' => [Role.rookpromoted],
  '太' || '太子' => [Role.prince],
  '鯨' || '鯨鯢' => [Role.whale],
  '鹿' || '飛鹿' => [Role.stag],
  '猪' || '奔猪' => [Role.boar],
  '牛' || '飛牛' => [Role.ox],
  '鷹' || '角鷹' => [Role.falcon],
  '鷲' || '飛鷲' => [Role.eagle],
  _ => [],
};

String? roleToCsa(Role role) => switch (role) {
  Role.pawn => 'FU',
  Role.lance => 'KY',
  Role.knight => 'KE',
  Role.silver => 'GI',
  Role.gold => 'KI',
  Role.bishop => 'KA',
  Role.rook => 'HI',
  Role.tokin => 'TO',
  Role.promotedlance => 'NY',
  Role.promotedknight => 'NK',
  Role.promotedsilver => 'NG',
  Role.horse => 'UM',
  Role.dragon => 'RY',
  Role.king => 'OU',
  _ => null,
};

Role? csaToRole(String str) => switch (str.toUpperCase()) {
  'FU' => Role.pawn,
  'KY' => Role.lance,
  'KE' => Role.knight,
  'GI' => Role.silver,
  'KI' => Role.gold,
  'KA' => Role.bishop,
  'HI' => Role.rook,
  'TO' => Role.tokin,
  'NY' => Role.promotedlance,
  'NK' => Role.promotedknight,
  'NG' => Role.promotedsilver,
  'UM' => Role.horse,
  'RY' => Role.dragon,
  'OU' => Role.king,
  _ => null,
};

String filesByRule(Rule rule) => switch (rule) {
  Rule.chushogi => ' １２ １１ １０ ９  ８  ７  ６  ５  ４  ３  ２  １',
  Rule.minishogi || Rule.kyotoshogi => '  ５ ４ ３ ２ １',
  Rule.dobutsu => '  ３ ２ １',
  _ => '  ９ ８ ７ ６ ５ ４ ３ ２ １',
};

String Function(Piece) pieceToBoardKanji(Rule rule) {
  return (piece) =>
      piece.side == Side.gote
          ? 'v${roleToBoardKanji(rule)(piece.role)}'
          : roleToBoardKanji(rule)(piece.role);
}

String makeNumberSquare(Square sq) {
  final file = sq.file.value + 1;
  final rank = sq.rank.value + 1;
  final fileStr = file >= 10 ? String.fromCharCode(file + 87) : file.toString();
  final rankStr = rank >= 10 ? String.fromCharCode(rank + 87) : rank.toString();
  return fileStr + rankStr;
}

int? parseNumberSquare(String str) {
  if (str.length != 2) return null;
  final file = str.codeUnitAt(0) - '1'.codeUnitAt(0);
  final rank = str.codeUnitAt(1) - '1'.codeUnitAt(0);
  if (file < 0 || file >= 16 || rank < 0 || rank >= 16) return null;
  return file + 16 * rank;
}

String makeJapaneseSquare(Square sq) {
  return (sq.file.value + 1)
          .toString()
          .split('')
          .map((c) => String.fromCharCode(c.codeUnitAt(0) + 0xfee0))
          .join() +
      numberToKanji(sq.rank.value + 1);
}

String makeJapaneseSquareHalf(Square sq) {
  return (sq.file.value + 1).toString() + numberToKanji(sq.rank.value + 1);
}

int? parseJapaneseSquare(String str) {
  if (str.length < 2 || str.length > 4) return null;
  final fileOffset =
      str.length == 2 || (str.length == 3 && str[1] == '十') ? 1 : 2;
  final file =
      int.tryParse(
        str.substring(0, fileOffset).split('').map((c) {
          return c.codeUnitAt(0) >= 0xfee0 + 48
              ? String.fromCharCode(c.codeUnitAt(0) - 0xfee0)
              : c;
        }).join(),
      ) ??
      -1 - 1;
  final rank = kanjiToNumber(str.substring(fileOffset)) - 1;
  if (file < 0 || file >= 16 || rank < 0 || rank >= 16) return null;
  return file + 16 * rank;
}

String toKanjiDigit(String str) => switch (str) {
  '1' => '一',
  '2' => '二',
  '3' => '三',
  '4' => '四',
  '5' => '五',
  '6' => '六',
  '7' => '七',
  '8' => '八',
  '9' => '九',
  '10' => '十',
  _ => '',
};

int fromKanjiDigit(String str) => switch (str) {
  '一' => 1,
  '二' => 2,
  '三' => 3,
  '四' => 4,
  '五' => 5,
  '六' => 6,
  '七' => 7,
  '八' => 8,
  '九' => 9,
  '十' => 10,
  _ => 0,
};

String numberToKanji(int np) {
  final n = np.clamp(0, 99);
  final tens = n ~/ 10;
  final ones = n % 10;
  final res =
      tens >= 2
          ? '${toKanjiDigit(tens.toString())}十'
          : tens == 1
          ? '十'
          : '';
  return res + toKanjiDigit(ones.toString());
}

int kanjiToNumber(String str) {
  var res = str.startsWith('十') ? 1 : 0;
  for (final s in str.split('')) {
    if (s == '十') {
      res *= 10;
    } else {
      res += fromKanjiDigit(s);
    }
  }
  return res.clamp(0, 99);
}
