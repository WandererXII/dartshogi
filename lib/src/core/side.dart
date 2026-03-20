import 'package:fast_immutable_collections/fast_immutable_collections.dart';

/// The player side, sente or gote.
enum Side {
  sente,
  gote;

  /// Gets the opposite side.
  Side get opposite => this == Side.sente ? Side.gote : Side.sente;
}

typedef BySide<T> = IMap<Side, T>;
