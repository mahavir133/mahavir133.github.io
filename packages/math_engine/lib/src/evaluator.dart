import 'dart:math' as math;
import 'ast.dart';

class EvaluationException implements Exception {
  final String message;
  EvaluationException(this.message);
  @override
  String toString() => 'Evaluation Error: $message';
}

class EvaluationContext {
  final bool isDegreeMode;
  final bool isProgrammerMode;
  final Map<String, double> variables;

  EvaluationContext({
    this.isDegreeMode = false,
    this.isProgrammerMode = false,
    this.variables = const {},
  });
}

class Evaluator implements ExpressionVisitor<double, EvaluationContext> {
  double evaluate(Expression expression, EvaluationContext context) {
    return expression.accept(this, context);
  }

  @override
  double visitNumber(NumberNode node, EvaluationContext context) {
    return node.value;
  }

  @override
  double visitVariable(VariableNode node, EvaluationContext context) {
    final value = context.variables[node.name];
    if (value == null) {
      throw EvaluationException('Variable "${node.name}" is undefined');
    }
    return value;
  }

  @override
  double visitConstant(ConstantNode node, EvaluationContext context) {
    switch (node.name.toLowerCase()) {
      case 'pi':
        return math.pi;
      case 'e':
        return math.e;
      case 'avogadro':
        return 6.02214076e23;
      case 'c':
        return 299792458.0; // speed of light in m/s
      case 'h':
        return 6.62607015e-34; // Planck's constant in J*s
      default:
        throw EvaluationException('Unknown constant "${node.name}"');
    }
  }

  @override
  double visitUnaryOp(UnaryOpNode node, EvaluationContext context) {
    final val = evaluate(node.expression, context);
    switch (node.operator) {
      case '+':
        return val;
      case '-':
        return -val;
      case '~':
        return (~val.toInt()).toDouble();
      default:
        throw EvaluationException('Unknown unary operator "${node.operator}"');
    }
  }

  @override
  double visitPostfixOp(PostfixOpNode node, EvaluationContext context) {
    final val = evaluate(node.expression, context);
    switch (node.operator) {
      case '!':
        if (val < 0 || val % 1 != 0) {
          throw EvaluationException('Factorial requires a non-negative integer');
        }
        return _factorial(val.toInt()).toDouble();
      default:
        throw EvaluationException('Unknown postfix operator "${node.operator}"');
    }
  }

  @override
  double visitBinaryOp(BinaryOpNode node, EvaluationContext context) {
    final leftVal = evaluate(node.left, context);
    final rightVal = evaluate(node.right, context);

    switch (node.operator) {
      case '+':
        return leftVal + rightVal;
      case '-':
        return leftVal - rightVal;
      case '*':
        return leftVal * rightVal;
      case '/':
        if (rightVal == 0) {
          throw EvaluationException('Division by zero');
        }
        return leftVal / rightVal;
      case '%':
        if (rightVal == 0) {
          throw EvaluationException('Modulo by zero');
        }
        return leftVal % rightVal;
      case '^':
        if (context.isProgrammerMode) {
          return (leftVal.toInt() ^ rightVal.toInt()).toDouble();
        }
        return math.pow(leftVal, rightVal).toDouble();
      case '&':
        return (leftVal.toInt() & rightVal.toInt()).toDouble();
      case '|':
        return (leftVal.toInt() | rightVal.toInt()).toDouble();
      case '<<':
        return (leftVal.toInt() << rightVal.toInt()).toDouble();
      case '>>':
        return (leftVal.toInt() >> rightVal.toInt()).toDouble();
      default:
        throw EvaluationException('Unknown binary operator "${node.operator}"');
    }
  }

