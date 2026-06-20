import 'dart:math';
import '../../complex_calculator/utils/complex_calculator.dart';

class EquationSolver {
  // Linear: ax + b = 0
  static String solveLinear(double a, double b) {
    if (a == 0) return b == 0 ? "Infinite solutions" : "No solution";
    double x = -b / a;
    return "x = ${x.toStringAsFixed(4)}";
  }

  // Quadratic: ax^2 + bx + c = 0
  static List<String> solveQuadratic(double a, double b, double c) {
    if (a == 0) return [solveLinear(b, c)];

    double d = b * b - 4 * a * c;
    if (d >= 0) {
      double x1 = (-b + sqrt(d)) / (2 * a);
      double x2 = (-b - sqrt(d)) / (2 * a);
      return ["x₁ = ${x1.toStringAsFixed(4)}", "x₂ = ${x2.toStringAsFixed(4)}"];
    } else {
      double real = -b / (2 * a);
      double imag = sqrt(-d) / (2 * a);
      return [
        "x₁ = ${real.toStringAsFixed(4)} + ${imag.toStringAsFixed(4)}i",
        "x₂ = ${real.toStringAsFixed(4)} - ${imag.toStringAsFixed(4)}i",
      ];
    }
  }

  // System of 2: a1x+b1y=c1, a2x+b2y=c2 (Cramer's rule)
  static String solveSystem2(
    double a1,
    double b1,
    double c1,
    double a2,
    double b2,
    double c2,
  ) {
    double det = a1 * b2 - a2 * b1;
    if (det == 0) return "No unique solution";
    double detX = c1 * b2 - c2 * b1;
    double detY = a1 * c2 - a2 * c1;
    return "x = ${(detX / det).toStringAsFixed(4)}, y = ${(detY / det).toStringAsFixed(4)}";
  }
}
