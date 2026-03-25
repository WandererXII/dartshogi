import 'package:result_dart/result_dart.dart';

import '../core/rule.dart';
import '../core/setup.dart';
import './position.dart';
import './rules/annanshogi.dart';
import './rules/checkshogi.dart';
import './rules/chushogi.dart';
import './rules/dobutsu.dart';
import './rules/kyotoshogi.dart';
import './rules/minishogi.dart';
import './rules/shogi.dart';

Result<Position> setupPosition(Rule rule, Setup setup, {bool strict = false}) =>
    switch (rule) {
      Rule.shogi => Shogi.fromSetup(setup, strict: strict),
      Rule.minishogi => Minishogi.fromSetup(setup, strict: strict),
      Rule.chushogi => Chushogi.fromSetup(setup, strict: strict),
      Rule.kyotoshogi => Kyotoshogi.fromSetup(setup, strict: strict),
      Rule.annanshogi => Annanshogi.fromSetup(setup, strict: strict),
      Rule.checkshogi => Checkshogi.fromSetup(setup, strict: strict),
      Rule.dobutsu => Dobutsu.fromSetup(setup, strict: strict),
    };
