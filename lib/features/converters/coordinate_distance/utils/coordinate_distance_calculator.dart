import 'package:latlong2/latlong.dart';

class DistanceResult {
  final double distanceKm;
  final double distanceMiles;
  final double distanceNM;
  final double initialBearing;

  DistanceResult({
    required this.distanceKm,
    required this.distanceMiles,
    required this.distanceNM,
    required this.initialBearing,
  });
}

class CoordinateDistanceCalculator {
  static DistanceResult calculate(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const Distance distance = Distance();
    final p1 = LatLng(lat1, lon1);
    final p2 = LatLng(lat2, lon2);

    final meters = distance.distance(p1, p2);
    final bearing = distance.bearing(p1, p2);

    return DistanceResult(
      distanceKm: meters / 1000.0,
      distanceMiles: meters * 0.000621371,
      distanceNM: meters * 0.000539957,
      initialBearing: bearing,
    );
  }
}
