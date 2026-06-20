import 'src/lexer.dart';
import 'src/ast.dart';
import 'src/parser.dart';
import 'src/evaluator.dart';
import 'src/solver.dart';

export 'src/token.dart' show TokenType, Token;
export 'src/ast.dart' show Expression, NumberBase, NumberNode, VariableNode, ConstantNode, BinaryOpNode, UnaryOpNode, PostfixOpNode, FunctionNode, EquationNode;
export 'src/lexer.dart' show LexerException;
export 'src/parser.dart' show ParserException;
export 'src/evaluator.dart' show EvaluationException, EvaluationContext;
export 'src/solver.dart' show SolverStep, SolverException;

class MathEngine {
  /// Evaluates a mathematical expression and returns the double result.
  double evaluate(
    String expression, {
    bool isDegreeMode = false,
    bool isProgrammerMode = false,
    Map<String, double> variables = const {},
  }) {
    // Basic regex normalization (e.g. replace smart-quotes or standard multiply/divide signs)
    final normalized = _normalize(expression);
    final lexer = Lexer(normalized);
    final tokens = lexer.tokenize();
    final parser = Parser(tokens);
    final ast = parser.parse();
    
    final evaluator = Evaluator();
    return evaluator.evaluate(ast, EvaluationContext(
      isDegreeMode: isDegreeMode,
      isProgrammerMode: isProgrammerMode,
      variables: variables,
    ));
  }

  /// Solves a simple linear algebraic equation and returns step-by-step solutions.
  List<SolverStep> solve(
    String equation, {
    String variable = 'x',
    bool isDegreeMode = false,
  }) {
    final normalized = _normalize(equation);
    final lexer = Lexer(normalized);
    final tokens = lexer.tokenize();
    final parser = Parser(tokens);
    final ast = parser.parse();

    if (ast is! EquationNode) {
      throw SolverException('Expression is not an equation (missing "=")');
    }

    final solver = Solver(variableName: variable);
    return solver.solve(ast, EvaluationContext(isDegreeMode: isDegreeMode));
  }

  /// Converts an integer string between HEX, DEC, OCT, and BIN bases.
  String convertBase(String valueStr, NumberBase fromBase, NumberBase toBase) {
    if (valueStr.isEmpty) return '';

    // Strip common prefixes if they exist
    var cleanStr = valueStr.trim();
    if (cleanStr.startsWith('0x') || cleanStr.startsWith('0X')) {
      cleanStr = cleanStr.substring(2);
      fromBase = NumberBase.hex;
    } else if (cleanStr.startsWith('0b') || cleanStr.startsWith('0B')) {
      cleanStr = cleanStr.substring(2);
      fromBase = NumberBase.bin;
    } else if (cleanStr.startsWith('0o') || cleanStr.startsWith('0O')) {
      cleanStr = cleanStr.substring(2);
      fromBase = NumberBase.oct;
    }

    int radix;
    switch (fromBase) {
      case NumberBase.hex:
        radix = 16;
        break;
      case NumberBase.oct:
        radix = 8;
        break;
      case NumberBase.bin:
        radix = 2;
        break;
      case NumberBase.dec:
        radix = 10;
        break;
    }

    // Parse value. If it contains a decimal part, we convert only the integer part
    final dotIdx = cleanStr.indexOf('.');
    final intPart = dotIdx != -1 ? cleanStr.substring(0, dotIdx) : cleanStr;

    int value;
    try {
      value = int.parse(intPart, radix: radix);
    } catch (_) {
      throw FormatException('Invalid number "$valueStr" for base $fromBase');
    }

    switch (toBase) {
      case NumberBase.hex:
        return '0x${value.toRadixString(16).toUpperCase()}';
      case NumberBase.oct:
        return '0o${value.toRadixString(8)}';
      case NumberBase.bin:
        return '0b${value.toRadixString(2)}';
      case NumberBase.dec:
        return value.toString();
    }
  }

  String _normalize(String input) {
    return input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', 'pi')
        .replaceAll('e', 'e')
        .replaceAll('NA', 'avogadro')
        .replaceAll('N_A', 'avogadro');
  }
}
