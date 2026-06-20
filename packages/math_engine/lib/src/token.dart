enum TokenType {
  number,
  identifier,
  plus,
  minus,
  multiply,
  divide,
  modulo,
  power,
  factorial,
  bitwiseAnd,
  bitwiseOr,
  bitwiseXor,
  bitwiseNot,
  leftShift,
  rightShift,
  equal,
  comma,
  leftParenthesis,
  rightParenthesis,
  eof,
}

class Token {
  final TokenType type;
  final String value;
  final int position;

  Token(this.type, this.value, this.position);

  @override
  String toString() => 'Token($type, "$value", @$position)';
}
