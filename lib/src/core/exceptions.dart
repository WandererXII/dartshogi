import 'package:meta/meta.dart';

enum IllegalSfenCause { format, board, turn, hands, moveNumber }

@immutable
class SfenException implements Exception {
  const SfenException(this.cause);
  final IllegalSfenCause cause;

  @override
  String toString() => 'SfenException: ${cause.name}';
}

@immutable
class PlayException implements Exception {
  const PlayException(this.message);
  final String message;

  @override
  String toString() => 'PlayException: $message';
}

enum IllegalSetupCause {
  empty,
  piecesOutsideBoard,
  invalidPieces,
  invalidPiecesHand,
  oppositeCheck,
  impossibleCheck,
  piecesInDeadZone,
  doublePawns,
  kings,
  variant,
}

@immutable
class PositionSetupException implements Exception {
  const PositionSetupException(this.cause);
  final IllegalSetupCause cause;

  @override
  String toString() => 'PositionSetupException: ${cause.name}';
}
