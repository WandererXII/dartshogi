import 'package:dartshogi/dartshogi.dart';

void main() {
  final stopwatch = Stopwatch()..start();
  const depth = 4;
  perft(parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow(), depth);
  print(
      'initial position perft at depht $depth executed in ${stopwatch.elapsed.inMilliseconds} ms');
}
