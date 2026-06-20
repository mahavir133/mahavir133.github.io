class PaceResult {
  final double distanceKm;
  final double distanceMi;
  final Duration time;
  final Duration pacePerKm;
  final Duration pacePerMi;
  final double speedKmh;
  final double speedMph;

  PaceResult({
    required this.distanceKm,
    required this.distanceMi,
    required this.time,
    required this.pacePerKm,
    required this.pacePerMi,
    required this.speedKmh,
    required this.speedMph,
  });
}

class PaceCalculator {
  static PaceResult calculate({
    double? distanceKm,
    Duration? time,
    Duration? pacePerKm, // Optional, can be calculated
  }) {
    // Need at least 2
    if (distanceKm == null && time == null) throw Exception("Need at least 2 values");
    if (distanceKm == null && pacePerKm == null) throw Exception("Need at least 2 values");
    if (time == null && pacePerKm == null) throw Exception("Need at least 2 values");

    if (distanceKm == null) {
      // D = T / P
      distanceKm = time!.inSeconds / pacePerKm!.inSeconds;
    } else if (time == null) {
      // T = D * P
      time = Duration(seconds: (distanceKm * pacePerKm!.inSeconds).round());
    } else if (pacePerKm == null) {
      // P = T / D
      if (distanceKm == 0) throw Exception("Distance cannot be zero");
      pacePerKm = Duration(seconds: (time.inSeconds / distanceKm).round());
    }

    double distanceMi = distanceKm * 0.621371;
    Duration pacePerMi = Duration(seconds: (pacePerKm.inSeconds / 0.621371).round());
    double speedKmh = distanceKm / (time.inSeconds / 3600.0);
    double speedMph = distanceMi / (time.inSeconds / 3600.0);

    return PaceResult(
      distanceKm: distanceKm,
      distanceMi: distanceMi,
      time: time,
      pacePerKm: pacePerKm,
      pacePerMi: pacePerMi,
      speedKmh: speedKmh,
      speedMph: speedMph,
    );
  }
}
