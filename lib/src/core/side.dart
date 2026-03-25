import 'package:fast_immutable_collections/fast_immutable_collections.dart';

enum Side {
  sente,
  gote;

  Side get opposite => this == Side.sente ? Side.gote : Side.sente;

  String get letter => this == Side.sente ? 'b' : 'w';

  static Side? fromLetter(String letter) {
    if (letter == 'b') return Side.sente;
    if (letter == 'w') return Side.gote;
    return null;
  }
}

typedef BySide<T> = IMap<Side, T>;
