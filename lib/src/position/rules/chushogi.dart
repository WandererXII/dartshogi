import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../../attacks.dart';
import '../../board.dart';
import '../../core/game_result.dart';
import '../../core/move_drop.dart';
import '../../core/outcome.dart';
import '../../core/piece.dart';
import '../../core/role.dart';
import '../../core/rule.dart';
import '../../core/setup.dart';
import '../../core/side.dart';
import '../../core/square.dart';
import '../../hands.dart';
import '../../history.dart';
import '../../square_set.dart';
import '../../utils.dart';
import '../position.dart';
import '../utils.dart';

@immutable
abstract class Chushogi extends Position {
  const factory Chushogi({
    required Board board,
    required Hands hands,
    required Side turn,
    required History history,
    required int moveNumber,
  }) = _Chushogi;

  const Chushogi._({
    required super.board,
    required super.hands,
    required super.turn,
    required super.history,
    required super.moveNumber,
  });

  @override
  Rule get rule => Rule.chushogi;

  @useResult
  static Result<Chushogi> fromSetup(Setup s, {bool strict = false}) =>
      Position.fromSetupBase(s, Chushogi.new, strict: strict);

  @override
  PositionValidation get validation => const PositionValidation(
    doublePawn: false,
    oppositeCheck: false,
    unpromotedForcedPromotion: false,
    maxNumberOfRoyalPieces: 2,
  );

  @override
  SquareSet squareAttackers(Square square, Side attacker, SquareSet occupied) {
    final defender = attacker.opposite;
    return board
        .bySide(attacker)
        .intersect(
          lanceAttacks(square, defender, occupied)
              .intersect(board.byRole(Role.lance))
              .union(
                leopardAttacks(square).intersect(board.byRole(Role.leopard)),
              )
              .union(
                copperAttacks(
                  square,
                  defender,
                ).intersect(board.byRole(Role.copper)),
              )
              .union(
                silverAttacks(
                  square,
                  defender,
                ).intersect(board.byRole(Role.silver)),
              )
              .union(
                goldAttacks(
                  square,
                  defender,
                ).intersect(board.byRoles([Role.gold, Role.promotedpawn])),
              )
              .union(
                kingAttacks(square).intersect(
                  board.byRoles([
                    Role.king,
                    Role.prince,
                    Role.dragon,
                    Role.dragonpromoted,
                    Role.horse,
                    Role.horsepromoted,
                  ]),
                ),
              )
              .union(
                elephantAttacks(square, defender).intersect(
                  board.byRoles([Role.elephant, Role.elephantpromoted]),
                ),
              )
              .union(
                chariotAttacks(
                  square,
                  occupied,
                ).intersect(board.byRole(Role.chariot)),
              )
              .union(
                bishopAttacks(square, occupied).intersect(
                  board.byRoles([
                    Role.bishop,
                    Role.bishoppromoted,
                    Role.horse,
                    Role.horsepromoted,
                    Role.queen,
                    Role.queenpromoted,
                  ]),
                ),
              )
              .union(
                tigerAttacks(
                  square,
                  defender,
                ).intersect(board.byRole(Role.tiger)),
              )
              .union(kirinAttacks(square).intersect(board.byRole(Role.kirin)))
              .union(
                phoenixAttacks(square).intersect(board.byRole(Role.phoenix)),
              )
              .union(
                sideMoverAttacks(square, occupied).intersect(
                  board.byRoles([Role.sidemover, Role.sidemoverpromoted]),
                ),
              )
              .union(
                verticalMoverAttacks(square, occupied).intersect(
                  board.byRoles([
                    Role.verticalmover,
                    Role.verticalmoverpromoted,
                  ]),
                ),
              )
              .union(
                rookAttacks(square, occupied).intersect(
                  board.byRoles([
                    Role.rook,
                    Role.rookpromoted,
                    Role.dragon,
                    Role.dragonpromoted,
                    Role.queen,
                    Role.queenpromoted,
                  ]),
                ),
              )
              .union(
                lionAttacks(
                  square,
                ).intersect(board.byRoles([Role.lion, Role.lionpromoted])),
              )
              .union(
                pawnAttacks(
                  square,
                  defender,
                ).intersect(board.byRole(Role.pawn)),
              )
              .union(
                goBetweenAttacks(
                  square,
                ).intersect(board.byRole(Role.gobetween)),
              )
              .union(
                whiteHorseAttacks(
                  square,
                  defender,
                  occupied,
                ).intersect(board.byRole(Role.whitehorse)),
              )
              .union(
                whaleAttacks(
                  square,
                  defender,
                  occupied,
                ).intersect(board.byRole(Role.whale)),
              )
              .union(
                stagAttacks(
                  square,
                  occupied,
                ).intersect(board.byRole(Role.stag)),
              )
              .union(
                boarAttacks(
                  square,
                  occupied,
                ).intersect(board.byRole(Role.boar)),
              )
              .union(
                oxAttacks(square, occupied).intersect(board.byRole(Role.ox)),
              )
              .union(
                falconAttacks(
                  square,
                  defender,
                  occupied,
                ).intersect(board.byRole(Role.falcon)),
              )
              .union(
                eagleAttacks(
                  square,
                  defender,
                  occupied,
                ).intersect(board.byRole(Role.eagle)),
              ),
        );
  }

