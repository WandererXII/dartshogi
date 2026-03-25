import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../core/move_drop.dart';
import '../../core/square.dart';
import '../../position/position.dart';
import '../../position/utils.dart';
import '../utils.dart';

// 歩-76
String? makeKitaoKawasakiMoveOrDrop(
  Position pos,
  MoveOrDrop md, [
  Square? lastDest,
]) {
  if (md is DropMove) {
    return '${roleToKanji(pos.rule)(md.role)}*${makeNumberSquare(md.to)}';
  } else if (md is NormalMove) {
    final piece = pos.board.pieceAt(md.from);
    if (piece == null) return null;

    final roleStr = roleToKanji(pos.rule)(piece.role).replaceAll('成', '+');
    final ambStr =
        aimingAt(
              pos,
              pos.board
                  .byRoles(
                    [
                      piece.role,
                    ].concat(roleKanjiDuplicates(pos.rule)(piece.role)),
                  )
                  .intersect(pos.board.bySide(piece.side)),
              md.to,
            ).withoutSquare(md.from).isEmpty
            ? ''
            : '(${makeNumberSquare(md.from)})';
    final toCapture = pos.board.pieceAt(md.to);
    final actionStr = toCapture != null ? 'x' : '-';

    if (md.midStep != null) {
      final midCapture = pos.board.pieceAt(md.midStep!);
      final igui = midCapture != null && md.to == md.from;
      if (igui) return '$roleStr${ambStr}x!${makeNumberSquare(md.midStep!)}';
      if (md.to == md.from) return '--';
      return '$roleStr$ambStr${midCapture != null ? 'x' : '-'}${makeNumberSquare(md.midStep!)}$actionStr${makeNumberSquare(md.to)}';
    } else {
      final lastTo = lastDest ?? pos.lastDest;
      final destStr = lastTo == md.to ? '' : makeNumberSquare(md.to);
      final promStr =
          md.promotion
              ? '+'
              : pieceCanPromote(pos.rule, piece, md.from, md.to, toCapture)
              ? '='
              : '';
      return '$roleStr$ambStr$actionStr$destStr$promStr';
    }
  } else {
    return null;
  }
}
