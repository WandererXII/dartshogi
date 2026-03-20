/// Represents the different possible rules of chess and its variants
enum Rule {
  shogi,
  minishogi,
  chushogi,
  annanshogi,
  kyotoshogi,
  checkshogi,
  dobutsu;

  static Rule? fromString(String? variant) {
    switch ((variant ?? 'standard').toLowerCase()) {
      case 'standard':
      case 'shogi':
      case '将棋':
      case '本将棋':
        return Rule.shogi;
      case 'minishogi':
      case '五将棋':
        return Rule.minishogi;
      case 'chushogi':
      case 'chuushogi':
      case '中将棋':
      case '中':
        return Rule.chushogi;
      case 'annanshogi':
      case '安南将棋':
      case '安南':
        return Rule.annanshogi;
      case 'kyotoshogi':
      case '京都将棋':
      case '京都':
        return Rule.kyotoshogi;
      case 'checkshogi':
      case '王手将棋':
      case '王手':
        return Rule.checkshogi;
      case 'dobutsu shogi':
      case 'dobutsushogi':
      case 'dobutsu':
      case 'どうぶつしょうぎ':
      case 'どうぶつ':
      case '動物将棋':
      case '動物':
        return Rule.dobutsu;
      default:
        return null;
    }
  }
}
