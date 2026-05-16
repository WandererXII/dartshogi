import 'package:result_dart/result_dart.dart';

import './board.dart';
import './core/exceptions.dart';
import './core/file.dart';
import './core/piece.dart';
import './core/rank.dart';
import './core/role.dart';
import './core/rule.dart';
import './core/setup.dart';
import './core/side.dart';
import './core/square.dart';
import './hands.dart';
import './position/position.dart';
import './position/setup.dart';
import './position/utils.dart';
import 'history.dart';

String initialSfen(Rule rule) => switch (rule) {
  Rule.chushogi =>
    'lfcsgekgscfl/a1b1txot1b1a/mvrhdqndhrvm/pppppppppppp/3i4i3/12/12/3I4I3/PPPPPPPPPPPP/MVRHDNQDHRVM/A1B1TOXT1B1A/LFCSGKEGSCFL b - 1',
  Rule.minishogi => 'rbsgk/4p/5/P4/KGSBR b - 1',
  Rule.annanshogi =>
    'lnsgkgsnl/1r5b1/p1ppppp1p/1p5p1/9/1P5P1/P1PPPPP1P/1B5R1/LNSGKGSNL b - 1',
  Rule.kyotoshogi => 'pgkst/5/5/5/TSKGP b - 1',
  Rule.dobutsu => 'rkb/1p1/1P1/BKR b - 1',
  _ => 'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1',
};

String? Function(Role) roleToForsyth(Rule rule) => switch (rule) {
  Rule.chushogi => _chushogiRoleToForsyth,
  Rule.minishogi => _minishogiRoleToForsyth,
  Rule.kyotoshogi => _kyotoshogiRoleToForsyth,
  Rule.dobutsu => _dobutsuRoleToForsyth,
  _ => _standardRoleToForsyth,
};

Role? Function(String) forsythToRole(Rule rule) => switch (rule) {
  Rule.chushogi => _chushogiForsythToRole,
  Rule.minishogi => _minishogiForsythToRole,
  Rule.kyotoshogi => _kyotoshogiForsythToRole,
  Rule.dobutsu => _dobutsuForsythToRole,
  _ => _standardForsythToRole,
};

String? Function(Piece) pieceToForsyth(Rule rule) {
  return (piece) {
    final r = roleToForsyth(rule)(piece.role);
    if (r != null && piece.side == Side.sente) {
      return r.toUpperCase();
    }
    return r;
  };
}

Piece? Function(String) forsythToPiece(Rule rule) {
  return (s) {
    final role = forsythToRole(rule)(s);
    if (role != null) {
      return Piece(
        role: role,
        side: s.toLowerCase() == s ? Side.gote : Side.sente,
      );
    }
    return null;
  };
}

int? _parseSmallUint(String str) {
  if (RegExp(r'^\d{1,4}$').hasMatch(str)) {
    return int.tryParse(str);
  }
  return null;
}

Result<Board> parseBoardSfen(Rule rule, String boardPart) {
  final dims = dimensions(rule);
  if (dims.ranks != boardPart.split('/').length) {
    return const Failure(SfenException(IllegalSfenCause.board));
  }

  Board board = Board.empty;
  int empty = 0;
  int rank = 0;
  int file = dims.files - 1;

  for (int i = 0; i < boardPart.length; i++) {
    String c = boardPart[i];
    if (c == '/' && file < 0) {
      empty = 0;
      file = dims.files - 1;
      rank++;
    } else {
      final step = int.tryParse(c);
      if (step != null) {
        file = file + empty - (empty * 10 + step);
        empty = empty * 10 + step;
      } else {
        if (file < 0 || file >= dims.files || rank < 0 || rank >= dims.ranks) {
          return const Failure(SfenException(IllegalSfenCause.board));
        }
        if (c == '+' && i + 1 < boardPart.length) {
          c += boardPart[++i];
        }
        final piece = forsythToPiece(rule)(c);
        if (piece == null) {
          return const Failure(SfenException(IllegalSfenCause.board));
        }
        final square = Square.fromCoords(File(file), Rank(rank));
        board = board.setPieceAt(square, piece);
        empty = 0;
        file--;
      }
    }
  }

  if (rank != dims.ranks - 1 || file != -1) {
    return const Failure(SfenException(IllegalSfenCause.board));
  }
  return Success(board);
}