  // we can move into check - not needed
  @override
  SquareSet squareSnipers(Square square, Side attacker) => SquareSet.empty;

  @override
  SquareSet kingsOf(Side side) =>
      board.byRoles([Role.king, Role.prince]).intersect(board.bySide(side));

  @override
  SquareSet moveDests(Square square, [Context? ctx]) {
    final context = ctx ?? makeCtx();
    final piece = board.pieceAt(square);
    if (piece == null || piece.side != context.side) return SquareSet.empty;

    var pseudo = attacks(
      piece,
      square,
      board.occupied,
    ).diff(board.bySide(context.side));

    final oppSide = context.side.opposite;
    final oppLions = board
        .bySide(oppSide)
        .intersect(board.byRoles([Role.lion, Role.lionpromoted]));

    if (Role.lionRoles.contains(piece.role)) {
      // Only first-step destinations here; second step handled by secondLionStepDests.
      // Don't allow capturing a non-adjacent opponent lion that is protected.
      final neighbors = kingAttacks(square);
      for (final lion in pseudo.diff(neighbors).intersect(oppLions).squares) {
        if (squareAttackers(
          lion,
          oppSide,
          board.occupied.withoutSquare(square),
        ).isNotEmpty) {
          pseudo = pseudo.withoutSquare(lion);
        }
      }
    } else if (history.lastLionCapture != null) {
      // Can't recapture a different lion on the very next move.
      for (final lion in oppLions.intersect(pseudo).squares) {
        if (lion != history.lastLionCapture) pseudo = pseudo.withoutSquare(lion);
      }
    }

    return pseudo.intersect(fullSquareSet(rule));
  }

  @override
  SquareSet dropDests(Piece piece, [Context? ctx]) => SquareSet.empty;

  @override
  Outcome? outcome([Context? ctx]) {
    final context = ctx ?? makeCtx();
    if (kingsOf(context.side).isEmpty) {
      return Outcome(
        result: GameResult.kingsLost,
        winner: context.side.opposite,
      );
    } else if (!hasDests(context)) {
      return Outcome(
        result: GameResult.stalemate,
        winner: context.side.opposite,
      );
    } else if (_isBareKing(Side.sente)) {
      return const Outcome(result: GameResult.bareKing, winner: Side.gote);
    } else if (_isBareKing(Side.gote)) {
      return const Outcome(result: GameResult.bareKing, winner: Side.sente);
    } else if (_isDraw()) {
      return const Outcome(result: GameResult.draw, winner: null);
    }
    return null;
  }

  @override
  bool isLegal(MoveOrDrop md, [Context? ctx]) {
    if (md is! NormalMove) return false;
    final midStep = md.midStep;
    if (midStep == null) {
      return super.isLegal(md, ctx);
    }
    return super.isLegal(NormalMove(from: md.from, to: midStep), ctx) &&
        secondLionStepDests(md.from, midStep).has(md.to);
  }

  bool _isBareKing(Side side) {
    final theirSide = side.opposite;
    final dims = dimensions(rule);
    final ourKing = kingsOf(side).singleSquare();
    final ourPieces = board
        .bySide(side)
        .diff(
          board
              .byRoles([Role.pawn, Role.lance])
              .intersect(
                SquareSet.fromRank(side == Side.sente ? 0 : dims.ranks - 1),
              ),
        );
    final theirKing = kingsOf(theirSide).singleSquare();
    final theirPieces = board
        .bySide(theirSide)
        .diff(
          board
              .byRoles([Role.pawn, Role.gobetween])
              .union(
                board
                    .byRole(Role.lance)
                    .intersect(
                      SquareSet.fromRank(
                        theirSide == Side.sente ? 0 : dims.ranks - 1,
                      ),
                    ),
              ),
        );

    return ourPieces.size == 1 &&
        ourKing != null &&
        theirPieces.size > 1 &&
        theirKing != null &&
        !isCheck(theirSide) &&
        (theirPieces.size > 2 ||
            kingAttacks(ourKing).intersect(theirPieces).isEmpty);
  }

