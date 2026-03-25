import 'package:meta/meta.dart';

import '../core/piece.dart';
import '../core/role.dart';
import '../core/rule.dart';
import '../core/side.dart';
import '../core/square.dart';
import '../square_set.dart';

bool pieceCanPromote(
  Rule rule,
  Piece piece,
  Square from,
  Square to,
  Piece? capture,
) => switch (rule) {
  Rule.chushogi => () {
    final pZone = promotionZone(rule, piece.side);
    final enteringZone = !pZone.has(from) && pZone.has(to);
    final captureInZone = capture != null && (pZone.has(from) || pZone.has(to));
    final forcedEdgeRank =
        (piece.role == Role.pawn || piece.role == Role.lance) &&
        to.rank == (piece.side == Side.sente ? 0 : dimensions(rule).ranks - 1);
    return promotableRoles(rule).contains(piece.role) &&
        (enteringZone || captureInZone || forcedEdgeRank);
  }(),
  Rule.kyotoshogi => promotableRoles(rule).contains(piece.role),
  _ =>
    promotableRoles(rule).contains(piece.role) &&
        (promotionZone(rule, piece.side).has(from) ||
            promotionZone(rule, piece.side).has(to)),
};

bool pieceForcePromote(Rule rule, Piece piece, Square sq) => switch (rule) {
  Rule.chushogi || Rule.annanshogi => false,
  Rule.kyotoshogi => promotableRoles(rule).contains(piece.role),
  _ => () {
    final dims = dimensions(rule);
    final rank = sq.rank;
    if (piece.role == Role.lance || piece.role == Role.pawn) {
      return rank == (piece.side == Side.sente ? 0 : dims.ranks - 1);
    } else if (piece.role == Role.knight) {
      return rank == (piece.side == Side.sente ? 0 : dims.ranks - 1) ||
          rank == (piece.side == Side.sente ? 1 : dims.ranks - 2);
    }
    return false;
  }(),
};

bool promotableOnDrop(Rule rule, Piece piece) => switch (rule) {
  Rule.kyotoshogi => promotableRoles(rule).contains(piece.role),
  _ => false,
};

List<Role> allRoles(Rule rule) => switch (rule) {
  Rule.chushogi => const [
    Role.lance,
    Role.leopard,
    Role.copper,
    Role.silver,
    Role.gold,
    Role.elephant,
    Role.chariot,
    Role.bishop,
    Role.tiger,
    Role.phoenix,
    Role.kirin,
    Role.sidemover,
    Role.verticalmover,
    Role.rook,
    Role.horse,
    Role.dragon,
    Role.queen,
    Role.lion,
    Role.pawn,
    Role.gobetween,
    Role.king,
    Role.promotedpawn,
    Role.ox,
    Role.stag,
    Role.boar,
    Role.falcon,
    Role.prince,
    Role.eagle,
    Role.whale,
    Role.whitehorse,
    Role.dragonpromoted,
    Role.horsepromoted,
    Role.lionpromoted,
    Role.queenpromoted,
    Role.bishoppromoted,
    Role.elephantpromoted,
    Role.sidemoverpromoted,
    Role.verticalmoverpromoted,
    Role.rookpromoted,
  ],
  Rule.minishogi => const [
    Role.rook,
    Role.bishop,
    Role.gold,
    Role.silver,
    Role.pawn,
    Role.dragon,
    Role.horse,
    Role.promotedsilver,
    Role.tokin,
    Role.king,
  ],
  Rule.kyotoshogi => const [
    Role.rook,
    Role.pawn,
    Role.silver,
    Role.bishop,
    Role.gold,
    Role.knight,
    Role.lance,
    Role.tokin,
    Role.king,
  ],
  Rule.dobutsu => const [
    Role.king,
    Role.rook,
    Role.bishop,
    Role.pawn,
    Role.tokin,
  ],
  _ => const [
    Role.rook,
    Role.bishop,
    Role.gold,
    Role.silver,
    Role.knight,
    Role.lance,
    Role.pawn,
    Role.dragon,
    Role.horse,
    Role.tokin,
    Role.promotedsilver,
    Role.promotedknight,
    Role.promotedlance,
    Role.king,
  ],
};

