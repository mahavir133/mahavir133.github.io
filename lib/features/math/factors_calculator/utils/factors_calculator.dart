class FactorsResult {
  final int? gcd;
  final int? lcm;
  final List<int>? primeFactors;

  FactorsResult({this.gcd, this.lcm, this.primeFactors});
}

class FactorsCalculator {
  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static int _lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a.abs() ~/ _gcd(a, b)) * b.abs();
  }

  static FactorsResult calculateMulti(List<int> numbers) {
    if (numbers.isEmpty) return FactorsResult();

    int gcd = numbers[0];
    int lcm = numbers[0];

    for (int i = 1; i < numbers.length; i++) {
      gcd = _gcd(gcd, numbers[i]);
      lcm = _lcm(lcm, numbers[i]);
    }

    return FactorsResult(gcd: gcd, lcm: lcm);
  }

  static FactorsResult primeFactorization(int n) {
    List<int> factors = [];
    int d = 2;
    n = n.abs();

    while (n > 1) {
      while (n % d == 0) {
        factors.add(d);
        n ~/= d;
      }
      d++;
      if (d * d > n && n > 1) {
        factors.add(n);
        break;
      }
    }

    return FactorsResult(primeFactors: factors);
  }
}
