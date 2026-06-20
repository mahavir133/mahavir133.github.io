class Fraction {
  final int numerator;
  final int denominator;

  Fraction(this.numerator, this.denominator) {
    if (denominator == 0) throw ArgumentError("Denominator cannot be 0");
  }

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

  Fraction simplify() {
    if (numerator == 0) return Fraction(0, 1);
    int gcd = _gcd(numerator, denominator);
    int n = numerator ~/ gcd;
    int d = denominator ~/ gcd;
    if (d < 0) {
      n = -n;
      d = -d;
    }
    return Fraction(n, d);
  }

  Fraction operator +(Fraction other) {
    int n = numerator * other.denominator + other.numerator * denominator;
    int d = denominator * other.denominator;
    return Fraction(n, d).simplify();
  }

  Fraction operator -(Fraction other) {
    int n = numerator * other.denominator - other.numerator * denominator;
    int d = denominator * other.denominator;
    return Fraction(n, d).simplify();
  }

  Fraction operator *(Fraction other) {
    int n = numerator * other.numerator;
    int d = denominator * other.denominator;
    return Fraction(n, d).simplify();
  }

  Fraction operator /(Fraction other) {
    if (other.numerator == 0) throw ArgumentError("Cannot divide by zero");
    int n = numerator * other.denominator;
    int d = denominator * other.numerator;
    return Fraction(n, d).simplify();
  }

  double toDouble() => numerator / denominator;

  @override
  String toString() {
    if (denominator == 1) return '$numerator';
    if (numerator == 0) return '0';
    // Mixed number logic could be applied here if requested,
    // but improper fractions are generally preferred in math.
    return '$numerator / $denominator';
  }

  String toMixedNumber() {
    if (numerator.abs() < denominator.abs()) return toString();
    int whole = numerator ~/ denominator;
    int remainder = (numerator % denominator).abs();
    if (remainder == 0) return '$whole';
    return '$whole $remainder/${denominator.abs()}';
  }
}
