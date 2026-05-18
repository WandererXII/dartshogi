import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';

import '../../attacks.dart';
import '../../board.dart';
import '../../core/game_result.dart';
import '../../core/move_drop.dart';
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
import './shogi.dart';

@immutable
abstract class Annanshogi extends Position {
  const factory Annanshogi({
    required Board board,
    required Hands hands,
    required Side turn,
    required History history,
    required int moveNumber,
  }) = _Annanshogi;

  const Annanshogi._({
    required super.board,
    required super.hands,
    required super.turn,
    required super.history,
    required super.moveNumber,
  });

  @override
  Rule get rule => Rule.annanshogi;

  @useResult
  static Result<Annanshogi> fromSetup(Setup s, {bool strict = false}) =>
      Position.fromSetupBase(s, Annanshogi.new, strict: strict);

  @override
  PositionValidation get validation => const PositionValidation(
    doublePawn: false,
    oppositeCheck: true,
    unpromotedForcedPromotion: true,
    maxNumberOfRoyalPieces: 1,
  );

  @override
  SquareSet squareAttackers(Square square, Side attacker, SquareSet occupied) {
    return standardSquareAttackers(
      square,
      attacker,
      _annanAttackBoard(board),
      occupied,
    );
  }

  @override
  SquareSet squareSnipers(Square square, Side attacker) {
    return standardSquareSnipers(square, attacker, _annanAttackBoard(board));
  }

  @override
  SquareSet moveDests(Square square, [Context? ctx]) {
    final context = ctx ?? makeCtx();
    final realPiece = board.pieceAt(square);
    if (realPiece == null || realPiece.side != context.side) {
      return SquareSet.empty;
    }

    final squareBehind = _directlyBehind(realPiece.side, square);
    final pieceBehind =
        squareBehind != null ? board.pieceAt(squareBehind) : null;

    var pseudo = attacks(
      pieceBehind?.side == realPiece.side ? pieceBehind! : realPiece,
      square,
      board.occupied,
    );
    pseudo = pseudo.diff(board.bySide(context.side));

    final king = context.king;
    if (king != null) {
      if (realPiece.role == Role.king) {
        final occ = board.occupied.withoutSquare(square);
        for (final to in pseudo.squares) {
          final boardClone = board.removePieceAt(to);
          if (standardSquareAttackers(
            to,
            context.side.opposite,
            _annanAttackBoard(boardClone),
            occ,
          ).isNotEmpty) {
            pseudo = pseudo.withoutSquare(to);
          }
        }
      } else {
        final stdAttackers = standardSquareAttackers(
          king,
          context.side.opposite,
          board,
          board.occupied,
        );
        final shiftedAttackers = (context.side == Side.sente
                ? stdAttackers.shr256(16)
                : stdAttackers.shl256(16))
            .intersect(board.occupied);
        pseudo = pseudo.diff(shiftedAttackers);

        if (context.checkers.isNotEmpty) {
          if (context.checkers.size > 2) return SquareSet.empty;

          final singularChecker = context.checkers.singleSquare();

          final moveGivers = (context.side == Side.sente
                  ? context.checkers.shr256(16)
                  : context.checkers.shl256(16))
              .intersect(pseudo);

          if (singularChecker != null) {
            pseudo = pseudo.intersect(
              between(singularChecker, king).withSquare(singularChecker),
            );
          } else {
            pseudo = SquareSet.empty;
          }

          for (final moveGiver in moveGivers.squares) {
            final boardClone = board
                .removePieceAt(square)
                .setPieceAt(moveGiver, realPiece);
            if (standardSquareAttackers(
              king,
              context.side.opposite,
              _annanAttackBoard(boardClone),
              boardClone.occupied,
            ).isEmpty) {
              pseudo = pseudo.withSquare(moveGiver);
            }
          }
        }

        if (context.blockers.has(square)) {
          var rayed = pseudo.intersect(ray(square, king));
          final occ = board.occupied.withoutSquare(square);
          for (final to in pseudo.diff(rayed).squares) {
            if (board.sideAt(to) != context.side) {
              final boardClone = board
                  .removePieceAt(square)
                  .setPieceAt(to, realPiece);
              if (standardSquareAttackers(
                king,
                context.side.opposite,
                _annanAttackBoard(boardClone),
                occ,
              ).isEmpty) {
                rayed = rayed.withSquare(to);
                break;
              }
            }
          }
          pseudo = rayed;
        }
      }
    }

    return pseudo.intersect(fullSquareSet(rule));
  }

  @override
  SquareSet dropDests(Piece piece, [Context? ctx]) {
    final context = ctx ?? makeCtx();
    if (piece.side != context.side) return SquareSet.empty;

    var mask = board.occupied.complement();
    final king = context.king;

    if (king != null && context.checkers.isNotEmpty) {
      final checker = context.checkers.singleSquare();
      if (checker == null) return SquareSet.empty;
      mask = mask.intersect(between(checker, king));
    }

    if (piece.role == Role.pawn) {
      // Checking for double pawns
      final pawns = board
          .byRole(Role.pawn)
          .intersect(board.bySide(context.side));
      for (final pawn in pawns.squares) {
        mask = mask.diff(SquareSet.fromFile(pawn.file));
      }

      // Checking for a pawn checkmate
      final oppKing = kingsOf(context.side.opposite).singleSquare();
      if (oppKing != null) {
        final kingFront = oppKing.offset(context.side == Side.sente ? 16 : -16);
        if (kingFront != null && mask.has(kingFront)) {
          final child = playUnchecked(DropMove(role: Role.pawn, to: kingFront));
          final childResult = child.outcome()?.result;
          if (childResult == GameResult.checkmate ||
              childResult == GameResult.stalemate) {
            mask = mask.withoutSquare(kingFront);
          }
        }
      }
    }

    return mask.intersect(fullSquareSet(rule));
  }

  Square? _directlyBehind(Side side, Square square) =>
      square.offset(side == Side.sente ? 16 : -16);

  // Changes the pieces in front of other friendly piece to said pieces
  Board _annanAttackBoard(Board board) {
    Board newBoard = Board.empty;
    for (final (sq, piece) in board.pieces) {
      final squareBehind = _directlyBehind(piece.side, sq);
      final pieceBehind =
          squareBehind != null ? board.pieceAt(squareBehind) : null;
      final role =
          pieceBehind?.side == piece.side ? pieceBehind!.role : piece.role;
      newBoard = newBoard.setPieceAt(sq, Piece(role: role, side: piece.side));
    }
    return newBoard;
  }
}

class _Annanshogi extends Annanshogi {
  const _Annanshogi({
    required super.board,
    required super.turn,
    required super.history,
    required super.hands,
    required super.moveNumber,
  }) : super._();

  @override
  Annanshogi copyWith({
    Board? board,
    Hands? hands,
    Side? turn,
    History? history,
    int? moveNumber,
    Object? lastDest = uniqueObjectInstance,
    Object? lastLionCapture = uniqueObjectInstance,
  }) {
    return Annanshogi(
      board: board ?? this.board,
      hands: hands ?? this.hands,
      turn: turn ?? this.turn,
      history: history ?? this.history,
      moveNumber: moveNumber ?? this.moveNumber,
    );
  }
}