Result<Hands> parseHandsSfen(Rule rule, String handsPart) {
  Hands hands = Hands.empty;
  for (int i = 0; i < handsPart.length; i++) {
    if (handsPart[i] == '-') break;

    // max 99
    int? count = int.tryParse(handsPart[i]);
    if (count != null) {
      if (i + 1 < handsPart.length) {
        final secondNum = int.tryParse(handsPart[i + 1]);
        i++;
        if (secondNum != null) {
          count = count * 10 + secondNum;
          i++;
        }
      }
    } else {
      count = 1;
    }

    Piece? piece = forsythToPiece(rule)(handsPart[i]);
    if (piece == null) {
      return const Failure(SfenException(IllegalSfenCause.hands));
    }
    if (rule == Rule.kyotoshogi && !handRoles(rule).contains(piece.role)) {
      piece = Piece(
        role: unpromote(rule, piece.role) ?? piece.role,
        side: piece.side,
      );
    }
    hands = hands.store(piece, cnt: count);
  }
  return Success(hands);
}

Result<Position> parseSfen(Rule rule, String sfen, {bool strict = false}) {
  String sfenStr = sfen;
  if (sfen == 'startpos') sfenStr = initialSfen(rule);

  final parts = sfenStr.trim().split(RegExp(r'[\s_]+'));

  // Board
  final boardPart = parts.removeAt(0);
  final board = parseBoardSfen(rule, boardPart);
  if (board.isError()) return Failure(board.exceptionOrNull()!);

  // Turn
  final turnPart = parts.isNotEmpty ? parts.removeAt(0) : null;
  final turn = turnPart != null ? Side.fromLetter(turnPart) : Side.sente;
  if (turn == null) {
    return const Failure(SfenException(IllegalSfenCause.turn));
  }

  // Hands
  final handsPart = parts.isNotEmpty ? parts.removeAt(0) : null;
  Result<Hands> hands = const Success(Hands.empty);
  Square? lastDest;
  Square? lastLionCapture;

  if (handsPart != null) {
    if (rule == Rule.chushogi) {
      final destSquare = Square.parse(handsPart);
      if (destSquare != null) {
        lastLionCapture = destSquare;
      }
    } else {
      hands = parseHandsSfen(rule, handsPart);
      if (hands.isError()) return Failure(hands.exceptionOrNull()!);
    }
  }

  //History
  final history = History.empty
      .addPosition(boardPart)
      .addLastDest(lastDest)
      .addLastLionCapture(lastLionCapture)
      .copyWith(initialSfen: boardPart);

  // Move number
  final moveNumberPart = parts.isNotEmpty ? parts.removeAt(0) : null;
  final moveNumber =
      moveNumberPart != null && moveNumberPart.isNotEmpty
          ? _parseSmallUint(moveNumberPart)
          : 1;
  if (moveNumber == null) {
    return const Failure(SfenException(IllegalSfenCause.turn));
  }

  if (parts.isNotEmpty) {
    return const Failure(SfenException(IllegalSfenCause.format));
  }

  return setupPosition(
    rule,
    Setup(
      board: board.getOrThrow(),
      hands: hands.getOrThrow(),
      history: history,
      turn: turn,
      moveNumber: moveNumber,
    ),
    strict: strict,
  );
}

String makeBoardSfen(Rule rule, Board board) {
  final dims = dimensions(rule);
  String sfen = '';
  int empty = 0;

  for (int rank = 0; rank < dims.ranks; rank++) {
    for (int file = dims.files - 1; file >= 0; file--) {
      final square = Square.fromCoords(File(file), Rank(rank));
      final piece = board.pieceAt(square);
      if (piece == null) {
        empty++;
      } else {
        if (empty > 0) {
          sfen += empty.toString();
          empty = 0;
        }
        sfen += pieceToForsyth(rule)(piece)!;
      }

      if (file == 0) {
        if (empty > 0) {
          sfen += empty.toString();
          empty = 0;
        }
        if (rank != dims.ranks - 1) sfen += '/';
      }
    }
  }
  return sfen;
}

