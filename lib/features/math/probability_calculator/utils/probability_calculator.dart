import 'dart:math';

class ProbabilityCalculator {
  static double _factorial(int n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1.0;
    double res = 1;
    for (int i = 2; i <= n; i++) res *= i;
    return res;
  }

  static double permutations(int n, int r) {
    if (n < 0 || r < 0 || r > n) return 0;
    return _factorial(n) / _factorial(n - r);
  }

  static double combinations(int n, int r) {
    if (n < 0 || r < 0 || r > n) return 0;
    return _factorial(n) / (_factorial(r) * _factorial(n - r));
  }

  // Binomial: P(X = k) = C(n, k) * p^k * (1-p)^(n-k)
  static double binomial(int n, int k, double p) {
    if (n < 0 || k < 0 || k > n || p < 0 || p > 1) return 0;
    return combinations(n, k) * pow(p, k) * pow(1 - p, n - k);
  }

  // Poisson: P(X = k) = (lambda^k * e^-lambda) / k!
  static double poisson(double lambda, int k) {
    if (lambda < 0 || k < 0) return 0;
    return (pow(lambda, k) * exp(-lambda)) / _factorial(k);
  }
}
