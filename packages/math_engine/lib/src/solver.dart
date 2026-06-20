import 'ast.dart';
import 'evaluator.dart';

class SolverStep {
  final String description;
  final String equation;

  SolverStep(this.description, this.equation);

  @override
  String toString() => '$description => $equation';
}

class SolverException implements Exception {
  final String message;
  SolverException(this.message);
  @override
  String toString() => 'Solver Error: $message';
}

class LinearCoefficient {
  final double a; // coefficient of x
  final double b; // constant term

  LinearCoefficient(this.a, this.b);

  @override
  String toString() => 'LinearCoefficient(${a}x + $b)';
}

class Solver {
  final String variableName;

  Solver({this.variableName = 'x'});

  List<SolverStep> solve(EquationNode equationNode, EvaluationContext context) {
    final steps = <SolverStep>[];

    // 1. Initial equation representation
    final initLeftStr = _toFriendlyString(equationNode.left);
    final initRightStr = _toFriendlyString(equationNode.right);
    steps.add(SolverStep('Original Equation', '$initLeftStr = $initRightStr'));

    // Verify if the variable is present
    final leftHasVar = _containsVariable(equationNode.left);
    final rightHasVar = _containsVariable(equationNode.right);

    if (!leftHasVar && !rightHasVar) {
      // Evaluate both sides
      final evaluator = Evaluator();
      final leftVal = evaluator.evaluate(equationNode.left, context);
      final rightVal = evaluator.evaluate(equationNode.right, context);
      steps.add(SolverStep(
        'Evaluate both sides (no variable found)',
        '${_formatDouble(leftVal)} = ${_formatDouble(rightVal)}',
      ));
      if (leftVal == rightVal) {
        steps.add(SolverStep('Conclusion', 'The equation is always TRUE (identity).'));
      } else {
        steps.add(SolverStep('Conclusion', 'The equation is FALSE (no solution).'));
      }
      return steps;
    }

    // Convert both sides to linear coefficients: ax + b
    LinearCoefficient leftCoeff;
    LinearCoefficient rightCoeff;
    try {
      leftCoeff = _toLinearForm(equationNode.left, context);
      rightCoeff = _toLinearForm(equationNode.right, context);
    } on SolverException catch (e) {
      throw SolverException('Cannot solve step-by-step: ${e.message}');
    }

    // 2. Simplify LHS and RHS
    final leftSimpStr = _linearToString(leftCoeff);
    final rightSimpStr = _linearToString(rightCoeff);
    steps.add(SolverStep('Simplify left and right sides', '$leftSimpStr = $rightSimpStr'));

    // 3. Move variable terms to LHS, constants to RHS
    // ax + b = cx + d => (a - c)x = d - b
    final aDiff = leftCoeff.a - rightCoeff.a;
    final bDiff = rightCoeff.b - leftCoeff.b;

    if (rightCoeff.a != 0 && leftCoeff.b != 0) {
      steps.add(SolverStep(
        'Move variable terms to left and constants to right (subtract ${_formatDouble(rightCoeff.a)}x and ${_formatDouble(leftCoeff.b)} from both sides)',
        '${_formatDouble(leftCoeff.a)}x - ${_formatDouble(rightCoeff.a)}x = ${_formatDouble(rightCoeff.b)} - ${_formatDouble(leftCoeff.b)}',
      ));
    } else if (rightCoeff.a != 0) {
      steps.add(SolverStep(
        'Move variable terms to left (subtract ${_formatDouble(rightCoeff.a)}x from both sides)',
        '${_formatDouble(leftCoeff.a)}x - ${_formatDouble(rightCoeff.a)}x = ${_formatDouble(rightCoeff.b)}',
      ));
    } else if (leftCoeff.b != 0) {
      steps.add(SolverStep(
        'Move constants to right (subtract ${_formatDouble(leftCoeff.b)} from both sides)',
        '${_formatDouble(leftCoeff.a)}x = ${_formatDouble(rightCoeff.b)} - ${_formatDouble(leftCoeff.b)}',
      ));
    }

    // Show grouped equation
    final lhsGrouped = '${_formatDouble(aDiff)}x';
    final rhsGrouped = _formatDouble(bDiff);
    steps.add(SolverStep('Combine like terms', '$lhsGrouped = $rhsGrouped'));

    // 4. Divide to isolate x
    if (aDiff == 0) {
      if (bDiff == 0) {
        steps.add(SolverStep('Conclusion', 'Infinite solutions (Identity: 0 = 0).'));
      } else {
        steps.add(SolverStep('Conclusion', 'No solution (Contradiction: 0 = $rhsGrouped).'));
      }
    } else {
      steps.add(SolverStep(
        'Isolate variable by dividing by coefficient ${_formatDouble(aDiff)}',
        '$variableName = $rhsGrouped / ${_formatDouble(aDiff)}',
      ));
      final result = bDiff / aDiff;
      steps.add(SolverStep(
        'Final Solution',
        '$variableName = ${_formatDouble(result)}',
      ));
    }

    return steps;
  }

