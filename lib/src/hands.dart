import 'package:meta/meta.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import './core/role.dart';
import './core/side.dart';

@immutable
class Hand {
  const Hand({required this.handMap});

  final IMap<Role, int> handMap;

  static const empty = Hand(handMap: IMapConst({}));

  // Helper to ensure we don't store zeros or negatives
  static IMap<Role, int> _clean(IMap<Role, int> map) =>
      map.removeWhere((role, count) => count <= 0);

  @useResult
  Hand combine(Hand other) {
    var newMap = handMap;
    for (final entry in other.handMap.entries) {
      newMap = newMap.update(entry.key, (curr) => curr + entry.value,
          ifAbsent: () => entry.value);
    }
    return Hand(handMap: _clean(newMap));
  }

  int countOf(Role role) => handMap[role] ?? 0;

  @useResult
  Hand set(Role role, int cnt) => Hand(
          handMap: _clean(handMap.update(
        role,
        (_) => cnt,
        ifAbsent: () => cnt,
      )));

  @useResult
  Hand drop(Role role) => set(role, countOf(role) - 1);

  @useResult
  Hand capture(Role role) => set(role, countOf(role) + 1);

  bool get isEmpty => handMap.isEmpty;
  bool get nonEmpty => handMap.isNotEmpty;

  int get count => handMap.values.fold(0, (acc, cnt) => acc + cnt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Hand && handMap == other.handMap;

  @override
  int get hashCode => handMap.hashCode;
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

  Hand side(Side side) => side == Side.sente ? sente : gote;

  int get count => sente.count + gote.count;

  bool get isEmpty => sente.isEmpty && gote.isEmpty;

  bool get nonEmpty => !isEmpty;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Hands && other.sente == sente && other.gote == gote);
  }

  @override
  int get hashCode => Object.hash(sente, gote);
}
