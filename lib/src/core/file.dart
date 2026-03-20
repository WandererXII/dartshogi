/// A file of the board.
extension type const File._(int value) implements int {
  /// Gets the board [File] from a file index between 0 and 15.
  const File(this.value) : assert(value >= 0 && value < 16);

  static const file1 = File(0);
  static const file2 = File(1);
  static const file3 = File(2);
  static const file4 = File(3);
  static const file5 = File(4);
  static const file6 = File(5);
  static const file7 = File(6);
  static const file8 = File(7);
  static const file9 = File(8);
  static const file10 = File(9);
  static const file11 = File(10);
  static const file12 = File(11);
  static const file13 = File(12);
  static const file14 = File(13);
  static const file15 = File(14);
  static const file16 = File(15);

  /// All files in ascending order.
  static const values = [
    file1,
    file2,
    file3,
    file4,
    file5,
    file6,
    file7,
    file8,
    file9,
    file10,
    file11,
    file12,
    file13,
    file14,
    file15,
    file16,
  ];

  static const _names = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
  ];

  /// The name of the file, such as '1', '2', '3', etc.
  String get name => _names[value];

  /// Returns the file offset by [delta].
  ///
  /// Returns `null` if the resulting file is out of bounds.
  File? offset(int delta) {
    assert(delta >= -15 && delta <= 15);
    final newFile = value + delta;
    if (newFile < 0 || newFile > 15) {
      return null;
    }
    return File(newFile);
  }
}
