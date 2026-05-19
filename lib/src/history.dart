import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

import './core/move_drop.dart';
import './core/side.dart';
import './core/square.dart';
import './utils.dart';

class History {
  const History({
    required this.initialSfen,
    required this.positions,
    required this.consecutiveAttacks,
    required this.lastMoveOrDrop,
    required this.lastLionCapture,
  });

  final String? initialSfen;

  /// Full SFEN positions history.
  final IList<String> positions;

  final ConsecutiveAttacks consecutiveAttacks;

  final MoveOrDrop? lastMoveOrDrop;

  /// Square of an enemy lion captured by a non-lion piece on the previous move.
  /// Used for the Chushogi anti-recapture rule.
  final Square? lastLionCapture;

  /// only positions with the same side to play
  IList<String> get _currentTurnPositions {
    final result = <String>[];

    for (int i = 0; i < positions.length; i += 2) {
      result.add(positions[i]);
    }

    return IList(result);
  }

  @useResult
  History addPosition(String position) {
    return copyWith(positions: positions.add(position));
  }

  bool isRepetition(int times) {
    final requiredLength = (times - 1) * 4 + 1;

    if (positions.length < requiredLength) {
      return false;
    }

    final currentPositions = _currentTurnPositions;

    if (currentPositions.isEmpty) {
      return times <= 1;
    }

    final current = currentPositions.first;
    final count = currentPositions.where((p) => p == current).length;

    return count >= times;
  }

  /// number of moves/drops each player made
  /// since the repeated position first occurred
  int? get firstRepetitionDistance {
    final currentPositions = _currentTurnPositions;

    if (currentPositions.isEmpty) {
      return null;
    }

    final current = currentPositions.first;

    int lastIndex = -1;

    for (int i = currentPositions.length - 1; i >= 0; i--) {
      if (currentPositions[i] == current) {
        lastIndex = i;
        break;
      }
    }

    return lastIndex > 0 ? lastIndex : null;
  }

  Side? get perpetualCheckAttacker {
    final dist = firstRepetitionDistance;

    if (dist == null) {
      return null;
    }

    final senteAttacks = consecutiveAttacks(Side.sente) >= dist;
    final goteAttacks = consecutiveAttacks(Side.gote) >= dist;

    if (senteAttacks && goteAttacks) {
      return null;
    }

    if (senteAttacks) {
      return Side.sente;
    }

    if (goteAttacks) {
      return Side.gote;
    }

    return null;
  }

  bool get threefoldRepetition => isRepetition(3);

  bool get fourfoldRepetition => isRepetition(4);

  History copyWith({
    Object? initialSfen = sentinel,
    IList<String>? positions,
    ConsecutiveAttacks? consecutiveAttacks,
    Object? lastMoveOrDrop = sentinel,
    Object? lastLionCapture = sentinel,
  }) {
    return History(
      initialSfen:
          identical(initialSfen, sentinel)
              ? this.initialSfen
              : initialSfen as String?,
      positions: positions ?? this.positions,
      consecutiveAttacks: consecutiveAttacks ?? this.consecutiveAttacks,
      lastMoveOrDrop:
          identical(lastMoveOrDrop, sentinel)
              ? this.lastMoveOrDrop
              : lastMoveOrDrop as MoveOrDrop?,
      lastLionCapture:
          identical(lastLionCapture, sentinel)
              ? this.lastLionCapture
              : lastLionCapture as Square?,
    );
  }

  @override
  String toString() {
    return '${initialSfen ?? "-"} '
        '[${positions.join(",")}] '
        '$consecutiveAttacks '
        '${lastMoveOrDrop?.usi ?? "-"} '
        '${lastLionCapture ?? "-"}';
  }

  static const empty = History(
    initialSfen: null,
    positions: IList<String>.empty(),
    consecutiveAttacks: ConsecutiveAttacks.empty,
    lastMoveOrDrop: null,
    lastLionCapture: null,
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is History &&
            other.initialSfen == initialSfen &&
            other.positions == positions &&
            other.consecutiveAttacks == consecutiveAttacks &&
            other.lastMoveOrDrop == lastMoveOrDrop &&
            other.lastLionCapture == lastLionCapture;
  }

  @override
  int get hashCode => Object.hash(
    initialSfen,
    positions,
    consecutiveAttacks,
    lastMoveOrDrop,
    lastLionCapture,
  );
}

/// attacks made in a row
class ConsecutiveAttacks {
  const ConsecutiveAttacks(this.sente, this.gote);

  final int sente;
  final int gote;

  ConsecutiveAttacks add(Side side) {
    if (side == Side.sente) {
      return ConsecutiveAttacks(sente + 1, gote);
    }

    return ConsecutiveAttacks(sente, gote + 1);
  }

  ConsecutiveAttacks reset(Side side) {
    if (side == Side.sente) {
      return ConsecutiveAttacks(0, gote);
    }

    return ConsecutiveAttacks(sente, 0);
  }

  int call(Side side) {
    return side == Side.sente ? sente : gote;
  }

  bool get nonEmpty => sente > 0 || gote > 0;

  bool get isEmpty => !nonEmpty;

  @override
  String toString() {
    return '($sente, $gote)';
  }

  static const empty = ConsecutiveAttacks(0, 0);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ConsecutiveAttacks &&
            sente == other.sente &&
            gote == other.gote;
  }

  @override
  int get hashCode => Object.hash(sente, gote);
}
