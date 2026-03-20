/// A rank of the board.
extension type const Rank._(int value) implements int {
  /// Gets the board [Rank] from a rank index between 0 and 15.
  const Rank(this.value) : assert(value >= 0 && value < 16);

  /// Gets a [Rank] from its name in algebraic notation.
  ///
  /// Throws a [FormatException] if the algebraic notation is invalid.
  factory Rank.fromName(String algebraic) {
    final rank = algebraic.codeUnitAt(0) - 97;
    if (rank < 0 || rank > 15) {
      throw FormatException('Invalid algebraic notation: $algebraic');
    }
    return Rank(rank);
  }

  static const rankA = Rank(0);
  static const rankB = Rank(1);
  static const rankC = Rank(2);
  static const rankD = Rank(3);
  static const rankE = Rank(4);
  static const rankF = Rank(5);
  static const rankG = Rank(6);
  static const rankH = Rank(7);
  static const rankI = Rank(8);
  static const rankJ = Rank(9);
  static const rankK = Rank(10);
  static const rankL = Rank(11);
  static const rankM = Rank(12);
  static const rankN = Rank(13);
  static const rankO = Rank(14);
  static const rankP = Rank(15);

  /// All ranks in ascending order.
  static const values = [
    rankA,
    rankB,
    rankC,
    rankD,
    rankE,
    rankF,
    rankG,
    rankH,
    rankI,
    rankJ,
    rankK,
    rankL,
    rankM,
    rankN,
    rankO,
    rankP,
  ];

  static const _names = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
  ];

  /// The name of the rank, such as 'a', 'b', 'c', etc.
  String get name => _names[value];

  /// Returns the rank offset by [delta].
  ///
  /// Returns `null` if the resulting rank is out of bounds.
  Rank? offset(int delta) {
    assert(delta >= -15 && delta <= 15);
    final newRank = value + delta;
    if (newRank < 0 || newRank > 15) {
      return null;
    }
    return Rank(newRank);
  }
}
