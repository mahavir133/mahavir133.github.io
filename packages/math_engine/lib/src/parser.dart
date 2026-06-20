import 'token.dart';
import 'ast.dart';

class ParserException implements Exception {
  final String message;
  final int position;
  ParserException(this.message, this.position);
  @override
  String toString() => 'Parser Error at position $position: $message';
}

enum Precedence {
  lowest,
  equals,       // =
  bitwiseOr,    // |
  bitwiseXor,   // ^
  bitwiseAnd,   // &
  shift,        // <<, >>
  sum,          // +, -
  product,      // *, /, %
  power,        // ^
  unary,        // -x, +x, ~x
  postfix,      // x!
  call          // function(args)
}

extension PrecedenceValue on Precedence {
  int get value => index;
}

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  Token get _currentToken => _peek(0);

  bool get _isAtEnd => _currentToken.type == TokenType.eof;

  Token _peek(int offset) {
    final idx = _current + offset;
    if (idx >= tokens.length) {
      return tokens.last;
    }
    return tokens[idx];
  }

  Token _consume(TokenType type, String errMsg) {
    if (_currentToken.type == type) {
      final t = _currentToken;
      _current++;
      return t;
    }
    throw ParserException(errMsg, _currentToken.position);
  }

  void _advance() {
    if (!_isAtEnd) {
      _current++;
    }
  }

  Precedence _getPrecedence(TokenType type) {
    switch (type) {
      case TokenType.equal:
        return Precedence.equals;
      case TokenType.bitwiseOr:
        return Precedence.bitwiseOr;
      case TokenType.bitwiseXor:
        return Precedence.bitwiseXor;
      case TokenType.bitwiseAnd:
        return Precedence.bitwiseAnd;
      case TokenType.leftShift:
      case TokenType.rightShift:
        return Precedence.shift;
      case TokenType.plus:
      case TokenType.minus:
        return Precedence.sum;
      case TokenType.multiply:
      case TokenType.divide:
      case TokenType.modulo:
        return Precedence.product;
      case TokenType.power:
        return Precedence.power;
      case TokenType.leftParenthesis:
        return Precedence.call;
      default:
        return Precedence.lowest;
    }
  }

  Precedence get _currentPrecedence => _getPrecedence(_currentToken.type);

  Expression parse() {
    final expr = _parseExpression(Precedence.lowest);
    if (!_isAtEnd) {
      if (_currentToken.type == TokenType.equal) {
        _advance();
        final right = _parseExpression(Precedence.lowest);
        if (!_isAtEnd) {
          throw ParserException('Unexpected token after equation', _currentToken.position);
        }
        return EquationNode(expr, right);
      }
      throw ParserException('Unexpected token "${_currentToken.value}" at end of expression', _currentToken.position);
    }
    return expr;
  }

  Expression _parseExpression(Precedence precedence) {
    // Parse prefix (numbers, variables, unary operators, parentheses)
    var left = _parsePrefix();

    while (true) {
      // Check for implicit multiplication.
      // If the next token can start a primary expression (number, identifier, left parenthesis)
      // and we are currently parsing at a precedence lower than product (*).
      if (_canStartPrimaryExpression(_currentToken) && precedence.value < Precedence.product.value) {
        // Treat as implicit multiplication
        left = BinaryOpNode(left, '*', _parseExpression(Precedence.product));
        continue;
      }

      // Check postfix operations like factorial
      if (_currentToken.type == TokenType.factorial) {
        if (precedence.value >= Precedence.postfix.value) {
          break;
        }
        final token = _currentToken;
        _advance();
        left = PostfixOpNode(token.value, left);
        continue;
      }

      if (_isAtEnd || _currentToken.type == TokenType.equal) {
        break;
      }

      final nextPrecedence = _currentPrecedence;
      if (precedence.value >= nextPrecedence.value) {
        break;
      }

      final token = _currentToken;
      _advance();

      left = _parseInfix(left, token);
    }

    return left;
  }

  bool _canStartPrimaryExpression(Token token) {
    return token.type == TokenType.number ||
        token.type == TokenType.identifier ||
        token.type == TokenType.leftParenthesis;
  }

  Expression _parsePrefix() {
    final token = _currentToken;
    switch (token.type) {
      case TokenType.number:
        _advance();
        return _parseNumber(token);

      case TokenType.identifier:
        _advance();
        // If it is followed by an open parenthesis, it is a function call
        if (_currentToken.type == TokenType.leftParenthesis) {
          _advance(); // consume '('
          final args = <Expression>[];
          if (_currentToken.type != TokenType.rightParenthesis) {
            args.add(_parseExpression(Precedence.lowest));
            while (_currentToken.type == TokenType.comma) {
              _advance(); // consume ','
              args.add(_parseExpression(Precedence.lowest));
            }
          }
          _consume(TokenType.rightParenthesis, "Expected ')' after function arguments");
          return FunctionNode(token.value, args);
        }

        // Check if constant
        final lower = token.value.toLowerCase();
        if (lower == 'pi' || lower == 'e' || lower == 'avogadro' || lower == 'c' || lower == 'h') {
          return ConstantNode(token.value);
        }
        // Else it is a variable (e.g. x)
        return VariableNode(token.value);

      case TokenType.plus:
      case TokenType.minus:
      case TokenType.bitwiseNot:
        _advance();
        final operand = _parseExpression(Precedence.unary);
        return UnaryOpNode(token.value, operand);

      case TokenType.leftParenthesis:
        _advance();
        final expr = _parseExpression(Precedence.lowest);
        _consume(TokenType.rightParenthesis, "Expected ')' to close parenthesis");
        return expr;

      default:
        throw ParserException('Expected expression, found "${token.value}"', token.position);
    }
  }

  Expression _parseInfix(Expression left, Token operatorToken) {
    final precedence = _getPrecedence(operatorToken.type);
    
    // Associativity: power is right-associative (e.g. 2^3^2 = 2^(3^2)), others are left-associative
    final rightPrecedence = operatorToken.type == TokenType.power
        ? Precedence.values[precedence.index - 1]
        : precedence;

    final right = _parseExpression(rightPrecedence);
    return BinaryOpNode(left, operatorToken.value, right);
  }

  Expression _parseNumber(Token token) {
    final raw = token.value;
    double val;
    NumberBase base = NumberBase.dec;

    try {
      if (raw.startsWith('0x') || raw.startsWith('0X')) {
        val = int.parse(raw.substring(2), radix: 16).toDouble();
        base = NumberBase.hex;
      } else if (raw.startsWith('0b') || raw.startsWith('0B')) {
        val = int.parse(raw.substring(2), radix: 2).toDouble();
        base = NumberBase.bin;
      } else if (raw.startsWith('0o') || raw.startsWith('0O')) {
        val = int.parse(raw.substring(2), radix: 8).toDouble();
        base = NumberBase.oct;
      } else {
        val = double.parse(raw);
        base = NumberBase.dec;
      }
    } catch (_) {
      throw ParserException('Invalid number literal "$raw"', token.position);
    }

    return NumberNode(val, raw, base);
  }
}
