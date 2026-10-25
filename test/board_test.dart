import 'package:dartshogi/dartshogi.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:test/test.dart';

void main() {
  test('implements hashCode/==', () {
    expect(Board.empty, Board.empty);
  });

  group('value equality', () {
    const rook = Piece(side: Side.sente, role: Role.rook);
    const pawn = Piece(side: Side.gote, role: Role.pawn);

    void expectEquivalent(Board first, Board second) {
      expect(first == second, isTrue);
      expect(second == first, isTrue);
      expect(first.hashCode, second.hashCode);
      expect(<Board>{first}.contains(second), isTrue);
      expect(<Board, String>{first: 'position'}[second], 'position');
    }

    test('independent allocations and insertion orders', () {
      final first = Board.empty
          .setPieceAt(const Square(0), rook)
          .setPieceAt(const Square(255), pawn);
      final second = Board.empty
          .setPieceAt(const Square(255), pawn)
          .setPieceAt(const Square(0), rook);

      expectEquivalent(first, second);
      expectEquivalent(
        first,
        second
            .setPieceAt(const Square(128), pawn)
            .removePieceAt(const Square(128)),
      );
    });

    test('empty board reconstructed by adding and removing a piece', () {
      final reconstructed = Board.empty
          .setPieceAt(const Square(255), rook)
          .removePieceAt(const Square(255));
      expectEquivalent(Board.empty, reconstructed);
    });

    test('empty role entries are ignored', () {
      final board = Board.empty.setPieceAt(const Square(0), rook);
      final withEmptyRole = Board(
        occupied: board.occupied,
        sente: board.sente,
        gote: board.gote,
        roles: board.roles.add(Role.pawn, SquareSet.fromSquares([])),
      );
      expectEquivalent(board, withEmptyRole);
      expectEquivalent(
        Board.empty,
        Board(
          occupied: SquareSet.fromSquares([]),
          sente: SquareSet.fromSquares([]),
          gote: SquareSet.fromSquares([]),
          roles: IMap({Role.rook: SquareSet.fromSquares([])}),
        ),
      );
    });

    test('different roles, sides and squares remain unequal', () {
      final board = Board.empty.setPieceAt(const Square(0), rook);
      for (final different in [
        Board.empty,
        Board.empty.setPieceAt(
          const Square(0),
          const Piece(side: Side.sente, role: Role.pawn),
        ),
        Board.empty.setPieceAt(
          const Square(0),
          const Piece(side: Side.gote, role: Role.rook),
        ),
        Board.empty.setPieceAt(const Square(32), rook),
      ]) {
        expect(board == different, isFalse);
        expect(different == board, isFalse);
      }
    });

    test('Setup delegates board value equality and hashing', () {
      Setup setup(Board board) => Setup(
        board: board,
        hands: Hands.empty,
        turn: Side.sente,
        history: History.empty,
        moveNumber: 1,
      );

      final first = setup(Board.empty.setPieceAt(const Square(0), rook));
      final second = setup(Board.empty.setPieceAt(const Square(0), rook));
      expect(first == second, isTrue);
      expect(first.hashCode, second.hashCode);
      expect(<Setup>{first}.contains(second), isTrue);
    });
  });

  test('empty board', () {
    expect(Board.empty.pieces.isEmpty, true);
    expect(Board.empty.pieceAt(const Square(0)), null);
  });

  test('setPieceAt', () {
    const piece = Piece(side: Side.sente, role: Role.bishop);
    const square = Square(0);

    final board = Board.empty.setPieceAt(square, piece);
    expect(board.occupied, SquareSet.empty.withSquare(0));
    expect(board.sente, SquareSet.empty.withSquare(0));
    expect(board.gote, SquareSet.empty);
    expect(board.roles.get(piece.role), SquareSet.empty.withSquare(0));
    expect(board.pieceAt(square), piece);
    expect(board.pieces.length, 1);
  });

  test('removePieceAt', () {
    const square = Square(0);
    const piece = Piece(side: Side.sente, role: Role.rook);

    final board = Board.empty.setPieceAt(square, piece);
    expect(board.removePieceAt(square), Board.empty);
  });
}