String makeHandSfen(Rule rule, Hand hand) {
  return handRoles(rule).map((role) {
    final r = roleToForsyth(rule)(role)!;
    final n = hand.countOf(role);
    if (n > 1) {
      return '$n$r';
    } else if (n == 1) {
      return r;
    } else {
      return '';
    }
  }).join();
}

String makeHandsSfen(Rule rule, Hands hands) {
  final handsStr =
      makeHandSfen(rule, hands.side(Side.sente)).toUpperCase() +
      makeHandSfen(rule, hands.side(Side.gote));
  return handsStr.isEmpty ? '-' : handsStr;
}

String _lastLionCapture(Square? square) {
  return square != null ? square.name : '-';
}

String makeSfen(Position pos) {
  return [
    makeBoardSfen(pos.rule, pos.board),
    pos.turn.letter,
    if (pos.rule == Rule.chushogi)
      _lastLionCapture(pos.history.lastLionCapture)
    else
      makeHandsSfen(pos.rule, pos.hands),
    pos.moveNumber.clamp(1, 9999).toString(),
  ].join(' ');
}

String? _chushogiRoleToForsyth(Role role) => switch (role) {
  Role.lance => 'l',
  Role.whitehorse => '+l',
  Role.leopard => 'f',
  Role.bishoppromoted => '+f',
  Role.copper => 'c',
  Role.sidemoverpromoted => '+c',
  Role.silver => 's',
  Role.verticalmoverpromoted => '+s',
  Role.gold => 'g',
  Role.rookpromoted => '+g',
  Role.king => 'k',
  Role.elephant => 'e',
  Role.prince => '+e',
  Role.chariot => 'a',
  Role.whale => '+a',
  Role.bishop => 'b',
  Role.horsepromoted => '+b',
  Role.tiger => 't',
  Role.stag => '+t',
  Role.kirin => 'o',
  Role.lionpromoted => '+o',
  Role.phoenix => 'x',
  Role.queenpromoted => '+x',
  Role.sidemover => 'm',
  Role.boar => '+m',
  Role.verticalmover => 'v',
  Role.ox => '+v',
  Role.rook => 'r',
  Role.dragonpromoted => '+r',
  Role.horse => 'h',
  Role.falcon => '+h',
  Role.dragon => 'd',
  Role.eagle => '+d',
  Role.lion => 'n',
  Role.queen => 'q',
  Role.pawn => 'p',
  Role.promotedpawn => '+p',
  Role.gobetween => 'i',
  Role.elephantpromoted => '+i',
  _ => null,
};

Role? _chushogiForsythToRole(String str) => switch (str.toLowerCase()) {
  'l' => Role.lance,
  '+l' => Role.whitehorse,
  'f' => Role.leopard,
  '+f' => Role.bishoppromoted,
  'c' => Role.copper,
  '+c' => Role.sidemoverpromoted,
  's' => Role.silver,
  '+s' => Role.verticalmoverpromoted,
  'g' => Role.gold,
  '+g' => Role.rookpromoted,
  'k' => Role.king,
  'e' => Role.elephant,
  '+e' => Role.prince,
  'a' => Role.chariot,
  '+a' => Role.whale,
  'b' => Role.bishop,
  '+b' => Role.horsepromoted,
  't' => Role.tiger,
  '+t' => Role.stag,
  'o' => Role.kirin,
  '+o' => Role.lionpromoted,
  'x' => Role.phoenix,
  '+x' => Role.queenpromoted,
  'm' => Role.sidemover,
  '+m' => Role.boar,
  'v' => Role.verticalmover,
  '+v' => Role.ox,
  'r' => Role.rook,
  '+r' => Role.dragonpromoted,
  'h' => Role.horse,
  '+h' => Role.falcon,
  'd' => Role.dragon,
  '+d' => Role.eagle,
  'n' => Role.lion,
  'q' => Role.queen,
  'p' => Role.pawn,
  '+p' => Role.promotedpawn,
  'i' => Role.gobetween,
  '+i' => Role.elephantpromoted,
  _ => null,
};
String? _minishogiRoleToForsyth(Role role) => switch (role) {
  Role.king => 'k',
  Role.gold => 'g',
  Role.silver => 's',
  Role.promotedsilver => '+s',
  Role.bishop => 'b',
  Role.horse => '+b',
  Role.rook => 'r',
  Role.dragon => '+r',
  Role.pawn => 'p',
  Role.tokin => '+p',
  _ => null,
};

