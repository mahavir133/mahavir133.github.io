import 'dart:math';

class StatisticsResult {
  final double mean;
  final double median;
  final List<double> mode;
  final double variance;
  final double stdDev;
  final double q1;
  final double q3;

  StatisticsResult({
    required this.mean,
    required this.median,
    required this.mode,
    required this.variance,
    required this.stdDev,
    required this.q1,
    required this.q3,
  });
}

class RegressionResult {
  final double correlation;
  final double slope;
  final double intercept;

  RegressionResult({
    required this.correlation,
    required this.slope,
    required this.intercept,
  });
}

class StatisticsCalculator {
  static StatisticsResult calculateSingle(List<double> data) {
    if (data.isEmpty) throw Exception("Data is empty");

    data.sort();
    int n = data.length;

    // Mean
    double sum = data.reduce((a, b) => a + b);
    double mean = sum / n;

    // Median
    double median = _getPercentile(data, 50);

    // Q1, Q3
    double q1 = _getPercentile(data, 25);
    double q3 = _getPercentile(data, 75);

    // Variance & StdDev (Sample)
    double variance = 0;
    if (n > 1) {
      double sqSum = data
          .map((x) => pow(x - mean, 2).toDouble())
          .reduce((a, b) => a + b);
      variance = sqSum / (n - 1);
    }
    double stdDev = sqrt(variance);

    // Mode
    Map<double, int> counts = {};
    for (var val in data) {
      counts[val] = (counts[val] ?? 0) + 1;
    }
    int maxCount = counts.values.reduce(max);
    List<double> mode = counts.entries
        .where((e) => e.value == maxCount)
        .map((e) => e.key)
        .toList();
    if (maxCount == 1) mode = []; // No true mode if all appear once

    return StatisticsResult(
      mean: mean,
      median: median,
      mode: mode,
      variance: variance,
      stdDev: stdDev,
      q1: q1,
      q3: q3,
    );
  }

  static RegressionResult calculateRegression(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty)
      throw Exception("Invalid data for regression");

    int n = x.length;
    double sumX = x.reduce((a, b) => a + b);
    double sumY = y.reduce((a, b) => a + b);

    double sumXY = 0;
    double sumX2 = 0;
    double sumY2 = 0;

    for (int i = 0; i < n; i++) {
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
      sumY2 += y[i] * y[i];
    }

    double num = (n * sumXY) - (sumX * sumY);
    double den1 = (n * sumX2) - (sumX * sumX);
    double den2 = (n * sumY2) - (sumY * sumY);

    double r = 0;
    if (den1 != 0 && den2 != 0) {
      r = num / sqrt(den1 * den2);
    }

    double slope = den1 != 0 ? num / den1 : 0;
    double intercept = (sumY - slope * sumX) / n;

    return RegressionResult(correlation: r, slope: slope, intercept: intercept);
  }

  static double _getPercentile(List<double> sortedData, double percentile) {
    if (sortedData.isEmpty) return 0;
    if (sortedData.length == 1) return sortedData[0];

    double p = percentile / 100.0;
    double index = (sortedData.length - 1) * p;
    int lower = index.floor();
    int upper = index.ceil();
    if (lower == upper) return sortedData[lower];

    double weight = index - lower;
    return sortedData[lower] * (1 - weight) + sortedData[upper] * weight;
  }
}
