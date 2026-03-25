import 'package:meta/meta.dart';

import './role.dart';
import './side.dart';

@immutable
class Piece {
  const Piece({required this.side, required this.role});

  final Side side;
  final Role role;

  Piece copyWith({Side? side, Role? role}) {
    return Piece(side: side ?? this.side, role: role ?? this.role);
  }

  @override
  String toString() {
    return '${side.name}${role.name}';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Piece &&
            other.runtimeType == runtimeType &&
            side == other.side &&
            role == other.role;
  }

  @override
  int get hashCode => Object.hash(side, role);
}
