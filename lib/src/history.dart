import '../dartshogi.dart';

class History {
  const History({
    required this.lastUsi,
    required this.lastLionCapture,
    required this.consecutiveAttacks,
    required this.positions,
    required this.initialSfen,
  });

  final String? lastUsi;
  final Position? lastLionCapture;
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

  History addPosition(String position) {
    return copyWith(positions: [...positions, position]);
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

  History withLastLionCapture(Position? position) {
    return copyWith(lastLionCapture: position);
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
    String? lastUsi,
    Position? lastLionCapture,
    ConsecutiveAttacks? consecutiveAttacks,
    List<String>? positions,
    String? initialSfen,
  }) {
    return History(
      lastUsi: lastUsi ?? this.lastUsi,
      lastLionCapture: lastLionCapture ?? this.lastLionCapture,
      consecutiveAttacks: consecutiveAttacks ?? this.consecutiveAttacks,
      positions: positions ?? this.positions,
      initialSfen: initialSfen ?? this.initialSfen,
    );
  }

  @override
  String toString() {
    return '${lastUsi ?? "-"} '
        '${lastLionCapture?.lastLionCapture ?? "-"} '
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
