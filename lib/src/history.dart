import 'package:meta/meta.dart';

import '../dartshogi.dart';

class History {
  const History({
    required this.lastUsi,
    required this.consecutiveAttacks,
    required this.positions,
    required this.initialSfen,
    this.lastLionCapture,
    this.lastDest,
  });

  final String? lastUsi;

  /// The destination of the last move/drop played.
  final Square? lastDest;

  /// Square of an enemy lion captured by a non-lion piece on the previous move.
  /// Used for the Chushogi anti-recapture rule.
  final Square? lastLionCapture;

  final ConsecutiveAttacks consecutiveAttacks;

  /// Full SFEN positions history.
  final List<String> positions;

  final String? initialSfen;

  /// only positions with the same side to play
  List<String> get _currentTurnPositions {
    final result = <String>[];

    for (int i = 0; i < positions.length; i += 2) {
      result.add(positions[i]);
    }

    return result;
  }

  @useResult
  History addPosition(String position) {
    final newPositions = [...positions, position];
    return copyWith(positions: newPositions);
  }

  @useResult
  History addLastDest(Square? lastDest) {
    return copyWith(lastDest: lastDest);
  }

  @useResult
  History addLastLionCapture(Square? lastLionCapture) {
    return copyWith(lastLionCapture: lastLionCapture);
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

  History withLastUsi(String usi) {
    return copyWith(lastUsi: usi);
  }

  History withConsecutiveAttacks(ConsecutiveAttacks attacks) {
    return copyWith(consecutiveAttacks: attacks);
  }

  History withPositions(List<String> positions) {
    return copyWith(positions: positions);
  }

  History withInitialSfen(String sfen) {
    return copyWith(initialSfen: sfen);
  }

  History copyWith({
    Object? lastUsi = sentinel,
    ConsecutiveAttacks? consecutiveAttacks,
    List<String>? positions,
    Object? initialSfen = sentinel,
    Object? lastLionCapture = sentinel,
    Object? lastDest = sentinel,
  }) {
    return History(
      lastUsi: identical(lastUsi, sentinel) ? this.lastUsi : lastUsi as String?,
      lastLionCapture:
          identical(lastLionCapture, sentinel)
              ? this.lastLionCapture
              : lastLionCapture as Square?,
      lastDest:
          identical(lastDest, sentinel) ? this.lastDest : lastDest as Square?,
      consecutiveAttacks: consecutiveAttacks ?? this.consecutiveAttacks,
      positions: positions ?? this.positions,
      initialSfen:
          identical(initialSfen, sentinel)
              ? this.initialSfen
              : initialSfen as String?,
    );
  }

  @override
  String toString() {
    return '${lastUsi ?? "-"} '
        '${lastLionCapture ?? "-"} '
        '$consecutiveAttacks '
        '${positions.join(" ")} '
        '${initialSfen ?? "-"}';
  }

  static const empty = History(
    lastUsi: null,
    lastLionCapture: null,
    consecutiveAttacks: ConsecutiveAttacks.empty,
    positions: [],
    initialSfen: null,
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
}
