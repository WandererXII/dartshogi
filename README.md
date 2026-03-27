[![lishogi.org](https://img.shields.io/badge/☗_lishogi.org-Play_shogi-black)](https://lishogi.org)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/WandererXII/dartshogi/ci.yml?label=CI)

WIP - Shogi and shogi variant rules written in dart. Based on `dartchess` and `shogiops`.

## Features

- Completely immutable Position class
- Read and write SFEN
- Read and write USI
- Shogi rules:
    - move/drop making
    - legal moves/drops generation
    - game end and outcome
    - setup validation
- Shogi variants: Minishogi, Chushogi, Annanshogi, Kyotoshogi, Checkshogi, Dobutsu
- KIF and CSA parser and writer (NOT YET SUPPORTED)
- Move notation - Western, Japanese, Kitao-Kawasaki, Yorozuya
- Bitboards
- Attacks and rays using hyperbola quintessence

## Example

```dart
import 'package:dartshogi/dartshogi.dart';

  // Parse sfen and create a valid shogi position
  final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi)).getOrThrow();

  // Generate all legal moves
  assert(pos.allMoveDests().length == 40);

  // Parse usi
  final move = MoveOrDrop.parse('7g7f')!;

  assert(pos.isLegal(move));

  // Play moves
  final pos2 = pos.play(move).getOrThrow();

  // Detect game end conditions
  assert(pos2.outcome() == null);
```
