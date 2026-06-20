import 'package:math_expressions/math_expressions.dart';

class CalculusResult {
  final double? value;
  final String? error;

  CalculusResult({this.value, this.error});
}

class CalculusToolkit {
  static Parser parser = Parser();

  static double evaluate(String expression, double xValue) {
    try {
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      cm.bindVariable(Variable('x'), Number(xValue));
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      throw Exception('Invalid expression: $expression');
    }
  }

  // Numerical Differentiation (Central Difference)
  // f'(x) = (f(x + h) - f(x - h)) / 2h
  static CalculusResult differentiate(
    String expression,
    double atX, {
    double h = 0.0001,
  }) {
    try {
      double fPlus = evaluate(expression, atX + h);
      double fMinus = evaluate(expression, atX - h);
      return CalculusResult(value: (fPlus - fMinus) / (2 * h));
    } catch (e) {
      return CalculusResult(error: e.toString());
    }
  }

  // Numerical Integration (Simpson's 1/3 Rule)
  // integral(a to b) f(x) dx
  static CalculusResult integrate(
    String expression,
    double a,
    double b, {
    int n = 1000,
  }) {
    if (n % 2 != 0) n++; // Simpson's rule requires even n
    try {
      double h = (b - a) / n;
      double sum = evaluate(expression, a) + evaluate(expression, b);

      for (int i = 1; i < n; i++) {
        double x = a + i * h;
        if (i % 2 == 0) {
          sum += 2 * evaluate(expression, x);
        } else {
          sum += 4 * evaluate(expression, x);
        }
      }
      return CalculusResult(value: (h / 3) * sum);
    } catch (e) {
      return CalculusResult(error: e.toString());
    }
  }

  // Limit approximation: lim x->a f(x)
  static CalculusResult limit(String expression, double approach) {
    try {
      // Evaluate very close to the approach point from both sides
      double h = 0.00001;
      double left = evaluate(expression, approach - h);
      double right = evaluate(expression, approach + h);

      // If they are somewhat close, we assume limit exists
      if ((left - right).abs() < 0.1) {
        return CalculusResult(value: (left + right) / 2);
      } else {
        return CalculusResult(error: "Limit does not exist or diverges.");
      }
    } catch (e) {
      return CalculusResult(error: e.toString());
    }
  }
}