  bool _isDraw() {
    final dims = dimensions(rule);
    final oneWayRoles = board.byRoles([Role.pawn, Role.lance]);
    final occ = board.occupied.diff(
      oneWayRoles
          .intersect(board.bySide(Side.sente).intersect(SquareSet.fromRank(0)))
          .union(
            oneWayRoles.intersect(
              board
                  .bySide(Side.gote)
                  .intersect(SquareSet.fromRank(dims.ranks - 1)),
            ),
          ),
    );
    return occ.size == 2 &&
        kingsOf(Side.sente).isSingleSquare() &&
        !isCheck(Side.sente) &&
        kingsOf(Side.gote).isSingleSquare() &&
        !isCheck(Side.gote);
  }

  // chushogi position before piece is moved from initial square
  SquareSet secondLionStepDests(Square initialSq, Square midSq) {
    final piece = board.pieceAt(initialSq);
    if (piece == null || piece.side != turn) return SquareSet.empty;

    if (Role.lionRoles.contains(piece.role)) {
      if (!kingAttacks(initialSq).has(midSq)) return SquareSet.empty;

      var pseudoDests = kingAttacks(midSq)
          .diff(board.bySide(turn).withoutSquare(initialSq))
          .intersect(fullSquareSet(rule));

      final oppSide = turn.opposite;
      final oppLions = board
          .bySide(oppSide)
          .intersect(board.byRoles([Role.lion, Role.lionpromoted]))
          .intersect(pseudoDests);
      final capture = board.pieceAt(midSq);
      final clearOccupied = board.occupied
          .withoutSquare(initialSq)
          .withoutSquare(midSq);

      // Can't capture a non-adjacent protected lion unless we already took
      // something valuable (i.e. not a pawn or go-between) on the first step.
      for (final lion in oppLions.squares) {
        if (initialSq.dist(lion) > 1 &&
            squareAttackers(lion, oppSide, clearOccupied).isNotEmpty &&
            (capture == null ||
                capture.role == Role.pawn ||
                capture.role == Role.gobetween)) {
          pseudoDests = pseudoDests.withoutSquare(lion);
        }
      }
      return pseudoDests;
    } else if (piece.role == Role.falcon) {
      if (!pawnAttacks(initialSq, piece.side).has(midSq)) {
        return SquareSet.empty;
      }

      var pseudoDests = goBetweenAttacks(midSq)
          .diff(board.bySide(turn).withoutSquare(initialSq))
          .intersect(fullSquareSet(rule));

      if (history.lastLionCapture != null) {
        pseudoDests = _removeLions(pseudoDests);
      }
      return pseudoDests;
    } else if (piece.role == Role.eagle) {
      var pseudoDests = eagleLionAttacks(
        initialSq,
        piece.side,
      ).diff(board.bySide(turn)).withSquare(initialSq);

      if (!pseudoDests.has(midSq) || initialSq.dist(midSq) > 1) {
        return SquareSet.empty;
      }

      pseudoDests = pseudoDests
          .intersect(kingAttacks(midSq))
          .intersect(fullSquareSet(rule));

      if (history.lastLionCapture != null) {
        pseudoDests = _removeLions(pseudoDests);
      }
      return pseudoDests;
    }

    return SquareSet.empty;
  }

  SquareSet _removeLions(SquareSet dests) {
    final oppSide = turn.opposite;
    final oppLions = board
        .bySide(oppSide)
        .intersect(board.byRoles([Role.lion, Role.lionpromoted]))
        .intersect(dests);
    var result = dests;
    for (final lion in oppLions.squares) {
      if (lion != history.lastLionCapture) result = result.withoutSquare(lion);
    }
    return result;
  }
}

class _Chushogi extends Chushogi {
  const _Chushogi({
    required super.board,
    required super.turn,
    required super.history,
    required super.hands,
    required super.moveNumber,
  }) : super._();

  @override
  Chushogi copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    History? history,
    int? moveNumber,
  }) {
    return Chushogi(
      board: board ?? this.board,
      hands: hands ?? this.hands,
      turn: turn ?? this.turn,
      history: history ?? this.history,
      moveNumber: moveNumber ?? this.moveNumber,
    );
  }
}
