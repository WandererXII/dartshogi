import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../attacks.dart';
import '../board.dart';
import '../core/exceptions.dart';
import '../core/file.dart';
import '../core/game_result.dart';
import '../core/move_drop.dart';
import '../core/outcome.dart';
import '../core/piece.dart';
import '../core/role.dart';
import '../core/rule.dart';
import '../core/setup.dart';
import '../core/side.dart';
import '../core/square.dart';
import '../hands.dart';
import '../history.dart';
import '../impasse.dart';
import '../sfen.dart';
import '../square_set.dart';
import './utils.dart';

@immutable
class Context {
  const Context({
    required this.side,
    required this.king,
    required this.blockers,
    required this.checkers,
  });

  final Side side;
  final Square? king;
  final SquareSet blockers;
  final SquareSet checkers;
}

@immutable
class PositionValidation {
  const PositionValidation({
    this.doublePawn = true,
    this.oppositeCheck = true,
    this.unpromotedForcedPromotion = true,
    this.maxNumberOfRoyalPieces = 1,
  });

  final bool doublePawn;
  final bool oppositeCheck;
  final bool unpromotedForcedPromotion;
  final int maxNumberOfRoyalPieces;
}

typedef PositionBuilder<T> =
    T Function({
      required Board board,
      required Hands hands,
      required Side turn,
      required History history,
      required int moveNumber,
    });

@immutable
abstract class Position {
  const Position({
    required this.board,
    required this.hands,
    required this.turn,
    required this.moveNumber,
    required this.history,
  });

  final Board board;
  final Hands hands;
  final Side turn;
  final int moveNumber;
  final History history;

  Rule get rule;

  @useResult
  static Result<T> fromSetupBase<T extends Position>(
    Setup s,
    PositionBuilder<T> build, {
    bool strict = false,
  }) {
    final pos = build(
      board: s.board,
      hands: s.hands,
      turn: s.turn,
      history: s.history,
      moveNumber: s.moveNumber,
    );

    return pos.validate(strict: strict).map((_) => pos);
  }

