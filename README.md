[![lishogi.org](https://img.shields.io/badge/☗_lishogi.org-Play_shogi-black)](https://lishogi.org)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/WandererXII/dartshogi/ci.yml?label=CI)

WIP - Shogi and shogi variant rules written in dart. Based on `dartchess` and `shogiops`.

NOT ALL FEATURES SUPPORTED YET!

## Features

- Completely immutable Position class
- Read and write SFEN
- Read and write USI
- Shogi rules:
    - move making
    - legal moves generation
    - game end and outcome
    - setup validation
- Shogi variants: Minishogi, Chushogi, Annanshogi, Kyotoshogi, Checkshogi, Dobutsu
- KIF and CSA parser and writer
- Move notation - Western, Japanese, Kitao-Kawasaki, Yorozuya
- Bitboards
- Attacks and rays using hyperbola quintessence

## Example

```dart
import 'package:dartshogi/dartshogi.dart';

final pos = parseSfen(Rule.shogi, initialSfen(Rule.shogi));
assert(pos.allMoveDests().length == 40);
```
