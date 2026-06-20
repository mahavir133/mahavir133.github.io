import 'dart:math';

class BodyFatCalculator {
  static double calculateNavyMethod({
    required String gender,
    required double heightCm,
    required double neckCm,
    required double waistCm,
    double hipCm = 0, // Required for females
  }) {
    if (heightCm <= 0 || neckCm <= 0 || waistCm <= 0) {
      throw Exception("Measurements must be greater than zero.");
    }
    if (gender.toLowerCase() == 'female' && hipCm <= 0) {
      throw Exception("Hip measurement is required for females.");
    }

    double log10(double x) => log(x) / ln10;

    double bf;
    if (gender.toLowerCase() == 'male') {
      double diff = waistCm - neckCm;
      if (diff <= 0) throw Exception("Invalid measurements: Waist must be larger than neck.");
      bf = 495 / (1.0324 - 0.19077 * log10(diff) + 0.15456 * log10(heightCm)) - 450;
    } else {
      double sum = waistCm + hipCm - neckCm;
      if (sum <= 0) throw Exception("Invalid measurements.");
      bf = 495 / (1.29579 - 0.35004 * log10(sum) + 0.22100 * log10(heightCm)) - 450;
    }

    return bf;
  }
}
