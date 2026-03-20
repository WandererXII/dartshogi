import 'package:meta/meta.dart';
import './square.dart';
import './role.dart';

/// Base class for a shogi move.
///
/// A [MoveOrDrop] can be either a [NormalMove] or a [DropMove].
@immutable
sealed class MoveOrDrop {
  const MoveOrDrop({
    required this.to,
  });

  /// The target square of this move.
  final Square to;

  /// Gets the USI notation of this move.
  String get usi;

  static final RegExp _usiDropRegex = RegExp(r'^([PLNSGBRT])\*(\d\d?[a-p])$');
  static final RegExp _usiMoveRegex =
      RegExp(r'^(\d\d?[a-p])(\d\d?[a-p])?(\d\d?[a-p])(\+|=|\?)?$');

  /// Parses a USI string into a move.
  ///
  /// Will return a [NormalMove] or a [DropMove] depending on the USI string.
  ///
  /// Returns `null` if USI string is not valid.
  static MoveOrDrop? parse(String str) {
    final dropMatch = _usiDropRegex.firstMatch(str);
    if (dropMatch != null) {
      final g1 = dropMatch.group(1);
      final role = g1 != null ? DropMove._parseUsiDropRole(g1) : null;
      final g2 = dropMatch.group(2);
      final to = g2 != null ? Square.parse(g2) : null;

      if (role != null && to != null) {
        return DropMove(
          role: role,
          to: to,
        );
      }
    }

    // 2. Try Move Match
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

  /// Returns `true` if [square] is a square of this move.
  bool hasSquare(Square square);

  /// Returns an iterable of all squares involved in this move.
  Iterable<Square> get squares;

  @override
  String toString() {
    return 'MoveOrDrop($usi)';
  }
}

/// Represents a chess move, which is possibly a promotion.
@immutable
class NormalMove extends MoveOrDrop {
  const NormalMove(
      {required this.from,
      required super.to,
      this.promotion = false,
      this.midStep});

  /// The origin square of this move.
  final Square from;

  /// Is the piece being promoted.
  final bool promotion;

  /// Square reached between [from] and [to] - used for lion in chushogi.
  final Square? midStep;

  @override
  bool hasSquare(Square square) =>
      square == from || square == to || square == midStep;

  @override
  Iterable<Square> get squares => [from, to];

  /// Returns a copy of this move with a [promotion] role.
  NormalMove withPromotion(bool promotion) =>
      NormalMove(from: from, to: to, promotion: promotion);

  /// Returns a copy of this move with a [promotion] role.
  NormalMove withMidStep(Square? sq) =>
      NormalMove(from: from, to: to, promotion: promotion, midStep: sq);

  /// Gets USI notation, like `7g7f+`.
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

/// Represents a drop move.
@immutable
class DropMove extends MoveOrDrop {
  /// Constructs a [DropMove] from a target square and a role.
  const DropMove({
    required super.to,
    required this.role,
  });

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

  /// The [Role] of the dropped piece.
  final Role role;

  @override
  bool hasSquare(Square square) => square == to;

  @override
  Iterable<Square> get squares => [to];

  /// Gets USI notation of the drop, like `P*7f`.
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
