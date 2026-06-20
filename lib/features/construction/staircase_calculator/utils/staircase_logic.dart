import 'dart:math';

class StaircaseResult {
  final int numberOfSteps;
  final double riserHeight;
  final double treadRun;
  final double totalRun;
  final double stringerLength;

  StaircaseResult({
    required this.numberOfSteps,
    required this.riserHeight,
    required this.treadRun,
    required this.totalRun,
    required this.stringerLength,
  });
}

class StaircaseLogic {
  static StaircaseResult calculate({
    required double totalRise,
    required double targetTread, // user optional input
    required bool isMetric,
  }) {
    // Ideal riser height is around 7 inches (0.1778 meters)
    double idealRiser = isMetric ? 0.1778 : 7.0;

    if (totalRise <= 0) {
      return StaircaseResult(
        numberOfSteps: 0,
        riserHeight: 0,
        treadRun: 0,
        totalRun: 0,
        stringerLength: 0,
      );
    }

    // Number of steps (risers)
    int steps = (totalRise / idealRiser).round();
    if (steps < 1) steps = 1;

    // Actual riser height
    double actualRiser = totalRise / steps;

    // Calculate ideal tread run if not provided
    // Rule: 2 * Riser + Tread ≈ 25 inches (or 0.635 meters)
    double tread;
    if (targetTread > 0) {
      tread = targetTread;
    } else {
      tread = isMetric ? (0.635 - 2 * actualRiser) : (25.0 - 2 * actualRiser);
      if (isMetric && tread < 0.25) tread = 0.25; // min 250mm
      if (!isMetric && tread < 10.0) tread = 10.0; // min 10 inches
    }

    // Total run
    // Often there is one less tread than risers (the top floor is the top tread)
    double totalRun = tread * (steps - 1);
    if (totalRun < 0) totalRun = 0;

    // Stringer Length = sqrt(Total Rise^2 + Total Run^2)
    double stringer = sqrt(pow(totalRise, 2) + pow(totalRun, 2));

    return StaircaseResult(
      numberOfSteps: steps,
      riserHeight: actualRiser,
      treadRun: tread,
      totalRun: totalRun,
      stringerLength: stringer,
    );
  }
}
