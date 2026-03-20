import 'package:dartshogi/src/core/piece.dart';
import 'package:dartshogi/src/core/side.dart';
import 'package:dartshogi/src/core/square.dart';
import 'package:dartshogi/src/core/role.dart';
import 'package:dartshogi/src/square_set.dart';
import 'package:dartshogi/src/board.dart';
import 'package:test/test.dart';

void main() {
  test('implements hashCode/==', () {
    expect(Board.empty, Board.empty);
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
