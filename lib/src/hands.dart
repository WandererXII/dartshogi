import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

import './core/piece.dart';
import './core/role.dart';
import './core/side.dart';

@immutable
class Hand {
  const Hand({required this.handMap});

  final IMap<Role, int> handMap;

  static const empty = Hand(handMap: IMapConst({}));

  @useResult
  Hand combine(Hand other) {
    var newMap = handMap;
    for (final entry in other.handMap.entries) {
      newMap = newMap.update(entry.key, (curr) => curr + entry.value, ifAbsent: () => entry.value);
    }
    return Hand(handMap: newMap);
  }

  int countOf(Role role) => handMap[role] ?? 0;

  @useResult
  Hand _update(Role role, int offset) => Hand(
          handMap: handMap.update(
        role,
        (cnt) => cnt + offset,
        ifAbsent: offset > 0 ? () => offset : null,
        ifRemove: (_, cnt) => cnt <= 0,
      ));

  @useResult
  Hand remove(Role role, {int cnt = 1}) => _update(role, -cnt);

  @useResult
  Hand store(Role role, {int cnt = 1}) => _update(role, cnt);

  bool get nonEmpty => handMap.values.any((cnt) => cnt > 0);
  bool get isEmpty => !nonEmpty;

  int get count => handMap.values.fold(0, (acc, cnt) => acc + cnt);

  Iterable<Role> get roles => handMap.entries.where((e) => e.value > 0).map((e) => e.key);

  // Helper to ensure we don't store zeros or negatives
  static IMap<Role, int> _clean(IMap<Role, int> map) =>
      map.removeWhere((role, count) => count <= 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Hand && _clean(handMap) == _clean(other.handMap));

  @override
  int get hashCode => _clean(handMap).hashCode;
}

@immutable
class Hands {
  const Hands({
    required this.sente,
    required this.gote,
  });

  final Hand sente;
  final Hand gote;

  static const empty = Hands(sente: Hand.empty, gote: Hand.empty);

  @useResult
  Hands combine(Hands other) =>
      Hands(sente: sente.combine(other.sente), gote: gote.combine(other.gote));

  @useResult
  Hands remove(Piece piece, {int cnt = 1}) => Hands(
        gote: piece.side == Side.gote ? gote.remove(piece.role, cnt: cnt) : gote,
        sente: piece.side == Side.sente ? sente.remove(piece.role, cnt: cnt) : sente,
      );

  @useResult
  Hands store(Piece piece, {int cnt = 1}) => Hands(
      gote: piece.side == Side.gote ? gote.store(piece.role, cnt: cnt) : gote,
      sente: piece.side == Side.sente ? sente.store(piece.role, cnt: cnt) : sente);

  Hand side(Side side) => side == Side.sente ? sente : gote;

  int get count => sente.count + gote.count;

  bool get isEmpty => sente.isEmpty && gote.isEmpty;

  bool get nonEmpty => !isEmpty;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is Hands && other.sente == sente && other.gote == gote);
  }

  @override
  int get hashCode => Object.hash(sente, gote);
}
