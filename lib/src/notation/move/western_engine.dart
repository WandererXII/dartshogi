import '../../core/move_drop.dart';
import '../../position/position.dart';
import '../../position/utils.dart';
import '../utils.dart';

// P-76
String? makeWesternEngineMoveOrDrop(Position pos, MoveOrDrop md) {
  if (md is DropMove) {
    return '${roleToWestern(pos.rule)(md.role)}*${md.to.name}';
  } else if (md is NormalMove) {
    final piece = pos.board.pieceAt(md.from);
    if (piece == null) return null;

    final roleStr = roleToWestern(pos.rule)(piece.role);
    final disambStr =
        aimingAt(
              pos,
              pos.board.piecesOf(piece.side, piece.role),
              md.to,
            ).withoutSquare(md.from).isEmpty
            ? ''
            : md.from.name;
    final toCapture = pos.board.pieceAt(md.to);
    final toStr = '${toCapture != null ? 'x' : '-'}${md.to.name}';

    if (md.midStep != null) {
      final midCapture = pos.board.pieceAt(md.midStep!);
      final igui = midCapture != null && md.to == md.from;
      if (igui) return '$roleStr${disambStr}x!${md.midStep!.name}';
      if (md.to == md.from) return '--';
      return '$roleStr$disambStr${midCapture != null ? 'x' : '-'}${md.midStep!.name}$toStr';
    } else {
      final promStr =
          md.promotion
              ? '+'
              : pieceCanPromote(pos.rule, piece, md.from, md.to, toCapture)
              ? '='
              : '';
      return '$roleStr$disambStr$toStr$promStr';
    }
  } else {
    return null;
  }
}
