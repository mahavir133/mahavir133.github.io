import 'dart:math';

class OneRepMaxResult {
  final double epley;
  final double brzycki;
  final double lombardi;
  final double average;
  final Map<int, double> percentages;

  OneRepMaxResult({
    required this.epley,
    required this.brzycki,
    required this.lombardi,
    required this.average,
    required this.percentages,
  });
}

class OneRepMaxCalculator {
  static OneRepMaxResult calculate(double weight, int reps) {
    if (weight <= 0 || reps <= 0) throw Exception("Weight and reps must be > 0");

    double epley = reps == 1 ? weight : weight * (1 + (reps / 30));
    double brzycki = reps == 1 ? weight : weight * (36 / (37 - reps));
    double lombardi = reps == 1 ? weight : weight * pow(reps, 0.10);

    double average = (epley + brzycki + lombardi) / 3;

    Map<int, double> percentages = {
      100: average,
      95: average * 0.95,
      90: average * 0.90,
      85: average * 0.85,
      80: average * 0.80,
      75: average * 0.75,
      70: average * 0.70,
      65: average * 0.65,
      60: average * 0.60,
      55: average * 0.55,
      50: average * 0.50,
    };

    return OneRepMaxResult(
      epley: epley,
      brzycki: brzycki,
      lombardi: lombardi,
      average: average,
      percentages: percentages,
    );
  }
}
