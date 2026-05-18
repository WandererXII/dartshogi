import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../attacks.dart';
import '../../core/move_drop.dart';
import '../../core/piece.dart';
import '../../core/role.dart';
import '../../core/rule.dart';
import '../../core/side.dart';
import '../../core/square.dart';
import '../../position/position.dart';
import '../../position/utils.dart';
import '../../square_set.dart';
import '../utils.dart';

const _silverGoldRoles = [
  Role.gold,
  Role.silver,
  Role.promotedlance,
  Role.promotedknight,
  Role.promotedsilver,
  Role.promotedpawn,
  Role.tokin,
];

const _majorRoles = [Role.bishop, Role.rook, Role.horse, Role.dragon];

// ７六歩
String? makeJapaneseMoveOrDrop(
  Position pos,
  MoveOrDrop md, [
  Square? lastDest,
]) {
  if (md is DropMove) {
    final ambStr =
        aimingAt(
              pos,
              pos.board
                  .byRoles(
                    [md.role].concat(roleKanjiDuplicates(pos.rule)(md.role)),
                  )
                  .intersect(pos.board.bySide(pos.turn)),
              md.to,
            ).isEmpty
            ? ''
            : '打';
    return '${makeJapaneseSquare(md.to)}${roleToKanji(pos.rule)(md.role)}$ambStr';
  } else if (md is NormalMove) {
    final piece = pos.board.pieceAt(md.from);
    if (piece == null) return null;

    final roleStr = roleToKanji(pos.rule)(piece.role);
    final ambPieces = aimingAt(
      pos,
      pos.board
          .byRoles(
            [piece.role].concat(roleKanjiDuplicates(pos.rule)(piece.role)),
          )
          .intersect(pos.board.bySide(piece.side)),
      md.to,
    ).withoutSquare(md.from);
    final ambStr =
        ambPieces.isEmpty
            ? ''
            : _disambiguate(pos.rule, piece, md.from, md.to, ambPieces);

    if (md.midStep != null) {
      final midCapture = pos.board.pieceAt(md.midStep!);
      final igui = midCapture != null && md.to == md.from;
      if (igui) return '${makeJapaneseSquare(md.midStep!)}居喰い';
      if (md.to == md.from) return 'じっと';
      return '${makeJapaneseSquare(md.midStep!)}・${makeJapaneseSquare(md.to)}$roleStr$ambStr';
    } else {
      final lastTo = lastDest ?? pos.history.lastDest;
      final destStr = lastTo == md.to ? '同　' : makeJapaneseSquare(md.to);
      final promStr =
          md.promotion
              ? '成'
              : pieceCanPromote(
                pos.rule,
                piece,
                md.from,
                md.to,
                pos.board.pieceAt(md.to),
              )
              ? '不成'
              : '';
      return '$destStr$roleStr$ambStr$promStr';
    }
  } else {
    return null;
  }
}

String _disambiguate(
  Rule rule,
  Piece piece,
  Square orig,
  Square dest,
  SquareSet others,
) {
  final myRank = orig.rank;
  final myFile = orig.file;

  final destRank = dest.rank;
  final destFile = dest.file;

  final movingUp = myRank > destRank;
  final movingDown = myRank < destRank;

  final jumpsButShouldnt =
      rule == Rule.annanshogi &&
      piece.role != Role.knight &&
      (myFile - destFile).abs() == 1 &&
      (myRank - destRank).abs() == 2;

  // special case - gold-like/silver piece is moving directly forward
  if (myFile == destFile &&
      (piece.side == Side.sente) == movingUp &&
      (_silverGoldRoles.contains(piece.role) ||
          (rule == Rule.annanshogi && _majorRoles.contains(piece.role))) &&
      others.intersect(SquareSet.fromRank(myRank)).isNotEmpty) {
    return '直';
  }

  // special case for lion moves on the same file
  if (const [Role.lion, Role.lionpromoted, Role.falcon].contains(piece.role) &&
      destFile == myFile &&
      kingAttacks(orig).isIntersected(others)) {
    return orig.dist(dest) == 2 ? '跳' : '直';
  }

  // is this the only piece moving in certain vertical direction (up, down, none - horizontally)
  if (!others.squares
      .map((s) => s.rank)
      .any((r) => r < destRank == movingDown && r > destRank == movingUp)) {
    return _verticalDisambiguation(
      rule,
      piece,
      movingUp,
      movingDown,
      jumpsButShouldnt,
    );
  }

  final othersFiles = others.squares.map((s) => s.file).toList();
  final rightest = othersFiles.reduce((prev, cur) => prev < cur ? prev : cur);
  final leftest = othersFiles.reduce((prev, cur) => prev > cur ? prev : cur);

  // is this piece positioned most on one side or in the middle
  if (rightest > myFile ||
      leftest < myFile ||
      (others.size == 2 && rightest < myFile && leftest > myFile)) {
    return _sideDisambiguation(piece, rightest > myFile, leftest < myFile);
  }

  return _sideDisambiguation(piece, rightest >= myFile, leftest <= myFile) +
      _verticalDisambiguation(
        rule,
        piece,
        movingUp,
        movingDown,
        jumpsButShouldnt,
      );
}

String _verticalDisambiguation(
  Rule rule,
  Piece piece,
  bool up,
  bool down,
  bool jumpOver,
) {
  if (jumpOver) return '跳';
  if (up == down) return '寄';
  if ((piece.side == Side.sente && up) || (piece.side == Side.gote && down)) {
    return rule != Rule.chushogi &&
            (piece.role == Role.horse || piece.role == Role.dragon)
        ? '行'
        : '上';
  }
  return '引';
}

String _sideDisambiguation(Piece piece, bool right, bool left) {
  if (left == right) {
    return '中';
  }
  if ((piece.side == Side.sente && right) ||
      (piece.side == Side.gote && left)) {
    return '右';
  }
  return '左';
}