List<Role> handRoles(Rule rule) => switch (rule) {
  Rule.chushogi => const [],
  Rule.minishogi => const [
    Role.rook,
    Role.bishop,
    Role.gold,
    Role.silver,
    Role.pawn,
  ],
  Rule.kyotoshogi => const [Role.tokin, Role.gold, Role.silver, Role.pawn],
  Rule.dobutsu => const [Role.rook, Role.bishop, Role.pawn],
  _ => const [
    Role.rook,
    Role.bishop,
    Role.gold,
    Role.silver,
    Role.knight,
    Role.lance,
    Role.pawn,
  ],
};

List<Role> promotableRoles(Rule rule) => switch (rule) {
  Rule.chushogi => const [
    Role.pawn,
    Role.gobetween,
    Role.sidemover,
    Role.verticalmover,
    Role.rook,
    Role.bishop,
    Role.dragon,
    Role.horse,
    Role.elephant,
    Role.chariot,
    Role.tiger,
    Role.kirin,
    Role.phoenix,
    Role.lance,
    Role.leopard,
    Role.copper,
    Role.silver,
    Role.gold,
  ],
  Rule.minishogi => const [Role.pawn, Role.silver, Role.bishop, Role.rook],
  Rule.kyotoshogi => const [
    Role.rook,
    Role.pawn,
    Role.silver,
    Role.bishop,
    Role.gold,
    Role.knight,
    Role.lance,
    Role.tokin,
  ],
  Rule.dobutsu => const [Role.pawn],
  _ => const [
    Role.pawn,
    Role.lance,
    Role.knight,
    Role.silver,
    Role.bishop,
    Role.rook,
  ],
};

SquareSet fullSquareSet(Rule rule) => switch (rule) {
  Rule.chushogi => SquareSet.fromList([
    0xfff0fff,
    0xfff0fff,
    0xfff0fff,
    0xfff0fff,
    0xfff0fff,
    0xfff0fff,
    0x0,
    0x0,
  ]),
  Rule.minishogi || Rule.kyotoshogi => SquareSet.fromList([
    0x1f001f,
    0x1f001f,
    0x1f,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
  ]),
  Rule.dobutsu => SquareSet.fromList([
    0x70007,
    0x70007,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
  ]),
  _ => SquareSet.fromList([
    0x1ff01ff,
    0x1ff01ff,
    0x1ff01ff,
    0x1ff01ff,
    0x1ff,
    0x0,
    0x0,
    0x0,
  ]),
};

SquareSet promotionZone(Rule rule, Side side) => switch (rule) {
  Rule.chushogi =>
    side == Side.sente
        ? SquareSet.fromList([
          0xfff0fff,
          0xfff0fff,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
          0x0,
        ])
        : SquareSet.fromList([
          0x0,
          0x0,
          0x0,
          0x0,
          0xfff0fff,
          0xfff0fff,
          0x0,
          0x0,
        ]),
  Rule.minishogi =>
    side == Side.sente
        ? SquareSet.fromList([0x1f, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])
        : SquareSet.fromList([0x0, 0x0, 0x1f, 0x0, 0x0, 0x0, 0x0, 0x0]),
  Rule.kyotoshogi => SquareSet.fromList([
    0x1f001f,
    0x1f001f,
    0x1f,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
  ]),
  Rule.dobutsu =>
    side == Side.sente
        ? SquareSet.fromList([0x7, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])
        : SquareSet.fromList([0x0, 0x70000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]),
  _ =>
    side == Side.sente
        ? SquareSet.fromList([0x1ff01ff, 0x1ff, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0])
        : SquareSet.fromList([0x0, 0x0, 0x0, 0x1ff01ff, 0x1ff, 0x0, 0x0, 0x0]),
};

@immutable
class Dimensions {
  const Dimensions({required this.files, required this.ranks});
  final int files;
  final int ranks;
}

Dimensions dimensions(Rule rule) => switch (rule) {
  Rule.chushogi => const Dimensions(files: 12, ranks: 12),
  Rule.minishogi || Rule.kyotoshogi => const Dimensions(files: 5, ranks: 5),
  Rule.dobutsu => const Dimensions(files: 3, ranks: 4),
  _ => const Dimensions(files: 9, ranks: 9),
};

Role? promote(Rule rule, Role role) => switch (rule) {
  Rule.chushogi => _chuShogiPromote(role),
  Rule.minishogi => _miniShogiPromote(role),
  Rule.kyotoshogi => _kyotoShogiPromote(role),
  Rule.dobutsu => _dobutsuPromote(role),
  _ => _standardPromote(role),
};