  @override
  double visitFunction(FunctionNode node, EvaluationContext context) {
    final args = node.arguments.map((arg) => evaluate(arg, context)).toList();

    switch (node.name.toLowerCase()) {
      case 'sin':
        _checkArgsCount(node.name, args, 1);
        final rad = context.isDegreeMode ? _degToRad(args[0]) : args[0];
        return math.sin(rad);

      case 'cos':
        _checkArgsCount(node.name, args, 1);
        final rad = context.isDegreeMode ? _degToRad(args[0]) : args[0];
        return math.cos(rad);

      case 'tan':
        _checkArgsCount(node.name, args, 1);
        final rad = context.isDegreeMode ? _degToRad(args[0]) : args[0];
        // Handle undefined tan(90 deg)
        if (context.isDegreeMode && (args[0] % 180 == 90 || args[0] % 180 == -90)) {
          throw EvaluationException('Tangent is undefined for this angle');
        }
        return math.tan(rad);

      case 'asin':
        _checkArgsCount(node.name, args, 1);
        if (args[0] < -1 || args[0] > 1) {
          throw EvaluationException('asin domain is [-1, 1]');
        }
        final res = math.asin(args[0]);
        return context.isDegreeMode ? _radToDeg(res) : res;

      case 'acos':
        _checkArgsCount(node.name, args, 1);
        if (args[0] < -1 || args[0] > 1) {
          throw EvaluationException('acos domain is [-1, 1]');
        }
        final res = math.acos(args[0]);
        return context.isDegreeMode ? _radToDeg(res) : res;

      case 'atan':
        _checkArgsCount(node.name, args, 1);
        final res = math.atan(args[0]);
        return context.isDegreeMode ? _radToDeg(res) : res;

      case 'ln':
        _checkArgsCount(node.name, args, 1);
        if (args[0] <= 0) {
          throw EvaluationException('ln requires a positive value');
        }
        return math.log(args[0]);

      case 'log':
        _checkArgsCount(node.name, args, 1);
        if (args[0] <= 0) {
          throw EvaluationException('log requires a positive value');
        }
        return math.log(args[0]) / math.ln10;

      case 'logbase':
        _checkArgsCount(node.name, args, 2);
        final base = args[0];
        final val = args[1];
        if (base <= 0 || base == 1 || val <= 0) {
          throw EvaluationException('Invalid logBase parameters');
        }
        return math.log(val) / math.log(base);

      case 'sqrt':
        _checkArgsCount(node.name, args, 1);
        if (args[0] < 0) {
          throw EvaluationException('Square root of negative number');
        }
        return math.sqrt(args[0]);

      case 'cbrt':
        _checkArgsCount(node.name, args, 1);
        final val = args[0];
        return val < 0 ? -math.pow(-val, 1 / 3.0).toDouble() : math.pow(val, 1 / 3.0).toDouble();

      case 'npr':
        _checkArgsCount(node.name, args, 2);
        final n = args[0];
        final r = args[1];
        if (n < 0 || r < 0 || n % 1 != 0 || r % 1 != 0 || n < r) {
          throw EvaluationException('nPr requires non-negative integers where n >= r');
        }
        return _permutation(n.toInt(), r.toInt()).toDouble();

      case 'ncr':
        _checkArgsCount(node.name, args, 2);
        final n = args[0];
        final r = args[1];
        if (n < 0 || r < 0 || n % 1 != 0 || r % 1 != 0 || n < r) {
          throw EvaluationException('nCr requires non-negative integers where n >= r');
        }
        return _combination(n.toInt(), r.toInt()).toDouble();

      case 'abs':
        _checkArgsCount(node.name, args, 1);
        return args[0].abs();

      default:
        throw EvaluationException('Unknown function "${node.name}"');
    }
  }

  @override
  double visitEquation(EquationNode node, EvaluationContext context) {
    throw EvaluationException('Equations cannot be evaluated directly. Use Solver instead.');
  }

  void _checkArgsCount(String func, List<double> args, int expected) {
    if (args.length != expected) {
      throw EvaluationException('Function "$func" expects $expected argument(s), got ${args.length}');
    }
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / math.pi);

  int _factorial(int n) {
    if (n > 20) {
      throw EvaluationException('Factorial input is too large (max 20 to prevent overflow)');
    }
    int res = 1;
    for (int i = 2; i <= n; i++) {
      res *= i;
    }
    return res;
  }

  int _permutation(int n, int r) {
    if (n > 20) {
      throw EvaluationException('nPr inputs are too large');
    }
    int res = 1;
    for (int i = n - r + 1; i <= n; i++) {
      res *= i;
    }
    return res;
  }

  int _combination(int n, int r) {
    if (n > 30) {
      // Use double division to avoid immediate overflow, though we cast to int
      // A more robust combinations logic for larger values
      double res = 1;
      final k = math.min(r, n - r);
      for (int i = 1; i <= k; i++) {
        res = res * (n - k + i) / i;
      }
      return res.round();
    }
    final k = math.min(r, n - r);
    int num = 1;
    int den = 1;
    for (int i = 1; i <= k; i++) {
      num *= (n - k + i);
      den *= i;
    }
    return num ~/ den;
  }
}