  @useResult
  Position copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    History? history,
    int? moveNumber,
  });

  PositionValidation get validation => const PositionValidation();

  /// [attacker] pieces attacking [square] - useful for checks for example
  SquareSet squareAttackers(Square square, Side attacker, SquareSet occupied);

  /// [attacker] long-range pieces at least x-raying [square] - for finding blockers
  SquareSet squareSnipers(Square square, Side attacker);

  SquareSet moveDests(Square square, [Context? ctx]);
  SquareSet dropDests(Piece piece, [Context? ctx]);

  /// Doesn't consider safety of the king
  SquareSet illegalMoveDests(Square square) => moveDests(
    square,
    Context(
      side: turn,
      king: null,
      blockers: SquareSet.empty,
      checkers: SquareSet.empty,
    ),
  );

  /// Doesn't consider safety of the king
  SquareSet illegalDropDests(Piece piece) => dropDests(
    piece,
    Context(
      side: turn,
      king: null,
      blockers: SquareSet.empty,
      checkers: SquareSet.empty,
    ),
  );

  Result<void> validate({bool strict = false}) {
    if (!board.occupied.intersect(fullSquareSet(rule)).equals(board.occupied)) {
      return const Failure(
        PositionSetupException(IllegalSetupCause.piecesOutsideBoard),
      );
    }

    for (final side in Side.values) {
      for (final role in hands.side(side).roles) {
        if (!handRoles(rule).contains(role)) {
          return const Failure(
            PositionSetupException(IllegalSetupCause.invalidPiecesHand),
          );
        }
      }
    }

    for (final role in board.presentRoles()) {
      if (!allRoles(rule).contains(role)) {
        return const Failure(
          PositionSetupException(IllegalSetupCause.invalidPieces),
        );
      }
    }

    if (validation.oppositeCheck) {
      final otherKing = kingsOf(turn.opposite).singleSquare();
      if (otherKing != null &&
          squareAttackers(otherKing, turn, board.occupied).isNotEmpty) {
        return const Failure(
          PositionSetupException(IllegalSetupCause.oppositeCheck),
        );
      }
    }

    if (strict) {
      if (board.occupied.isEmpty) {
        return const Failure(PositionSetupException(IllegalSetupCause.empty));
      }

      if (validation.doublePawn) {
        for (final side in Side.values) {
          final files = <File>{};
          final pawns = board.byRole(Role.pawn).intersect(board.bySide(side));
          for (final pawn in pawns.squares) {
            if (!files.add(pawn.file)) {
              return const Failure(
                PositionSetupException(IllegalSetupCause.doublePawns),
              );
            }
          }
        }
      }

      if (kingsOf(Side.sente).size > validation.maxNumberOfRoyalPieces ||
          kingsOf(Side.gote).size > validation.maxNumberOfRoyalPieces) {
        return const Failure(PositionSetupException(IllegalSetupCause.kings));
      }
      if (kingsOf(Side.sente).isEmpty && kingsOf(Side.gote).isEmpty) {
        return const Failure(PositionSetupException(IllegalSetupCause.kings));
      }

      if (validation.unpromotedForcedPromotion) {
        for (final (square, piece) in board.pieces) {
          if (pieceForcePromote(rule, piece, square)) {
            return const Failure(
              PositionSetupException(IllegalSetupCause.piecesInDeadZone),
            );
          }
        }
      }
    }

    return const Success(());
  }

  Context makeCtx([Side? side]) {
    side ??= turn;
    final king = kingsOf(side).singleSquare();
    if (king == null) {
      return Context(
        side: side,
        king: null,
        blockers: SquareSet.empty,
        checkers: SquareSet.empty,
      );
    }
    final snipers = squareSnipers(king, side.opposite);
    var blockers = SquareSet.empty;
    for (final sniper in snipers.squares) {
      final b = between(king, sniper).intersect(board.occupied);
      if (!b.moreThanOne()) blockers = blockers.union(b);
    }
    return Context(
      side: side,
      king: king,
      blockers: blockers,
      checkers: squareAttackers(king, side.opposite, board.occupied),
    );
  }

  SquareSet kingsOf(Side side) =>
      board.byRole(Role.king).intersect(board.bySide(side));

  bool isCheck([Side? side]) {
    side ??= turn;
    for (final king in kingsOf(side).squares) {
      if (squareAttackers(king, side.opposite, board.occupied).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  SquareSet checks() {
    var result = SquareSet.empty;
    for (final side in Side.values) {
      for (final king in kingsOf(side).squares) {
        if (squareAttackers(king, side.opposite, board.occupied).isNotEmpty) {
          result = result.withSquare(king);
        }
      }
    }
    return result;
  }

  bool isEnd([Context? ctx]) => outcome(ctx) != null;

  Outcome? outcome([Context? ctx]) {
    final c = ctx ?? makeCtx();
    if (!hasDests(c)) {
      return Outcome(
        result:
            c.checkers.isNotEmpty ? GameResult.checkmate : GameResult.stalemate,
        winner: c.side.opposite,
      );
    }
    final totalSente =
        board.bySide(Side.sente).size + hands.side(Side.sente).count;
    final totalGote =
        board.bySide(Side.gote).size + hands.side(Side.gote).count;
    if (totalSente < 2 && totalGote < 2) {
      return const Outcome(result: GameResult.draw, winner: null);
    }

    if (isImpasse(this)) {
      return Outcome(result: GameResult.Impasse27, winner: turn);
    }

    return null;
  }

  Map<Square, SquareSet> allMoveDests([Context? ctx]) {
    final c = ctx ?? makeCtx();
    return {
      for (final square in board.bySide(c.side).squares)
        square: moveDests(square, c),
    };
  }

  Map<Piece, SquareSet> allDropDests([Context? ctx]) {
    final c = ctx ?? makeCtx();
    return {
      for (final role in handRoles(rule))
        Piece(side: c.side, role: role):
            hands.side(c.side).countOf(role) > 0
                ? dropDests(Piece(side: c.side, role: role), c)
                : SquareSet.empty,
    };
  }

  bool hasDests([Context? ctx]) {
    final c = ctx ?? makeCtx();
    for (final square in board.bySide(c.side).squares) {
      if (moveDests(square, c).isNotEmpty) return true;
    }
    for (final role in hands.side(c.side).roles) {
      if (dropDests(Piece(side: c.side, role: role), c).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  bool isLegal(MoveOrDrop md, [Context? ctx]) {
    final side = ctx?.side ?? turn;
    if (md is DropMove) {
      if (!handRoles(rule).contains(md.role) ||
          hands.side(side).countOf(md.role) <= 0) {
        return false;
      }
      return dropDests(Piece(side: side, role: md.role), ctx).has(md.to);
    } else if (md is NormalMove) {
      final piece = board.pieceAt(md.from);
      if (piece == null || !allRoles(rule).contains(piece.role)) return false;
      if (md.promotion == true &&
          !pieceCanPromote(rule, piece, md.from, md.to, board.pieceAt(md.to))) {
        return false;
      }
      if (md.promotion != true && pieceForcePromote(rule, piece, md.to)) {
        return false;
      }
      return moveDests(md.from, ctx).has(md.to);
    }
    return false;
  }

  @useResult
  Result<Position> play(MoveOrDrop md) {
    if (isLegal(md)) {
      return Success(playUnchecked(md));
    } else {
      return Failure(PlayException('Invalid move/drop: ${md.usi}'));
    }
  }

  @useResult
  Position playUnchecked(MoveOrDrop md) {
    Square? newLastLionCapture;
    Board newBoard = board;
    Hands newHands = hands;

    if (md is DropMove) {
      final newBoard = board.setPieceAt(
        md.to,
        Piece(role: md.role, side: turn),
      );
      final newHistory = history
          .addPosition(makeBoardSfen(rule, newBoard))
          .addLastDest(md.to)
          .addLastLionCapture(null);

      return copyWith(
        board: newBoard,
        history: newHistory,
        hands: hands.remove(
          Piece(side: turn, role: unpromoteForHand(rule, md.role) ?? md.role),
        ),
        turn: turn.opposite,
        moveNumber: moveNumber + 1,
      );
    } else if (md is NormalMove) {
      final piece = board.pieceAt(md.from);
      // return the position thing for nonsense moves.
      if (piece == null) return copyWith();

      newBoard = board.removePieceAt(md.from);

      final shouldPromote =
          (md.promotion == true &&
              pieceCanPromote(
                rule,
                piece,
                md.from,
                md.to,
                newBoard.pieceAt(md.to),
              )) ||
          pieceForcePromote(rule, piece, md.to);

      final movedPiece =
          shouldPromote
              ? Piece(
                side: piece.side,
                role: promote(rule, piece.role) ?? piece.role,
              )
              : piece;

      final capture = newBoard.pieceAt(md.to);
      newBoard = newBoard.setPieceAt(md.to, movedPiece);

      // Mid-step capture (Chushogi lion moves).
      final midStep = md.midStep;
      if (midStep != null) {
        final midCapture = newBoard.pieceAt(midStep);
        if (midCapture != null) {
          if (!Role.lionRoles.contains(piece.role) &&
              midCapture.side == turn.opposite &&
              Role.lionRoles.contains(midCapture.role)) {
            newLastLionCapture = md.midStep;
          }
          newHands = _storeCapture(newHands, midCapture);
        }
      }

      if (capture != null) {
        if (!Role.lionRoles.contains(piece.role) &&
            capture.side == turn.opposite &&
            Role.lionRoles.contains(capture.role)) {
          newLastLionCapture = md.to;
        }
        newHands = _storeCapture(newHands, capture);
      }
    }

    final newHistory = history
        .addPosition(makeBoardSfen(rule, newBoard))
        .addLastDest(md.to)
        .addLastLionCapture(newLastLionCapture);

    return copyWith(
      board: newBoard,
      history: newHistory,
      hands: newHands,
      turn: turn.opposite,
      moveNumber: moveNumber + 1,
    );
  }

  @useResult
  Hands _storeCapture(Hands h, Piece capture) {
    final unpromotedRole = unpromoteForHand(rule, capture.role);
    if (unpromotedRole != null && handRoles(rule).contains(unpromotedRole)) {
      return Hands(
        gote:
            capture.side.opposite == Side.gote
                ? h.gote.store(unpromotedRole)
                : h.gote,
        sente:
            capture.side.opposite == Side.sente
                ? h.sente.store(unpromotedRole)
                : h.sente,
      );
    }
    return h;
  }
}