Role? _minishogiForsythToRole(String ch) => switch (ch.toLowerCase()) {
  'k' => Role.king,
  's' => Role.silver,
  '+s' => Role.promotedsilver,
  'g' => Role.gold,
  'b' => Role.bishop,
  '+b' => Role.horse,
  'r' => Role.rook,
  '+r' => Role.dragon,
  'p' => Role.pawn,
  '+p' => Role.tokin,
  _ => null,
};

String? _standardRoleToForsyth(Role role) => switch (role) {
  Role.lance => 'l',
  Role.promotedlance => '+l',
  Role.knight => 'n',
  Role.promotedknight => '+n',
  Role.silver => 's',
  Role.promotedsilver => '+s',
  Role.gold => 'g',
  Role.king => 'k',
  Role.bishop => 'b',
  Role.horse => '+b',
  Role.rook => 'r',
  Role.dragon => '+r',
  Role.pawn => 'p',
  Role.tokin => '+p',
  _ => null,
};

Role? _standardForsythToRole(String ch) => switch (ch.toLowerCase()) {
  'l' => Role.lance,
  '+l' => Role.promotedlance,
  'n' => Role.knight,
  '+n' => Role.promotedknight,
  's' => Role.silver,
  '+s' => Role.promotedsilver,
  'g' => Role.gold,
  'k' => Role.king,
  'b' => Role.bishop,
  '+b' => Role.horse,
  'r' => Role.rook,
  '+r' => Role.dragon,
  'p' => Role.pawn,
  '+p' => Role.tokin,
  _ => null,
};
String? _kyotoshogiRoleToForsyth(Role role) => switch (role) {
  Role.king => 'k',
  Role.pawn => 'p',
  Role.rook => 'r',
  Role.silver => 's',
  Role.bishop => 'b',
  Role.gold => 'g',
  Role.knight => 'n',
  Role.tokin => 't',
  Role.lance => 'l',
  _ => null,
};

Role? _kyotoshogiForsythToRole(String ch) => switch (ch.toLowerCase()) {
  'k' => Role.king,
  'p' => Role.pawn,
  'r' => Role.rook,
  '+p' => Role.rook,
  's' => Role.silver,
  'b' => Role.bishop,
  '+s' => Role.bishop,
  'g' => Role.gold,
  '+n' => Role.gold,
  'n' => Role.knight,
  't' => Role.tokin,
  '+l' => Role.tokin,
  'l' => Role.lance,
  _ => null,
};

String? _dobutsuRoleToForsyth(Role role) => switch (role) {
  Role.king => 'k',
  Role.pawn => 'p',
  Role.rook => 'r',
  Role.bishop => 'b',
  Role.tokin => '+p',
  _ => null,
};

Role? _dobutsuForsythToRole(String ch) => switch (ch.toLowerCase()) {
  'k' => Role.king,
  'l' => Role.king,
  'p' => Role.pawn,
  'c' => Role.pawn,
  'r' => Role.rook,
  'g' => Role.rook,
  'b' => Role.bishop,
  'e' => Role.bishop,
  '+p' => Role.tokin,
  '+c' => Role.tokin,
  _ => null,
};
