import 'token.dart';

class LexerException implements Exception {
  final String message;
  final int position;
  LexerException(this.message, this.position);
  @override
  String toString() => 'Lexer Error at position $position: $message';
}

class Lexer {
  final String input;
  int _position = 0;

  Lexer(this.input);

  int get position => _position;

  bool get _isAtEnd => _position >= input.length;

  String get _current => _isAtEnd ? '' : input[_position];

  void _advance() {
    _position++;
  }

  String _peek([int offset = 1]) {
    final target = _position + offset;
    return target >= input.length ? '' : input[target];
  }

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (!_isAtEnd) {
      final char = _current;

      if (_isWhitespace(char)) {
        _advance();
        continue;
      }

      final startPos = _position;

      // Check multi-character operators first
      if (char == '<' && _peek() == '<') {
        _advance();
        _advance();
        tokens.add(Token(TokenType.leftShift, '<<', startPos));
        continue;
      }
      if (char == '>' && _peek() == '>') {
        _advance();
        _advance();
        tokens.add(Token(TokenType.rightShift, '>>', startPos));
        continue;
      }

      // Check single character operators
      if (char == '+') {
        _advance();
        tokens.add(Token(TokenType.plus, '+', startPos));
        continue;
      }
      if (char == '-') {
        _advance();
        tokens.add(Token(TokenType.minus, '-', startPos));
        continue;
      }
      if (char == '*') {
        _advance();
        tokens.add(Token(TokenType.multiply, '*', startPos));
        continue;
      }
      if (char == '/') {
        _advance();
        tokens.add(Token(TokenType.divide, '/', startPos));
        continue;
      }
      if (char == '%') {
        _advance();
        tokens.add(Token(TokenType.modulo, '%', startPos));
        continue;
      }
      if (char == '^') {
        _advance();
        tokens.add(Token(TokenType.power, '^', startPos));
        continue;
      }
      if (char == '!') {
        _advance();
        tokens.add(Token(TokenType.factorial, '!', startPos));
        continue;
      }
      if (char == '&') {
        _advance();
        tokens.add(Token(TokenType.bitwiseAnd, '&', startPos));
        continue;
      }
      if (char == '|') {
        _advance();
        tokens.add(Token(TokenType.bitwiseOr, '|', startPos));
        continue;
      }
      if (char == '~') {
        _advance();
        tokens.add(Token(TokenType.bitwiseNot, '~', startPos));
        continue;
      }
      if (char == '=') {
        _advance();
        tokens.add(Token(TokenType.equal, '=', startPos));
        continue;
      }
      if (char == ',') {
        _advance();
        tokens.add(Token(TokenType.comma, ',', startPos));
        continue;
      }
      if (char == '(') {
        _advance();
        tokens.add(Token(TokenType.leftParenthesis, '(', startPos));
        continue;
      }
      if (char == ')') {
        _advance();
        tokens.add(Token(TokenType.rightParenthesis, ')', startPos));
        continue;
      }

      // Check numbers (hex, octal, binary, or normal float/integer)
      if (_isDigit(char) || (char == '.' && _isDigit(_peek()))) {
        tokens.add(_readNumber(startPos));
        continue;
      }

      // Check identifiers (variables, constants, functions)
      if (_isAlpha(char) || char == '_') {
        tokens.add(_readIdentifier(startPos));
        continue;
      }

      throw LexerException('Unexpected character "$char"', _position);
    }

    tokens.add(Token(TokenType.eof, '', _position));
    return tokens;
  }

  Token _readNumber(int startPos) {
    // Check for base prefixes: 0x (hex), 0b (bin), 0o (oct)
    if (_current == '0' && _position + 1 < input.length) {
      final prefix = _peek().toLowerCase();
      if (prefix == 'x') {
        _advance(); // advance '0'
        _advance(); // advance 'x'
        final buffer = StringBuffer();
        while (!_isAtEnd && _isHexDigit(_current)) {
          buffer.write(_current);
          _advance();
        }
        if (buffer.isEmpty) {
          throw LexerException('Invalid hexadecimal literal', startPos);
        }
        return Token(TokenType.number, '0x${buffer.toString()}', startPos);
      } else if (prefix == 'b') {
        _advance(); // advance '0'
        _advance(); // advance 'b'
        final buffer = StringBuffer();
        while (!_isAtEnd && (_current == '0' || _current == '1')) {
          buffer.write(_current);
          _advance();
        }
        if (buffer.isEmpty) {
          throw LexerException('Invalid binary literal', startPos);
        }
        return Token(TokenType.number, '0b${buffer.toString()}', startPos);
      } else if (prefix == 'o') {
        _advance(); // advance '0'
        _advance(); // advance 'o'
        final buffer = StringBuffer();
        while (!_isAtEnd && _isOctalDigit(_current)) {
          buffer.write(_current);
          _advance();
        }
        if (buffer.isEmpty) {
          throw LexerException('Invalid octal literal', startPos);
        }
        return Token(TokenType.number, '0o${buffer.toString()}', startPos);
      }
    }

    // Standard floating-point or integer decimal parsing
    final buffer = StringBuffer();
    bool hasDot = false;
    bool hasExponent = false;

    while (!_isAtEnd) {
      final c = _current;
      if (c == '.') {
        if (hasDot || hasExponent) break;
        hasDot = true;
        buffer.write(c);
        _advance();
      } else if (c.toLowerCase() == 'e') {
        if (hasExponent) break;
        hasExponent = true;
        buffer.write(c);
        _advance();
        // Exponent sign
        if (!_isAtEnd && (_current == '+' || _current == '-')) {
          buffer.write(_current);
          _advance();
        }
        // Exponent digits
        if (_isAtEnd || !_isDigit(_current)) {
          throw LexerException('Malformed exponent in number literal', startPos);
        }
        while (!_isAtEnd && _isDigit(_current)) {
          buffer.write(_current);
          _advance();
        }
      } else if (_isDigit(c)) {
        buffer.write(c);
        _advance();
      } else {
        break;
      }
    }

    return Token(TokenType.number, buffer.toString(), startPos);
  }

  Token _readIdentifier(int startPos) {
    final buffer = StringBuffer();
    while (!_isAtEnd && (_isAlphaNumeric(_current) || _current == '_')) {
      buffer.write(_current);
      _advance();
    }
    return Token(TokenType.identifier, buffer.toString(), startPos);
  }

  bool _isWhitespace(String c) => c == ' ' || c == '\t' || c == '\n' || c == '\r';

  bool _isDigit(String c) => c.isNotEmpty && c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  bool _isHexDigit(String c) {
    if (c.isEmpty) return false;
    final code = c.toLowerCase().codeUnitAt(0);
    return (code >= 48 && code <= 57) || (code >= 97 && code <= 102); // 0-9 or a-f
  }

  bool _isOctalDigit(String c) {
    if (c.isEmpty) return false;
    final code = c.codeUnitAt(0);
    return code >= 48 && code <= 55; // 0-7
  }

  bool _isAlpha(String c) {
    if (c.isEmpty) return false;
    final code = c.toLowerCase().codeUnitAt(0);
    return (code >= 97 && code <= 122); // a-z
  }

  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);
}