  bool _containsVariable(Expression expr) {
    if (expr is VariableNode) {
      return expr.name == variableName;
    } else if (expr is UnaryOpNode) {
      return _containsVariable(expr.expression);
    } else if (expr is PostfixOpNode) {
      return _containsVariable(expr.expression);
    } else if (expr is BinaryOpNode) {
      return _containsVariable(expr.left) || _containsVariable(expr.right);
    } else if (expr is FunctionNode) {
      return expr.arguments.any(_containsVariable);
    } else if (expr is EquationNode) {
      return _containsVariable(expr.left) || _containsVariable(expr.right);
    }
    return false;
  }

  LinearCoefficient _toLinearForm(Expression expr, EvaluationContext context) {
    // If expression does not contain variable, evaluate it to a constant double.
    if (!_containsVariable(expr)) {
      try {
        final val = Evaluator().evaluate(expr, context);
        return LinearCoefficient(0, val);
      } catch (e) {
        throw SolverException('Failed to evaluate constant expression: $e');
      }
    }

    if (expr is VariableNode) {
      if (expr.name == variableName) {
        return LinearCoefficient(1, 0);
      }
      throw SolverException('Unsupported variable "${expr.name}" (only "$variableName" is solvable)');
    }

    if (expr is UnaryOpNode) {
      final inner = _toLinearForm(expr.expression, context);
      if (expr.operator == '+') {
        return inner;
      } else if (expr.operator == '-') {
        return LinearCoefficient(-inner.a, -inner.b);
      }
      throw SolverException('Unsupported unary operator "${expr.operator}" on variable');
    }

    if (expr is BinaryOpNode) {
      final leftForm = _toLinearForm(expr.left, context);
      final rightForm = _toLinearForm(expr.right, context);

      switch (expr.operator) {
        case '+':
          return LinearCoefficient(leftForm.a + rightForm.a, leftForm.b + rightForm.b);
        case '-':
          return LinearCoefficient(leftForm.a - rightForm.a, leftForm.b - rightForm.b);
        case '*':
          // Multiplication: (ax + b) * (cx + d)
          // We only support linear, meaning either left has no x (a=0) or right has no x (c=0)
          if (leftForm.a != 0 && rightForm.a != 0) {
            throw SolverException('Quadratic or non-linear term (multiplication of terms containing variable)');
          }
          if (leftForm.a != 0) {
            // (ax + b) * d = (a*d)x + b*d
            return LinearCoefficient(leftForm.a * rightForm.b, leftForm.b * rightForm.b);
          } else {
            // b * (cx + d) = (b*c)x + b*d
            return LinearCoefficient(rightForm.a * leftForm.b, rightForm.b * leftForm.b);
          }
        case '/':
          // Division: (ax + b) / (cx + d)
          // We only support divisor being a constant (c=0)
          if (rightForm.a != 0) {
            throw SolverException('Variable in divisor (non-linear division)');
          }
          if (rightForm.b == 0) {
            throw SolverException('Division by zero in linear expression');
          }
          return LinearCoefficient(leftForm.a / rightForm.b, leftForm.b / rightForm.b);
        default:
          throw SolverException('Unsupported operator "${expr.operator}" in algebraic expression');
      }
    }

    throw SolverException('Non-linear function or operator contains variable');
  }

  String _linearToString(LinearCoefficient coeff) {
    if (coeff.a == 0) {
      return _formatDouble(coeff.b);
    }
    final aStr = coeff.a == 1 ? '' : (coeff.a == -1 ? '-' : _formatDouble(coeff.a));
    if (coeff.b == 0) {
      return '$aStr$variableName';
    }
    final sign = coeff.b < 0 ? ' - ' : ' + ';
    final bStr = _formatDouble(coeff.b.abs());
    return '$aStr$variableName$sign$bStr';
  }

  String _toFriendlyString(Expression expr) {
    return expr.toDisplayString();
  }

  String _formatDouble(double val) {
    if (val.isInfinite) return val.isNegative ? '-Infinity' : 'Infinity';
    if (val.isNaN) return 'NaN';
    if (val % 1 == 0) {
      return val.toInt().toString();
    }
    // Limit decimals for presentation
    final s = val.toStringAsFixed(6);
    // Remove trailing zeros
    var end = s.length - 1;
    while (end >= 0 && s[end] == '0') {
      end--;
    }
    if (end >= 0 && s[end] == '.') {
      end--;
    }
    return s.substring(0, end + 1);
  }
}
