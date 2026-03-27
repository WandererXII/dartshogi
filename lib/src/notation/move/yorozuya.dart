import '../../core/move_drop.dart';
import '../../core/square.dart';
import '../../position/position.dart';
import './japanese.dart';

const _dizhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

String? makeYorozuyaMoveOrDrop(
  Position pos,
  MoveOrDrop md, [
  Square? lastDest,
]) {
  final jpMove = makeJapaneseMoveOrDrop(pos, md, lastDest);
  return jpMove != null ? convertJapaneseToYorozuya(jpMove) : null;
}

String convertJapaneseToYorozuya(String jp) {
  return jp
      .replaceAll('不成', '')
      .replaceAllMapped(RegExp(r'成$'), (_) => 'ナル')
      .replaceAllMapped(
        // matches full width and ascii digits
        RegExp(r'[\d\uFF10-\uFF19]+'),
        (match) {
          final normalized = match[0]!.replaceAllMapped(
            RegExp(r'[\uFF10-\uFF19]'),
            (c) => String.fromCharCode(c[0]!.codeUnitAt(0) - 0xFF10 + 48),
          );
          final index = int.tryParse(normalized);
          if (index == null) return match[0]!;
          final dizhi =
              index >= 1 && index <= _dizhi.length ? _dizhi[index - 1] : null;
          return dizhi ?? match[0]!;
        },
      );
}
