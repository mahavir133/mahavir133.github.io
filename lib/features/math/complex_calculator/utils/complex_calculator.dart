import 'dart:math';

class ComplexResult {
  final String rectangular;
  final String polar;

  ComplexResult({required this.rectangular, required this.polar});
}

class ComplexNumber {
  final double real;
  final double imaginary;

  ComplexNumber(this.real, this.imaginary);

  double get magnitude => sqrt(real * real + imaginary * imaginary);
  double get phase => atan2(imaginary, real); // radians

  ComplexNumber operator +(ComplexNumber other) {
    return ComplexNumber(real + other.real, imaginary + other.imaginary);
  }

  ComplexNumber operator -(ComplexNumber other) {
    return ComplexNumber(real - other.real, imaginary - other.imaginary);
  }

  ComplexNumber operator *(ComplexNumber other) {
    return ComplexNumber(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }

  ComplexNumber operator /(ComplexNumber other) {
    double denom = other.real * other.real + other.imaginary * other.imaginary;
    if (denom == 0) throw ArgumentError("Division by zero");
    return ComplexNumber(
      (real * other.real + imaginary * other.imaginary) / denom,
      (imaginary * other.real - real * other.imaginary) / denom,
    );
  }

  ComplexNumber power(double n) {
    double r = pow(magnitude, n).toDouble();
    double theta = phase * n;
    return ComplexNumber(r * cos(theta), r * sin(theta));
  }

  String toRectangularString() {
    final rStr = real.toStringAsFixed(4).replaceAll(RegExp(r'\.0000$'), '');
    final iStr = imaginary
        .abs()
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'\.0000$'), '');
    final sign = imaginary >= 0 ? '+' : '-';
    return '$rStr $sign ${iStr}i';
  }

  String toPolarString() {
    final rStr = magnitude
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'\.0000$'), '');
    final thStr = (phase * 180 / pi)
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'\.00$'), '');
    return '$rStr ∠ $thStr°';
  }

  ComplexResult toResult() {
    return ComplexResult(
      rectangular: toRectangularString(),
      polar: toPolarString(),
    );
  }
}