Role? unpromote(Rule rule, Role role) => switch (rule) {
  Rule.chushogi => _chuShogiUnpromote(role),
  Rule.minishogi => _miniShogiUnpromote(role),
  Rule.kyotoshogi => _kyotoShogiPromote(role),
  Rule.dobutsu => _dobutsuUnpromote(role),
  _ => _standardUnpromote(role),
};

Role? unpromoteForHand(Rule rule, Role role) {
  if (handRoles(rule).contains(role)) return role;
  final unpromotedRole = unpromote(rule, role);
  if (unpromotedRole != null && handRoles(rule).contains(unpromotedRole)) {
    return unpromotedRole;
  }
  return null;
}

Role? _standardPromote(Role role) => switch (role) {
  Role.pawn => Role.tokin,
  Role.lance => Role.promotedlance,
  Role.knight => Role.promotedknight,
  Role.silver => Role.promotedsilver,
  Role.bishop => Role.horse,
  Role.rook => Role.dragon,
  _ => null,
};

Role? _standardUnpromote(Role role) => switch (role) {
  Role.tokin => Role.pawn,
  Role.promotedlance => Role.lance,
  Role.promotedknight => Role.knight,
  Role.promotedsilver => Role.silver,
  Role.horse => Role.bishop,
  Role.dragon => Role.rook,
  _ => null,
};

Role? _miniShogiPromote(Role role) => switch (role) {
  Role.pawn => Role.tokin,
  Role.silver => Role.promotedsilver,
  Role.bishop => Role.horse,
  Role.rook => Role.dragon,
  _ => null,
};

Role? _miniShogiUnpromote(Role role) => switch (role) {
  Role.tokin => Role.pawn,
  Role.promotedsilver => Role.silver,
  Role.horse => Role.bishop,
  Role.dragon => Role.rook,
  _ => null,
};

Role? _chuShogiPromote(Role role) => switch (role) {
  Role.pawn => Role.promotedpawn,
  Role.gobetween => Role.elephantpromoted,
  Role.sidemover => Role.boar,
  Role.verticalmover => Role.ox,
  Role.rook => Role.dragonpromoted,
  Role.bishop => Role.horsepromoted,
  Role.dragon => Role.eagle,
  Role.horse => Role.falcon,
  Role.elephant => Role.prince,
  Role.chariot => Role.whale,
  Role.tiger => Role.stag,
  Role.kirin => Role.lionpromoted,
  Role.phoenix => Role.queenpromoted,
  Role.lance => Role.whitehorse,
  Role.leopard => Role.bishoppromoted,
  Role.copper => Role.sidemoverpromoted,
  Role.silver => Role.verticalmoverpromoted,
  Role.gold => Role.rookpromoted,
  _ => null,
};

Role? _chuShogiUnpromote(Role role) => switch (role) {
  Role.promotedpawn => Role.pawn,
  Role.elephantpromoted => Role.gobetween,
  Role.boar => Role.sidemover,
  Role.ox => Role.verticalmover,
  Role.dragonpromoted => Role.rook,
  Role.horsepromoted => Role.bishop,
  Role.eagle => Role.dragon,
  Role.falcon => Role.horse,
  Role.prince => Role.elephant,
  Role.whale => Role.chariot,
  Role.stag => Role.tiger,
  Role.lionpromoted => Role.kirin,
  Role.queenpromoted => Role.phoenix,
  Role.whitehorse => Role.lance,
  Role.bishoppromoted => Role.leopard,
  Role.sidemoverpromoted => Role.copper,
  Role.verticalmoverpromoted => Role.silver,
  Role.rookpromoted => Role.gold,
  _ => null,
};

Role? _kyotoShogiPromote(Role role) => switch (role) {
  Role.rook => Role.pawn,
  Role.pawn => Role.rook,
  Role.silver => Role.bishop,
  Role.bishop => Role.silver,
  Role.gold => Role.knight,
  Role.knight => Role.gold,
  Role.tokin => Role.lance,
  Role.lance => Role.tokin,
  _ => null,
};

Role? _dobutsuPromote(Role role) => switch (role) {
  Role.pawn => Role.tokin,
  _ => null,
};

Role? _dobutsuUnpromote(Role role) => switch (role) {
  Role.tokin => Role.pawn,
  _ => null,
};
