import 'package:meta/meta.dart';

import './role.dart';
import './square.dart';

@immutable
sealed class MoveOrDrop {
  const MoveOrDrop({required this.to});

  final Square to;

  String get usi;

  static final RegExp _usiDropRegex = RegExp(r'^([PLNSGBRT])\*(\d\d?[a-p])$');
  static final RegExp _usiMoveRegex = RegExp(
    r'^(\d\d?[a-p])(\d\d?[a-p])?(\d\d?[a-p])(\+|=|\?)?$',
  );

  static MoveOrDrop? parse(String str) {
    final dropMatch = _usiDropRegex.firstMatch(str);
    if (dropMatch != null) {
      final g1 = dropMatch.group(1);
      final role = g1 != null ? DropMove._parseUsiDropRole(g1) : null;
      final g2 = dropMatch.group(2);
      final to = g2 != null ? Square.parse(g2) : null;

      if (role != null && to != null) {
        return DropMove(role: role, to: to);
      }
    }

    final moveMatch = _usiMoveRegex.firstMatch(str);
    if (moveMatch != null) {
      final g1 = moveMatch.group(1);
      final from = g1 != null ? Square.parse(g1) : null;

      final g2 = moveMatch.group(2);
      final midStep = g2 != null ? Square.parse(g2) : null;

      final g3 = moveMatch.group(3);
      final to = g3 != null ? Square.parse(g3) : null;

      final promotion = moveMatch.group(4) == '+';

      if (from != null && to != null) {
        return NormalMove(
          from: from,
          to: to,
          promotion: promotion,
          midStep: midStep,
        );
      }
    }

    return null;
  }

  bool hasSquare(Square square);

  Iterable<Square> get squares;

  @override
  String toString() {
    return 'MoveOrDrop($usi)';
  }
}

@immutable
class NormalMove extends MoveOrDrop {
  const NormalMove({
    required this.from,
    required super.to,
    this.promotion = false,
    this.midStep,
  });

  final Square from;
  final bool promotion;
  final Square? midStep;

  @override
  bool hasSquare(Square square) =>
      square == from || square == to || square == midStep;

  @override
  Iterable<Square> get squares => [from, to];

  NormalMove withPromotion(bool promotion) =>
      NormalMove(from: from, to: to, promotion: promotion);

  NormalMove withMidStep(Square? sq) =>
      NormalMove(from: from, to: to, promotion: promotion, midStep: sq);

  @override
  String get usi {
    final base = "${from.name}${midStep?.name ?? ''}${to.name}";
    return promotion ? '$base+' : base;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NormalMove &&
            runtimeType == other.runtimeType &&
            from == other.from &&
            to == other.to &&
            promotion == other.promotion &&
            midStep == other.midStep;
  }

  @override
  int get hashCode => Object.hash(from, to, promotion, midStep);
}

@immutable
class DropMove extends MoveOrDrop {
  const DropMove({required super.to, required this.role});

  static Role? _parseUsiDropRole(String ch) => switch (ch.toUpperCase()) {
    'P' => Role.pawn,
    'L' => Role.lance,
    'N' => Role.knight,
    'S' => Role.silver,
    'G' => Role.gold,
    'B' => Role.bishop,
    'R' => Role.rook,
    'T' => Role.tokin,
    _ => null,
  };

  static String makeUsiDropRole(Role role) {
    return role == Role.knight ? 'N' : role.name[0].toUpperCase();
  }

  final Role role;

  @override
  bool hasSquare(Square square) => square == to;

  @override
  Iterable<Square> get squares => [to];

  @override
  String get usi => '${makeUsiDropRole(role)}*${to.name}';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType && hashCode == other.hashCode;
  }

  @override
  int get hashCode => Object.hash(to, role);
}
