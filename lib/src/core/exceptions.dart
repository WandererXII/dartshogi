import 'package:meta/meta.dart';

/// An enumeration of the possible causes of an illegal SFEN string.
enum IllegalSfenCause {
  /// The SFEN string is not in the correct format.
  format,

  /// The board part of the SFEN string is invalid.
  board,

  /// The turn part of the SFEN string is invalid.
  turn,

  /// The hands part of the SFEN string is invalid.
  hands,

  /// The fullmove number part of the SFEN string is invalid.
  moveNumber,
}

/// An exception thrown when trying to parse an invalid SFEN string.
@immutable
class SfenException implements Exception {
  /// Constructs a [SfenException] with a [cause].
  const SfenException(this.cause);

  /// The cause of the exception.
  final IllegalSfenCause cause;

  @override
  String toString() => 'SfenException: ${cause.name}';
}

/// Exception thrown when trying to play an illegal move.
@immutable
class PlayException implements Exception {
  /// Constructs a [PlayException] with a [message].
  const PlayException(this.message);

  /// The exception message.
  final String message;

  @override
  String toString() => 'PlayException: $message';
}

/// Enumeration of the possible causes of an illegal setup.
enum IllegalSetupCause {
  /// There are no pieces on the board.
  empty,

  /// The player not to move is in check.
  oppositeCheck,

  /// There are impossibly many checkers, two sliding checkers are
  /// aligned, or check is not possible because the last move was a
  /// double pawn push.
  ///
  /// Such a position cannot be reached by any sequence of legal moves.
  impossibleCheck,

  /// There are piece that canot move again.
  piecesInDeadZone,

  /// Two or more pawns on the same file
  doublePawns,

  /// A king is missing, or there are too many kings.
  kings,

  /// A variant specific rule is violated.
  variant,
}
